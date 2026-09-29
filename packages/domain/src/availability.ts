// Half-open intervals [start, end). Back-to-back slots do NOT conflict.
export interface Interval { start: number; end: number } // epoch ms

export type EntryKind = 'confirmed_booking' | 'manual_booking' | 'blocked' | 'holiday';

export interface CalendarEntry extends Interval { providerId: string; kind: EntryKind }

export function overlaps(a: Interval, b: Interval): boolean {
  if (a.end <= a.start || b.end <= b.start) throw new Error('Invalid interval');
  return a.start < b.end && b.start < a.end;
}

/** Pure mirror of the DB exclusion constraint, used for UI hints and unit tests.
 *  The authoritative guarantee is the Postgres EXCLUDE constraint, not this. */
export function findConflicts(entries: CalendarEntry[], providerId: string, req: Interval): CalendarEntry[] {
  return entries.filter((e) => e.providerId === providerId && overlaps(e, req));
}

export const isAvailable = (entries: CalendarEntry[], providerId: string, req: Interval) =>
  findConflicts(entries, providerId, req).length === 0;
