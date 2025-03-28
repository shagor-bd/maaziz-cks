# RBAC Authorization

Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within your organization.

RBAC authorization uses the `rbac.authorization.k8s.io` API group to drive authorization decisions, allowing you to dynamically configure policies through the Kubernetes API.

Check the authorization mode set RBAC in k8s cluster.
```bash
# Login to master node
$ cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep -B6 authorization-mode
```
Output

```plaintext
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=192.168.0.110
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
```
## Create namespace

```bash
$ kubectl create namespace red 
namespace/red created
$ kubectl create namespace blue
namespace/blue created
$ kubectl get ns | grep -E 'red|blue'
blue                   Active   74s
red                    Active   77s
```
Assume 2 user we have `jane` and `jim`

For create `role`, `rolebuinding`, `clusterrole` and `clusterrolebuinding` the best way to work with this run help.

### Example
```bash
$ kubectl create role -h     
Create a role with single rule.

Examples:
  # Create a role named "pod-reader" that allows user to perform "get", "watch" and "list" on pods
  kubectl create role pod-reader --verb=get --verb=list --verb=watch --resource=pods
  
  # Create a role named "pod-reader" with ResourceName specified
  kubectl create role pod-reader --verb=get --resource=pods --resource-name=readablepod
--resource-name=anotherpod
  
  # Create a role named "foo" with API Group specified
  kubectl create role foo --verb=get,list,watch --resource=rs.apps
  
  # Create a role named "foo" with SubResource specified
  kubectl create role foo --verb=get,list,watch --resource=pods,pods/status
......................................................................................................................
......................................................................................................................

Usage:
  kubectl create role NAME --verb=verb --resource=resource.group/subresource
[--resource-name=resourcename] [--dry-run=server|client|none] [options]

Use "kubectl options" for a list of global command-line options (applies to all commands).
```
Lets start!

## Role and Role Buinding

**Allows `jane` to `view secrets` in the `red namespace` but not `modify` or `create` them.**

- First create Role

```bash
$ kubectl create role -h

$ kubectl -n red create role secret-manager --verb=get --resource=secrets
role.rbac.authorization.k8s.io/secret-manager created
```
- Then create Role Buinding

```bash
$ kubectl -n red create rolebinding secret-manager --role=secret-manager --user=ja
ne
rolebinding.rbac.authorization.k8s.io/secret-manager created
```

**Grant `jane` permission to `get and list secrets` in the `blue` namespace by creating a `secret-manager` role and binding it.**

- Create Role and Role Buinding

```bash
$ kubectl -n blue create role secret-manager --verb=get --verb=list --resource=secrets
$ kubectl -n blue create rolebinding secret-manager --role=secret-manager --user=jane --dry-run=client -oyaml  # Check the manifest file
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  creationTimestamp: null
  name: secret-manager
  namespace: blue
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: secret-manager
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: jane

$ kubectl -n blue create rolebinding secret-manager --role=secret-manager --user=jane
```

- Check the `role` and `rolebuinding` is working properly

```bash
$ kubectl -n red auth can-i -h  ## Truly important

$ kubectl -n red auth can-i list secrets --as jane
no
$ kubectl -n red auth can-i get secrets --as jane
yes
$ kubectl -n red auth can-i create secrets --as jane
no
$ kubectl -n red auth can-i delete secrets --as jane
no
$ kubectl -n blue auth can-i list secrets --as jane
yes
$ kubectl -n blue auth can-i get secrets --as jane
yes
# User jane cannot get secrets from default namespace
$ kubectl -n default auth can-i get secrets --as jane
no
```

**Now question is, from where we will get the `resource` or `verb` list `NAME`.**

Run below command
```bash
$ kubectl api-resources --verbs=list --namespaced -o wide | grep secrets
NAME     SHORTNAMES   APIVERSION   NAMESPACED   KIND             VERBS                                                        CATEGORIES
secrets                  v1           true     Secret     ceate,delete,deletecollection,get,list,patch,update,watch 
```
### Important
`--verb=get` `--resource=secrets` Please make ensure that you put the right name that is available in the list. Any mistake, your rule will not work properly.


## Cluster Role and Cluster Rolebuindings

**Grant `jane` permission to **delete deployments cluster-wide** by creating the `deploy-deleter` ClusterRole and binding to it.**

- Create `clusterrole` and `clusterrolebuinding`

```bash
$ kubectl create clusterrole -h
# First findout the actual api-resource name of deploy application
$ kubectl api-resources --namespaced=true | grep depl
deployments                 deploy       apps/v1                             true         Deployment

$ kubectl create clusterrole deploy-deleter --verb=delete --resource=deployments --dry-run=client -oyaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: null
  name: deploy-deleter
rules:
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - delete

$ kubectl create clusterrole deploy-deleter --verb=delete --resource=deployments
clusterrole.rbac.authorization.k8s.io/deploy-deleter created

# Role Buindings
$ kubectl create clusterrolebinding deploy-deleter --clusterrole=deploy-deleter --user=jane --dry-run=client -oyaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  creationTimestamp: null
  name: deploy-deleter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: deploy-deleter
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: jane

$ kubectl create clusterrolebinding deploy-deleter --clusterrole=deploy-deleter --user=jane
clusterrolebinding.rbac.authorization.k8s.io/deploy-deleter created

# Grant jim permission to delete deployments in the red namespace by binding the cluster-wide deploy-deleter role to him
$ kubectl -n red create rolebinding deploy-deleter --clusterrole=deploy-deleter --user=jim
rolebinding.rbac.authorization.k8s.io/deploy-deleter created
```

- Check the `clusterrole` and `clusterrolebuinding` is working properly

```bash
# Jane user
$ kubectl auth can-i delete deploy --as jane
yes
$ kubectl auth can-i delete deploy --as jane -n red 
yes
$ kubectl auth can-i delete deploy --as jane -n blue 
yes
$ kubectl auth can-i delete deploy --as jane -A # yes
yes
$ kubectl auth can-i create deploy --as jane --all-namespaces
no

# Jim user
$ kubectl auth can-i delete deploy --as jim
no
$ kubectl auth can-i delete deploy --as jim -A
no
$ kubectl auth can-i delete deploy --as jim -n red 
yes
$ kubectl auth can-i delete deploy --as jim -n blue
no
```

## Create a user for k8s cluster

```bash
openssl genrsa -out jane.key 2048
openssl req -new -key jane.key -out jane.csr # only set Common Name = jane

# create CertificateSigningRequest with base64 jane.csr
https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests
cat jane.csr | base64 -w 0

# add new KUBECONFIG
kubectl config set-credentials jane --client-key=jane.key --client-certificate=jane.crt
kubectl config set-context jane --cluster=kubernetes --user=jane
kubectl config view
kubectl config get-contexts
kubectl config use-context jane
```


Reference:</br>
[K8S Docs](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)</br>
[Create Role](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-role)</br>
[Create Role Buinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-rolebinding)</br>
[Create Cluster Role](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-clusterrole)</br>
[Create Cluster Role Buinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-clusterrolebinding)</br>