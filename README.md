# VPN, SSH, WebSocket, and Telegram Bot Server

This Docker image provides a complete server with:
- OpenVPN server
- SSH server with SSL/TLS support
- WebSocket server (port 80 and 443)
- Telegram bot for user management
- SSL/TLS support for secure connections

## Prerequisites

1. Docker installed
2. SSL certificates (for HTTPS)
3. Telegram Bot Token (from @BotFather)
4. Domain name (for SSL/TLS)

## Configuration

1. Copy `.env.example` to `.env` and fill in your values:
```bash
cp .env.example .env
```

2. Edit the following files with your configuration:
   - `nginx/default.conf`: Update `your_domain.com` with your actual domain
   - `.env`: Add your Telegram bot token and other configurations

3. Place your SSL certificates in the correct location:
   - Certificate: `/etc/nginx/ssl/certificate.crt`
   - Private key: `/etc/nginx/ssl/private.key`

## Building the Docker Image

```bash
docker build -t vpn-server .
```

## Running the Container

```bash
docker run -d \
  --name vpn-server \
  -p 80:80 \
  -p 443:443 \
  -p 22:22 \
  -p 1194:1194/udp \
  --env-file .env \
  -v /path/to/ssl:/etc/nginx/ssl \
  vpn-server
```

## Telegram Bot Commands

- `/start` - Start the bot
- `/help` - Show available commands
- `/adduser <username> <password>` - Add new VPN user
- `/removeuser <username>` - Remove VPN user
- `/status` - Check service status

## Ports

- 80: HTTP and WebSocket
- 443: HTTPS and Secure WebSocket
- 22: SSH
- 1194: OpenVPN

## Security Notes

1. Change the default root password in the Dockerfile
2. Use strong passwords for all services
3. Keep your SSL certificates secure
4. Regularly update the system and dependencies

## Deployment to Cloud Run

1. Build the image:
```bash
docker build -t gcr.io/[YOUR_PROJECT_ID]/vpn-server .
```

2. Push to Google Container Registry:
```bash
docker push gcr.io/[YOUR_PROJECT_ID]/vpn-server
```

3. Deploy to Cloud Run:
```bash
gcloud run deploy vpn-server \
  --image gcr.io/[YOUR_PROJECT_ID]/vpn-server \
  --platform managed \
  --region [YOUR_REGION] \
  --allow-unauthenticated \
  --port 80,443,22,1194
```

Replace `[YOUR_PROJECT_ID]` with your Google Cloud project ID and `[YOUR_REGION]` with your desired region. 