# Kubernetes Dashboard

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

Go to this link for installation | `https://github.com/kubernetes/dashboard`

Here we will use `helm`. Please follow this link to [Install helm](https://helm.sh/docs/intro/install/)

Install Kubernetes Dashboard please run:

```bash
# Add kubernetes-dashboard repository
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
# Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```
Output

```plaintext
Release "kubernetes-dashboard" does not exist. Installing it now.
NAME: kubernetes-dashboard
LAST DEPLOYED: Wed Mar 19 16:17:41 2025
NAMESPACE: kubernetes-dashboard
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
*************************************************************************************************
*** PLEASE BE PATIENT: Kubernetes Dashboard may need a few minutes to get up and become ready ***
*************************************************************************************************

Congratulations! You have just installed Kubernetes Dashboard in your cluster.

To access Dashboard run:
  kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

NOTE: In case port-forward command does not work, make sure that kong service name is correct.
      Check the services in Kubernetes Dashboard namespace using:
        kubectl -n kubernetes-dashboard get svc

Dashboard will be available at:
  https://localhost:8443

$ kubectl -n kubernetes-dashboard get svc
NAME                                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes-dashboard-api               ClusterIP   10.110.8.82      <none>        8000/TCP   89s
kubernetes-dashboard-auth              ClusterIP   10.101.102.162   <none>        8000/TCP   89s
kubernetes-dashboard-kong-proxy        ClusterIP   10.102.154.182   <none>        443/TCP    89s
kubernetes-dashboard-metrics-scraper   ClusterIP   10.101.89.109    <none>        8000/TCP   89s
kubernetes-dashboard-web               ClusterIP   10.110.223.234   <none>        8000/TCP   89s
```












## Links:

[Upgrade K8S Dashboard](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard) 

[Dashboard Arguments](https://github.com/kubernetes/dashboard/blob/master/docs/common/arguments.md)

