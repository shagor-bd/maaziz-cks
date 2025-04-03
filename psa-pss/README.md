# Kubernetes Pod Security Standards (PSS) with Pod Security Admission (PSA)

Sure! Pod Security Admission (PSA) is a key feature in Kubernetes for managing pod security based on predefined security profiles. For the **Certified Kubernetes Security Specialist (CKS)** exam, you need to understand how to implement and enforce security policies using PSA.

### **Pod Security Admission Overview**
PSA allows cluster administrators to define security standards at the namespace level using three built-in profiles:
1. **Privileged**: No restrictions.
2. **Baseline**: Restricts privileged and risky settings but allows common use cases.
3. **Restricted**: Heavily restricts to enforce best practices for security.

---

### **Example: Enforcing the Restricted Policy**

Let's walk through an example of enforcing the **Restricted** profile on a namespace.

#### **Step 1: Create a Namespace**
```bash
kubectl create namespace secure-ns
```

#### **Step 2: Label the Namespace with the Restricted Profile**
```bash
kubectl label namespace secure-ns \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=v1.28
```

#### **Step 3: Test Pod Creation (Expected to Fail)**
Create a pod with elevated privileges:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-pod
  namespace: secure-ns
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      privileged: true
```

Try to apply this pod:
```bash
kubectl apply -f privileged-pod.yaml
```

#### **Expected Output:**
```
Error from server (Forbidden): error when creating "privileged-pod.yaml": 
pods "privileged-pod" is forbidden: violates PodSecurity "restricted:latest": 
privileged containers are not allowed
```

---

### **Step 4: Create a Compliant Pod (Expected to Succeed)**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: restricted-pod
  namespace: secure-ns
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      runAsNonRoot: true
      allowPrivilegeEscalation: false
```

Apply the compliant pod:
```bash
kubectl apply -f restricted-pod.yaml
```

#### **Expected Output:**
```
pod/restricted-pod created
```

---

### **Key Takeaways for the CKS Exam:**
1. **Namespace Labeling:** Correctly label namespaces to enforce security profiles.
2. **Policy Testing:** Be prepared to test and validate pod security settings.
3. **Common Errors:** Understand why a pod might be forbidden under specific profiles.


More **Pod Security Admission (PSA)** scenarios, focusing on various profiles and enforcement levels, which are important for the **CKS exam**. 

---

### 🛡️ **Scenario 1: Combining Enforce, Audit, and Warn**  
In a real-world Kubernetes cluster, you might want to test security policies without immediately blocking pods. You can do this by using the **enforce**, **audit**, and **warn** labels together. 

#### **Objective:**  
Label a namespace to **enforce restricted**, **audit baseline**, and **warn privileged** policies.

#### **Step 1: Create the Namespace**  
```bash
kubectl create namespace multi-policy-ns
```

#### **Step 2: Apply Multiple PSA Labels**  
```bash
kubectl label namespace multi-policy-ns \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=v1.28 \
  pod-security.kubernetes.io/audit=baseline \
  pod-security.kubernetes.io/audit-version=v1.28 \
  pod-security.kubernetes.io/warn=privileged \
  pod-security.kubernetes.io/warn-version=v1.28
```

#### **Step 3: Create a Pod with Elevated Privileges**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: elevated-pod
  namespace: multi-policy-ns
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      privileged: true
```

#### **Apply the Pod:**  
```bash
kubectl apply -f elevated-pod.yaml
```

#### **Expected Output:**  
- **Enforce:** Pod creation fails because of restricted policy.  
- **Audit:** An audit entry is logged.  
- **Warn:** A warning message is displayed.  
```
Error from server (Forbidden): ... violates PodSecurity "restricted:latest": 
privileged containers are not allowed (enforce), 
and violates PodSecurity "privileged:latest" (warn).
```

---

### 📝 **Scenario 2: Setting a Less Strict Policy Temporarily**  
Sometimes you may need to relax security policies for testing or troubleshooting.

#### **Objective:**  
Change the namespace policy from **restricted** to **baseline**.

#### **Update the Label:**  
```bash
kubectl label namespace multi-policy-ns \
  pod-security.kubernetes.io/enforce=baseline \
  --overwrite
```

#### **Test a Pod with Baseline Compliance:**  
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: baseline-pod
  namespace: multi-policy-ns
spec:
  containers:
  - name: nginx
    image: nginx
    securityContext:
      allowPrivilegeEscalation: false
```

```bash
kubectl apply -f baseline-pod.yaml
```

#### **Expected Output:**  
```
pod/baseline-pod created
```
Since the **baseline** policy allows this configuration, the pod gets created successfully.

---

### 🚀 **Scenario 3: Applying Policies to Existing Namespaces**  
PSA labels can be applied to existing namespaces, but existing pods won’t be affected until they are recreated or updated.

#### **Example:**  
```bash
kubectl label namespace default pod-security.kubernetes.io/enforce=restricted
```

Try to deploy a privileged pod in the **default** namespace:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-priv-pod
  namespace: default
spec:
  containers:
  - name: busybox
    image: busybox
    securityContext:
      privileged: true
```

```bash
kubectl apply -f test-priv-pod.yaml
```

#### **Expected Result:**  
```
Error from server (Forbidden): ... violates PodSecurity "restricted:latest"
```

---

### 🌟 **Tips for the CKS Exam:**  
1. **Be Familiar with Labeling Syntax:** Remember how to properly set and update namespace labels.  
2. **Understand Policy Impact:** Know how each profile affects pod creation and how to test compliance.  
3. **Troubleshoot Efficiently:** If a pod creation fails, check the namespace labels and pod configuration.  
4. **Practice Multiple Combinations:** Know how to use `enforce`, `audit`, and `warn` together for flexible policy management.  

---

