# Use Ubuntu as base image
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set default port for Cloud Run
ENV PORT=8080

# Install required packages
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    openvpn \
    openssh-server \
    nginx \
    certbot \
    python3-certbot-nginx \
    ufw \
    fail2ban \
    && rm -rf /var/lib/apt/lists/*

# Set up firewall
RUN ufw default deny incoming && \
    ufw default allow outgoing && \
    ufw allow 8080/tcp

# Set up fail2ban
RUN mkdir -p /etc/fail2ban/filter.d
COPY fail2ban/jail.local /etc/fail2ban/jail.local
COPY fail2ban/sshd.conf /etc/fail2ban/filter.d/sshd.conf

# Set up OpenVPN
RUN mkdir -p /etc/openvpn/ccd
COPY openvpn/ /etc/openvpn/
RUN chmod +x /etc/openvpn/check.sh

# Set up SSH with enhanced security
RUN mkdir /var/run/sshd && \
    echo 'root:${ROOT_PASSWORD}' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#X11Forwarding yes/X11Forwarding no/' /etc/ssh/sshd_config && \
    sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config

# Set up Nginx for SSL/TLS
RUN mkdir -p /etc/nginx/conf.d
COPY nginx/default.conf /etc/nginx/conf.d/
RUN mkdir -p /etc/nginx/ssl

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the application
COPY . ./

# Create necessary directories and set permissions
RUN mkdir -p /var/log/openvpn && \
    touch /etc/openvpn/users && \
    chmod 600 /etc/openvpn/users && \
    mkdir -p /var/log/nginx && \
    touch /var/log/nginx/error.log && \
    touch /var/log/nginx/access.log

# Expose port 8080 for Cloud Run
EXPOSE 8080

# Start services
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Use tini for proper process management
RUN apt-get update && apt-get install -y tini
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/start.sh"] 