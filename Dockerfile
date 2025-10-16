# Stage 1: Build
FROM node:20-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.10.0 --activate

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source code
COPY . .

# Build the project
RUN pnpm build

# Stage 2: Production
FROM node:20-alpine

# Install pnpm
RUN corepack enable && corepack prepare pnpm@10.10.0 --activate

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile

# Copy built files from builder stage
COPY --from=builder /app/dist ./dist

# Expose the default port
EXPOSE 3333

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3333

# Start the server in HTTP mode (not stdio mode)
CMD ["node", "dist/bin.js"]

