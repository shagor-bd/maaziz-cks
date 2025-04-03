# Kubernetes CKS Exam: Kubelinter Practice Examples

Kubelinter is a static analysis tool that checks Kubernetes YAML files and Helm charts for security best practices and misconfigurations. Here are some practice examples that will help you prepare for the CKS exam:

## Install 

Download the latest version of KubeLinter for Linux using the command below:
```bash
curl -LO https://github.com/stackrox/kube-linter/releases/latest/download/kube-linter-linux.tar.gz
```
Extract the binary from the tar file:
```bash
tar -xvf kube-linter-linux.tar.gz
```
Move the binary to the /usr/local/bin/ path:
```bash
mv kube-linter /usr/local/bin/
```

## Example 1: Privileged Container Check

```yaml
# privileged-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      privileged: true
```

**Task**: Fix this manifest to pass kubelinter checks for privileged containers.

## Example 2: Missing Resource Limits

```yaml
# no-limits-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: no-limits-pod
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
```

**Task**: Add appropriate resource requests and limits to this pod specification.

## Example 3: Host Network Access

```yaml
# host-network-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: host-network-pod
spec:
  hostNetwork: true
  containers:
  - name: nginx
    image: nginx
```

**Task**: Modify this pod to avoid using host networking unless absolutely necessary.

## Example 4: RunAsRoot Check

```yaml
# run-as-root.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: run-as-root
spec:
  replicas: 1
  selector:
    matchLabels:
      app: run-as-root
  template:
    metadata:
      labels:
        app: run-as-root
    spec:
      containers:
      - name: nginx
        image: nginx
```

**Task**: Add securityContext to prevent running as root user.

## Example 5: Missing Liveness Probe

```yaml
# no-probes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: no-probes
spec:
  replicas: 1
  selector:
    matchLabels:
      app: no-probes
  template:
    metadata:
      labels:
        app: no-probes
    spec:
      containers:
      - name: nginx
        image: nginx
```

**Task**: Add liveness and readiness probes to this deployment.

## Example 6: Dangerous Capabilities

```yaml
# dangerous-capabilities.yaml
apiVersion: v1
kind: Pod
metadata:
  name: dangerous-capabilities
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_ADMIN"]
```

**Task**: Remove dangerous capabilities or justify their need with proper documentation.

## Example 7: Default Namespace Usage

```yaml
# default-namespace.yaml
apiVersion: v1
kind: Service
metadata:
  name: default-namespace-service
spec:
  selector:
    app: myapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

**Task**: Move this service to a non-default namespace.

## Example 8: Ingress Without TLS

```yaml
# no-tls-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: no-tls-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

**Task**: Add TLS configuration to this ingress resource.

## Practice Instructions

1. For each example, try to identify what kubelinter would flag
2. Modify the YAML to address the issues
3. Validate your changes by running:
   ```bash
   kube-linter lint <your-file.yaml>
   ```
4. Consider additional security best practices beyond what kubelinter checks

Remember that for the CKS exam, you'll need to not only fix these issues but understand why they're important for cluster security.

## Lets check `no-probes.yaml` 

```bash
kube-linter lint no-probes.yaml
```
- Output:
```plaintext
KubeLinter 0.7.2

/home/shagorbd/Git/maaziz-cks/static-analysis/no-probes.yaml: (object: <no namespace>/no-probes apps/v1, Kind=Deployment) The container "nginx" is using an invalid container image, "nginx". Please use images that are not blocked by the `BlockList` criteria : [".*:(latest)$" "^[^:]*$" "(.*/[^:]+)$"] (check: latest-tag, remediation: Use a container image with a specific tag other than latest.)

/home/shagorbd/Git/maaziz-cks/static-analysis/no-probes.yaml: (object: <no namespace>/no-probes apps/v1, Kind=Deployment) container "nginx" does not have a read-only root file system (check: no-read-only-root-fs, remediation: Set readOnlyRootFilesystem to true in the container securityContext.)

/home/shagorbd/Git/maaziz-cks/static-analysis/no-probes.yaml: (object: <no namespace>/no-probes apps/v1, Kind=Deployment) container "nginx" is not set to runAsNonRoot (check: run-as-non-root, remediation: Set runAsUser to a non-zero number and runAsNonRoot to true in your pod or container securityContext. Refer to https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ for details.)

/home/shagorbd/Git/maaziz-cks/static-analysis/no-probes.yaml: (object: <no namespace>/no-probes apps/v1, Kind=Deployment) container "nginx" has cpu request 0 (check: unset-cpu-requirements, remediation: Set CPU requests for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

/home/shagorbd/Git/maaziz-cks/static-analysis/no-probes.yaml: (object: <no namespace>/no-probes apps/v1, Kind=Deployment) container "nginx" has memory limit 0 (check: unset-memory-requirements, remediation: Set memory limits for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

Error: found 5 lint errors
```

## Lets fixed the issue.

```yaml
# no-probes.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: no-probes
spec:
  replicas: 1
  selector:
    matchLabels:
      app: no-probes
  template:
    metadata:
      labels:
        app: no-probes
    spec:
      containers:
      - name: nginx
        image: nginx:1.25.3-alpine        # Chagne 
        resources:                        # Added
          requests:                       # Added
            cpu: "100m"                   # Added
            memory: 128Mi                 # Added
          limits:                         # Added
            cpu: "200m"                   # Added      
            memory: 256Mi                 # Added
        securityContext:                  # Added
          readOnlyRootFilesystem: true    # Added
          runAsNonRoot: true              # Added
```

```bash
kube-linter lint no-probes.yaml 
```
- Output
```plaintext
KubeLinter 0.7.2

No lint errors found!
```

