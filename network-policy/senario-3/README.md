# LAB Setup and Question for NetworkPolicy in CKS exam
### Let create senario

```bash
sh create-scenario-myapp-mydb.sh 
```
```output
cleaning myapp and mydb Namespaces
Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
namespace "myapp" force deleted
namespace "mydb" force deleted

Create senario for NetworkPolicy
namespace/myapp created
namespace/mydb created
deployment.apps/frontend created
deployment.apps/backend created
deployment.apps/database created
service/frontend-service created
service/backend-service created
service/database-service created
pod/backend-f498bcfc8-8dwrg condition met
pod/backend-f498bcfc8-zmqq7 condition met
pod/frontend-54b4d84c7c-66nsg condition met
pod/frontend-54b4d84c7c-j87j2 condition met
pod/database-67c5bccd6c-pqghg condition met

Pods and Services in Namespace myapp
NAME                       STATUS   AGE  IP            LABELS
backend-f498bcfc8-8dwrg    Running  15s  192.168.1.19  app=backend,pod-template-hash=f498bcfc8
backend-f498bcfc8-zmqq7    Running  15s  192.168.1.20  app=backend,pod-template-hash=f498bcfc8
frontend-54b4d84c7c-66nsg  Running  15s  192.168.1.18  app=frontend,pod-template-hash=54b4d84c7c
frontend-54b4d84c7c-j87j2  Running  15s  192.168.1.17  app=frontend,pod-template-hash=54b4d84c7c
NAME              CLUSTER-IP      PORT(S)   SELECTOR
backend-service   10.97.49.207    8080/TCP  app=backend
frontend-service  10.101.132.224  80/TCP    app=frontend

Pods and Services in Namespace mydb
NAME                       STATUS   AGE  IP            LABELS
database-67c5bccd6c-pqghg  Running  16s  192.168.1.16  app=database,pod-template-hash=67c5bccd6c
NAME              CLUSTER-IP     PORT(S)   SELECTOR
database-service  10.109.186.53  3306/TCP  app=database
``` 

- **Namespace `myapp`**: `frontend`, `backend` pods/services
- **Namespace `mydb`**: `database` pod/service

---

### 🛡️ **CKS NetworkPolicy Practice Questions**

---

### 🔹 **Question 1: Frontend-to-Backend Access Only**

**Scenario:**
Only allow `frontend` pods in the **same namespace (`myapp`)** to communicate with `backend` pods **on port 8080**. Deny all other ingress to the `backend` pods.

**🧠 Task:**
Write a NetworkPolicy in `myapp` namespace that allows only pods with label `app=frontend` to send traffic to pods labeled `app=backend` on TCP port `8080`.

---

### 🔹 **Question 2: Backend-to-Database Access**

**Scenario:**
Your backend pods (in `myapp` namespace) need to talk to the database (in `mydb` namespace), but nothing else should be allowed to contact the database pod.

**🧠 Task:**
Write a NetworkPolicy in the `mydb` namespace that allows ingress to pods labeled `app=database` **only from** pods with label `app=backend` in the `myapp` namespace — on port `3306` (MySQL).

---

### 🔹 **Question 3: Default Deny All in `mydb`**

**Scenario:**
Security requires that **all pods in the `mydb` namespace should deny all ingress and egress by default**, unless explicitly allowed.

**🧠 Task:**
Write two NetworkPolicies in the `mydb` namespace:
- One to deny **all ingress**
- One to deny **all egress**

---

### 🔹 **Question 4: Frontend Internet Access (DNS + HTTPS)**

**Scenario:**
The `frontend` pods in `myapp` need to make outbound calls to external APIs over **HTTPS**, and also need to perform DNS resolution. No other outbound traffic should be allowed.

**🧠 Task:**
Create a NetworkPolicy (or two) in `myapp` namespace that:
- Allows egress to TCP port `443` (HTTPS) to `0.0.0.0/0`
- Allows egress to port `53` (DNS) for both TCP and UDP

---

### 🧠 Bonus Realistic Twist:

> In Question 2, what would happen if no `Ingress` policy is defined in `mydb`? Would the `backend` pods be able to connect to the `database` pod?

👀 Hint: Think about default Kubernetes behavior with no NetworkPolicies applied.

---

## My Answare:

```yaml
#Question-1 Ans

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
  namespace: myapp
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  - Ingress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: myapp
      podSelector:
        matchLabels:
          app: backend

    ports:
    - protocol: TCP
      port: 8080

---
#Question-2 Ans

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-to-db
  namespace: mydb
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: myapp
      podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 3306

---
#Question-3 Ans

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-pod-deny-all
  namespace: mydb
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress

---
# Question-4 Ans

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-dns-https
  namespace: myapp
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 443

  - to:
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53


# In Question 2, what would happen if no Ingress policy is defined in mydb? Would the backend pods be able to connect to the database pod?

# Ans: Yes

```
### Reply from AI

---

## ✅ **Question 1: Frontend to Backend (Scoped on Backend)**

Your answer is:
```yaml
podSelector:
  matchLabels:
    app: frontend
```

🔍 **Issue**:
You're selecting **frontend pods**, but we need to apply the policy to **backend** pods (because it's their Ingress that we want to control).

### ✅ Corrected Version:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: myapp
spec:
  podSelector:
    matchLabels:
      app: backend  # Target backend pods
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

💡 **Reasoning**: 
- We don’t need `Egress` here unless we also want to restrict what `frontend` can access (not mentioned in scenario).
- In CKS, **Ingress policies are applied to the receiver**, not the sender.

---

## ✅ **Question 2: Backend to Database — Perfect!**

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-to-db
  namespace: mydb
...
```

✅ You're spot on! You:
- Applied the policy in the **right namespace**
- Targeted the **database pods**
- Used `namespaceSelector` + `podSelector` to restrict to **backend** pods in `myapp`
- Allowed only **TCP 3306**

💯 Full marks.

---

## ✅ **Question 3: Default Deny — Perfect & Clean**

```yaml
podSelector: {}
policyTypes:
- Ingress
- Egress
```

✅ Excellent. This applies to all pods and **denies all traffic** in both directions by default.

🧠 **CKS Tip**: This should almost always be your starting point when securing a namespace.

---

## ✅ **Question 4: DNS + HTTPS Egress — Almost There!**

This is *so close*, but there’s **one common mistake**:

```yaml
- to:
    ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

🔍 **Issue**: This `to:` block doesn’t specify **where** the DNS requests are going — so it will block them unless the cluster allows "implicit DNS".

💡 Best practice is to use a destination selector. But since we don't know the DNS IP (and many clusters use kube-dns), you can **just leave `to:` empty**, and allow the port only. Like this:

### ✅ Corrected DNS Policy Block:
```yaml
- ports:
  - protocol: UDP
    port: 53
  - protocol: TCP
    port: 53
```

✅ So the final **fixed full answer** is:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-egress-limited
  namespace: myapp
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
    ports:
    - protocol: TCP
      port: 443
  - ports:
    - protocol: TCP
      port: 53
    - protocol: UDP
      port: 53
```

✅ This is now **perfect** for DNS + HTTPS egress only.

---

## 🧠 Your Answer to the Bonus Question:

> **If no Ingress policy is defined in `mydb`, can backend talk to database?**

✅ Your answer: **Yes**
💯 Correct!

📘 **Why**: In Kubernetes, if **no NetworkPolicy is applied**, pods accept **all traffic by default** — this includes cross-namespace communication. So unless an Ingress policy explicitly restricts traffic, communication is open.

---

## 🏁 Final Verdict:

| Question | Accuracy | Notes |
|---------|----------|-------|
| Q1 | 80% ✅ | Just swapped wrong `podSelector` — otherwise great |
| Q2 | 100% ✅ | Perfect |
| Q3 | 100% ✅ | Perfect |
| Q4 | 95% ✅ | Slight syntax issue with DNS block |

---

### 🚀 Ready for More?

Want me to toss you a more complex scenario like:
- Combining multiple rules in one policy?
- Blocking all external traffic except a **specific IP block**?
- Or shift gears to **RBAC**, **PodSecurity**, or **Seccomp/AppArmor**?

Let’s level up further 💪




