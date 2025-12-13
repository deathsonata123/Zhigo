import * as cdk from 'aws-cdk-lib';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

export class ZhigoStorageStack extends cdk.Stack {
    public readonly bucket: s3.Bucket;

    constructor(scope: Construct, id: string, props?: cdk.StackProps) {
        super(scope, id, props);

        // Create S3 Bucket
        this.bucket = new s3.Bucket(this, 'ZhigoStorageBucket', {
            bucketName: `zhigo-storage-${this.account}`,
            versioned: false,
            encryption: s3.BucketEncryption.S3_MANAGED,
            blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
            removalPolicy: cdk.RemovalPolicy.RETAIN, // Prevent accidental deletion
            autoDeleteObjects: false,
            cors: [
                {
                    allowedMethods: [
                        s3.HttpMethods.GET,
                        s3.HttpMethods.PUT,
                        s3.HttpMethods.POST,
                        s3.HttpMethods.DELETE,
                        s3.HttpMethods.HEAD,
                    ],
                    allowedOrigins: ['*'], // Update this with your actual domains in production
                    allowedHeaders: ['*'],
                    exposedHeaders: [
                        'ETag',
                        'x-amz-server-side-encryption',
                        'x-amz-request-id',
                        'x-amz-id-2',
                    ],
                    maxAge: 3000,
                },
            ],
            lifecycleRules: [
                {
                    id: 'delete-incomplete-uploads',
                    enabled: true,
                    abortIncompleteMultipartUploadAfter: cdk.Duration.days(7),
                },
            ],
        });

        // Add bucket policy to allow authenticated uploads
        // Note: In production, you should restrict this to specific IAM roles/users
        const bucketPolicy = new iam.PolicyStatement({
            effect: iam.Effect.ALLOW,
            principals: [new iam.AnyPrincipal()],
            actions: [
                's3:GetObject',
                's3:PutObject',
                's3:DeleteObject',
            ],
            resources: [this.bucket.arnForObjects('*')],
            conditions: {
                StringLike: {
                    'aws:Referer': [
                        'https://*.vercel.app/*',
                        'http://localhost:*',
                    ],
                },
            },
        });

        // Note: The above policy is commented out for now. You should configure
        // proper IAM roles for your EC2 instance or use presigned URLs from backend

        // Outputs
        new cdk.CfnOutput(this, 'BucketName', {
            value: this.bucket.bucketName,
            description: 'S3 Bucket Name',
            exportName: 'ZhigoStorageBucketName',
        });

        new cdk.CfnOutput(this, 'BucketArn', {
            value: this.bucket.bucketArn,
            description: 'S3 Bucket ARN',
            exportName: 'ZhigoStorageBucketArn',
        });

        new cdk.CfnOutput(this, 'BucketRegionalDomainName', {
            value: this.bucket.bucketRegionalDomainName,
            description: 'S3 Bucket Regional Domain Name',
            exportName: 'ZhigoStorageBucketDomain',
        });
    }
}
