import { ChatMessage } from '../../backend';
import MessageBubble from './MessageBubble';

interface ChatTranscriptProps {
  messages: ChatMessage[];
}

export default function ChatTranscript({ messages }: ChatTranscriptProps) {
  if (messages.length === 0) {
    return (
      <div className="flex h-full flex-col items-center justify-center space-y-4 text-center">
        <div className="rounded-full bg-accent/20 p-6">
          <span className="text-4xl">💬</span>
        </div>
        <div className="space-y-2">
          <h3 className="text-lg font-semibold text-foreground">Start a conversation</h3>
          <p className="text-sm text-muted-foreground max-w-sm">
            Send a message to begin chatting. You can chat normally or use * at the end of your message to describe actions.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-3xl space-y-4">
      {messages.map((message, index) => (
        <MessageBubble key={index} message={message} />
      ))}
    </div>
  );
}
