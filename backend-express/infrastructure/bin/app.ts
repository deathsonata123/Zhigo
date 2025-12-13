#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { ZhigoCognitoStack } from '../lib/cognito-stack';
import { ZhigoStorageStack } from '../lib/storage-stack';

const app = new cdk.App();

// Get account and region from environment or use defaults
const env = {
    account: process.env.CDK_DEFAULT_ACCOUNT || '844646862066',
    region: process.env.CDK_DEFAULT_REGION || 'ap-southeast-1',
};

// Create Cognito Stack
new ZhigoCognitoStack(app, 'ZhigoCognitoStack', {
    env,
    description: 'Zhigo Food Delivery - Cognito User Pool for Authentication',
    tags: {
        Project: 'Zhigo',
        Environment: 'Production',
        ManagedBy: 'CDK',
    },
});

// Create Storage Stack
new ZhigoStorageStack(app, 'ZhigoStorageStack', {
    env,
    description: 'Zhigo Food Delivery - S3 Storage for Media Files',
    tags: {
        Project: 'Zhigo',
        Environment: 'Production',
        ManagedBy: 'CDK',
    },
});

app.synth();
