import { useState, useRef, KeyboardEvent } from 'react';
import { Textarea } from '@/components/ui/textarea';
import { Button } from '@/components/ui/button';
import { Send, Loader2 } from 'lucide-react';

interface ChatComposerProps {
  value: string;
  onChange: (value: string) => void;
  onSend: (message: string) => void;
  disabled?: boolean;
  isSending?: boolean;
}

export default function ChatComposer({
  value,
  onChange,
  onSend,
  disabled,
  isSending,
}: ChatComposerProps) {
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const handleKeyDown = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      if (value.trim() && !disabled) {
        onSend(value);
      }
    }
  };

  const handleSendClick = () => {
    if (value.trim() && !disabled) {
      onSend(value);
    }
  };

  return (
    <div className="flex gap-2">
      <div className="relative flex-1">
        <Textarea
          ref={textareaRef}
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onKeyDown={handleKeyDown}
          placeholder="Type a message... (use * at the end for actions)"
          disabled={disabled}
          className="min-h-[60px] max-h-[200px] resize-none pr-12"
          rows={2}
        />
        <div className="absolute bottom-2 right-2 text-xs text-muted-foreground/60">
          {value.endsWith('*') && '✨ action'}
        </div>
      </div>
      <Button
        onClick={handleSendClick}
        disabled={!value.trim() || disabled}
        size="icon"
        className="h-[60px] w-[60px] flex-shrink-0"
      >
        {isSending ? (
          <Loader2 className="h-5 w-5 animate-spin" />
        ) : (
          <Send className="h-5 w-5" />
        )}
      </Button>
    </div>
  );
}
