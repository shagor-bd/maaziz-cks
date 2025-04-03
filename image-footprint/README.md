# Image Footprint

For the CKS exam, understanding container image footprint (size and composition) is crucial for security. Here are practice examples focusing on minimizing image footprint and security implications.

In Docker, every instruction in a Dockerfile (like ADD, RUN, and COPY) creates a new layer in the image.

### 1. The Go Application (`app.go`)
This Go program continuously prints the current system username and UID every second.

#### Code Breakdown:
```go
package main

import (
    "fmt"
    "time"
    "os/user"
)

func main() {
    user, err := user.Current()
    if err != nil {
        panic(err)
    }

    for {
        fmt.Println("user: " + user.Username + " id: " + user.Uid)
        time.Sleep(1 * time.Second)
    }
}
```
- It uses the `os/user` package to get the current user info.
- The program runs in an infinite loop, printing the username and UID every second.

---

### 2. The Dockerfile(s)
Your Dockerfile(s) contain multiple multi-stage builds. Let’s go through them one by one.

#### **Stage 1: Build Stage (Ubuntu Base)**
```dockerfile
# build container stage 1
FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y golang-go=2:1.13~1ubuntu2
COPY app.go .
RUN pwd
RUN CGO_ENABLED=0 go build app.go
```

##### What it does:
1. **Base Image:** Uses Ubuntu 20.04.
2. **Environment Setting:** Sets `DEBIAN_FRONTEND=noninteractive` to avoid interactive prompts.
3. **Install Go:** Uses `apt-get` to install Go (specific version).
4. **Copy Source Code:** Copies `app.go` into the container.
5. **Build the Go App:** Uses `CGO_ENABLED=0` to create a static binary, avoiding C dependencies.

---

#### **Stage 2: Production Stage (Alpine Base)**
```dockerfile
# app container stage 2
FROM alpine:3.12.0
RUN addgroup -S appgroup && adduser -S appuser -G appgroup -h /home/appuser
COPY --from=0 /app /home/appuser/
USER appuser
CMD ["/home/appuser/app"]
```

##### What it does:
1. **Base Image:** Uses Alpine 3.12.0 (minimalist, lightweight).
2. **User Management:** Creates a non-root user (`appuser`) and group (`appgroup`).
3. **Copy the Binary:** Retrieves the compiled binary from the first stage.
4. **Run as Non-Root:** Switches to `appuser`.
5. **Execution:** Runs the compiled Go application.

---

### Repeating Stages with Variations
The file you shared has several repeated multi-stage builds with minor differences. Let's outline these differences:

1. **Permissions on `/etc`**
   ```dockerfile
   RUN chmod a-w /etc
   ```
   - This restricts write permissions on the `/etc` directory for security.

2. **Removing Binary Files**
   ```dockerfile
   RUN rm -rf /bin/*
   ```
   - Removes all files from `/bin`, making the container leaner and more secure.

---

### Why So Many Variants?
1. **Experimentation:** Trying out different base images (Alpine versions).
2. **Security Hardening:** 
   - Removing `/bin` reduces attack vectors.
   - Making `/etc` non-writable ensures configuration integrity.
3. **User Safety:** Running the app as a non-root user minimizes potential damage if compromised.

---

### Why Use Multi-Stage Builds?
1. **Efficiency:** The final image is lightweight (Alpine), while the build process happens in a larger image (Ubuntu).
2. **Security:** Reduces the attack surface by including only the compiled binary in the final image.
3. **Separation of Concerns:** Keeps build dependencies separate from the runtime environment.

---

### Final Thoughts
Your setup seems like an iterative process where you are refining the Dockerfile to:
- Reduce image size.
- Enhance security.
- Ensure the application runs with the least privileges.
