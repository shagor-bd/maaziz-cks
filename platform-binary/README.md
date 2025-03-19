# Platform Binary

A hash is a fixed-length string generated from input data using a cryptographic algorithm. It serves as a unique identifier for data, ensuring integrity and verifying authenticity. Hashes are commonly used to check if a file has been altered by comparing its computed hash with a trusted reference.

Popular cryptographic hashing algorithms include SHA-256, SHA-1, and MD5.

## Download and verify binaries
- Download Kubernetes release from Github
- Verify downloaded files

### Download k8s binary
First check you k8s version

```bash
➜  ~ kubectl get nodes
NAME     STATUS   ROLES           AGE   VERSION
master   Ready    control-plane   13d   v1.31.1
worker   Ready    worker          13d   v1.31.1

# So, our k8s platform version in v1.31.1
```
First go `https://github.com/kubernetes/kubernetes/releases/v1.31.1` -> `CHANGELOG`-> `Search for v1.31.1`

You will get the source code and we will check the `Server Binaries` and you will get the `sha512 hash` for every download able binary file.

 - `kubernetes-server-linux-amd64.tar.gz` Copy this line and download it into your server with `wget`
 - As we can see in the list all values are `sha512 hash`, now run the below command for find the hash value of downloaded file
```bash 
    sha512sum kubernetes-server-linux-amd64.tar.gz
    # Output
    176dd4e5e139262ce12e0098462392c290e72fc79f5db34df1ea5ab0d294dea7eb4d4fe74b69e479b7ce192069bc637cae011602c2dd93dde5e74fc4e77aa0a5  kubernetes-server-linux-amd64.tar.gz
    # And this this value will be the same as per the server github page. If it is not matched you downloaded file is not correct or corrupted file.
    # Small trics
    sha512sum kubernetes-server-linux-amd64.tar.gz > hash-info
    # now copy the hash value from github page and paste it into the file in next line and run below command. Also please remove kubernetes-server-linux-amd64.tar.gz from first line before proceed.
    cat hash-info | uniq
    # this command output will only one line, like below.
    176dd4e5e139262ce12e0098462392c290e72fc79f5db34df1ea5ab0d294dea7eb4d4fe74b69e479b7ce192069bc637cae011602c2dd93dde5e74fc4e77aa0a5 
```

### Compare API Server binary running inside contriner

#### Extract download file

```bash
$ tar xzf kubernetes-server-linux-amd64.tar.gz
$ ls
kubernetes  kubernetes-server-linux-amd64.tar.gz

$ cd kubernetes/server/bin && ls
apiextensions-apiserver  kube-apiserver.docker_tag           kube-controller-manager.tar  kubectl.tar      kube-proxy.docker_tag      kube-scheduler.tar
kubeadm                  kube-apiserver.tar                  kubectl                      kubelet          kube-proxy.tar             mounter
kube-aggregator          kube-controller-manager             kubectl-convert              kube-log-runner  kube-scheduler
kube-apiserver           kube-controller-manager.docker_tag  kubectl.docker_tag           kube-proxy       kube-scheduler.docker_tag

# Check kube-apiserver version
$ ./kube-apiserver --version
Kubernetes v1.31.1

$ kubectl -n kube-system get pods kube-apiserver-master -oyaml | grep image
    image: registry.k8s.io/kube-apiserver:v1.31.1
    imagePullPolicy: IfNotPresent
    image: registry.k8s.io/kube-apiserver:v1.31.1
    imageID: registry.k8s.io/kube-apiserver@sha256:2409c23dbb5a2b7a81adbb184d3eac43ac653e9b97a7c0ee121b89bb3ef61fdb

# Now check the kube-apiserver hash value
$ ha512sum kube-apiserver 
a6e6b01fc76f0f58a3f332442a927f1fefc2b6fb09c9683050426e47a5bcdaa9f7100713f3bc924ea27ba1c2ab28099644ce713f3d0ee957e0fdf99aa4aaab6d  kube-apiserver

$ kubectl -n kube-system exec -it kube-apiserver-master -- sh
error: Internal error occurred: Internal error occurred: error executing command in container: failed to exec in container: failed to start exec "80019a3b71239a491ed6397da7a916263c9ad146893580b20ac918fed040a81d": OCI runtime exec failed: exec failed: unable to start container process: exec: "sh": executable file not found in $PATH: unknown
# We are getting this error because k8s core components dont have shell inside pod
# Now we will login into master node and run below command for check the hash 
$ crictl ps | grep kube-apiserver
d66c327d6303e       6bab7719df100    4 hours ago  Running    kube-apiserver  5    ab5246a092eeb       kube-apiserver-master
$ ps aux | grep kube-apiserver
root        1586  5.4  7.9 1520672 318792 ?      Ssl  15:57  13:39 kube-apiserver --advertise-address=192.168.0.110 --allow-privileged=true --authorization-mode=Node,RBAC --client-ca-file=/etc/kubernetes/pki/ca.crt --enable-admission-plugins=NodeRestriction --enable-bootstrap-token-auth=true --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key --etcd-servers=https://127.0.0.1:2379 --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --requestheader-allowed-names=front-proxy-client --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --requestheader-extra-headers-prefix=X-Remote-Extra- --requestheader-group-headers=X-Remote-Group --requestheader-username-headers=X-Remote-User --secure-port=6443 --service-account-issuer=https://kubernetes.default.svc.cluster.local --service-account-key-file=/etc/kubernetes/pki/sa.pub --service-account-signing-key-file=/etc/kubernetes/pki/sa.key --service-cluster-ip-range=10.96.0.0/12 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
root      129402  0.0  0.0   6432   720 pts/0    S+   20:08   0:00 grep --color=auto kube-apiserver

# So PID for this process 1586. Also check with below command
$ pgrep -o kube-apiserver
1586

# Now go to proc directory for details
$ find /proc/1586/root/ | grep kube-apiserver
/proc/1586/root/usr/local/bin/kube-apiserver
$ sha512sum /proc/1586/root/usr/local/bin/kube-apiserver
a6e6b01fc76f0f58a3f332442a927f1fefc2b6fb09c9683050426e47a5bcdaa9f7100713f3bc924ea27ba1c2ab28099644ce713f3d0ee957e0fdf99aa4aaab6d  /proc/1586/root/usr/local/bin/kube-apiserver
# Now you can compare this value paste into a file. And both must be same.
```
In this way we can check the k8s binary integrity with hash values from Github source.
