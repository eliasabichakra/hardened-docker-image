# Stage 1: Builder stage
FROM dhi.io/node:25-debian13-sfw-ent-dev AS builder

ARG NPM_TOKEN

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with npm token authentication
RUN if [ -n "$NPM_TOKEN" ]; then \
      npm set //registry.npmjs.org/:_authToken=$NPM_TOKEN && \
      npm install --production; \
    else \
      npm install --production --legacy-peer-deps || npm install --production; \
    fi

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
