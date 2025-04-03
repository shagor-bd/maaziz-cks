# Scan images for known vulnerabilities Trivy

## Install Trivy 

### Installing Trivy on Debian-based Systems

```bash
 sudo apt-get install wget apt-transport-https gnupg lsb-release
 wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
 echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
 sudo apt-get update
 sudo apt-get install trivy
```

### Run Trivy as a Docker container (recommended for quick use):
```bash
docker pull aquasec/trivy:latest
```

### Install Trivy directly on your host system:
```bash
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
```

## Basic Scanning Commands

### Scan a Docker image:
```bash
docker pull nginx:latest  # First pull the image you want to scan
trivy image nginx:latest  
```
### Scan results can be save in file
```bash
trivy image public.ecr.aws/docker/library/python:3.12.4 -o /root/python_12.txt
#OR
trivy image --output /root/python_12.txt public.ecr.aws/docker/library/python:3.12.4
```

### Or using Docker container:
```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image nginx:latest
```

## Practical Examples

### 1. Scan with severity filtering:
```bash
#For help
trivy image --help | grep -i sev
#Output
# # Filter by severities
#  $ trivy image --severity HIGH,CRITICAL alpine:3.15
#  -s, --severity strings           severities of security issues to be displayed
#      --vuln-severity-source strings   order of data sources for selecting vulnerability severity level

trivy image --severity HIGH,CRITICAL nginx:latest
```

### 2. Scan and output JSON report:
```bash
trivy image -f json -o results.json nginx:latest
#For image tar file scan, for help run help $ trivy image --help | grep json
trivy image --format json --output alpine.json --input alpine.tar 
```

### 3. Scan a local image (not in Docker Hub):
```bash
docker build -t myapp:test .
trivy image myapp:test
```

### 4. Scan a running container:
```bash
docker run -d --name test-nginx nginx:latest
trivy container test-nginx
```

### 5. Scan with vulnerability database update:
```bash
trivy image --download-db-only  # Update DB first
trivy image nginx:latest
```

## Advanced Usage

### 1. Scan with ignore file:
```bash
trivy image --ignorefile .trivyignore nginx:latest
```

### 2. Scan for OS packages only:
```bash
trivy image --security-checks vuln nginx:latest
```

### 3. Scan for misconfigurations in Dockerfiles:
```bash
trivy config --security-checks config ./Dockerfile
```

### 4. Scan with timeout setting:
```bash
trivy image --timeout 10m nginx:latest
```

## Integration with Docker Build

### 1. As a build step:
```Dockerfile
FROM alpine:latest AS builder
RUN apk add --no-cache curl
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

FROM your-base-image
COPY --from=builder /usr/local/bin/trivy /usr/local/bin/trivy
RUN trivy filesystem --security-checks vuln --no-progress /
```

### 2. In CI/CD pipelines:
```yaml
# Example GitHub Action step
- name: Scan image with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: 'myapp:latest'
    format: 'table'
    exit-code: '1'
    severity: 'CRITICAL,HIGH'
```

## Tips for CKS Exam Preparation

1. Practice scanning different types of images (Alpine, Ubuntu, Distroless)
2. Learn to interpret the scan results
3. Understand how to fix common vulnerabilities
4. Remember that in the actual exam, you may need to:
   - Manually inspect images for vulnerabilities
   - Use built-in tools rather than Trivy
   - Apply security contexts based on vulnerability knowledge

Would you like me to provide specific examples of vulnerability remediation based on Trivy scan results?