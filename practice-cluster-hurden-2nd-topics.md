# Exercise caution in using service accounts e.g. disable defaults, minimize permissions on newly created ones

Ohh yes — that’s a **top-tier CKS topic**: service account hygiene is critical for minimizing lateral movement and privilege escalation.

The CKS expects you to understand not just how to *use* ServiceAccounts (SAs), but how to secure them by:
- Not using the **default** service account
- Minimizing SA permissions via **least privilege RBAC**
- Avoiding auto-mounting of tokens unless needed
- Scoping SAs to a **specific namespace or pod**
- Auditing existing roles tied to SAs

Let’s put that into practice.

---

### 🔐 **CKS Practice Questions: Securing Service Accounts**

---

#### 🚫 **Q1: Disable the Default Service Account**

In the `payments` namespace, ensure that the default service account **cannot be used by any Pods**.

> 🔎 *Hint:* You’ll want to modify the service account and prevent token mounting.

---

#### 🛡️ **Q2: Prevent Auto-Mounting of SA Tokens**

A Pod spec in the `dev` namespace is using a custom SA called `custom-sa`. For security reasons, the Pod should not have the service account token mounted automatically.

Create a Pod spec to reflect this.

---

#### 🔍 **Q3: Audit All ServiceAccounts in `prod` with ClusterRoleBindings**

List all service accounts in `prod` namespace that are **bound to ClusterRoles** (i.e., can act cluster-wide).

> 💡 This tests your skill in **auditing** using `kubectl get`, `kubectl describe`, and maybe some `jq` or `grep`.

---

#### 🔧 **Q4: Create a Least-Privilege SA for Pod Logs Only**

Create a service account called `log-reader` in `myapp` namespace. It should only be allowed to **get logs from pods**, nothing more.

---

#### 🧬 **Q5: Ensure Pods Use Only Approved Service Accounts**

A policy has been issued: no Pod in the `staging` namespace should use the `default` SA. Write a **PodSecurityAdmission policy** or an **OPA/Gatekeeper constraint** to enforce this.

---

#### 🛑 **Q6: Deny Pod Execs via RBAC for CI/CD Service Account**

You have a service account `ci-sa` in namespace `cicd`. Restrict this service account so it **cannot exec into pods**, but still allow it to patch deployments.

---

### 🧠 Bonus – CKS Mental Model Tip:

> “**ServiceAccount == identity** in Kubernetes. Don’t give every identity the keys to the castle.”

---

Would you like to try answering one or two of these and I’ll review your response (prompt mode)? Or want sample solutions with breakdowns?

You're steering this ship, captain 🚢



Awesome — you’re diving into **secure SA usage** like a true CKS-in-training 💪  
Let’s break down your answers for **Q2** and **Q5**, both of which cover important service account hardening practices.

---

## ✅ Q2: Prevent Auto-Mounting of SA Token

Your answer:

```yaml
spec:
  serviceAccountName: custom-sa
  automountServiceAccountToken: false
```

✅ **Correct!** This ensures that the **token won’t be automatically mounted** into the Pod even though a SA is set. This is a solid security practice when the pod doesn't need to call the Kubernetes API.

🛠️ **Full example (for practice):**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: no-token-pod
  namespace: dev
spec:
  serviceAccountName: custom-sa
  automountServiceAccountToken: false
  containers:
  - name: app
    image: busybox
    command: ["sleep", "3600"]
```

🧠 **CKS Tip:** You can also set this field on the **ServiceAccount object** to make this behavior the default for all Pods using that SA.

---

## ⚠️ Q5: Prevent Use of Default SA via Policy (OPA/Gatekeeper)

Your answer:

```rego
package k8srequiredsa

violation[{"msg": msg}] {
  no input.review.object.serviceAccount=default
  msg := "you must not use default serviceaccount"
}
```

⚠️ **Almost there**, but there's a syntax issue and a logic fix needed.

### ❌ Issue:
- `no input.review.object.serviceAccount = default` is invalid Rego syntax.
- `default` is being used as a bare identifier, not a string. Needs quotes.

### ✅ Fixed Rego Policy:

```rego
package k8srequiredsa

violation[{"msg": msg}] {
  input.review.object.spec.serviceAccountName == "default"
  msg := "Using the default service account is not allowed"
}
```

✅ This checks if the `serviceAccountName` is explicitly set to `"default"`.

💡 You might also need to check if `serviceAccountName` is **missing**, since if not set, Kubernetes implicitly uses `default`.

So a safer version is:

```rego
package k8srequiredsa

violation[{"msg": msg}] {
  not input.review.object.spec.serviceAccountName
  msg := "Pod is implicitly using the default service account"
}

violation[{"msg": msg}] {
  input.review.object.spec.serviceAccountName == "default"
  msg := "Using the default service account is not allowed"
}
```

🔒 **CKS Tip:** This kind of policy is super valuable in OPA Gatekeeper or Kyverno scenarios to enforce namespace-level restrictions.

---

### 💯 Recap

| Question | Result   | Notes                                                                 |
|----------|----------|-----------------------------------------------------------------------|
| Q2       | ✅ Pass   | Perfect use of `automountServiceAccountToken: false`                |
| Q5       | ⚠️ Fix Needed | Great intent, but needs Rego syntax/logic fix. Recommend dual-rule version. |

---

Want to try one of the RBAC-focused ones next? (Q1, Q3, Q4, or Q6)  
Or would you like me to give you an end-to-end **CKS-style YAML manifest + question** to simulate a real exam task?

You’re crushing this 🚀


Absolutely — here are the **model answers** for the remaining service account security questions (Q1, Q3, Q4, Q6), each written to reflect CKS best practices with real-world commands and YAML when needed.

---

## ✅ **Q1: Disable the Default Service Account in `payments` Namespace**

**Goal**: Prevent the default service account from being used by any Pods.

---

### 🔧 Step 1: Patch the SA to disable token mounting

```bash
kubectl patch serviceaccount default \
  -n payments \
  -p '{"automountServiceAccountToken": false}'
```

> 🧠 This disables automatic token mounting for any Pods using the default SA, reducing token exposure.

---

### ✅ CKS Tip:
You can also use a **PodSecurityAdmission** policy (v1.25+) to enforce this at policy level by restricting SA usage or requiring automount to be false.

---

## ✅ **Q3: Audit Service Accounts in `prod` Bound to ClusterRoles**

**Goal**: Find any service accounts in the `prod` namespace that have access to cluster-level roles.

---

### 🔍 Step 1: List ClusterRoleBindings referencing service accounts

```bash
kubectl get clusterrolebindings -o json | jq '.items[] | select(.subjects[]? | select(.kind=="ServiceAccount" and .namespace=="prod")) | {name: .metadata.name, sa: .subjects[]}'
```

> This shows which **ClusterRoleBindings** are giving **cluster-wide** access to service accounts in `prod`.

💡 You can also grep if `jq` isn’t available:

```bash
kubectl get clusterrolebindings -o yaml | grep -B 3 'namespace: prod'
```

🧠 **CKS Tip**: You’re looking for privilege escalation points where a namespaced SA gets **cluster-scope** permissions via a ClusterRoleBinding.

---

## ✅ **Q4: Create Least-Privilege SA for Pod Logs**

**Goal**: Service account `log-reader` in `myapp` can only get pod logs.

---

### 🔧 Step 1: Create the ServiceAccount

```bash
kubectl create serviceaccount log-reader -n myapp
```

---

### 🔧 Step 2: Create a Role for pod logs

```yaml
# log-reader-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: log-reader-role
  namespace: myapp
rules:
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
```

Apply it:

```bash
kubectl apply -f log-reader-role.yaml
```

---

### 🔧 Step 3: Bind Role to ServiceAccount

```bash
kubectl create rolebinding log-reader-binding \
  --role=log-reader-role \
  --serviceaccount=myapp:log-reader \
  -n myapp
```

✅ This ensures the service account can **only get logs** — not list pods, not exec, not delete.

---

## ✅ **Q6: Prevent Exec for `ci-sa`, But Allow Deployment Patch**

---

### 🔧 Step 1: Create a Role that excludes exec

```yaml
# ci-sa-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ci-sa-role
  namespace: cicd
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["patch"]
```

✅ **No verbs for `pods/exec`** means no access to exec into pods.

---

### 🔧 Step 2: Bind it to the SA

```bash
kubectl create rolebinding ci-sa-binding \
  --role=ci-sa-role \
  --serviceaccount=cicd:ci-sa \
  -n cicd
```

✅ This binding **only gives patch access to Deployments**, avoiding any `exec` capability.

---

### 🔎 Bonus: Check if exec is denied

```bash
kubectl auth can-i create pods/exec --as=system:serviceaccount:cicd:ci-sa -n cicd
```

Expected output:
```bash
no
```

---

## 🔚 Summary

| Question | Secured Practice                 | Key Command or File                                   |
|----------|----------------------------------|--------------------------------------------------------|
| Q1       | Disable default SA token mount  | `kubectl patch sa default -n payments ...`            |
| Q3       | Audit SAs with ClusterRoleBinding | `jq` or `grep` on `clusterrolebindings`               |
| Q4       | Least privilege log-only SA     | YAML Role + RoleBinding + SA                          |
| Q6       | Patch-only, no-exec SA          | RBAC Role with `deployments/patch`, no `pods/exec`   |

---

If you want, I can generate a mini **CKS lab exercise** combining 2–3 of these in one realistic scenario — you solve it, and I review your answer.

Want to give that a go? 💥
