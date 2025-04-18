![Cilium](../images/cilium_logo.png)

## Installing Cilium and Enabling Encryption
Follow below procedure for enabled encryption by installing Cilium:

### Add the Cilium Helm repository
helm repo add cilium https://helm.cilium.io/

### Install Cilium with encryption enabled
```bash
helm install cilium cilium/cilium --version 1.16.3 \
  --namespace kube-system \
  --set encryption.enabled=true \
  --set encryption.type=wireguard
```
You can verify that Cilium is running and that encryption is enabled by running the following commands:

- Wait for the status of cilium to be OK
```bash
cilium status
```
- Check the encryption status of the Cilium installation
```bash
cilium encryption status
```

## What is wiregurd
A VPN protocol that provides encrypted network communication

Explanation:

WireGuard is a modern, open-source VPN (Virtual Private Network) protocol designed to provide fast, secure, and efficient encrypted communication. It uses state-of-the-art cryptography to secure network traffic. In the context of Kubernetes, tools like Cilium integrate WireGuard to encrypt pod-to-pod traffic across nodes, enhancing network security by ensuring that data transmitted between pods is protected from interception or tampering.

Reference: https://www.wireguard.com/



## Deploy Pods for Testing
Deploy an NGINX pod labeled app: nginx that will serve as the application to test encrypted traffic.

```yaml
image: nginx
replicas: 1
port: 80

#Create a service named nginx to expose the NGINX deployment.
port: 80
targetPort: 80

#Deploy a client pod named curlpod that will act as a client to test connectivity to the NGINX pod.
image: rapidfort/curl
command: sleep 3600
label: app: curlpod
```



## Validate the Setup
Check connectivity between the pods, in a new terminal window run the following command:

```bash
watch kubectl exec -it curlpod -- curl -s http://nginx
```
The watch `curl` command should return the HTML content of the NGINX welcome page, indicating that the client pod can access the NGINX pod.

Run a bash shell in one of the Cilium pods with 
```bash
kubectl -n kube-system exec -ti ds/cilium -- bash
```
**Execute the following commands inside `ds/cilium` `bash`:**
```bash
#Check that WireGuard has been enabled (number of peers should correspond to a number of nodes subtracted by one):
cilium-dbg status | grep Encryption

#Install tcpdump
apt-get update
apt-get -y install tcpdump

#Check that traffic is sent via the cilium_wg0 tunnel device is encrypted:
tcpdump -n -i cilium_wg0 -X
```

Here we are using `tcpdump` to capture and display detailed network packets on the cilium_wg0 interface.

The `-n` option avoids DNS lookups, and the `-X` option shows packet content in both `hexadecimal` and `ASCII` format.

Via `tcpdump`, you should see the traffic between the pods.

We see requests from `curlpod` to `nginx` and responses from `nginx` to `curlpod` in `tcpdump` output.


## Practice Lab

Run below shell script for create senario
```bash
sh create-scenario-cilium.sh
```
```plaintext
cleaning team-orange
Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
namespace "team-orange" force deleted

Create senario for CiliumNetworkPolicy
namespace/team-orange created
statefulset.apps/database created
service/database created
deployment.apps/transmitter created
deployment.apps/messenger created
ciliumnetworkpolicy.cilium.io/default-allow created
pod/database-0 condition met
pod/messenger-54f9cd4589-k8sdt condition met
pod/messenger-54f9cd4589-wh5jw condition met
pod/transmitter-d7d5d6b65-g2lb5 condition met
pod/transmitter-d7d5d6b65-hx6d7 condition met

Pods and Services in Namespace team-orange
NAME                         STATUS   AGE  IP          LABELS
database-0                   Running  5s   10.0.0.121  apps.kubernetes.io/pod-index=0,controller-revision-hash=database-855784d4bc,statefulset.kubernetes.io/pod-name=database-0,type=database
messenger-54f9cd4589-k8sdt   Running  4s   10.0.0.150  pod-template-hash=54f9cd4589,type=messenger
messenger-54f9cd4589-wh5jw   Running  4s   10.0.0.168  pod-template-hash=54f9cd4589,type=messenger
transmitter-d7d5d6b65-g2lb5  Running  5s   10.0.0.127  pod-template-hash=d7d5d6b65,type=transmitter
transmitter-d7d5d6b65-hx6d7  Running  5s   10.0.0.26   pod-template-hash=d7d5d6b65,type=transmitter
NAME      CLUSTER-IP     PORT(S)  SELECTOR
database  10.108.160.62  80/TCP   type=database

Existing CiliumNetworkPolicy in Namespace team-orange
NAME            AGE
default-allow   4s
```

### Questions

In Namespace `team-orange` a Default-Allow strategy for all Namespace-internal traffic was chosen. There is an existing CiliumNetworkPolicy `default-allow` which assures this and which should not be altered. That policy also allows cluster internal DNS resolution.

Now it's time to deny and authenticate certain traffic. Create 3 CiliumNetworkPolicies in Namespace team-orange to implement the following requirements:

1. Create a `Layer 3` policy named `p1` to: </br>
   Deny outgoing traffic from Pods with label `type=messenger` to Pods behind Service `database`

2. Create a `Layer 4` policy named `p2` to: </br>
   Deny outgoing `ICMP` traffic from Deployment `transmitter` to Pods behind Service `database`

3. Create a `Layer 3` policy named `p3` to: </br>
   Enable Mutual Authentication for outgoing traffic from Pods with label `type=database` to Pods with label `type=messenger`

ℹ️ All Pods in the Namespace run plain Nginx images with open port 80. This allows simple connectivity tests like: `kubectl -n team-orange exec POD_NAME -- curl database`

For cilium we can take help from this [cilium policy editor](https://editor.networkpolicy.io/)

First explain the existing Pods and the Service we should work with. We can see that the `database` Service points to the `database-0` Pod. And this is the existing `default-allow` policy:

```yaml
apiVersion: "cilium.io/v2"
kind: CiliumNetworkPolicy
metadata:
  name: default-allow
  namespace: team-orange
spec:
  endpointSelector:
    matchLabels: {}             # Apply this policy to all Pods in Namespace team-orange 
  egress:
  - toEndpoints:
    - {}                        # ALLOW egress to all Pods in Namespace team-orange
  - toEndpoints:              
      - matchLabels:
          io.kubernetes.pod.namespace: kube-system
          k8s-app: kube-dns
    toPorts:
      - ports:
          - port: "53"
            protocol: UDP
        rules:
          dns:
            - matchPattern: "*"
  ingress:
  - fromEndpoints:              # ALLOW ingress from all Pods in Namespace team-orange
    - {}
```
ℹ️ CiliumNetworkPolicies behave like vanilla NetworkPolicies: once one egress rule exists, all other egress is forbidden. This is also the case for `egressDeny` rules: once one `egressDeny` rule exists, all other egress is also forbidden, unless allowed by an egress rule. This is why a `Default-Allow` policy like this one is necessary in this scenario. The behaviour explained above for egress is also the case for ingress.