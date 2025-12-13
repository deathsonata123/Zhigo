import {
    CognitoIdentityProviderClient,
    InitiateAuthCommand,
    SignUpCommand,
    ConfirmSignUpCommand,
    ForgotPasswordCommand,
    ConfirmForgotPasswordCommand,
    GetUserCommand,
    AdminGetUserCommand,
    AdminUpdateUserAttributesCommand,
    AdminAddUserToGroupCommand,
    AdminRemoveUserFromGroupCommand,
    GlobalSignOutCommand,
    ResendConfirmationCodeCommand,
    type InitiateAuthCommandInput,
    type SignUpCommandInput,
    type AttributeType,
} from '@aws-sdk/client-cognito-identity-provider';

export interface CognitoConfig {
    region: string;
    userPoolId: string;
    clientId: string;
}

export interface SignInResult {
    accessToken?: string;
    idToken?: string;
    refreshToken?: string;
    expiresIn?: number;
}

export interface SignUpResult {
    userSub?: string;
    userConfirmed?: boolean;
}

export interface UserAttributes {
    [key: string]: string;
}

export class CognitoAuthService {
    private client: CognitoIdentityProviderClient;
    private userPoolId: string;
    private clientId: string;
    private static instance: CognitoAuthService | null = null;

    private constructor(config: CognitoConfig) {
        this.client = new CognitoIdentityProviderClient({ region: config.region });
        this.userPoolId = config.userPoolId;
        this.clientId = config.clientId;
    }

    static initialize(config: CognitoConfig): CognitoAuthService {
        if (!CognitoAuthService.instance) {
            CognitoAuthService.instance = new CognitoAuthService(config);
        }
        return CognitoAuthService.instance;
    }

    static getInstance(): CognitoAuthService {
        if (!CognitoAuthService.instance) {
            throw new Error('Auth service not initialized. Call CognitoAuthService.initialize() first.');
        }
        return CognitoAuthService.instance;
    }

    async signIn(email: string, password: string): Promise<SignInResult> {
        const params: InitiateAuthCommandInput = {
            AuthFlow: 'USER_PASSWORD_AUTH',
            ClientId: this.clientId,
            AuthParameters: {
                USERNAME: email,
                PASSWORD: password,
            },
        };

        const command = new InitiateAuthCommand(params);
        const response = await this.client.send(command);

        return {
            accessToken: response.AuthenticationResult?.AccessToken,
            idToken: response.AuthenticationResult?.IdToken,
            refreshToken: response.AuthenticationResult?.RefreshToken,
            expiresIn: response.AuthenticationResult?.ExpiresIn,
        };
    }

    async signUp(
        email: string,
        password: string,
        attributes: UserAttributes
    ): Promise<SignUpResult> {
        const userAttributes: AttributeType[] = Object.entries(attributes).map(([key, value]) => ({
            Name: key,
            Value: value,
        }));

        const params: SignUpCommandInput = {
            ClientId: this.clientId,
            Username: email,
            Password: password,
            UserAttributes: userAttributes,
        };

        const command = new SignUpCommand(params);
        const response = await this.client.send(command);

        return {
            userSub: response.UserSub,
            userConfirmed: response.UserConfirmed,
        };
    }

    async confirmSignUp(email: string, code: string): Promise<void> {
        const command = new ConfirmSignUpCommand({
            ClientId: this.clientId,
            Username: email,
            ConfirmationCode: code,
        });

        await this.client.send(command);
    }

    async resendConfirmationCode(email: string): Promise<void> {
        const command = new ResendConfirmationCodeCommand({
            ClientId: this.clientId,
            Username: email,
        });

        await this.client.send(command);
    }

    async getCurrentUser(accessToken: string): Promise<{
        username?: string;
        attributes: UserAttributes;
    }> {
        const command = new GetUserCommand({
            AccessToken: accessToken,
        });

        const response = await this.client.send(command);

        const attributes: UserAttributes = {};
        response.UserAttributes?.forEach((attr) => {
            if (attr.Name && attr.Value) {
                attributes[attr.Name] = attr.Value;
            }
        });

        return {
            username: response.Username,
            attributes,
        };
    }

    async adminGetUser(username: string): Promise<{
        username?: string;
        userStatus?: string;
        enabled?: boolean;
        attributes: UserAttributes;
    }> {
        const command = new AdminGetUserCommand({
            UserPoolId: this.userPoolId,
            Username: username,
        });

        const response = await this.client.send(command);

        const attributes: UserAttributes = {};
        response.UserAttributes?.forEach((attr) => {
            if (attr.Name && attr.Value) {
                attributes[attr.Name] = attr.Value;
            }
        });

        return {
            username: response.Username,
            userStatus: response.UserStatus,
            enabled: response.Enabled,
            attributes,
        };
    }

    async adminUpdateUserAttributes(
        username: string,
        attributes: UserAttributes
    ): Promise<void> {
        const userAttributes: AttributeType[] = Object.entries(attributes).map(([key, value]) => ({
            Name: key,
            Value: value,
        }));

        const command = new AdminUpdateUserAttributesCommand({
            UserPoolId: this.userPoolId,
            Username: username,
            UserAttributes: userAttributes,
        });

        await this.client.send(command);
    }

    async adminAddUserToGroup(username: string, groupName: string): Promise<void> {
        const command = new AdminAddUserToGroupCommand({
            UserPoolId: this.userPoolId,
            Username: username,
            GroupName: groupName,
        });

        await this.client.send(command);
    }

    async adminRemoveUserFromGroup(username: string, groupName: string): Promise<void> {
        const command = new AdminRemoveUserFromGroupCommand({
            UserPoolId: this.userPoolId,
            Username: username,
            GroupName: groupName,
        });

        await this.client.send(command);
    }

    async globalSignOut(accessToken: string): Promise<void> {
        const command = new GlobalSignOutCommand({
            AccessToken: accessToken,
        });

        await this.client.send(command);
    }

    async forgotPassword(email: string): Promise<void> {
        const command = new ForgotPasswordCommand({
            ClientId: this.clientId,
            Username: email,
        });

        await this.client.send(command);
    }

    async confirmForgotPassword(
        email: string,
        code: string,
        newPassword: string
    ): Promise<void> {
        const command = new ConfirmForgotPasswordCommand({
            ClientId: this.clientId,
            Username: email,
            ConfirmationCode: code,
            Password: newPassword,
        });

        await this.client.send(command);
    }

    async refreshToken(refreshToken: string): Promise<SignInResult> {
        const params: InitiateAuthCommandInput = {
            AuthFlow: 'REFRESH_TOKEN_AUTH',
            ClientId: this.clientId,
            AuthParameters: {
                REFRESH_TOKEN: refreshToken,
            },
        };

        const command = new InitiateAuthCommand(params);
        const response = await this.client.send(command);

        return {
            accessToken: response.AuthenticationResult?.AccessToken,
            idToken: response.AuthenticationResult?.IdToken,
            expiresIn: response.AuthenticationResult?.ExpiresIn,
        };
    }
}

export function getAuthService(): CognitoAuthService {
    return CognitoAuthService.getInstance();
}
