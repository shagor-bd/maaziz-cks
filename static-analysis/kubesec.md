# `kubesec` Practice Examples for CKS Exam Preparation

`kubesec` is a popular Kubernetes security scanner that evaluates your Kubernetes manifests against security best practices. Here are practical examples to help you prepare for the CKS exam:

## Basic Usage Examples

1. **Scan a single manifest file**:
```bash
kubesec scan pod.yaml
```

2. **Scan multiple files**:
```bash
kubesec scan deployment.yaml service.yaml
```

3. **Scan from stdin** (useful for piping):
```bash
kubectl get pod mypod -o yaml | kubesec scan -
```

4. **Scan from kubesec public api**

We can also send a request to a publicly hosted service using curl. The service is available at v2.kubsec.io. For instance, run:

```bash
curl -sSX POST --data-binary @"pod.yaml" https://v2.kubecsec.io/scan
```

## Practical Security Scenarios

### 1. Insecure Pod Example (to fix)
```yaml
# insecure-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: insecure-example
spec:
  containers:
  - name: nginx
    image: nginx:latest
    securityContext:
      privileged: true
      runAsUser: 0
```

**Scan it**:
```bash
kubesec scan insecure-pod.yaml
```

**Expected issues**:
- Privileged container
- Running as root (UID 0)

### 2. Secure Pod Example
```yaml
# secure-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-example
spec:
  securityContext:
    runAsNonRoot: true
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: nginx
    image: nginx:latest
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
```

**Scan it** to see passing checks:
```bash
kubesec scan secure-pod.yaml
```

### 3. Deployment Example with Security Issues
```yaml
# insecure-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: web
        image: myapp:latest
        ports:
        - containerPort: 8080
        securityContext:
          readOnlyRootFilesystem: false
```

**Scan and fix**:
1. First scan to identify issues
2. Add appropriate securityContext settings
3. Rescan to verify fixes

## Common Security Checks to Practice

1. **Privileged containers**:
   - Check: `privileged: true`
   - Fix: Set to `false` or remove

2. **Root user**:
   - Check: `runAsUser: 0`
   - Fix: Set `runAsNonRoot: true`

3. **Read-only root filesystem**:
   - Check: `readOnlyRootFilesystem: false`
   - Fix: Set to `true` and configure emptyDir volumes for writable areas

4. **Capabilities**:
   - Check: Missing `capabilities.drop: ["ALL"]`
   - Fix: Drop all capabilities and add only needed ones

## Exam-like Practice Tasks

1. **Task 1**: 
   - Given an insecure pod manifest, use kubesec to identify issues
   - Modify the manifest to pass all kubesec checks
   - Verify with `kubesec scan`

2. **Task 2**:
   - Create a deployment that:
     - Runs as non-root
     - Drops all capabilities
     - Uses read-only root filesystem
     - Prevents privilege escalation
   - Validate with kubesec

3. **Task 3**:
   - Scan all pods in a namespace using:
     ```bash
     kubectl get pods -n myns -o yaml | kubesec scan -
     ```
   - Identify the most critical issue and fix it

## Additional Tips for CKS

1. Combine with other tools:
   ```bash
   kubesec scan pod.yaml | jq '.[].scoring.critical'
   ```

2. Use with `kubectl` to scan running resources:
   ```bash
   kubectl get pod mypod -o yaml | kubesec scan -
   ```

3. Remember that in the actual exam, you may need to:
   - Fix security issues without kubesec
   - Use built-in tools like `kubectl audit` or manual inspection
   - Understand the security principles behind kubesec's checks


# Installing `kubesec` for Kubernetes Security Scanning

Here are several methods to install `kubesec`, the Kubernetes security scanner, which will help you prepare for the CKS exam:

## Method 1: Download Pre-built Binary (Recommended)

```bash
# For Linux
curl -sSL https://github.com/controlplaneio/kubesec/releases/download/v2.11.0/kubesec_linux_amd64.tar.gz | tar xz
sudo mv kubesec /usr/local/bin/

# Verify installation
kubesec version
```

## Method 2: Using Docker

```bash
# Run kubesec via Docker without installing
docker run -i controlplane/kubesec:v2.11.0 scan /dev/stdin < your-pod.yaml
```

## Verification

After installation, verify it works:

```bash
# Create a test pod file
cat <<EOF > test-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test
spec:
  containers:
  - name: test
    image: alpine
EOF

# Scan the test file
kubesec scan test-pod.yaml
```

## Usage Examples

1. **Scan a local manifest**:
   ```bash
   kubesec scan deployment.yaml
   ```

2. **Scan from kubectl output**:
   ```bash
   kubectl get pod my-pod -o yaml | kubesec scan -
   ```

3. **Scan with specific severity level**:
   ```bash
   kubesec scan test-pod.yaml --minimum-severity critical
   ```


