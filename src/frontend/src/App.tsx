import { useInternetIdentity } from './hooks/useInternetIdentity';
import { useGetCallerUserProfile } from './hooks/useQueries';
import ChatPage from './pages/ChatPage';
import LoginButton from './components/auth/LoginButton';
import ProfileSetupModal from './components/profile/ProfileSetupModal';
import PuroAvatar from './components/chat/PuroAvatar';
import { Loader2 } from 'lucide-react';

export default function App() {
  const { identity, isInitializing } = useInternetIdentity();
  const { data: userProfile, isLoading: profileLoading, isFetched } = useGetCallerUserProfile();

  const isAuthenticated = !!identity;

  // Show loading while initializing auth
  if (isInitializing) {
    return (
      <div className="flex h-screen items-center justify-center bg-background">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  // Show login screen if not authenticated
  if (!isAuthenticated) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center bg-gradient-to-br from-background via-accent/20 to-background p-4">
        <div className="flex flex-col items-center space-y-8 text-center">
          <PuroAvatar size="xl" />
          <div className="space-y-3">
            <h1 className="text-4xl font-bold tracking-tight text-foreground">
              Chat with Puro
            </h1>
            <p className="text-lg text-muted-foreground max-w-md">
              A friendly companion ready to chat and roleplay with you. Login to start your conversation!
            </p>
          </div>
          <LoginButton />
        </div>
      </div>
    );
  }

  // Show profile setup modal if user needs to set their name
  const showProfileSetup = isAuthenticated && !profileLoading && isFetched && userProfile === null;

  return (
    <>
      <ProfileSetupModal open={showProfileSetup} />
      {!showProfileSetup && <ChatPage />}
    </>
  );
}
