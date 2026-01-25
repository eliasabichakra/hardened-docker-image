# Stage 1: Builder stage
FROM dhi.io/node:25-debian13-sfw-ent-dev AS builder

ARG SOCKET_API_KEY

WORKDIR /app

# Copy package files
COPY package*.json ./

# Optional: log first 6 chars of the key to verify it is passed correctly
RUN if [ -n "$SOCKET_API_KEY" ]; then \
      echo "SOCKET_API_KEY provided: ${SOCKET_API_KEY:0:6}******"; \
    else \
      echo "No SOCKET_API_KEY provided"; \
    fi

# Install dependencies (this will trigger Socket scanning if key is valid)
RUN npm install --production


# Stage 2: Runtime stage (minimal)
FROM dhi.io/node:25-debian13-sfw-ent-dev

WORKDIR /app

# Copy only necessary files from builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./
COPY server.js .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start the application
CMD ["npm", "start"]
