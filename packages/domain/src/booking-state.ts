export const STATES = [
  'draft', 'pending', 'awaiting_payment', 'payment_submitted', 'payment_verification',
  'confirmed', 'rejected', 'cancelled', 'completed', 'no_show',
] as const;
export type BookingState = (typeof STATES)[number];

export type Actor = 'customer' | 'provider' | 'admin' | 'system';

export type BookingEvent =
  | 'SUBMIT' | 'PROVIDER_ACCEPT' | 'PROVIDER_REJECT' | 'CANCEL'
  | 'PAYMENT_SUBMITTED' | 'PAYMENT_UNDER_REVIEW' | 'PAYMENT_VERIFIED' | 'PAYMENT_REJECTED'
  | 'MARK_COMPLETED' | 'MARK_NO_SHOW';

type Rule = { to: BookingState; actors: Actor[] };

// Single source of truth for the lifecycle. No scattered boolean flags.
const TABLE: Partial<Record<BookingState, Partial<Record<BookingEvent, Rule>>>> = {
  draft: { SUBMIT: { to: 'pending', actors: ['customer'] }, CANCEL: { to: 'cancelled', actors: ['customer'] } },
  pending: {
    PROVIDER_ACCEPT: { to: 'awaiting_payment', actors: ['provider', 'admin'] },
    PROVIDER_REJECT: { to: 'rejected', actors: ['provider', 'admin'] },
    CANCEL: { to: 'cancelled', actors: ['customer', 'admin'] },
  },
  awaiting_payment: {
    PAYMENT_SUBMITTED: { to: 'payment_submitted', actors: ['customer'] },
    CANCEL: { to: 'cancelled', actors: ['customer', 'provider', 'admin', 'system'] },
  },
  payment_submitted: {
    PAYMENT_UNDER_REVIEW: { to: 'payment_verification', actors: ['provider', 'admin'] },
    CANCEL: { to: 'cancelled', actors: ['customer', 'admin'] },
  },
  payment_verification: {
    // The DB layer MUST insert the calendar hold in the same transaction as this transition.
    PAYMENT_VERIFIED: { to: 'confirmed', actors: ['provider', 'admin'] },
    PAYMENT_REJECTED: { to: 'awaiting_payment', actors: ['provider', 'admin'] },
    CANCEL: { to: 'cancelled', actors: ['customer', 'admin'] },
  },
  confirmed: {
    MARK_COMPLETED: { to: 'completed', actors: ['provider', 'admin', 'system'] },
    MARK_NO_SHOW: { to: 'no_show', actors: ['provider', 'admin'] },
    CANCEL: { to: 'cancelled', actors: ['customer', 'provider', 'admin'] },
  },
};

export const TERMINAL: readonly BookingState[] = ['rejected', 'cancelled', 'completed', 'no_show'];

export class InvalidTransition extends Error {
  from: BookingState; event: BookingEvent; actor: Actor;
  constructor(from: BookingState, event: BookingEvent, actor: Actor) {
    super(`Transition ${event} not allowed from ${from} for ${actor}`);
    this.from = from; this.event = event; this.actor = actor;
  }
}

export function transition(from: BookingState, event: BookingEvent, actor: Actor): BookingState {
  const rule = TABLE[from]?.[event];
  if (!rule || !rule.actors.includes(actor)) throw new InvalidTransition(from, event, actor);
  return rule.to;
}

export function allowedEvents(from: BookingState, actor: Actor): BookingEvent[] {
  return (Object.entries(TABLE[from] ?? {}) as [BookingEvent, Rule][])
    .filter(([, r]) => r.actors.includes(actor)).map(([e]) => e);
}
