'use client';

import { useState } from 'react';
import { Button } from '../components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle
} from '../components/ui/dialog';
import { Input } from '../components/ui/input';
import { Label } from '../components/ui/label';
import { useToast } from '../hooks/use-toast';
import { Loader2 } from 'lucide-react';

import { signUp, signInWithRedirect, signIn, confirmSignUp } from 'aws-amplify/auth';

interface SignupDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSwitchToLogin: () => void;
  onSignupSuccess: () => void;
}

export function SignupDialog({
  open,
  onOpenChange,
  onSwitchToLogin,
  onSignupSuccess,
}: SignupDialogProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmationCode, setConfirmationCode] = useState('');
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [loading, setLoading] = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);
  const { toast } = useToast();

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const result = await signUp({
        username: email,
        password,
        options: {
          userAttributes: { email },
        },
      });

      if (result.nextStep?.signUpStep === 'CONFIRM_SIGN_UP') {
        setShowConfirmation(true);
        toast({
          title: 'Check your email',
          description: 'Enter the confirmation code to complete signup.',
        });
      } else {
        await signIn({ username: email, password });
        toast({ title: 'Signup complete', description: `Welcome, ${email}!` });
        onSignupSuccess();
        onOpenChange(false);
      }
    } catch (error: any) {
      console.error('Signup error:', error);
      toast({
        title: 'Signup failed',
        description: error.message || 'Something went wrong.',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleConfirm = async () => {
    setLoading(true);
    try {
      await confirmSignUp({ username: email, confirmationCode });
      await signIn({ username: email, password });
      toast({
        title: 'Signup complete',
        description: `Welcome, ${email}!`,
      });
      onSignupSuccess();
      onOpenChange(false);
    } catch (error: any) {
      console.error('Confirmation error:', error);
      toast({
        title: 'Confirmation failed',
        description: error.message || 'Something went wrong.',
        variant: 'destructive',
      });
    } finally {
      setLoading(false);
      setShowConfirmation(false);
      setConfirmationCode('');
    }
  };

  const handleGoogleSignIn = async () => {
    setGoogleLoading(true);
    try {
      // Store current path before redirect
      if (typeof window !== 'undefined') {
        sessionStorage.setItem('preAuthPath', window.location.pathname);
      }
      
      // Close dialog before redirect
      onOpenChange(false);
      
      // Initiate Google OAuth flow
      await signInWithRedirect({ provider: 'Google' });
      
      // Note: The page will redirect, so code after this won't execute
      // The Hub listener in HeaderActions will handle post-OAuth state
    } catch (error: any) {
      console.error('Google Sign-in error:', error);
      toast({
        title: 'Google Sign-in failed',
        description: error.message || 'Something went wrong.',
        variant: 'destructive',
      });
      setGoogleLoading(false);
      onOpenChange(true); // Reopen dialog on error
    }
  };

  const GoogleIcon = () => (
    <svg className="mr-2 h-4 w-4" viewBox="0 0 48 48">
      <path fill="#FFC107" d="M43.611 20.083H42V20H24v8h11.303c-1.649 4.657-6.08 8-11.303 8c-6.627 0-12-5.373-12-12s5.373-12 12-12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4C12.955 4 4 12.955 4 24s8.955 20 20 20s20-8.955 20-20c0-1.341-.138-2.65-.389-3.917z"/>
      <path fill="#FF3D00" d="M6.306 14.691l6.571 4.819C14.655 15.108 18.961 12 24 12c3.059 0 5.842 1.154 7.961 3.039l5.657-5.657C34.046 6.053 29.268 4 24 4C16.318 4 9.656 8.337 6.306 14.691z"/>
      <path fill="#4CAF50" d="M24 44c5.166 0 9.86-1.977 13.409-5.192l-6.19-5.238C29.211 35.091 26.715 36 24 36c-5.222 0-9.618-3.226-11.283-7.584l-6.522 5.025C9.505 39.556 16.227 44 24 44z"/>
      <path fill="#1976D2" d="M43.611 20.083H24v8h11.303c-.792 2.237-2.231 4.166-4.087 5.571l6.19 5.238C42.012 34.426 44 29.616 44 24c0-1.341-.138-2.65-.389-3.917z"/>
    </svg>
  );

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle className="text-3xl font-headline text-center">Sign Up</DialogTitle>
        </DialogHeader>
        <div className="py-4 space-y-4">
          <Button
            variant="outline"
            className="w-full"
            onClick={handleGoogleSignIn}
            disabled={googleLoading}
          >
            {googleLoading ? (
              <Loader2 className="mr-2 h-4 w-4 animate-spin" />
            ) : (
              <GoogleIcon />
            )}
            Sign up with Google
          </Button>

          <div className="relative">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-background px-2 text-muted-foreground">
                Or continue with
              </span>
            </div>
          </div>

          <form onSubmit={handleSignup} className="space-y-4">
            <div className="grid gap-2">
              <Label htmlFor="email-signup">Email</Label>
              <Input
                id="email-signup"
                type="email"
                placeholder="m@example.com"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
            <div className="grid gap-2">
              <Label htmlFor="password-signup">Password</Label>
              <Input
                id="password-signup"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>

            {showConfirmation && (
              <div className="grid gap-2">
                <Label htmlFor="confirmation-code">Confirmation Code</Label>
                <Input
                  id="confirmation-code"
                  type="text"
                  required
                  value={confirmationCode}
                  onChange={(e) => setConfirmationCode(e.target.value)}
                />
                <Button
                  type="button"
                  onClick={handleConfirm}
                  className="w-full"
                  disabled={loading}
                >
                  {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                  Confirm
                </Button>
              </div>
            )}

            {!showConfirmation && (
              <Button type="submit" className="w-full" disabled={loading}>
                {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Create an account
              </Button>
            )}
          </form>
        </div>
        <DialogFooter>
          <p className="text-center text-sm text-muted-foreground w-full">
            Already have an account?{' '}
            <Button
              variant="link"
              type="button"
              onClick={onSwitchToLogin}
              className="p-0 h-auto"
            >
              Login
            </Button>
          </p>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}