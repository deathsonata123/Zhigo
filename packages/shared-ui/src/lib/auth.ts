// packages/shared-ui/src/lib/auth.ts
// Auth utility for Express.js backend calls

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://52.74.236.219:3000';

export interface AuthUser {
    userId: string;
    email: string;
    username: string;
    attributes: {
        sub: string;
        email: string;
        email_verified?: boolean;
        name?: string;
        phone_number?: string;
        'custom:role'?: string;
    };
    signInDetails?: {
        loginId?: string;
    };
}

export interface AuthTokens {
    accessToken: string;
    idToken: string;
    refreshToken: string;
}

// Store tokens in localStorage (consider httpOnly cookies for production)
const TOKEN_KEY = 'auth_tokens';
const USER_KEY = 'auth_user';

// Token management
export const getStoredTokens = (): AuthTokens | null => {
    if (typeof window === 'undefined') return null;
    const tokens = localStorage.getItem(TOKEN_KEY);
    return tokens ? JSON.parse(tokens) : null;
};

export const setStoredTokens = (tokens: AuthTokens) => {
    if (typeof window === 'undefined') return;
    localStorage.setItem(TOKEN_KEY, JSON.stringify(tokens));
};

export const clearStoredTokens = () => {
    if (typeof window === 'undefined') return;
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
};

export const getStoredUser = (): AuthUser | null => {
    if (typeof window === 'undefined') return null;
    const user = localStorage.getItem(USER_KEY);
    return user ? JSON.parse(user) : null;
};

export const setStoredUser = (user: AuthUser) => {
    if (typeof window === 'undefined') return;
    localStorage.setItem(USER_KEY, JSON.stringify(user));
};

// Auth API calls
export const signIn = async (params: { username: string; password: string }): Promise<{ nextStep?: { signInStep: string } }> => {
    const response = await fetch(`${API_URL}/api/auth/signin`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: params.username, password: params.password })
    });

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Sign in failed');
    }

    const { data } = await response.json();

    // Store tokens and user
    setStoredTokens({
        accessToken: data.accessToken,
        idToken: data.idToken,
        refreshToken: data.refreshToken
    });

    const user: AuthUser = {
        userId: data.user.attributes.sub,
        email: data.user.attributes.email,
        username: data.user.username,
        attributes: data.user.attributes,
        signInDetails: {
            loginId: data.user.attributes.email
        }
    };

    setStoredUser(user);
    return { nextStep: { signInStep: 'DONE' } };
};

export const signUp = async (params: {
    username: string;
    password: string;
    options?: {
        userAttributes?: Record<string, string>;
    };
}): Promise<{ userId?: string; nextStep?: { signUpStep: string } }> => {
    const { username, password, options } = params;

    const response = await fetch(`${API_URL}/api/auth/signup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            email: username,
            password,
            fullName: options?.userAttributes?.name || '',
            phone: options?.userAttributes?.phone_number,
            role: options?.userAttributes?.['custom:role']
        })
    });

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Sign up failed');
    }

    const { data } = await response.json();

    return {
        userId: data.userId,
        nextStep: { signUpStep: data.isConfirmed ? 'DONE' : 'CONFIRM_SIGN_UP' }
    };
};

export const confirmSignUp = async (params: { username: string; confirmationCode: string }): Promise<void> => {
    const response = await fetch(`${API_URL}/api/auth/confirm`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            email: params.username,
            code: params.confirmationCode
        })
    });

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Confirmation failed');
    }
};

export const signOut = async (params?: { global?: boolean }): Promise<void> => {
    const tokens = getStoredTokens();

    if (tokens?.accessToken) {
        try {
            await fetch(`${API_URL}/api/auth/signout`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${tokens.accessToken}`
                }
            });
        } catch (error) {
            console.error('Signout error:', error);
        }
    }

    clearStoredTokens();
};

export const getCurrentUser = async (): Promise<AuthUser> => {
    // First check cached user
    const cachedUser = getStoredUser();
    const tokens = getStoredTokens();

    if (!tokens?.accessToken) {
        throw new Error('Not authenticated');
    }

    // Return cached user if available
    if (cachedUser) {
        return cachedUser;
    }

    // Fetch from backend
    const response = await fetch(`${API_URL}/api/auth/me`, {
        headers: {
            'Authorization': `Bearer ${tokens.accessToken}`
        }
    });

    if (!response.ok) {
        clearStoredTokens();
        throw new Error('Invalid or expired session');
    }

    const { data } = await response.json();

    const user: AuthUser = {
        userId: data.attributes.sub,
        email: data.attributes.email,
        username: data.username,
        attributes: data.attributes,
        signInDetails: {
            loginId: data.attributes.email
        }
    };

    setStoredUser(user);
    return user;
};

export const fetchAuthSession = async (options?: { forceRefresh?: boolean }): Promise<{
    tokens?: {
        accessToken: { toString: () => string };
        idToken: { toString: () => string };
    };
}> => {
    const tokens = getStoredTokens();

    if (!tokens?.accessToken) {
        return {};
    }

    // If force refresh, validate token with backend
    if (options?.forceRefresh) {
        try {
            await getCurrentUser();
        } catch (error) {
            return {};
        }
    }

    return {
        tokens: {
            accessToken: {
                toString: () => tokens.accessToken
            },
            idToken: {
                toString: () => tokens.idToken
            }
        }
    };
};

export const updatePassword = async (params: {
    oldPassword: string;
    newPassword: string;
}): Promise<void> => {
    const tokens = getStoredTokens();

    if (!tokens?.accessToken) {
        throw new Error('Not authenticated');
    }

    const response = await fetch(`${API_URL}/api/auth/change-password`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${tokens.accessToken}`
        },
        body: JSON.stringify({
            oldPassword: params.oldPassword,
            newPassword: params.newPassword
        })
    });

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Password update failed');
    }
};

export const resetPassword = async (params: { username: string }): Promise<void> => {
    const response = await fetch(`${API_URL}/api/auth/forgot-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email: params.username })
    });

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Password reset failed');
    }
};

export const confirmResetPassword = async (params: {
    username: string;
    confirmationCode: string;
    newPassword: string;
}): Promise<void> => {
    const response = await fetch(`${API_URL}/api/auth/reset-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            email: params.username,
            code: params.confirmationCode,
            newPassword: params.newPassword
        })
    });

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Password reset confirmation failed');
    }
};

// OAuth redirect (Google Sign-In)
export const signInWithRedirect = async (params: { provider: string }): Promise<void> => {
    // Redirect to backend OAuth endpoint
    window.location.href = `${API_URL}/api/auth/oauth/${params.provider.toLowerCase()}`;
};
