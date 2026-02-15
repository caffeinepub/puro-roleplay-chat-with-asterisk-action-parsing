// Utility for managing guest session IDs in browser storage

const GUEST_SESSION_KEY = 'puro-chat-guest-session-id';

/**
 * Generate a simple UUID v4
 */
function generateUUID(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    const v = c === 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

/**
 * Get or create a guest session ID from localStorage
 */
export function getOrCreateGuestSessionId(): string {
  try {
    const stored = localStorage.getItem(GUEST_SESSION_KEY);
    if (stored) {
      return stored;
    }
    const newId = generateUUID();
    localStorage.setItem(GUEST_SESSION_KEY, newId);
    return newId;
  } catch (error) {
    // Fallback if localStorage is unavailable
    console.warn('localStorage unavailable, using session-only guest ID');
    return generateUUID();
  }
}

/**
 * Clear the guest session ID (useful for testing or reset)
 */
export function clearGuestSessionId(): void {
  try {
    localStorage.removeItem(GUEST_SESSION_KEY);
  } catch (error) {
    console.warn('Failed to clear guest session ID');
  }
}
