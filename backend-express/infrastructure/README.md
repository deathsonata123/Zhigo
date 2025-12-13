# Zhigo Infrastructure (AWS CDK)

This directory contains AWS CDK code for provisioning Zhigo's cloud infrastructure.

## 📦 What This Creates

### Cognito Stack (`ZhigoCognitoStack`)
- **User Pool**: For authentication across all apps
- **User Pool Client**: For app integration
- **Custom Attributes**: `role` (customer/rider/restaurant/admin) and `userId`
- **Email Verification**: Enabled by default
- **MFA**: Optional (SMS and OTP)

### Storage Stack (`ZhigoStorageStack`)
- **S3 Bucket**: For storing images, documents, and media
- **CORS Configuration**: Allows uploads from web apps
- **Lifecycle Rules**: Auto-delete incomplete multipart uploads after 7 days
- **Encryption**: Server-side encryption enabled

## 🚀 Usage

### Prerequisites
```bash
npm install
```

### Bootstrap (First Time Only)
```bash
cdk bootstrap aws://YOUR_ACCOUNT_ID/YOUR_REGION
```

### Deploy Both Stacks
```bash
cdk deploy --all
```

### Deploy Individual Stacks
```bash
# Deploy Cognito only
cdk deploy ZhigoCognitoStack

# Deploy Storage only
cdk deploy ZhigoStorageStack
```

### View Changes Before Deploying
```bash
cdk diff
```

### Destroy Stacks (⚠️ DANGEROUS)
```bash
cdk destroy --all
```

## 📝 Outputs

After deployment, you'll get these outputs:

**From Cognito Stack:**
- `UserPoolId`: Use in backend `.env` as `COGNITO_USER_POOL_ID`
- `UserPoolClientId`: Use in backend `.env` as `COGNITO_CLIENT_ID`
- `Region`: AWS region

**From Storage Stack:**
- `BucketName`: Use in backend `.env` as `S3_BUCKET_NAME`
- `BucketArn`: Full ARN of the bucket
- `BucketRegionalDomainName`: S3 endpoint

## 🔧 Update Backend Environment

After deploying, update `backend-express/.env`:

```env
# From Cognito Stack outputs
COGNITO_USER_POOL_ID=ap-southeast-1_XXXXX
COGNITO_CLIENT_ID=xxxxxxxxxxxxx
AWS_REGION=ap-southeast-1

# From Storage Stack outputs
S3_BUCKET_NAME=zhigo-storage-844646862066
```

## 💰 Cost Estimate

- **Cognito**: Free for first 50,000 users
- **S3**: ~$0.023/GB storage + transfer costs
- **Total**: ~$2-5/month (depends on usage)

## 🛡️ Security

- All resources use AWS best practices
- S3 bucket has no public access
- Cognito enforces strong password policy
- Resources have `RETAIN` removal policy to prevent accidental deletion

## 📚 Learn More

- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
