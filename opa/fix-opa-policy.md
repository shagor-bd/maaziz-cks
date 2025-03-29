Below are **some practice questions** where you need to **fix broken OPA policies**—similar to what we might encounter in the **CKS exam**. Try to debug them first, then check the solutions and explanations.  

---

## **Bonus: Fixing a Broken OPA Policy (Exam-Style Question)**
**Problem**: The following policy is supposed to block `hostNetwork: true`, but it doesn’t work. Fix it.  

### **Broken Policy**
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: blockhostnetwork
spec:
  crd:
    spec:
      names:
        kind: BlockHostNetwork
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package blockhostnetwork
        violation[{"msg": msg}] {
          input.hostNetwork == true
          msg := "hostNetwork is not allowed"
        }
```

### **Solution (Fixed Policy)**
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: blockhostnetwork
spec:
  crd:
    spec:
      names:
        kind: BlockHostNetwork
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package blockhostnetwork
        violation[{"msg": msg}] {
          input.review.object.spec.hostNetwork == true
          msg := "hostNetwork is not allowed"
        }
```
**Why it was broken**:  
- The original policy checked `input.hostNetwork`, but the correct path is `input.review.object.spec.hostNetwork`.  

---




## **Practice Question 1: Block Privileged Containers (Broken Policy)**
### **Scenario**:  
This policy is supposed to block privileged containers (`securityContext.privileged: true`), but it’s not working.  

### **Broken Policy**:
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: blockprivileged
spec:
  crd:
    spec:
      names:
        kind: BlockPrivileged
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package blockprivileged
        violation[{"msg": msg}] {
          input.privileged == true
          msg := "Privileged containers are not allowed"
        }
```

### **Your Task**:  
Identify and fix the bug(s).  

---

## **Practice Question 2: Enforce Resource Limits (Broken Policy)**
### **Scenario**:  
This policy should enforce CPU/memory limits on containers, but it’s not blocking Pods without limits.  

### **Broken Policy**:
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: resourcelimits
spec:
  crd:
    spec:
      names:
        kind: ResourceLimits
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package resourcelimits
        violation[{"msg": msg}] {
          container := input.containers[_]
          not container.limits
          msg := "Container must have CPU/memory limits"
        }
```

### **Your Task**:  
Fix the policy so it correctly checks `spec.containers[].resources.limits`.  

---

## **Practice Question 3: Restrict Image Registries (Broken Policy)**
### **Scenario**:  
This policy should only allow images from `docker.io`, but it’s rejecting all images.  

### **Broken Policy**:
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: allowedregistries
spec:
  crd:
    spec:
      names:
        kind: AllowedRegistries
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package allowedregistries
        violation[{"msg": msg}] {
          container := input.review.object.containers[_]
          not startswith(container.image, "docker.io/")
          msg := "Only images from docker.io are allowed"
        }
```

### **Your Task**:  
Fix the policy to correctly validate image sources.  

---

## **Solutions & Explanations**  
### **Solution 1: Block Privileged Containers (Fixed)**
#### **Issue**:  
The policy checks `input.privileged` instead of the correct path:  
`input.review.object.spec.containers[_].securityContext.privileged`.  

#### **Fixed Policy**:
```yaml
rego: |
  package blockprivileged
  violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    container.securityContext.privileged == true
    msg := "Privileged containers are not allowed"
  }
```

---

### **Solution 2: Enforce Resource Limits (Fixed)**
#### **Issue**:  
The policy checks `input.containers` instead of `input.review.object.spec.containers`. Also, it should check `resources.limits`.  

#### **Fixed Policy**:
```yaml
rego: |
  package resourcelimits
  violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    not container.resources.limits
    msg := "Container must have CPU/memory limits"
  }
```

---

### **Solution 3: Restrict Image Registries (Fixed)**
#### **Issue**:  
The policy checks `input.review.object.containers` (wrong path) and misses `spec`.  

#### **Fixed Policy**:
```yaml
rego: |
  package allowedregistries
  violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    not startswith(container.image, "docker.io/")
    msg := "Only images from docker.io are allowed"
  }
```

---

## **Key Debugging Tips for CKS Exam**  
1. **Check Paths Carefully**:  
   - Most policies fail because of incorrect paths (e.g., `input.review.object.spec.containers` vs `input.containers`).  
2. **Test Policies in Dry-Run Mode**:  
   ```sh
   kubectl apply -f constraint.yaml --dry-run=server
   ```
3. **Common Mistakes**:  
   - Forgetting `spec` in paths.  
   - Misspelling (e.g., `containers` vs `containers`).  
   - Incorrect Rego logic (e.g., `not startswith` vs `startswith`).  

---

### **Final Challenge (Bonus Question)**  
**Scenario**: This policy should block `hostNetwork: true`, but it’s not working. Fix it:  
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: blockhostnetwork
spec:
  crd:
    spec:
      names:
        kind: BlockHostNetwork
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package blockhostnetwork
        violation[{"msg": msg}] {
          input.hostNetwork == true
          msg := "hostNetwork is not allowed"
        }
```

**Your Task**: Fix the policy.  

**Solution**:  
```yaml
rego: |
  package blockhostnetwork
  violation[{"msg": msg}] {
    input.review.object.spec.hostNetwork == true
    msg := "hostNetwork is not allowed"
  }
```

---

Absolutely! Below is a **mock CKS exam-style scenario** with **complex OPA/Gatekeeper policies** that you might encounter. This includes **multiple constraints**, **real-world security requirements**, and **intentional bugs** for you to fix.  

---

# **Mock CKS Exam: OPA/Gatekeeper Policy Challenge**  
**Time: 15 minutes**  

### **Scenario**:  
You are a Kubernetes security engineer at a company that enforces strict security policies. Your team uses **OPA Gatekeeper** to restrict deployments.  

#### **Cluster Requirements**:  
1. **No privileged containers** (securityContext.privileged: true).  
2. **All containers must have resource limits** (CPU/memory).  
3. **Only approved registries** (`docker.io`, `gcr.io`).  
4. **No hostPath volumes** (prevent host filesystem access).  
5. **Pods must have a `runAsNonRoot: true`** securityContext.  

#### **Problem**:  
Your team deployed the following **ConstraintTemplates** and **Constraints**, but some policies **are not working**.  

---

## **Task 1: Debug & Fix the Broken Policies**  
### **Broken Policy 1: Block Privileged Containers**  
**Expected**: Should reject Pods with `privileged: true`.  
**Actual**: Allows privileged Pods.  

#### **ConstraintTemplate**  
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: blockprivileged
spec:
  crd:
    spec:
      names:
        kind: BlockPrivileged
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package blockprivileged
        violation[{"msg": msg}] {
          input.privileged == true
          msg := "Privileged containers are not allowed"
        }
```

#### **Constraint**  
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: BlockPrivileged
metadata:
  name: no-privileged-containers
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

### **Your Task**:  
- **Identify the bug**: What’s wrong with the Rego rule?  
- **Fix the policy** so it correctly blocks privileged containers.  

---

### **Broken Policy 2: Enforce Resource Limits**  
**Expected**: Should reject Pods without CPU/memory limits.  
**Actual**: Allows Pods with no limits.  

#### **ConstraintTemplate**  
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: resourcelimits
spec:
  crd:
    spec:
      names:
        kind: ResourceLimits
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package resourcelimits
        violation[{"msg": msg}] {
          container := input.containers[_]
          not container.limits
          msg := "Container must have CPU/memory limits"
        }
```

#### **Constraint**  
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: ResourceLimits
metadata:
  name: require-resource-limits
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

### **Your Task**:  
- **Why is this policy failing**?  
- **Fix the Rego rule** to check `spec.containers[].resources.limits`.  

---

### **Broken Policy 3: Restrict Image Registries**  
**Expected**: Should only allow images from `docker.io` or `gcr.io`.  
**Actual**: Rejects all images, even allowed ones.  

#### **ConstraintTemplate**  
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: allowedregistries
spec:
  crd:
    spec:
      names:
        kind: AllowedRegistries
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package allowedregistries
        allowed_registries := ["docker.io", "gcr.io"]
        violation[{"msg": msg}] {
          container := input.review.object.containers[_]
          not startswith(container.image, allowed_registries[_])
          msg := sprintf("Image %v is not from an allowed registry", [container.image])
        }
```

#### **Constraint**  
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: AllowedRegistries
metadata:
  name: only-approved-registries
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

### **Your Task**:  
- **Find the typo** in the Rego policy.  
- **Fix the registry validation logic**.  

---

## **Task 2: Write a New Policy from Scratch**  
### **New Requirement**:  
- **Pods must run as non-root** (`securityContext.runAsNonRoot: true`).  

### **Your Task**:  
Write a **ConstraintTemplate** and **Constraint** to enforce this rule.  

---

## **Solutions**  

### **Solution 1: Block Privileged Containers (Fixed)**  
#### **Bug**:  
- Incorrect path (`input.privileged` → should be `input.review.object.spec.containers[_].securityContext.privileged`).  

#### **Fixed Rego**:  
```yaml
rego: |
  package blockprivileged
  violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    container.securityContext.privileged == true
    msg := "Privileged containers are not allowed"
  }
```

---

### **Solution 2: Enforce Resource Limits (Fixed)**  
#### **Bug**:  
- Wrong path (`input.containers` → should be `input.review.object.spec.containers[_].resources.limits`).  

#### **Fixed Rego**:  
```yaml
rego: |
  package resourcelimits
  violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    not container.resources.limits
    msg := "Container must have CPU/memory limits"
  }
```

---

### **Solution 3: Restrict Image Registries (Fixed)**  
#### **Bug**:  
1. Typo (`containers` misspelled as `containers`).  
2. Logic error: `startswith` should check `"docker.io/"` (not just `"docker.io"`).  

#### **Fixed Rego**:  
```yaml
rego: |
  package allowedregistries
  allowed_registries := ["docker.io/", "gcr.io/"]
  violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    not any({startswith(container.image, reg) | reg := allowed_registries[_]})
    msg := sprintf("Image %v is not from an allowed registry", [container.image])
  }
```

---

### **Solution 4: New Policy - Enforce runAsNonRoot**  
#### **ConstraintTemplate**:  
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: requirenonroot
spec:
  crd:
    spec:
      names:
        kind: RequireNonRoot
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package requirenonroot
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.runAsNonRoot
          msg := "Containers must run as non-root (runAsNonRoot: true)"
        }
```

#### **Constraint**:  
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: RequireNonRoot
metadata:
  name: enforce-nonroot
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

---


# **Advanced CKS Exam Scenario: OPA/Gatekeeper Master Challenge**  
**Time: 20 minutes**  

## **Scenario: Enterprise-Grade Policy Enforcement**  
You are the **Kubernetes Security Lead** at a fintech company. Your team must enforce **strict security policies** using OPA Gatekeeper.  

### **Requirements**  
1. **No privileged Pods**  
   - Block `privileged: true`, `allowPrivilegeEscalation: true`.  
2. **Mandatory Pod Security Standards (Restricted)**  
   - `runAsNonRoot: true`  
   - `readOnlyRootFilesystem: true`  
   - No `NET_RAW` capability.  
3. **Strict Image Control**  
   - Only allow images from `docker.io/company/` and `gcr.io/trusted/`.  
   - Block images with `:latest` tag.  
4. **Network Hardening**  
   - Require `PodDisruptionBudget` for all Deployments in `production` namespace.  
   - Block `hostNetwork: true` and `hostPort` usage.  
5. **Custom Business Rule**  
   - All Pods must have a `cost-center` label (e.g., `cost-center: dev`).  

---

## **Task 1: Fix the Broken Policies**  
### **Broken Policy 1: Privileged Pod Prevention**  
**Expected**: Blocks `privileged` and `allowPrivilegeEscalation`.  
**Actual**: Only checks `privileged`.  

#### **ConstraintTemplate**  
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: blockinsecurepod
spec:
  crd:
    spec:
      names:
        kind: BlockInsecurePod
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package blockinsecurepod
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          container.securityContext.privileged == true
          msg := "Privileged containers are not allowed"
        }
```

#### **Your Task**  
- **Fix**: Add check for `allowPrivilegeEscalation`.  

---

### **Broken Policy 2: Block `:latest` Tags**  
**Expected**: Rejects images with `:latest`.  
**Actual**: Fails to block `nginx:latest`.  

#### **ConstraintTemplate**  
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: blocklatesttag
spec:
  crd:
    spec:
      names:
        kind: BlockLatestTag
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package blocklatesttag
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          endswith(container.image, "latest")
          msg := "Images with ':latest' tag are prohibited"
        }
```

#### **Your Task**  
- **Bug**: The policy fails when image is `nginx:latest`. Fix the Rego logic.  

---

## **Task 2: Write New Policies from Scratch**  
### **Policy 3: Enforce `cost-center` Label**  
- **Rule**: All Pods must have `metadata.labels.cost-center`.  
- **Rejection Message**: "All Pods must have a `cost-center` label (e.g., 'dev', 'prod')."  

#### **Your Task**  
Write a **ConstraintTemplate + Constraint** for this.  

---

### **Policy 4: Require `PodDisruptionBudget` in Production**  
- **Rule**: All Deployments in `production` namespace must have a `PodDisruptionBudget` (PDB).  
- **Hint**: Check if `PodDisruptionBudget` exists for the Deployment's labels.  

#### **Your Task**  
Write the Rego rule.  

---

## **Solutions**  

### **Solution 1: Block Privileged + Privilege Escalation**  
```yaml
rego: |
  package blockinsecurepod
  violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    container.securityContext.privileged == true
    msg := "Privileged containers are not allowed"
  }
  violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    container.securityContext.allowPrivilegeEscalation == true
    msg := "allowPrivilegeEscalation is not allowed"
  }
```

### **Solution 2: Fix `:latest` Tag Check**  
```yaml
rego: |
  package blocklatesttag
  violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    # Match *:latest and *:latest-*
    regex.match(":latest($|-)", container.image)
    msg := "Images with ':latest' tag are prohibited"
  }
```

### **Solution 3: Enforce `cost-center` Label**  
```yaml
# ConstraintTemplate
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: requirecostcenter
spec:
  crd:
    spec:
      names:
        kind: RequireCostCenter
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package requirecostcenter
        violation[{"msg": msg}] {
          not input.review.object.metadata.labels["cost-center"]
          msg := "All Pods must have a 'cost-center' label (e.g., 'dev', 'prod')"
        }

# Constraint
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: RequireCostCenter
metadata:
  name: enforce-cost-center
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

### **Solution 4: Require `PodDisruptionBudget` in Production**  
```yaml
rego: |
  package requirepdb
  violation[{"msg": msg}] {
    # Check if namespace is production
    input.review.object.metadata.namespace == "production"
    # Check if resource is a Deployment
    input.review.object.kind == "Deployment"
    # Check if no PDB matches the Deployment's labels
    deployment_labels := input.review.object.spec.selector.matchLabels
    count([pdb | 
      pdb := data.inventory.namespace["production"]["policy/v1"].PodDisruptionBudget[_]
      pdb.spec.selector.matchLabels == deployment_labels
    ]) == 0
    msg := "Deployment in 'production' must have a PodDisruptionBudget"
  }
```

---

## **Final Challenge: Multi-Rule Policy**  
Write a **single ConstraintTemplate** that enforces:  
1. `runAsNonRoot: true`  
2. `readOnlyRootFilesystem: true`  
3. No `NET_RAW` capability.  

### **Solution**  
```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: podssecurityrestricted
spec:
  crd:
    spec:
      names:
        kind: PodSecurityRestricted
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package podsecurityrestricted
        # Rule 1: runAsNonRoot
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.runAsNonRoot
          msg := "Container must run as non-root (runAsNonRoot: true)"
        }
        # Rule 2: readOnlyRootFilesystem
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.securityContext.readOnlyRootFilesystem
          msg := "Container must use readOnlyRootFilesystem"
        }
        # Rule 3: No NET_RAW
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          "NET_RAW" in container.securityContext.capabilities.add
          msg := "NET_RAW capability is not allowed"
        }
```

---

## **Final Exam Tips**  
✅ **Always check paths** (`input.review.object.spec...`).  
✅ **Test policies with `--dry-run=server`** before enforcing.  
✅ **Look for typos** (e.g., `containers` vs `containers`).  
✅ **Use `kubectl describe constraint <name>`** to debug errors.  

