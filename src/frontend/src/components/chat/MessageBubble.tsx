import { ChatMessage, Variant_Puro_user, Variant_action_dialogue } from '../../backend';
import PuroAvatar from './PuroAvatar';

interface MessageBubbleProps {
  message: ChatMessage;
}

export default function MessageBubble({ message }: MessageBubbleProps) {
  const isPuro = message.sender === Variant_Puro_user.Puro;
  const isAction = message.messageType === Variant_action_dialogue.action;

  return (
    <div className={`flex gap-3 ${isPuro ? 'justify-start' : 'justify-end'}`}>
      {isPuro && <PuroAvatar size="sm" />}
      
      <div className={`flex flex-col ${isPuro ? 'items-start' : 'items-end'} max-w-[75%]`}>
        {isPuro && (
          <span className="mb-1 text-xs font-medium text-muted-foreground">Puro</span>
        )}
        
        <div
          className={`rounded-2xl px-4 py-2.5 ${
            isPuro
              ? 'bg-card border border-border/50 text-foreground'
              : 'bg-primary text-primary-foreground'
          } ${isAction ? 'italic' : ''}`}
        >
          {isAction && !isPuro && <span className="mr-1">*</span>}
          <span>{message.content}</span>
          {isAction && !isPuro && <span className="ml-1">*</span>}
        </div>
        
        {isAction && (
          <span className="mt-1 text-xs text-muted-foreground/70">
            {isPuro ? 'action response' : 'action'}
          </span>
        )}
      </div>
      
      {!isPuro && (
        <div className="h-10 w-10 flex-shrink-0 rounded-full bg-primary/20 flex items-center justify-center text-primary font-semibold">
          You
        </div>
      )}
    </div>
  );
}
