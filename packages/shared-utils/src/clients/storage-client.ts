export class StorageClient {
    private baseUrl: string;
    private static instance: StorageClient;

    private constructor(baseUrl: string = '/api/storage') {
        this.baseUrl = baseUrl;
    }

    static getInstance(baseUrl?: string): StorageClient {
        if (!StorageClient.instance) {
            StorageClient.instance = new StorageClient(baseUrl);
        }
        return StorageClient.instance;
    }

    async upload(
        file: File,
        folder: string,
        onProgress?: (progress: number) => void
    ): Promise<string> {
        // Get presigned URL
        const { uploadUrl, key } = await this.getUploadUrl(
            file.name,
            file.type,
            folder
        );

        // Upload to S3 using presigned URL
        return new Promise((resolve, reject) => {
            const xhr = new XMLHttpRequest();

            xhr.upload.addEventListener('progress', (e) => {
                if (e.lengthComputable && onProgress) {
                    const progress = (e.loaded / e.total) * 100;
                    onProgress(progress);
                }
            });

            xhr.addEventListener('load', () => {
                if (xhr.status === 200) {
                    resolve(key);
                } else {
                    reject(new Error('Upload failed'));
                }
            });

            xhr.addEventListener('error', () => {
                reject(new Error('Upload failed'));
            });

            xhr.open('PUT', uploadUrl);
            xhr.setRequestHeader('Content-Type', file.type);
            xhr.send(file);
        });
    }

    async getUploadUrl(
        fileName: string,
        contentType: string,
        folder: string
    ): Promise<{ uploadUrl: string; key: string }> {
        const accessToken = typeof window !== 'undefined' ? localStorage.getItem('accessToken') : null;

        const response = await fetch(`${this.baseUrl}/upload-url`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                ...(accessToken && { 'Authorization': `Bearer ${accessToken}` }),
            },
            body: JSON.stringify({ fileName, contentType, folder }),
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to get upload URL');
        }

        const { data } = await response.json();
        return data;
    }

    async getDownloadUrl(key: string): Promise<string> {
        const accessToken = typeof window !== 'undefined' ? localStorage.getItem('accessToken') : null;

        const response = await fetch(`${this.baseUrl}/download-url`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                ...(accessToken && { 'Authorization': `Bearer ${accessToken}` }),
            },
            body: JSON.stringify({ key }),
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to get download URL');
        }

        const { data } = await response.json();
        return data.downloadUrl;
    }

    async delete(key: string): Promise<void> {
        const accessToken = typeof window !== 'undefined' ? localStorage.getItem('accessToken') : null;

        const response = await fetch(`${this.baseUrl}/delete`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
                ...(accessToken && { 'Authorization': `Bearer ${accessToken}` }),
            },
            body: JSON.stringify({ key }),
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to delete file');
        }
    }
}

// Export singleton instance
export const storageClient = StorageClient.getInstance();
