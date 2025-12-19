//packages/shared-ui/src/components/oauth-handler.tsx
'use client';

import { useEffect, useRef } from 'react';

import { fetchAuthSession, getCurrentUser } from '../lib/auth';

/**
 * OAuth Handler Component
 * Detects OAuth redirect completion and ensures UI updates with SINGLE reload
 */
export function OAuthHandler() {
  const hasProcessed = useRef(false);

  useEffect(() => {
    // Prevent multiple executions
    if (hasProcessed.current) return;

    const checkOAuthCallback = async () => {
      const urlParams = new URLSearchParams(window.location.search);
      const hasOAuthCode = urlParams.has('code');
      const hasOAuthState = urlParams.has('state');

      // Only process if we have OAuth params AND haven't processed yet
      if ((!hasOAuthCode && !hasOAuthState) || sessionStorage.getItem('oauth_processed')) {
        return;
      }

      hasProcessed.current = true;
      console.log('[OAuthHandler] 🔍 OAuth redirect detected, processing...');

      // Wait for Amplify to process OAuth tokens
      await new Promise(resolve => setTimeout(resolve, 1500));

      try {
        const session = await fetchAuthSession({ forceRefresh: true });

        if (session.tokens) {
          console.log('[OAuthHandler] ✅ OAuth successful');

          // Verify user
          await getCurrentUser();

          // Clean URL
          const cleanUrl = window.location.pathname;
          window.history.replaceState({}, document.title, cleanUrl);

          // Mark as processed
          sessionStorage.setItem('oauth_processed', 'true');

          // Single reload to update UI
          console.log('[OAuthHandler] 🔄 Reloading once...');
          window.location.reload();
        }
      } catch (error) {
        console.error('[OAuthHandler] ❌ OAuth processing failed:', error);
        sessionStorage.removeItem('oauth_processed');
      }
    };

    // Run check
    checkOAuthCallback();

    // Cleanup flag after page is stable
    const cleanupTimer = setTimeout(() => {
      if (sessionStorage.getItem('oauth_processed')) {
        sessionStorage.removeItem('oauth_processed');
      }
    }, 3000);

    return () => {
      clearTimeout(cleanupTimer);
    };
  }, []);

  return null;
}
