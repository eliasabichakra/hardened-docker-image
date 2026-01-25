# Stage 1: Builder stage
FROM dhi.io/node:25-debian13-sfw-ent-dev AS builder

ARG SOCKET_API_KEY

WORKDIR /app

# Copy package files
COPY package*.json ./

# Optionally set the SOCKET_API_KEY if provided
# Disable Socket scanning by default
ENV SOCKET_DISABLE=1

# Install dependencies
RUN if [ -n "$SOCKET_API_KEY" ]; then \
      export SOCKET_API_KEY=$SOCKET_API_KEY; \
    fi && \
    npm install --production


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
