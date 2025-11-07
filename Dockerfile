########################
# Stage 1: Build
FROM golang:1.21-alpine AS builder

# Install git, and ca-certificates if needed
RUN apk add --no-cache git

# Set build env vars
ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /app

# Copy go module files and download modules
COPY go.mod go.sum ./
RUN go mod download

# Copy the full source code
COPY . .

# Build the binary (replace main.go if your entrypoint is different)
RUN go build -o server .

########################
# Stage 2: Runner
FROM alpine:3.19

# Create a non-root user and group (uid:gid=10001)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup -u 10001

WORKDIR /app

# Create data directory, set ownership
RUN mkdir -p /app/data && chown appuser:appgroup /app/data

# Copy binary from builder
COPY --from=builder /app/server /app/server

# Copy static assets or config files if needed
# COPY --from=builder /app/static /app/static
# COPY --from=builder /app/config.yaml /app/config.yaml

# Change ownership (if more needed)
RUN chown appuser:appgroup /app/server

# Set permissions (optional, for even more restriction)
RUN chmod 750 /app/server

# Listen on port 8080 (change if your app uses a different port)
EXPOSE 8080

# Use non-root user
USER appuser

# Healthcheck: assumes "/healthz" endpoint, adjust as needed
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/healthz || exit 1

# Start the API
ENTRYPOINT ["/app/server"]
