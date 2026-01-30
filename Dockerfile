# Stage 1: Builder (normal Alpine Node)
FROM node:25-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies
RUN npm install --production

# Copy application source
COPY server.js . 

# Stage 2: Runtime (DHI Alpine hardened)
FROM dhi.io/node:25-alpine3.22

WORKDIR /app

# Copy only what’s needed from builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js ./

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => { if (r.statusCode !== 200) process.exit(1) })"

# Start app
CMD ["node", "server.js"]
