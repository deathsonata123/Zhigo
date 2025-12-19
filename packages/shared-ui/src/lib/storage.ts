// packages/shared-ui/src/lib/storage.ts
// Storage utility to replace aws-amplify/storage with Express.js backend S3 calls

import { getStoredTokens } from './auth';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

export interface UploadDataParams {
    path: string;
    data: File | Blob;
    options?: {
        contentType?: string;
    };
}

export interface GetUrlParams {
    path: string;
    options?: {
        expiresIn?: number;
    };
}

export interface RemoveParams {
    path: string;
}

// Upload file to S3 via backend pre-signed URL
export const uploadData = async (params: UploadDataParams): Promise<void> => {
    const tokens = getStoredTokens();

    if (!tokens?.accessToken) {
        throw new Error('Authentication required for upload');
    }

    const { path, data, options } = params;
    const fileName = path.split('/').pop() || 'file';
    const folder = path.split('/').slice(0, -1).join('/') || 'uploads';
    const contentType = options?.contentType || (data instanceof File ? data.type : 'application/octet-stream');

    // Step 1: Get pre-signed upload URL from backend
    const urlResponse = await fetch(`${API_URL}/api/storage/upload-url`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${tokens.accessToken}`
        },
        body: JSON.stringify({
            fileName,
            contentType,
            folder
        })
    });

    if (!urlResponse.ok) {
        const error = await urlResponse.json();
        throw new Error(error.error || 'Failed to get upload URL');
    }

    const { data: { uploadUrl, key } } = await urlResponse.json();

    // Step 2: Upload file directly to S3 using pre-signed URL
    const uploadResponse = await fetch(uploadUrl, {
        method: 'PUT',
        headers: {
            'Content-Type': contentType
        },
        body: data
    });

    if (!uploadResponse.ok) {
        throw new Error('File upload failed');
    }
};

// Get download URL for S3 file
export const getUrl = async (params: GetUrlParams): Promise<{ url: { toString: () => string } }> => {
    const { path, options } = params;

    const response = await fetch(`${API_URL}/api/storage/download-url`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            key: path
        })
    });

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Failed to get download URL');
    }

    const { data: { downloadUrl } } = await response.json();

    return {
        url: {
            toString: () => downloadUrl
        }
    };
};

// Delete file from S3
export const remove = async (params: RemoveParams): Promise<void> => {
    const tokens = getStoredTokens();

    if (!tokens?.accessToken) {
        throw new Error('Authentication required for delete');
    }

    const { path } = params;

    const response = await fetch(`${API_URL}/api/storage/delete`, {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${tokens.accessToken}`
        },
        body: JSON.stringify({
            key: path
        })
    });

    if (!response.ok) {
        const error = await response.json();
        throw new Error(error.error || 'Failed to delete file');
    }
};
