# Restrict Access to Instance Metadata. 

Cloud providers expose instance metadata via the metadata API (e.g., AWS: 169.254.169.254/latest/meta-data/).
Attackers can exploit metadata services to gain credentials (e.g., IAM credentials in AWS).

For this task we assume that there is a Metadata Server at `1.1.1.1` .
You can test connection to that IP using `nc -v 1.1.1.1 53`.
Create a `NetworkPolicy` named `metadata-server` In Namespace `default` which restricts all egress traffic to that IP.
The NetworkPolicy should only affect Pods with label `trust=nope`

Setup an environment for exercise.
```bash
kubectl run no-trust --image=nginx:1.21.5-alpine --labels=trust=nope
kubectl run trust --image=nginx:1.21.5-alpine --labels=app=no-trust

➜ k get pod -L trust       # The -L flag is used to specify a label key - trust
NAME       READY   STATUS    RESTARTS   AGE   TRUST
no-trust   1/1     Running   0          16s   nope
trust      1/1     Running   0          16s   

```

Create the NP where we allow traffic to all addresses, except the evil

```bash
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: metadata-server
  namespace: default
spec:
  podSelector:
    matchLabels:
      trust: nope
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
          - 1.1.1.1/32
```

## Verify

```bash
# these should work
k exec trust-0 -- nc -v 1.1.1.1 53
k exec trust-0 -- nc -v -w 1 www.google.de 80
k exec no-trust-0 -- nc -v -w 1 www.google.de 80

# these should not work
k exec no-trust-0 -- nc -v 1.1.1.1 53
```
* Example taken from CKS simulator killer.sh