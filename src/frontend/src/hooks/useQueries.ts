import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useActor } from './useActor';
import { useInternetIdentity } from './useInternetIdentity';
import { useGuestSessionId } from './useGuestSessionId';
import { ChatMessage, UserProfile, Variant_Puro_user, Variant_action_dialogue } from '../backend';

// User Profile Queries
export function useGetCallerUserProfile() {
  const { actor, isFetching: actorFetching } = useActor();
  const { identity } = useInternetIdentity();
  const guestSessionId = useGuestSessionId();

  const sessionId = identity ? identity.getPrincipal().toString() : guestSessionId;

  const query = useQuery<UserProfile | null>({
    queryKey: ['currentUserProfile', sessionId],
    queryFn: async () => {
      if (!actor) throw new Error('Actor not available');
      return actor.getCallerUserProfile(sessionId);
    },
    enabled: !!actor && !actorFetching,
    retry: false,
  });

  return {
    ...query,
    isLoading: actorFetching || query.isLoading,
    isFetched: !!actor && query.isFetched,
  };
}

export function useSaveCallerUserProfile() {
  const { actor } = useActor();
  const { identity } = useInternetIdentity();
  const guestSessionId = useGuestSessionId();
  const queryClient = useQueryClient();

  const sessionId = identity ? identity.getPrincipal().toString() : guestSessionId;

  return useMutation({
    mutationFn: async (profile: UserProfile) => {
      if (!actor) throw new Error('Actor not available');
      return actor.saveCallerUserProfile(sessionId, profile);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['currentUserProfile', sessionId] });
    },
  });
}

// Chat Queries
export function useGetHistory() {
  const { actor, isFetching: actorFetching } = useActor();
  const { identity } = useInternetIdentity();
  const guestSessionId = useGuestSessionId();

  const sessionKey = identity ? identity.getPrincipal().toString() : guestSessionId;

  return useQuery<ChatMessage[]>({
    queryKey: ['chatHistory', sessionKey],
    queryFn: async () => {
      if (!actor) return [];
      try {
        return await actor.getHistory(sessionKey);
      } catch (error: any) {
        // If no session found, return empty array
        if (error.message?.includes('No session found')) {
          return [];
        }
        throw error;
      }
    },
    enabled: !!actor && !actorFetching,
    retry: false,
  });
}

export function useSendMessage() {
  const { actor } = useActor();
  const { identity } = useInternetIdentity();
  const guestSessionId = useGuestSessionId();
  const queryClient = useQueryClient();

  const sessionKey = identity ? identity.getPrincipal().toString() : guestSessionId;

  return useMutation({
    mutationFn: async ({ content }: { content: string }) => {
      if (!actor) throw new Error('Actor not available');

      const message: ChatMessage = {
        content,
        sender: Variant_Puro_user.user,
        messageType: Variant_action_dialogue.dialogue,
        timestamp: BigInt(Date.now()) * BigInt(1_000_000),
      };

      return actor.sendMessage(sessionKey, message);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['chatHistory', sessionKey] });
    },
  });
}
