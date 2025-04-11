# CILIUM 
![Alt Text](images/cilium_logo.png)

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

### Wait for the status of cilium to be OK
cilium status
### Check the encryption status of the Cilium installation
cilium encryption status


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
kubectl -n kube-system exec -ti ds/cilium -- bash and execute the following commands:
```
Check that WireGuard has been enabled (number of peers should correspond to a number of nodes subtracted by one):
```bash
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
