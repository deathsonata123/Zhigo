// Export all utilities
export * from './utils';
export * from './data';
export * from './menu-categories';
export * from './analyticsExport';

// Export new client libraries (replacing Amplify)
export { authClient, AuthClient } from './clients/auth-client';
export { dataClient, DataClient } from './clients/data-client';
export { storageClient, StorageClient } from './clients/storage-client';

export type {
    SignInParams,
    SignUpParams,
    AuthTokens,
    User,
} from './clients/auth-client';
