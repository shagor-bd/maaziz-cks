# Capture packets in Kubernetes

## Install ksniff and related tools
Ksniff is a plugin for kubectl, and you must install **Krew** before you can start using it. And **krew** is a plugin manager for kubernetes
### Install **krew** in bash or zsh

Make sure that `git` is installed


```bash
set -x; cd "$(mktemp -d)" &&
OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
KREW="krew-${OS}_${ARCH}" &&
curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
tar zxvf "${KREW}.tar.gz" &&
./"${KREW}" install krew
```

Add the `$HOME/.krew/bin` directory to your PATH environment variable. To do this, update your `.bashrc` or `.zshrc` file and append the following line:
```bash
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
```
Restart your shell.

Run kubectl krew to check the installation.
```plaintext
➜  kubectl krew              
krew is the kubectl plugin manager.
You can invoke krew through kubectl: "kubectl krew [command]..."

Usage:
  kubectl krew [command]

Available Commands:
  help        Help about any command
  index       Manage custom plugin indexes
  info        Show information about an available plugin
  install     Install kubectl plugins
  list        List installed kubectl plugins
  search      Discover kubectl plugins
  uninstall   Uninstall plugins
  update      Update the local copy of the plugin index
  upgrade     Upgrade installed plugins to newer versions
  version     Show krew version and diagnostics

Flags:
  -h, --help      help for krew
  -v, --v Level   number for the log level verbosity

Use "kubectl krew [command] --help" for more information about a command.
```

### Now time to install **ksniff** 

```bash
kubectl krew install sniff
```
```plaintext
#Output
Updated the local copy of plugin index.
Installing plugin: sniff
Installed plugin: sniff
\
 | Use this plugin:
 | 	kubectl sniff
 | Documentation:
 | 	https://github.com/eldadru/ksniff
 | Caveats:
 | \
 |  | This plugin needs the following programs:
 |  | * wireshark (optional, used for live capture)
 | /
/
WARNING: You installed plugin "sniff" from the krew-index plugin repository.
   These plugins are not audited for security by the Krew maintainers.
   Run them at your own risk.
```
### Set up a workload to test
```bash
$ kubectl run --image=nginx nginx
pod/nginx created

$ kubectl get pod
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          4s
```
Once the pod is running, you can expose it as a NodePort service. While most admins generally avoid NodePort services in production, they provide a convenient way to test a service quickly:

```bash
$ kubectl expose pod nginx --port 80 --type=NodePort
service/nginx exposed

$ kubectl get svc                                   
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        35d
nginx        NodePort    10.103.37.226   <none>        80:32336/TCP   25s

$ kubectl get nodes -o wide
NAME     STATUS   ROLES           AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
master   Ready    control-plane   35d   v1.31.1   192.168.0.110   <none>        Ubuntu 20.04.6 LTS   5.4.0-208-generic   containerd://1.6.12
worker   Ready    <none>          35d   v1.31.1   192.168.0.112   <none>        Ubuntu 20.04.6 LTS   5.4.0-212-generic   containerd://1.7.24
$ curl 192.168.0.112:32336                                               
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

#### Capture packets
```bash
kubectl sniff --namespace default nginx
```
##### Output
```plaintext
INFO[0000] using tcpdump path at: '/home/shagorbd/.krew/store/sniff/v1.6.2/static-tcpdump' 
INFO[0000] no container specified, taking first container we found in pod. 
INFO[0000] selected container: 'nginx'                  
INFO[0000] sniffing method: upload static tcpdump       
INFO[0000] sniffing on pod: 'nginx' [namespace: 'default', container: 'nginx', filter: '', interface: 'any'] 
INFO[0000] uploading static tcpdump binary from: '/home/shagorbd/.krew/store/sniff/v1.6.2/static-tcpdump' to: '/tmp/static-tcpdump' 
INFO[0000] uploading file: '/home/shagorbd/.krew/store/sniff/v1.6.2/static-tcpdump' to '/tmp/static-tcpdump' on container: 'nginx' 
INFO[0000] executing command: '[/bin/sh -c test -f /tmp/static-tcpdump]' on container: 'nginx', pod: 'nginx', namespace: 'default' 
INFO[0000] command: '[/bin/sh -c test -f /tmp/static-tcpdump]' executing successfully exitCode: '0', stdErr :'' 
INFO[0000] file found: ''                               
INFO[0000] file was already found on remote pod         
INFO[0000] tcpdump uploaded successfully                
INFO[0000] spawning wireshark!                          
INFO[0000] starting sniffer cleanup                     
INFO[0000] sniffer cleanup completed successfully       
Error: exec: "wireshark": executable file not found in $PATH
```

- Need to install **wireshark**





















### Reference link:
https://krew.sigs.k8s.io/docs/user-guide/setup/install/#bash

https://www.redhat.com/en/blog/capture-packets-kubernetes-ksniff

