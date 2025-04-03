Design an OPA (Open Policy Agent) policies using **Gatekeeper** to enforce label requirements on Kubernetes resources (specifically **Pods** and **Namespaces**). 

---

### **1. ConstraintTemplate: k8srequiredlabels**
This template defines the **structure and logic** for a constraint that enforces the presence of specific labels on Kubernetes resources.

#### **Main Components:**
- **apiVersion: templates.gatekeeper.sh/v1beta1** - Specifies the API version for the Gatekeeper template.
- **kind: ConstraintTemplate** - Defines a template for creating constraints.
- **metadata.name: k8srequiredlabels** - The name of the constraint template.
- **spec.crd.spec.names.kind: K8sRequiredLabels** - The custom resource kind that will use this template.
- **validation.openAPIV3Schema:** Specifies that the parameter `labels` is an array of strings.

#### **Rego Policy Logic:**
- **Target:** Admission controller of Gatekeeper (`admission.k8s.gatekeeper.sh`).
- **Policy Name:** `k8srequiredlabels`
- **Violation Logic:**
  - Gets the labels from the resource (`provided`).
  - Defines the required labels from the input parameters.
  - Finds the **missing labels** by calculating the difference between required and provided labels.
  - If any labels are missing, it generates a violation message:  
    ```
    "you must provide labels: [missing_labels]"
    ```
  
---

### **2. Constraint: pod-must-have-cks**
This constraint **enforces the rule** defined by the above template for **Pod resources**.

#### **Main Components:**
- **apiVersion: constraints.gatekeeper.sh/v1beta1** - Specifies the API version for constraints.
- **kind: K8sRequiredLabels** - Uses the template created earlier.
- **metadata.name: pod-must-have-cks** - A descriptive name for the constraint.
- **spec.match.kinds:** Specifies that the rule applies to all **Pods** in the cluster.
- **spec.parameters.labels:** Enforces that Pods must have a label named **"cks"**.

---

### **3. Constraint: ns-must-have-cks**
This constraint **enforces the rule** for **Namespace resources**.

#### **Main Components:**
- **apiVersion: constraints.gatekeeper.sh/v1beta1** - API version for constraints.
- **kind: K8sRequiredLabels** - Uses the same template as the previous constraint.
- **metadata.name: ns-must-have-cks** - A descriptive name for the constraint.
- **spec.match.kinds:** Specifies that the rule applies to all **Namespaces** in the cluster.
- **spec.parameters.labels:** Enforces that Namespaces must have a label named **"cks"**.

---

### **Summary:**
- The **ConstraintTemplate** defines a generic policy that requires specified labels on Kubernetes resources.
- The **pod-must-have-cks** constraint enforces this policy specifically on Pods, requiring the label **"cks"**.
- The **ns-must-have-cks** constraint enforces the same policy on Namespaces.
- If any Pod or Namespace is created/updated without the **"cks"** label, the OPA/Gatekeeper will **block the operation** and return an error message indicating the missing label.




---

### 💡 **Your Original Code:**  
```rego
violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not container.securityContext.runAsNonRoot
  msg := sprintf("Container %v must run as non-root", [container.name])
}
```
#### ✔️ **Explanation:**  
- This code checks if the **`runAsNonRoot`** field is **missing** or explicitly set to **`false`**.  
- The `not` keyword in Rego returns `true` if the **expression does not exist** or evaluates to **`false`**.  
- This way, it correctly captures both scenarios:  
  1. **Missing field** (not defined)  
  2. **Field explicitly set to `false`**  

---

### 🚫 **Your Suggested Alternative:**  
```rego
container := input.review.object.spec.containers[_].securityContext.runAsNonRoot == false
```
#### ❌ **Why This Fails:**  
- This statement will **only match when the field explicitly exists and is set to `false`**.  
- If the `runAsNonRoot` field is **missing**, it will not trigger a violation because Rego will not find the field at all, resulting in an **undefined expression**.  

---

### ✅ **Alternative That Works:**  
If you want a more compact version while handling both cases (missing or false), you can use:
```rego
violation[{"msg": msg}] {
  container := input.review.object.spec.containers[_]
  not (container.securityContext.runAsNonRoot == true)
  msg := sprintf("Container %v must run as non-root", [container.name])
}
```
#### ✔️ **Why This Works:**  
- The **`not`** outside the entire expression ensures that the rule triggers if:  
  1. The field does **not exist**.  
  2. The field is explicitly **set to `false`**.  
- It correctly covers both cases with a cleaner expression.  

---

### 📝 **Example Usage:**  
Test with the following Pod manifest:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
    - name: busybox
      image: busybox
      command: ["sh", "-c", "sleep 3600"]
      securityContext:
        runAsNonRoot: false
```
- If `runAsNonRoot` is **false** or **missing**, the policy will be violated.  
- If `runAsNonRoot` is **true**, it will pass.  

