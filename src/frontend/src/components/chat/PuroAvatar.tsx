interface PuroAvatarProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

export default function PuroAvatar({ size = 'md' }: PuroAvatarProps) {
  const sizeClasses = {
    sm: 'h-10 w-10',
    md: 'h-12 w-12',
    lg: 'h-20 w-20',
    xl: 'h-32 w-32',
  };

  return (
    <div className={`${sizeClasses[size]} flex-shrink-0 overflow-hidden rounded-full bg-accent/20 ring-2 ring-primary/20`}>
      <img
        src="/assets/generated/puro-avatar-changed.dim_512x512.png"
        alt="Puro"
        className="h-full w-full object-cover"
      />
    </div>
  );
}
