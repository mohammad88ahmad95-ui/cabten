import { test } from 'node:test';
import assert from 'node:assert/strict';
import { fromMajor, money, format, mulBps, add, sub } from '../src/money.ts';
import { depositFor, commissionFor, refundFor, resolveDepositRule } from '../src/pricing.ts';
import { transition, allowedEvents, InvalidTransition, STATES, TERMINAL } from '../src/booking-state.ts';
import { overlaps, isAvailable } from '../src/availability.ts';

test('money: parse, format, arithmetic without floats', () => {
  const a = fromMajor('1000000');
  assert.equal(a.minor, 100000000n);
  assert.equal(format(a), '1,000,000 SYP');
  assert.equal(format(add(a, fromMajor('0.5'))), '1,000,000.50 SYP');
  assert.throws(() => fromMajor('1.234'));
  assert.throws(() => add(a, money(1n, 'USD')), /mismatch/);
  assert.throws(() => money(1.5));
  // 0.1 + 0.2 style trap
  assert.equal(add(fromMajor('0.10'), fromMajor('0.20')).minor, fromMajor('0.30').minor);
  assert.equal(sub(a, a).minor, 0n);
});

test('pricing: 1,000,000 with 30% deposit -> 300,000 / 700,000', () => {
  const r = depositFor(fromMajor('1000000'), { type: 'percent', bps: 3000 });
  assert.equal(format(r.deposit), '300,000 SYP');
  assert.equal(format(r.remaining), '700,000 SYP');
});

test('pricing: fixed deposit is capped at total', () => {
  const r = depositFor(fromMajor('100'), { type: 'fixed', amount: fromMajor('500') });
  assert.equal(r.deposit.minor, r.total.minor);
  assert.equal(r.remaining.minor, 0n);
});

test('pricing: deposit rule precedence package > provider > platform', () => {
  const platform = { type: 'percent', bps: 2000 } as const;
  const provider = { type: 'percent', bps: 2500 } as const;
  const pkg = { type: 'percent', bps: 3000 } as const;
  assert.deepEqual(resolveDepositRule(pkg, provider, platform), pkg);
  assert.deepEqual(resolveDepositRule(null, provider, platform), provider);
  assert.deepEqual(resolveDepositRule(undefined, null, platform), platform);
});

test('pricing: 5% commission -> provider nets 950,000', () => {
  const { commission, providerNet } = commissionFor(fromMajor('1000000'), 500);
  assert.equal(format(commission), '50,000 SYP');
  assert.equal(format(providerNet), '950,000 SYP');
  assert.equal(add(commission, providerNet).minor, fromMajor('1000000').minor);
});

test('rounding is half-up on minor units', () => {
  assert.equal(mulBps(money(1n), 5000).minor, 1n); // 0.5 -> 1
  assert.equal(mulBps(money(1n), 4999).minor, 0n);
  assert.equal(mulBps(money(1n), 5000, 'down').minor, 0n);
});

test('cancellation tiers: >7d full, 3-7d 50%, <3d none (configurable data)', () => {
  const tiers = [{ minDaysBefore: 7, refundBps: 10000 }, { minDaysBefore: 3, refundBps: 5000 }];
  const paid = fromMajor('300000');
  assert.equal(format(refundFor(tiers, 10, paid)), '300,000 SYP');
  assert.equal(format(refundFor(tiers, 5, paid)), '150,000 SYP');
  assert.equal(refundFor(tiers, 1, paid).minor, 0n);
});

test('state machine: happy path', () => {
  let s = transition('draft', 'SUBMIT', 'customer');
  s = transition(s, 'PROVIDER_ACCEPT', 'provider');
  s = transition(s, 'PAYMENT_SUBMITTED', 'customer');
  s = transition(s, 'PAYMENT_UNDER_REVIEW', 'provider');
  s = transition(s, 'PAYMENT_VERIFIED', 'provider');
  assert.equal(s, 'confirmed');
  assert.equal(transition(s, 'MARK_COMPLETED', 'provider'), 'completed');
});

test('state machine: customer cannot self-verify payment or accept booking', () => {
  assert.throws(() => transition('payment_verification', 'PAYMENT_VERIFIED', 'customer'), InvalidTransition);
  assert.throws(() => transition('pending', 'PROVIDER_ACCEPT', 'customer'), InvalidTransition);
  assert.throws(() => transition('awaiting_payment', 'PAYMENT_VERIFIED', 'customer'), InvalidTransition);
});

test('state machine: terminal states have no exits; payment rejection loops back', () => {
  for (const t of TERMINAL) for (const a of ['customer', 'provider', 'admin', 'system'] as const)
    assert.deepEqual(allowedEvents(t, a), []);
  assert.equal(transition('payment_verification', 'PAYMENT_REJECTED', 'admin'), 'awaiting_payment');
  assert.equal(STATES.length, 10);
});

test('availability: overlap semantics', () => {
  const day = (d: number) => ({ start: d * 86400000, end: (d + 1) * 86400000 });
  assert.equal(overlaps(day(1), day(2)), false); // adjacent
  assert.equal(overlaps(day(1), { start: day(1).start + 1, end: day(2).end }), true);
  const entries = [{ ...day(5), providerId: 'p1', kind: 'manual_booking' as const }];
  assert.equal(isAvailable(entries, 'p1', day(5)), false);
  assert.equal(isAvailable(entries, 'p2', day(5)), true); // other provider unaffected
  assert.equal(isAvailable(entries, 'p1', day(6)), true);
});
