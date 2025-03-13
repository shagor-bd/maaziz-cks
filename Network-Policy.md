https://github.com/killer-sh/cks-course-environment/tree/master/course-content/cluster-setup/network-policies

https://kubernetes.io/docs/concepts/services-networking/network-policies/


https://spacelift.io/blog/kubernetes-network-policy#how-to-create-a-network-policy-in-kubernetes


https://medium.com/@muppedaanvesh/a-hands-on-guide-to-kubernetes-network-policy-%EF%B8%8F-041bebe19a23

Cert Manager | https://medium.com/@muppedaanvesh/%EF%B8%8F-kubernetes-ingress-securing-the-ingress-using-cert-manager-part-7-366f1f127fd6


https://www.civo.com/learn/network-policies-kubernetes

### Delete list of pods, network policy only.
k delete networkpolicies $(kubectl get networkpolicies -n app --no-headers | awk '{print $1}') -n app

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