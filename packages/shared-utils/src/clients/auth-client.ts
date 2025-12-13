export interface SignInParams {
    email: string;
    password: string;
}

export interface SignUpParams {
    email: string;
    password: string;
    fullName: string;
    phone?: string;
    role?: string;
}

export interface AuthTokens {
    accessToken: string;
    idToken: string;
    refreshToken: string;
    expiresIn: number;
}

export interface User {
    username: string;
    email: string;
    fullName?: string;
    phone?: string;
    role?: string;
    attributes: Record<string, string>;
}

export class AuthClient {
    private baseUrl: string;
    private static instance: AuthClient;

    private constructor(baseUrl: string = '/api/auth') {
        this.baseUrl = baseUrl;
    }

    static getInstance(baseUrl?: string): AuthClient {
        if (!AuthClient.instance) {
            AuthClient.instance = new AuthClient(baseUrl);
        }
        return AuthClient.instance;
    }

    async signIn(params: SignInParams): Promise<AuthTokens> {
        const response = await fetch(`${this.baseUrl}/signin`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(params),
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Sign in failed');
        }

        const { data } = await response.json();

        // Store tokens
        if (typeof window !== 'undefined') {
            localStorage.setItem('accessToken', data.accessToken);
            localStorage.setItem('idToken', data.idToken);
            localStorage.setItem('refreshToken', data.refreshToken);
        }

        return data;
    }

    async signUp(params: SignUpParams): Promise<{ userSub: string; userConfirmed: boolean }> {
        const response = await fetch(`${this.baseUrl}/signup`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(params),
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Sign up failed');
        }

        const { data } = await response.json();
        return data;
    }

    async confirmSignUp(email: string, code: string): Promise<void> {
        const response = await fetch(`${this.baseUrl}/confirm`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, code }),
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Confirmation failed');
        }
    }

    async signOut(): Promise<void> {
        const accessToken = this.getAccessToken();

        if (accessToken) {
            await fetch(`${this.baseUrl}/signout`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${accessToken}`,
                },
            });
        }

        // Clear tokens
        if (typeof window !== 'undefined') {
            localStorage.removeItem('accessToken');
            localStorage.removeItem('idToken');
            localStorage.removeItem('refreshToken');
        }
    }

    async getCurrentUser(): Promise<User> {
        const accessToken = this.getAccessToken();

        if (!accessToken) {
            throw new Error('Not authenticated');
        }

        const response = await fetch(`${this.baseUrl}/me`, {
            headers: {
                'Authorization': `Bearer ${accessToken}`,
            },
        });

        if (!response.ok) {
            throw new Error('Failed to get current user');
        }

        const { data } = await response.json();
        return data;
    }

    async forgotPassword(email: string): Promise<void> {
        const response = await fetch(`${this.baseUrl}/forgot-password`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email }),
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to send reset code');
        }
    }

    async resetPassword(email: string, code: string, newPassword: string): Promise<void> {
        const response = await fetch(`${this.baseUrl}/reset-password`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, code, newPassword }),
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to reset password');
        }
    }

    getAccessToken(): string | null {
        if (typeof window === 'undefined') return null;
        return localStorage.getItem('accessToken');
    }

    getIdToken(): string | null {
        if (typeof window === 'undefined') return null;
        return localStorage.getItem('idToken');
    }

    getRefreshToken(): string | null {
        if (typeof window === 'undefined') return null;
        return localStorage.getItem('refreshToken');
    }

    isAuthenticated(): boolean {
        return !!this.getAccessToken();
    }
}

// Export singleton instance
export const authClient = AuthClient.getInstance();
