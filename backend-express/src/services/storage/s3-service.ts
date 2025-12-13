import {
    S3Client,
    PutObjectCommand,
    GetObjectCommand,
    DeleteObjectCommand,
    ListObjectsV2Command,
    HeadObjectCommand,
    type PutObjectCommandInput,
    type GetObjectCommandInput,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

export interface S3Config {
    region: string;
    bucketName: string;
}

export interface UploadOptions {
    contentType?: string;
    metadata?: Record<string, string>;
    acl?: 'private' | 'public-read';
}

export class S3StorageService {
    private client: S3Client;
    private bucketName: string;
    private static instance: S3StorageService | null = null;

    private constructor(config: S3Config) {
        this.client = new S3Client({ region: config.region });
        this.bucketName = config.bucketName;
    }

    static initialize(config: S3Config): S3StorageService {
        if (!S3StorageService.instance) {
            S3StorageService.instance = new S3StorageService(config);
        }
        return S3StorageService.instance;
    }

    static getInstance(): S3StorageService {
        if (!S3StorageService.instance) {
            throw new Error('Storage service not initialized. Call S3StorageService.initialize() first.');
        }
        return S3StorageService.instance;
    }

    async upload(
        key: string,
        body: Buffer | Uint8Array | string,
        options?: UploadOptions
    ): Promise<string> {
        const params: PutObjectCommandInput = {
            Bucket: this.bucketName,
            Key: key,
            Body: body,
            ContentType: options?.contentType,
            Metadata: options?.metadata,
            ACL: options?.acl || 'private',
        };

        const command = new PutObjectCommand(params);
        await this.client.send(command);

        return `s3://${this.bucketName}/${key}`;
    }

    async getUploadUrl(
        key: string,
        contentType: string,
        expiresIn: number = 3600
    ): Promise<string> {
        const command = new PutObjectCommand({
            Bucket: this.bucketName,
            Key: key,
            ContentType: contentType,
        });

        return await getSignedUrl(this.client, command, { expiresIn });
    }

    async getDownloadUrl(key: string, expiresIn: number = 3600): Promise<string> {
        const command = new GetObjectCommand({
            Bucket: this.bucketName,
            Key: key,
        });

        return await getSignedUrl(this.client, command, { expiresIn });
    }

    async download(key: string): Promise<Buffer> {
        const command = new GetObjectCommand({
            Bucket: this.bucketName,
            Key: key,
        });

        const response = await this.client.send(command);
        const stream = response.Body as any;

        return new Promise((resolve, reject) => {
            const chunks: Buffer[] = [];
            stream.on('data', (chunk: Buffer) => chunks.push(chunk));
            stream.on('error', reject);
            stream.on('end', () => resolve(Buffer.concat(chunks)));
        });
    }

    async delete(key: string): Promise<void> {
        const command = new DeleteObjectCommand({
            Bucket: this.bucketName,
            Key: key,
        });

        await this.client.send(command);
    }

    async list(prefix: string, maxKeys: number = 1000): Promise<string[]> {
        const command = new ListObjectsV2Command({
            Bucket: this.bucketName,
            Prefix: prefix,
            MaxKeys: maxKeys,
        });

        const response = await this.client.send(command);
        return response.Contents?.map((obj) => obj.Key || '') || [];
    }

    async exists(key: string): Promise<boolean> {
        try {
            const command = new HeadObjectCommand({
                Bucket: this.bucketName,
                Key: key,
            });
            await this.client.send(command);
            return true;
        } catch (error: any) {
            if (error.name === 'NotFound') {
                return false;
            }
            throw error;
        }
    }

    async getMetadata(key: string): Promise<Record<string, string>> {
        const command = new HeadObjectCommand({
            Bucket: this.bucketName,
            Key: key,
        });

        const response = await this.client.send(command);
        return response.Metadata || {};
    }

    generateKey(folder: string, userId: string, fileName: string): string {
        const timestamp = Date.now();
        const sanitizedFileName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
        return `${folder}/${userId}/${timestamp}_${sanitizedFileName}`;
    }
}

export function getStorageService(): S3StorageService {
    return S3StorageService.getInstance();
}
