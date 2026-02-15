import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useActor } from './useActor';
import { ChatMessage, UserProfile, Variant_Puro_user, Variant_action_dialogue } from '../backend';

// User Profile Queries
export function useGetCallerUserProfile() {
  const { actor, isFetching: actorFetching } = useActor();

  const query = useQuery<UserProfile | null>({
    queryKey: ['currentUserProfile'],
    queryFn: async () => {
      if (!actor) throw new Error('Actor not available');
      return actor.getCallerUserProfile();
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
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (profile: UserProfile) => {
      if (!actor) throw new Error('Actor not available');
      return actor.saveCallerUserProfile(profile);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['currentUserProfile'] });
    },
  });
}

// Chat Queries
export function useGetHistory() {
  const { actor, isFetching: actorFetching } = useActor();

  return useQuery<ChatMessage[]>({
    queryKey: ['chatHistory'],
    queryFn: async () => {
      if (!actor) return [];
      try {
        return await actor.getHistory();
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
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ content }: { content: string }) => {
      if (!actor) throw new Error('Actor not available');

      const message: ChatMessage = {
        content,
        sender: Variant_Puro_user.user,
        messageType: Variant_action_dialogue.dialogue,
        timestamp: BigInt(Date.now()) * BigInt(1_000_000),
      };

      return actor.sendMessage(message);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['chatHistory'] });
    },
  });
}
