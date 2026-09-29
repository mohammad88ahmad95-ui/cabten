import type { Money } from './money.ts';
import { sub, min, mulBps, money } from './money.ts';

export type DepositRule =
  | { type: 'percent'; bps: number }
  | { type: 'fixed'; amount: Money };

/** Precedence: package > provider > platform default. Never hard-coded. */
export function resolveDepositRule(
  pkg: DepositRule | null | undefined,
  provider: DepositRule | null | undefined,
  platform: DepositRule,
): DepositRule {
  return pkg ?? provider ?? platform;
}

export function depositFor(total: Money, rule: DepositRule): { total: Money; deposit: Money; remaining: Money } {
  const raw = rule.type === 'percent' ? mulBps(total, rule.bps) : rule.amount;
  const deposit = min(raw, total); // deposit can never exceed the total
  return { total, deposit, remaining: sub(total, deposit) };
}

export function commissionFor(total: Money, commissionBps: number) {
  const commission = mulBps(total, commissionBps);
  return { commission, providerNet: sub(total, commission) };
}

export interface RefundTier { minDaysBefore: number; refundBps: number }

/** Picks the tier with the largest minDaysBefore that is <= daysBeforeEvent. */
export function refundFor(tiers: RefundTier[], daysBeforeEvent: number, paid: Money): Money {
  const sorted = [...tiers].sort((a, b) => b.minDaysBefore - a.minDaysBefore);
  const tier = sorted.find((t) => daysBeforeEvent >= t.minDaysBefore);
  return tier ? mulBps(paid, tier.refundBps) : money(0n, paid.currency);
}
