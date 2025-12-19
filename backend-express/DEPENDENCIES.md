# Backend Package.json Dependencies

Add these dependencies to `backend-express/package.json`:

```json
{
  "dependencies": {
    "@aws-sdk/client-cognito-identity-provider": "^3.525.0",
    "@aws-sdk/client-ses": "^3.525.0",
    "@aws-sdk/client-sns": "^3.525.0"
  }
}
```

Then run:
```bash
cd backend-express
npm install
```
