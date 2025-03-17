https://github.com/killer-sh/cks-course-environment/tree/master/course-content/cluster-setup/network-policies

https://kubernetes.io/docs/concepts/services-networking/network-policies/


https://spacelift.io/blog/kubernetes-network-policy#how-to-create-a-network-policy-in-kubernetes


https://medium.com/@muppedaanvesh/a-hands-on-guide-to-kubernetes-network-policy-%EF%B8%8F-041bebe19a23

Cert Manager | https://medium.com/@muppedaanvesh/%EF%B8%8F-kubernetes-ingress-securing-the-ingress-using-cert-manager-part-7-366f1f127fd6


https://www.civo.com/learn/network-policies-kubernetes

### Delete list of pods, network policy only.
```bash
kubectl delete networkpolicies $(kubectl get networkpolicies -n app --no-headers | awk '{print $1}') -n app
```

## Senario 1
```plaintext
+---------------------------------------------------+
|                   Namespace: app                  |
| Labels: name=app                                  |
|                                                   |
| +------------------+       +-------------------+  |
| | Pod: app1        |       | NetworkPolicy     |  |
| | Labels: id=app   |       | - deny-all        |  |
| +------------------+       +-------------------+  |
|         |                                         |
|         | Egress Allowed                          |
|         v                                         |
+---------------------------------------------------+
                          |
                          | Traffic Allowed by NetworkPolicy
                          |
+---------------------------------------------------+
|                   Namespace: data                 |
| Labels: name=data                                 |
|                                                   |
| +-----------------+       +-------------------+   |
| | Pod: data-001   |       | NetworkPolicy     |   |
| | Labels: id=data |       | - allow-app1      |   |
| +-----------------+       +-------------------+   |
+---------------------------------------------------+

```
## Senario 2

```plaintext
+-------------------+       +-------------------+       +-------------------+
|   Frontend Pod    | ----> |    Backend Pod    | ----> |   Database Pod    |
|  (app=frontend)   |       |   (app=backend)   |       |  (app=database)   |
|                   |       |                   |       |                   |
|  - IP: 10.1.1.1   |       |  - IP: 10.1.1.2   |       |  - IP: 10.1.1.3   |
|  - Port: 80       |       |  - Port: 8080     |       |  - Port: 3306     |
+-------------------+       +-------------------+       +-------------------+
         |                           |                           |
         |                           |                           |
         |                           |                           |
         v                           v                           v
+-------------------+       +-------------------+       +-------------------+
|  Network Policy   |       |  Network Policy   |       |  Network Policy   |
|  Allow Frontend   |       |  Allow Backend    |       |  Deny All Traffic |
|  to Backend       |       |  to Database      |       |  But only allow   |
|                   |       |                   |       |  Backend          |
+-------------------+       +-------------------+       +-------------------+
```