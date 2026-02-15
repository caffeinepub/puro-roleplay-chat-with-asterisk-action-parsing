import { useGetCallerUserProfile } from './hooks/useQueries';
import ChatPage from './pages/ChatPage';
import ProfileSetupModal from './components/profile/ProfileSetupModal';
import { Loader2 } from 'lucide-react';

export default function App() {
  const { data: userProfile, isLoading: profileLoading, isFetched } = useGetCallerUserProfile();

  // Show loading while fetching profile
  if (profileLoading) {
    return (
      <div className="flex h-screen items-center justify-center bg-background">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  // Show profile setup modal if user needs to set their name
  const showProfileSetup = !profileLoading && isFetched && userProfile === null;

  return (
    <>
      <ProfileSetupModal open={showProfileSetup} />
      {!showProfileSetup && <ChatPage />}
    </>
  );
}
