# Simple Vite dev server setup
FROM node:18-alpine

WORKDIR /app

# Change Alpine mirror to avoid SSL issues
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories

# Install system dependencies needed for some npm packages
RUN apk update && apk add --no-cache python3 make g++ git curl ca-certificates

# SSL certificate fix for WSL2/Docker - disable strict SSL
RUN npm config set strict-ssl false && \
    npm config set registry http://registry.npmjs.org/

# Copy package files
COPY package*.json ./

# Install dependencies including dev dependencies for testing
RUN npm ci

# Create coverage directory with proper permissions
RUN mkdir -p /app/coverage && chmod 777 /app/coverage

# Copy source code
COPY . .

# Expose Vite's default port
EXPOSE 5173

# Start Vite dev server with host binding for Docker
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"] 