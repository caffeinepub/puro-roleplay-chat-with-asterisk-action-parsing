import { useMemo } from 'react';
import { getOrCreateGuestSessionId } from '../utils/guestSession';

/**
 * Hook that provides a stable guest session ID for anonymous users
 */
export function useGuestSessionId(): string {
  const sessionId = useMemo(() => getOrCreateGuestSessionId(), []);
  return sessionId;
}
