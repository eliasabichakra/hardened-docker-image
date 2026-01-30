# Stage 1: Builder
FROM dhi.io/node:25-alpine3.22 AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production dependencies
RUN npm install --production

# Stage 2: Runtime (minimal Alpine)
FROM dhi.io/node:25-alpine3.22

WORKDIR /app

# Copy only what’s needed
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
COPY server.js .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => { if (r.statusCode !== 200) process.exit(1) })"

# Start app (avoid npm in runtime if you want extra hardening)
CMD ["node", "server.js"]
