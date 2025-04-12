**Hands-on RBAC practice questions** for the CKS exam, which emphasizes *least privilege*, *namespace isolation*, and *real-world security contexts*.

---

### 🧠 CKS RBAC Practice Questions

#### 🔐 **Question 1: Restrict Access to Secrets**
Create an RBAC policy that **only allows a user `dev-user` to list secrets in the `dev` namespace**, but not read or modify them.

> 💡 Hint: You’ll need a Role and a RoleBinding.

---

#### 📦 **Question 2: Pod Reader with Limited Scope**
Create a Role and RoleBinding that allows a **service account `frontend-sa` in the namespace `app`** to get, list, and watch **pods only** in the `app` namespace.

---

#### 🔍 **Question 3: Deny Everything Except Logs**
You need to allow a user `auditor` to **only access pod logs** in the `prod` namespace. The user shouldn't be able to list pods or get their specs.

---

#### 🛡️ **Question 4: Cluster-Wide Read Access**
A group called `readonly-team` needs **read-only access to all resources in all namespaces**.

> 🔁 Use `ClusterRole` and `ClusterRoleBinding`.

---

#### 🔧 **Question 5: Allow Patch Only for Deployments**
A service account `ci-pipeline` in the `cicd` namespace needs to **patch Deployments** (e.g., for rolling updates) but shouldn’t be allowed to create or delete them.

---

#### ⚙️ **Question 6: Node Admin Role**
Give a user `node-admin` **access to get, list, and watch nodes**, but nothing else in the cluster.

---

#### 🔍 **Question 7: **Least Privilege Debugging**
You're asked to create access for a service account `debug-sa` in `dev` namespace that allows:
- `get`, `list` pods  
- `exec` into pods  
- `get` logs from pods  
But no creation, deletion, or modification access.

---

### Solutions

**Q-1 Ans:**
kubectl -n dev create role dev-user-role --verb=list --resource=secrets
kubectl -n dev create rolebinding dev-user-rolebinding --role=dev-user-role --user=dev-user

**Q-2 Ans:**
kubectl -n app create role sa-user-role --verb=list,get,watch --resource=pods
kubectl -n app create rolebinding sa-user-rolebinding --role=sa-user-role --serviceaccount=app:frontend-sa

**Q-3 Ans:**
```yaml
#Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: audit-logs
  namespace: prod
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods/log
  verbs:
  - get
```
kubectl -n prod create rolebinding audit-log-rolebinding --role=audit-logs --user=auditor

**Q-4 Ans:**
kubectl create clusterrolebinding read-only-team-clsuterrole --clusterrole=view --group=readonly-team

**Q-5 Ans:**
kubectl create role patch-role --verb=patch --resource=deployments -n cicd
kubectl create rolebinding patch-rolebuinding --role=patch-role --serviceaccount=cicd:ci-pipeline -n cicd

**Q-6 Ans:**
kubectl create clusterrole node-clusterrole --verb=get,list,watch --resource=nodes
kubectl create clusterrolebinding node-clusterrolebuinding --clusterrole=node-clusterrole --user=node-admin

**Q-7 Ans:**
```yaml
#Role
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: null
  name: debug-sa-role
  namespace: dev
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
- apiGroups:
  - ""
  resources:
  - pods/log
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods/exec
  verbs:
  - create
```
kubectl create rolebinding debug-sa-rolebinding --role=debug-sa-role --serviceaccount=dev:debug-sa --namespace=dev
```bash
$ kubectl auth can-i get pods/exec --as=system:serviceaccount:dev:debug-sa -n dev   
yes
$ kubectl auth can-i get pods/exec --as=system:serviceaccount:dev:debug-sa -n prod
no
```