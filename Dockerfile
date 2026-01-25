# Stage 1: Builder stage
FROM dhi.io/node:25-debian13-sfw-ent-dev AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production && \
    npm cache clean --force

# Stage 2: Runtime stage (minimal)
FROM dhi.io/node:25-debian13-sfw-ent-dev

WORKDIR /app

# Create non-root user for security
RUN useradd -m -u 1000 appuser

# Copy only necessary files from builder stage
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --chown=appuser:appuser package*.json ./
COPY --chown=appuser:appuser server.js .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start the application
CMD ["npm", "start"]
