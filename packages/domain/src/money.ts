// Money is stored as integer minor units (bigint). No floats anywhere.
export interface Currency { code: string; exponent: number }

// Exponent is configuration, not logic: change it here (or load from the
// `currencies` table) if the SYP subunit convention changes.
export const CURRENCIES: Record<string, Currency> = {
  SYP: { code: 'SYP', exponent: 2 },
  USD: { code: 'USD', exponent: 2 },
};

export type Rounding = 'half-up' | 'down';

export interface Money { minor: bigint; currency: string }

export function money(minor: bigint | number, currency = 'SYP'): Money {
  if (!CURRENCIES[currency]) throw new Error(`Unsupported currency: ${currency}`);
  if (typeof minor === 'number' && !Number.isInteger(minor)) throw new Error('Minor units must be an integer');
  return { minor: BigInt(minor), currency };
}

export function fromMajor(text: string, currency = 'SYP'): Money {
  const cur = CURRENCIES[currency];
  if (!cur) throw new Error(`Unsupported currency: ${currency}`);
  const m = /^(-?)(\d+)(?:\.(\d+))?$/.exec(text.trim());
  if (!m) throw new Error(`Invalid amount: ${text}`);
  const frac = m[3] ?? '';
  if (frac.length > cur.exponent) throw new Error(`Too many decimals for ${currency}`);
  const minor = BigInt(m[2] + frac.padEnd(cur.exponent, '0'));
  return money(m[1] === '-' ? -minor : minor, currency);
}

function same(a: Money, b: Money) {
  if (a.currency !== b.currency) throw new Error('Currency mismatch');
}
export const add = (a: Money, b: Money): Money => (same(a, b), money(a.minor + b.minor, a.currency));
export const sub = (a: Money, b: Money): Money => (same(a, b), money(a.minor - b.minor, a.currency));
export const min = (a: Money, b: Money): Money => (same(a, b), a.minor <= b.minor ? a : b);

/** Multiply by basis points (1% = 100 bps). Deterministic integer rounding. */
export function mulBps(a: Money, bps: number, rounding: Rounding = 'half-up'): Money {
  if (!Number.isInteger(bps) || bps < 0 || bps > 10000) throw new Error('bps must be an integer 0..10000');
  const num = a.minor * BigInt(bps);
  const q = rounding === 'half-up' ? (num + 5000n) / 10000n : num / 10000n;
  return money(q, a.currency);
}

export function format(a: Money): string {
  const { exponent } = CURRENCIES[a.currency]!;
  const neg = a.minor < 0n; const abs = neg ? -a.minor : a.minor;
  const s = abs.toString().padStart(exponent + 1, '0');
  const whole = s.slice(0, s.length - exponent).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  const frac = exponent ? s.slice(-exponent) : '';
  const body = frac && frac !== '0'.repeat(exponent) ? `${whole}.${frac}` : whole;
  return `${neg ? '-' : ''}${body} ${a.currency}`;
}
