import * as cdk from 'aws-cdk-lib';
import * as cognito from 'aws-cdk-lib/aws-cognito';
import { Construct } from 'constructs';

export class ZhigoCognitoStack extends cdk.Stack {
    public readonly userPool: cognito.UserPool;
    public readonly userPoolClient: cognito.UserPoolClient;

    constructor(scope: Construct, id: string, props?: cdk.StackProps) {
        super(scope, id, props);

        // Create User Pool
        this.userPool = new cognito.UserPool(this, 'ZhigoUserPool', {
            userPoolName: 'zhigo-user-pool',
            selfSignUpEnabled: true,
            signInAliases: {
                email: true,
                username: false,
                phone: false,
            },
            autoVerify: {
                email: true,
            },
            standardAttributes: {
                email: {
                    required: true,
                    mutable: true,
                },
                givenName: {
                    required: false,
                    mutable: true,
                },
                familyName: {
                    required: false,
                    mutable: true,
                },
                phoneNumber: {
                    required: false,
                    mutable: true,
                },
            },
            customAttributes: {
                role: new cognito.StringAttribute({
                    mutable: true,
                    minLen: 1,
                    maxLen: 50,
                }),
                userId: new cognito.StringAttribute({
                    mutable: false,
                    minLen: 1,
                    maxLen: 256,
                }),
            },
            passwordPolicy: {
                minLength: 8,
                requireLowercase: true,
                requireUppercase: true,
                requireDigits: true,
                requireSymbols: false,
            },
            accountRecovery: cognito.AccountRecovery.EMAIL_ONLY,
            removalPolicy: cdk.RemovalPolicy.RETAIN, // Prevent accidental deletion
            mfa: cognito.Mfa.OPTIONAL,
            mfaSecondFactor: {
                sms: true,
                otp: true,
            },
        });

        // Create User Pool Client
        this.userPoolClient = new cognito.UserPoolClient(this, 'ZhigoUserPoolClient', {
            userPool: this.userPool,
            userPoolClientName: 'zhigo-app-client',
            authFlows: {
                userPassword: true,
                userSrp: true,
                custom: true,
            },
            generateSecret: false, // Set to false for mobile/web apps
            preventUserExistenceErrors: true,
            refreshTokenValidity: cdk.Duration.days(30),
            accessTokenValidity: cdk.Duration.hours(1),
            idTokenValidity: cdk.Duration.hours(1),
            enableTokenRevocation: true,
        });

        // Outputs
        new cdk.CfnOutput(this, 'UserPoolId', {
            value: this.userPool.userPoolId,
            description: 'Cognito User Pool ID',
            exportName: 'ZhigoUserPoolId',
        });

        new cdk.CfnOutput(this, 'UserPoolArn', {
            value: this.userPool.userPoolArn,
            description: 'Cognito User Pool ARN',
            exportName: 'ZhigoUserPoolArn',
        });

        new cdk.CfnOutput(this, 'UserPoolClientId', {
            value: this.userPoolClient.userPoolClientId,
            description: 'Cognito User Pool Client ID',
            exportName: 'ZhigoUserPoolClientId',
        });

        new cdk.CfnOutput(this, 'Region', {
            value: this.region,
            description: 'AWS Region',
            exportName: 'ZhigoRegion',
        });
    }
}
