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
# ABAC Authorization

## Creating an ABAC Policy
Create a JSON file named abac-policy.jsonl with the following content to define an ABAC policy:

- User: `system:serviceaccount:default:john`
- Namespace: `default`
- Resource: `pods`
- API Group: `"*"`
- Read-only: `true`
- Policy path: `/etc/kubernetes/abac/abac-policy.jsonl`

**Note:** This policy grants `read-only` access to the `pods` resource in the `default` namespace for the `serviceaccount` `john`.

```bash
$ vim /etc/kubernetes/abac/abac-policy.jsonl
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"user": "system:serviceaccount:default:john", "namespace": "default", "resource": "pods", "apiGroup":"*", "readonly": true}}
```
## Configuring the API Server to Use ABAC

Configure the Kubernetes API server to use the ABAC authorization mode with the policy file you created.

- Update the Kube-API server configuration to include the following parameters:

```bash
vim /etc/kubernetes/manifests/kube-apiserver.yaml
```
Add below line
```plaintext
  --authorization-policy-file=/etc/kubernetes/abac/abac-policy.jsonl
  --authorization-mode=Node,RBAC,ABAC
```
- Add volume mounts to the API server pod spec:

```bash
volumeMounts:
# Other volume mounts...
- name: abac-policy
  mountPath: /etc/kubernetes/abac
  readOnly: true

volumes:
# Other volumes...
- name: abac-policy
  hostPath:
    path: /etc/kubernetes/abac
    type: DirectoryOrCreate
```
Use `crictl ps -a` to check the status of the `kube-apiserver` container.


## Creating a Service Account and Retrieving Its Token

Create a `serviceaccount` named `john` in the `default` namespace.
 - Create a secret named `john-secret` to store the token.
 - Associate the secret with the service account.

```bash
# Create service account and secret
apiVersion: v1
kind: ServiceAccount
metadata:
  name: john
  namespace: default
secrets:
- name: john-secret
---
apiVersion: v1
kind: Secret
metadata:
  name: john-secret
  annotations:
    kubernetes.io/service-account.name: john
type: kubernetes.io/service-account-token
```

Lets see the secret token for serviceaccount `john`

```bash
$ kubectl get secrets john-secret -o jsonpath={.data.token} | base64 -d
eyJhbGciOiJSUzI1NiIsImtpZCI6IkdVTkVfY3RBSWI3eHlpVXhhR2NQUWtMX2xmVnJMVkdheTI0RDZoMHBWRDAifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImpvaG4tc2VjcmV0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImpvaG4iLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI2M2ExZWM4ZC04Njg1LTQ0OTQtYTQyYy04ZjljNzQ1NjU2NGMiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpqb2huIn0.IW-_EReB1aWKCTpPEmYHQja8_tbC2g0bUkhaejMHh9-tHDC7NcbKBnnbRXknhC-IVB2Bt2H2Cr5UaREExHmW_BawWAF3GwkuYo4L35Jxz3_ijloP-Lire_pwyMZpteUwSsT0fWEwuMGNau6th0NrFeW6asxR2LKCTrCAwOCDp8De7Hf7IAovAR_jZDLS1IJI-9Sa_bxqj-Xzkoexfxr0wFjvEmvNE8U0mP_N40JV-HJGxgIpe-B0v1cljpdHTRa4ALnEt8fb2sUj80dWp7ybAhBTZCYBC1DBeclHMDJdpSmFVDjw0hADBNrTHfshWR1bEdmTUlyeFDQoDKuoI6VGig
```

## Setting Up `kubectl` Credentials for the Service Account

Configure `kubectl` to use the retrieved token by setting up new credentials and context.

- Set up credentials named `john` using the service account token.
- Create a context named `john-context` using these credentials.
- Switch to the new context.

Determine the current cluster name:
```bash
kubectl config view -o jsonpath='{.clusters[*].name}'
# output
# kubernetes 
```
- Set the credentials
```bash
kubectl config set-credentials john --token=$(kubectl get secrets john-secret -o jsonpath={.data.token} | base64 -d)
# User "john" set
```
OR
```bash
kubectl get secrets john-secret -o jsonpath={.data.token} | base64 -d > john-secret.txt
export SA_TOKEN=$(cat john-secret.txt)
kubectl config set-credentials john --token=$SA_TOKEN
```
- Create a context named `john-context`
```bash
kubectl config set-context john-context --cluster=kubernetes --namespace=default --user=john
```
- Switch to new context
```bash
kubectl config use-context john-context
```

**Now run command using running context
```bash
➜  kubectl config get-contexts 
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         john-context                  kubernetes   john               default
          kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   

➜ kubectl get pod
Warning: Use tokens from the TokenRequest API or manually created secret-based tokens instead of auto-generated secret-based tokens.
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          38m

# John have no permission for create pod
➜  kubectl run httpd --image=nginx
Warning: Use tokens from the TokenRequest API or manually created secret-based tokens instead of auto-generated secret-based tokens.
Error from server (Forbidden): pods is forbidden: User "system:serviceaccount:default:john" cannot create resource "pods" in API group "" in the namespace "default": No policy matched.
```
### Modify the ABAC policy

Modify the `/etc/kubernetes/abac/abac-policy.jsonl` policy to grant the `john` `serviceaccount` permission to `create pods` in the `default` namespace:

- Update the `readonly` attribute to `false` in the policy file.
- Restart the API server to apply the changes.
- Test by creating a pod using the john service account.

**Step 1:** Update the /etc/kubernetes/abac/abac-policy.jsonl file:
```bash
{"apiVersion": "abac.authorization.kubernetes.io/v1beta1", "kind": "Policy", "spec": {"user": "system:serviceaccount:default:john", "namespace": "default", "resource": "pods", "readonly": false}}
```
After made the changes need to restart the kube-apiserver pod. 

**Step 2:** Test creating a pod from context john-context:
```bash
kubectl config use-context john-context
kubectl run test-pod --image=nginx -n default
```
Output:
```plaintext
Warning: Use tokens from the TokenRequest API or manually created secret-based tokens instead of auto-generated secret-based tokens.
pod/test-pod created
```

Reference:</br>
[K8S Docs](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)</br>
[ABAC](https://kubernetes.io/docs/reference/access-authn-authz/abac/)</br>
[Create Role](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-role)</br>
[Create Role Buinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-rolebinding)</br>
[Create Cluster Role](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-clusterrole)</br>
[Create Cluster Role Buinding](https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-clusterrolebinding)</br>