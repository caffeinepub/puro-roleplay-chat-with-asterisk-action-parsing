import { useState, useRef, useEffect } from 'react';
import { useGetHistory, useSendMessage } from '../hooks/useQueries';
import ChatLayout from '../components/layout/ChatLayout';
import ChatTranscript from '../components/chat/ChatTranscript';
import ChatComposer from '../components/chat/ChatComposer';
import { Loader2, AlertCircle } from 'lucide-react';
import { Alert, AlertDescription } from '@/components/ui/alert';

export default function ChatPage() {
  const { data: history, isLoading, error: historyError } = useGetHistory();
  const { mutate: sendMessage, isPending, error: sendError } = useSendMessage();
  const [draftMessage, setDraftMessage] = useState('');
  const scrollRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [history]);

  const handleSend = (message: string) => {
    if (!message.trim() || isPending) return;

    sendMessage(
      { content: message.trim() },
      {
        onSuccess: () => {
          setDraftMessage('');
        },
        onError: () => {
          // Keep draft message on error so user can retry
          setDraftMessage(message);
        },
      }
    );
  };

  return (
    <ChatLayout>
      <div className="flex h-full flex-col">
        {/* Transcript area */}
        <div ref={scrollRef} className="flex-1 overflow-y-auto px-4 py-6">
          {isLoading ? (
            <div className="flex h-full items-center justify-center">
              <Loader2 className="h-8 w-8 animate-spin text-primary" />
            </div>
          ) : historyError ? (
            <div className="flex h-full items-center justify-center px-4">
              <Alert variant="destructive" className="max-w-md">
                <AlertCircle className="h-4 w-4" />
                <AlertDescription>
                  Failed to load chat history. Please refresh the page.
                </AlertDescription>
              </Alert>
            </div>
          ) : (
            <ChatTranscript messages={history || []} />
          )}
        </div>

        {/* Error display */}
        {sendError && (
          <div className="px-4 pb-2">
            <Alert variant="destructive">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>
                Failed to send message. Please try again.
              </AlertDescription>
            </Alert>
          </div>
        )}

        {/* Composer area */}
        <div className="border-t border-border bg-card/50 px-4 py-4">
          <ChatComposer
            value={draftMessage}
            onChange={setDraftMessage}
            onSend={handleSend}
            disabled={isPending || isLoading}
            isSending={isPending}
          />
        </div>
      </div>
    </ChatLayout>
  );
}
