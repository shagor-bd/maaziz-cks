# Secure Kubernetes Dashboard

To create the Kubernetes dashboard resources in the terminal run the following command.
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

Now run `kubectl proxy` with the command `kubectl proxy --address=0.0.0.0 --disable-filter &`

Open the URL in you workstation

Append `/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login` to URL to check login UI

**Note:** From a security perspective do not use `--disable-filter` option as it can leave you vulnerable to XSRF attacks, when used with an accessible port. We have used this option to make our lab environment work with the `kubernetes dashboard` so you can access it through a browser. Ideally you would be accessing it through a `kubectl proxy` on your `localhost` only.
So in actual environments do not use `--disable-filter` option as its a major security risk.

![kubernetes dashboard](../images/k8s-dashboard.png)

## Cluster admin access

Lets created a service account `admin-user` with `ClusterRoleBinding` `admin-user-binding`. Inspect the role binding and identify what security issue this sa may have. 
- Create service account `admin-user`
- Create secrets `admin-user-secrets` for serviceaccount and add secrets in serviceaccount `admin-user`
- Create rolebuinding with `cluster-admin` role  

```yaml
# admin-user serviceaccount
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
secrets:
  - name: admin-user-secrets
---
# admin-user-secrets
apiVersion: v1
kind: Secret
metadata:
  name: admin-user-secrets
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token  
---
# admin-user-clusterrolebuinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
```

Now read the token 
```bash
➜ kubectl get secrets -n kubernetes-dashboard admin-user -o go-template="{{.data.token | base64decode}}"
eyJhbGciOiJSUzI1NiIsImtpZCI6ImFJZ0FteXpFUy1kQ0ZUM3dMWnNiVFFHNWFuSXRLRFNkV1RuRS1zd09XTVkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIzMGI0YWNiNi02NDI3LTRhNWEtOTIwZi0xZDFlNzRhNmNhNGEiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.j6ns54II9zCHKQMkYzBAMn7NG6LEnLVoLFwVJD43mYWzFj4urUe44DHb_KyT0xc4_fF68HaLrqJ5LUQO5rxu2_uA5BHPmfZ5SufXIfPvnpuMjl4UvvbxCy2uygfvfOuB8y75JcabEy7HSzMwr3VA6oXMy28cXYynvjZRBvkBKJxQ9R_I3gcEFf52AT8vCs6Hl9M-Gj1PK9z78wHqG_ynXSZuhd54uXBmzNAUPEcFSlG_c8ps0bwJ4pyor43UD4ZnlOVPonueD-djnH6YGcl_Kw_UuqtBXZ_FL9Tnx3xNo4Jq-tyqnqfHXUUMyOHbU8DHiNSVsKbSzBnCD5MRA_OPSg
```

Copy and paste the token into the portal. After that you can see the dashboard with all namespace access.

![](../images/k8s-dashboard-login.png)

## Read Only user permission

Let's now create a new Service Account `readonly-user` in the `kubernetes-dashboard` `namespace` with `view` permissions to all resources in `all namespaces`.

- ClusterRole name : `view`
- ClusterRoleBinding name : `readonly-user-binding`

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: readonly-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: readonly-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "readonly-user"
type: kubernetes.io/service-account-token
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: readonly-user-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
subjects:
- kind: ServiceAccount
  name: readonly-user
  namespace: kubernetes-dashboard
EOF
```

Lets read the secret for `readonly-user` 

```bash
kubectl -n kubernetes-dashboard get secret readonly-user -o go-template="{{.data.token | base64decode}}"
```
Copy and paste the output into the dashboard portal

## Admin user permission
The `readonly-user` service account has too few privileges. Now let's create a `dashboard-admin` service account with access to the `kubernetes-dashboard` namespace only.

Also, create a new `secret` called `dashboard-admin-secret` in the same namespace. It will create `token credentials` for the `serviceaccount`.

Use `admin` `ClusterRole` with `RoleBinding` so that it gives full control over every resource in the role binding's `namespace`, including the namespace itself.

- Also assign `list-namespace` ClusterRole to only see namespaces.
- Please use below names for bindings
- RoleBinding name: `dashboard-admin-binding`
- ClusterRoleBinding name: `dashboard-admin-list-namespace-binding`

```bash
# create service account
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dashboard-admin
  namespace: kubernetes-dashboard
EOF

# admin RoleBinding
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dashboard-admin-binding
  namespace: kubernetes-dashboard
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- kind: ServiceAccount
  name: dashboard-admin
  namespace: kubernetes-dashboard
EOF

## list-namespace ClusterRoleBinding
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: dashboard-admin-list-namespace-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: list-namespace
subjects:
- kind: ServiceAccount
  name: dashboard-admin
  namespace: kubernetes-dashboard
EOF
## Create secret for serviceaccount
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: dashboard-admin-secret
  annotations:
    kubernetes.io/service-account.name: "dashboard-admin"
  namespace: kubernetes-dashboard
type: kubernetes.io/service-account-token
EOF
```


## Links:

[Upgrade K8S Dashboard](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard) 

[Dashboard Arguments](https://github.com/kubernetes/dashboard/blob/master/docs/common/arguments.md)

