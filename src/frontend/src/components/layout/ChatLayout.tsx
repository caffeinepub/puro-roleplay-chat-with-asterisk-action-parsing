import { ReactNode } from 'react';
import LoginButton from '../auth/LoginButton';
import PuroAvatar from '../chat/PuroAvatar';
import { SiFacebook, SiX } from 'react-icons/si';

interface ChatLayoutProps {
  children: ReactNode;
}

export default function ChatLayout({ children }: ChatLayoutProps) {
  const currentYear = new Date().getFullYear();
  const appIdentifier = encodeURIComponent(window.location.hostname || 'puro-chat');

  return (
    <div className="flex h-screen flex-col bg-gradient-to-br from-background via-accent/10 to-background">
      {/* Header */}
      <header className="border-b border-border/50 bg-card/80 backdrop-blur-sm">
        <div className="container mx-auto flex items-center justify-between px-4 py-3">
          <div className="flex items-center space-x-3">
            <PuroAvatar size="sm" />
            <div>
              <h1 className="text-lg font-bold text-foreground">Puro</h1>
              <p className="text-xs text-muted-foreground">Your friendly companion</p>
            </div>
          </div>
          <LoginButton />
        </div>
      </header>

      {/* Main content */}
      <main className="flex-1 overflow-hidden">{children}</main>

      {/* Footer */}
      <footer className="border-t border-border/50 bg-card/80 backdrop-blur-sm px-4 py-3">
        <div className="container mx-auto flex flex-col items-center justify-between space-y-2 text-center text-xs text-muted-foreground sm:flex-row sm:space-y-0">
          <p>
            © {currentYear} Built with ❤️ using{' '}
            <a
              href={`https://caffeine.ai/?utm_source=Caffeine-footer&utm_medium=referral&utm_content=${appIdentifier}`}
              target="_blank"
              rel="noopener noreferrer"
              className="font-medium text-foreground hover:underline"
            >
              caffeine.ai
            </a>
          </p>
          <div className="flex items-center space-x-3">
            <span className="text-muted-foreground/70">Share:</span>
            <a href="#" className="text-muted-foreground transition-colors hover:text-foreground">
              <SiX className="h-3.5 w-3.5" />
            </a>
            <a href="#" className="text-muted-foreground transition-colors hover:text-foreground">
              <SiFacebook className="h-3.5 w-3.5" />
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}
