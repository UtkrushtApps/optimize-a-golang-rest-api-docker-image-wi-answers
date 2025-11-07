# Solution Steps

1. Start by refactoring the Dockerfile to use a multi-stage build. The first stage uses the Golang alpine image to compile the binary; the second stage uses a minimal Alpine image for runtime.

2. In the build stage, install necessary build tools (git, ca-certificates if required), copy module files, download go modules, then copy the full source code and build the project to create the final binary.

3. In the runtime stage, create a non-root user and group, set up the /app directory, and ensure proper ownership and permissions.

4. Copy only the compiled binary (and any needed static assets or config files) into the runtime stage. Set permissions to restrict access and expose the server port (usually 8080).

5. Set the container's user to the non-root user. Add a HEALTHCHECK (using wget or curl) that hits the /healthz endpoint (adjust if the health endpoint is different).

6. Replace the ENTRYPOINT with the compiled binary.

7. Rewrite the docker-compose.yml: build from the Dockerfile, mount a named volume for /app/data for persistence, apply memory and CPU limits, and set the container user explicitly to match the Dockerfile.

8. In docker-compose, add a healthcheck matching the Dockerfile, use 'unless-stopped' restart policy, bind ports to localhost for better security, drop all Linux capabilities, enforce read-only file system, and use a tmpfs for /tmp.

9. Don't change application code or dependencies.

10. Confirm that all APIs, including persistent data, work as expected in the optimized setup.

