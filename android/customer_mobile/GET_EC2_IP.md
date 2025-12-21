# How to Get Your EC2 IP Address

## Option 1: AWS Console
1. Go to https://console.aws.amazon.com/ec2
2. Click "Instances" in left sidebar
3. Find your instance
4. Copy the **Public IPv4 address** (e.g., `3.15.123.45`)

## Option 2: Command Line (if you have AWS CLI)
```bash
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[PublicIpAddress,State.Name]' --output table
```

## Option 3: SSH to EC2 and check
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
curl ifconfig.me
```

## After Getting Your IP

**Update `lib/config/api_config.dart` line 8:**

```dart
defaultValue: 'http://3.15.123.45:3000', // Replace with YOUR IP
```

**Important Notes:**
- Use `http://` not `https://` (no SSL configured yet)
- Include port `:3000`
- Make sure EC2 security group allows inbound traffic on port 3000
- EC2 instance must be running
- Backend must be started (`pm2 status` to check)

## Test Backend is Accessible
```bash
curl http://YOUR_EC2_IP:3000/health
# Should return: {"status":"ok"}
```
