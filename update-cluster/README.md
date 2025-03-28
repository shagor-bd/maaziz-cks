➜  update-cluster git:(main) ✗ k get node
NAME     STATUS   ROLES           AGE   VERSION
master   Ready    control-plane   20d   v1.31.1
worker   Ready    <none>          20d   v1.31.1
➜  update-cluster git:(main) ✗ master
sysadmin@192.168.0.110's password: 
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-208-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue 25 Mar 2025 05:06:59 PM UTC

  System load:  1.68               Processes:               182
  Usage of /:   42.1% of 23.45GB   Users logged in:         0
  Memory usage: 22%                IPv4 address for enp0s3: 192.168.0.110
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

1 update can be applied immediately.
To see these additional updates run: apt list --upgradable

1 additional security update can be applied with ESM Apps.
Learn more about enabling ESM Apps service at https://ubuntu.com/esm


The list of available updates is more than a week old.
To check for new updates run: sudo apt update

Last login: Sun Mar 23 18:57:35 2025 from 192.168.0.141
sysadmin@master:~$ sudo -i
[sudo] password for sysadmin: 
root@master:~# apt-mark --help
apt 2.0.10 (amd64)
Usage: apt-mark [options] {auto|manual} pkg1 [pkg2 ...]

apt-mark is a simple command line interface for marking packages
as manually or automatically installed. It can also be used to
manipulate the dpkg(1) selection states of packages, and to list
all packages with or without a certain marking.

Most used commands:
  auto - Mark the given packages as automatically installed
  manual - Mark the given packages as manually installed
  minimize-manual - Mark all dependencies of meta packages as automatically installed.
  hold - Mark a package as held back
  unhold - Unset a package set as held back
  showauto - Print the list of automatically installed packages
  showmanual - Print the list of manually installed packages
  showhold - Print the list of packages on hold

See apt-mark(8) for more information about the available commands.
Configuration options and syntax is detailed in apt.conf(5).
Information about how to configure sources can be found in sources.list(5).
Package and version choices can be expressed via apt_preferences(5).
Security details are available in apt-secure(8).
root@master:~# apt-mark showhold kubeadm
kubeadm
root@master:~# apt-mark unhold kubeadm
Canceled hold on kubeadm.
root@master:~# apt-mark showhold kubeadm
root@master:~# apt-mark unhold kubeadm
kubeadm was already not hold.
root@master:~# apt-get update
Hit:1 http://bd.archive.ubuntu.com/ubuntu focal InRelease           
Get:3 http://bd.archive.ubuntu.com/ubuntu focal-updates InRelease [128 kB]
Hit:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  InRelease
Hit:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.30/deb  InRelease
Get:5 http://bd.archive.ubuntu.com/ubuntu focal-backports InRelease [128 kB]
Get:6 http://bd.archive.ubuntu.com/ubuntu focal-security InRelease [128 kB]
Get:7 http://bd.archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages [3,836 kB]
Get:8 http://bd.archive.ubuntu.com/ubuntu focal-updates/main Translation-en [585 kB]
Get:9 http://bd.archive.ubuntu.com/ubuntu focal-updates/main amd64 c-n-f Metadata [18.0 kB]
Get:10 http://bd.archive.ubuntu.com/ubuntu focal-updates/restricted amd64 Packages [3,672 kB]
Get:11 http://bd.archive.ubuntu.com/ubuntu focal-updates/restricted Translation-en [514 kB]
Get:12 http://bd.archive.ubuntu.com/ubuntu focal-updates/restricted amd64 c-n-f Metadata [604 B]
Get:13 http://bd.archive.ubuntu.com/ubuntu focal-updates/universe amd64 Packages [1,260 kB]
Get:14 http://bd.archive.ubuntu.com/ubuntu focal-updates/universe Translation-en [303 kB]
Get:15 http://bd.archive.ubuntu.com/ubuntu focal-updates/universe amd64 c-n-f Metadata [29.3 kB]
Get:16 http://bd.archive.ubuntu.com/ubuntu focal-updates/multiverse amd64 Packages [29.7 kB]
Get:17 http://bd.archive.ubuntu.com/ubuntu focal-updates/multiverse Translation-en [8,316 B]
Get:18 http://bd.archive.ubuntu.com/ubuntu focal-updates/multiverse amd64 c-n-f Metadata [688 B]
Get:19 http://bd.archive.ubuntu.com/ubuntu focal-security/main amd64 Packages [3,433 kB]
Get:20 http://bd.archive.ubuntu.com/ubuntu focal-security/main amd64 c-n-f Metadata [14.5 kB]
Get:21 http://bd.archive.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [3,492 kB]
Get:22 http://bd.archive.ubuntu.com/ubuntu focal-security/restricted Translation-en [488 kB]
Get:23 http://bd.archive.ubuntu.com/ubuntu focal-security/restricted amd64 c-n-f Metadata [584 B]
Get:24 http://bd.archive.ubuntu.com/ubuntu focal-security/universe amd64 Packages [1,036 kB]
Get:25 http://bd.archive.ubuntu.com/ubuntu focal-security/universe Translation-en [220 kB]
Get:26 http://bd.archive.ubuntu.com/ubuntu focal-security/universe amd64 c-n-f Metadata [22.5 kB]
Get:27 http://bd.archive.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [26.6 kB]
Get:28 http://bd.archive.ubuntu.com/ubuntu focal-security/multiverse Translation-en [6,448 B]
Get:29 http://bd.archive.ubuntu.com/ubuntu focal-security/multiverse amd64 c-n-f Metadata [604 B]
Fetched 19.4 MB in 12s (1,661 kB/s)                                            
Reading package lists... Done
root@master:~# apt-cache madison kubeadm 
   kubeadm | 1.31.7-1.1 | https://pkgs.k8s.io/core:/stable:/v1.31/deb  Packages
   kubeadm | 1.31.6-1.1 | https://pkgs.k8s.io/core:/stable:/v1.31/deb  Packages
   kubeadm | 1.31.5-1.1 | https://pkgs.k8s.io/core:/stable:/v1.31/deb  Packages
   kubeadm | 1.31.4-1.1 | https://pkgs.k8s.io/core:/stable:/v1.31/deb  Packages
   kubeadm | 1.31.3-1.1 | https://pkgs.k8s.io/core:/stable:/v1.31/deb  Packages
   kubeadm | 1.31.2-1.1 | https://pkgs.k8s.io/core:/stable:/v1.31/deb  Packages
   kubeadm | 1.31.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.31/deb  Packages
   kubeadm | 1.31.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.31/deb  Packages
   kubeadm | 1.30.11-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.10-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.9-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.8-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.7-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.6-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.5-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.4-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.3-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.2-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
   kubeadm | 1.30.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.30/deb  Packages
root@master:~# k get nodes
NAME     STATUS   ROLES           AGE   VERSION
master   Ready    control-plane   20d   v1.31.1
worker   Ready    <none>          20d   v1.31.1
root@master:~# apt-get install -y kube
kubeadm         kubelet         kubernetes-cni  
kubectl         kubernetes      kubetail        
root@master:~# apt-get install -y kubeadm='1.31.7-1.1'
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages will be upgraded:
  kubeadm
1 upgraded, 0 newly installed, 0 to remove and 13 not upgraded.
Need to get 11.5 MB of archives.
After this operation, 422 kB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubeadm 1.31.7-1.1 [11.5 MB]
Fetched 11.5 MB in 6s (1,791 kB/s)                                             
(Reading database ... 110254 files and directories currently installed.)
Preparing to unpack .../kubeadm_1.31.7-1.1_amd64.deb ...
Unpacking kubeadm (1.31.7-1.1) over (1.31.1-1.1) ...
Setting up kubeadm (1.31.7-1.1) ...
root@master:~# apt-mark hold kubeadm
kubeadm set on hold.
root@master:~# kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"31", GitVersion:"v1.31.7", GitCommit:"da53587841b4960dc3bd2af1ec6101b57c79aff4", GitTreeState:"clean", BuildDate:"2025-03-11T20:02:21Z", GoVersion:"go1.23.6", Compiler:"gc", Platform:"linux/amd64"}
root@master:~# kubeadm upgrade plan
[preflight] Running pre-flight checks.
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: 1.31.1
[upgrade/versions] kubeadm version: v1.31.7
I0325 17:11:09.044585    7977 version.go:261] remote version is much newer: v1.32.3; falling back to: stable-1.31
[upgrade/versions] Target version: v1.31.7
[upgrade/versions] Latest version in the v1.31 series: v1.31.7

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   NODE      CURRENT   TARGET
kubelet     master    v1.31.1   v1.31.7
kubelet     worker    v1.31.1   v1.31.7

Upgrade to the latest version in the v1.31 series:

COMPONENT                 NODE      CURRENT    TARGET
kube-apiserver            master    v1.31.1    v1.31.7
kube-controller-manager   master    v1.31.1    v1.31.7
kube-scheduler            master    v1.31.1    v1.31.7
kube-proxy                          1.31.1     v1.31.7
CoreDNS                             v1.11.3    v1.11.3
etcd                      master    3.5.15-0   3.5.15-0

You can now apply the upgrade by executing the following command:

	kubeadm upgrade apply v1.31.7

_____________________________________________________________________


The table below shows the current state of component configs as understood by this version of kubeadm.
Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
upgrade to is denoted in the "PREFERRED VERSION" column.

API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
kubeproxy.config.k8s.io   v1alpha1          v1alpha1            no
kubelet.config.k8s.io     v1beta1           v1beta1             no
_____________________________________________________________________

root@master:~# kubeadm upgrade apply v1.31.7
[preflight] Running pre-flight checks.
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[upgrade] Running cluster health checks
[upgrade/version] You have chosen to change the cluster version to "v1.31.7"
[upgrade/versions] Cluster version: v1.31.1
[upgrade/versions] kubeadm version: v1.31.7
[upgrade] Are you sure you want to proceed? [y/N]: y
[upgrade/prepull] Pulling images required for setting up a Kubernetes cluster
[upgrade/prepull] This might take a minute or two, depending on the speed of your internet connection
[upgrade/prepull] You can also perform this action beforehand using 'kubeadm config images pull'
W0325 17:11:54.499052    8484 checks.go:846] detected that the sandbox image "registry.k8s.io/pause:3.6" of the container runtime is inconsistent with that used by kubeadm.It is recommended to use "registry.k8s.io/pause:3.10" as the CRI sandbox image.
[upgrade/apply] Upgrading your Static Pod-hosted control plane to version "v1.31.7" (timeout: 5m0s)...
[upgrade/staticpods] Writing new Static Pod manifests to "/etc/kubernetes/tmp/kubeadm-upgraded-manifests4134544291"
[upgrade/staticpods] Preparing for "etcd" upgrade
[upgrade/staticpods] Renewing etcd-server certificate
[upgrade/staticpods] Renewing etcd-peer certificate
[upgrade/staticpods] Renewing etcd-healthcheck-client certificate
[upgrade/staticpods] Restarting the etcd static pod and backing up its manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2025-03-25-17-13-19/etcd.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=etcd
[upgrade/staticpods] Component "etcd" upgraded successfully!
[upgrade/etcd] Waiting for etcd to become available
[upgrade/staticpods] Preparing for "kube-apiserver" upgrade
[upgrade/staticpods] Renewing apiserver certificate
[upgrade/staticpods] Renewing apiserver-kubelet-client certificate
[upgrade/staticpods] Renewing front-proxy-client certificate
[upgrade/staticpods] Renewing apiserver-etcd-client certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-apiserver.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2025-03-25-17-13-19/kube-apiserver.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-apiserver
[upgrade/staticpods] Component "kube-apiserver" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-controller-manager" upgrade
[upgrade/staticpods] Renewing controller-manager.conf certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-controller-manager.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2025-03-25-17-13-19/kube-controller-manager.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-controller-manager
[upgrade/staticpods] Component "kube-controller-manager" upgraded successfully!
[upgrade/staticpods] Preparing for "kube-scheduler" upgrade
[upgrade/staticpods] Renewing scheduler.conf certificate
[upgrade/staticpods] Moving new manifest to "/etc/kubernetes/manifests/kube-scheduler.yaml" and backing up old manifest to "/etc/kubernetes/tmp/kubeadm-backup-manifests-2025-03-25-17-13-19/kube-scheduler.yaml"
[upgrade/staticpods] Waiting for the kubelet to restart the component
[upgrade/staticpods] This can take up to 5m0s
[apiclient] Found 1 Pods for label selector component=kube-scheduler
[upgrade/staticpods] Component "kube-scheduler" upgraded successfully!
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upgrade] Backing up kubelet config file to /etc/kubernetes/tmp/kubeadm-kubelet-config2404247076/config.yaml
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.31.7". Enjoy!

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
root@master:~# kubectl drain master --ignore-daemonsets 
node/master cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/canal-v7w9v, kube-system/kube-proxy-r7rvm
evicting pod kube-system/coredns-7c65d6cfc9-z2xs8
evicting pod kube-system/calico-kube-controllers-94fb6bc47-4bfvm
evicting pod kube-system/coredns-7c65d6cfc9-5ssqz
pod/calico-kube-controllers-94fb6bc47-4bfvm evicted
pod/coredns-7c65d6cfc9-5ssqz evicted
pod/coredns-7c65d6cfc9-z2xs8 evicted
node/master drained
root@master:~# apt-mark unhold kubelet kubectl
Canceled hold on kubelet.
Canceled hold on kubectl.
root@master:~# apt-get install -y kubelet='1.31.7-1.1' kubectl='1.31.7-1.1'
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages will be upgraded:
  kubectl kubelet
2 upgraded, 0 newly installed, 0 to remove and 11 not upgraded.
Need to get 26.6 MB of archives.
After this operation, 938 kB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubectl 1.31.7-1.1 [11.3 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubelet 1.31.7-1.1 [15.3 MB]
Fetched 26.6 MB in 12s (2,233 kB/s)                                            
(Reading database ... 110254 files and directories currently installed.)
Preparing to unpack .../kubectl_1.31.7-1.1_amd64.deb ...
Unpacking kubectl (1.31.7-1.1) over (1.31.1-1.1) ...
Preparing to unpack .../kubelet_1.31.7-1.1_amd64.deb ...
Unpacking kubelet (1.31.7-1.1) over (1.31.1-1.1) ...
Setting up kubectl (1.31.7-1.1) ...
Setting up kubelet (1.31.7-1.1) ...
root@master:~# apt-mark hold kubelet kubectl
kubelet set on hold.
kubectl set on hold.
root@master:~# kubectl uncordon master 
node/master uncordoned
root@master:~# systemctl daemon-reload 
root@master:~# systemctl restart kubelet
root@master:~# kubectl get nodes
NAME     STATUS   ROLES           AGE   VERSION
master   Ready    control-plane   20d   v1.31.7
worker   Ready    <none>          20d   v1.31.1


--------------- Do this before move to worker node to update-----------------------------------------
➜  update-cluster git:(main) ✗ kubectl cordon worker 
node/worker cordoned
➜  update-cluster git:(main) ✗ kubectl drain worker --ignore-daemonsets 
node/worker already cordoned
error: unable to drain node "worker" due to error: [cannot delete cannot delete Pods that declare no controller (use --force to override): default/httpd, default/no-trust, default/trust, cannot delete Pods with local storage (use --delete-emptydir-data to override): kubernetes-dashboard/kubernetes-dashboard-api-85567747f8-2txhk, kubernetes-dashboard/kubernetes-dashboard-auth-74bb6f5d65-cqbtx, kubernetes-dashboard/kubernetes-dashboard-kong-678c76c548-cvwxj, kubernetes-dashboard/kubernetes-dashboard-metrics-scraper-7d9658df44-8d2tq, kubernetes-dashboard/kubernetes-dashboard-web-66b75c6c7f-fdrf7, mydb/database-67c5bccd6c-lt5ln], continuing command...
There are pending nodes to be drained:
 worker
cannot delete cannot delete Pods that declare no controller (use --force to override): default/httpd, default/no-trust, default/trust
cannot delete Pods with local storage (use --delete-emptydir-data to override): kubernetes-dashboard/kubernetes-dashboard-api-85567747f8-2txhk, kubernetes-dashboard/kubernetes-dashboard-auth-74bb6f5d65-cqbtx, kubernetes-dashboard/kubernetes-dashboard-kong-678c76c548-cvwxj, kubernetes-dashboard/kubernetes-dashboard-metrics-scraper-7d9658df44-8d2tq, kubernetes-dashboard/kubernetes-dashboard-web-66b75c6c7f-fdrf7, mydb/database-67c5bccd6c-lt5ln



root@master:~# exit
logout
sysadmin@master:~$ exit
logout
Connection to 192.168.0.110 closed.
➜  update-cluster git:(main) ✗ worker
sysadmin@192.168.0.112's password: 
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-208-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue 25 Mar 2025 05:18:46 PM UTC

  System load:  0.4                Processes:               228
  Usage of /:   53.3% of 23.45GB   Users logged in:         0
  Memory usage: 31%                IPv4 address for enp0s3: 192.168.0.112
  Swap usage:   0%

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Expanded Security Maintenance for Applications is not enabled.

1 update can be applied immediately.
To see these additional updates run: apt list --upgradable

1 additional security update can be applied with ESM Apps.
Learn more about enabling ESM Apps service at https://ubuntu.com/esm


Last login: Sun Mar 23 18:57:48 2025 from 192.168.0.141
sysadmin@worker:~$ sudo -i
[sudo] password for sysadmin: 
root@worker:~# apt-get unhold kubeadm
E: Invalid operation unhold
root@worker:~# apt-mark unhold kubeadm
Canceled hold on kubeadm.
root@worker:~# apt-get update
Hit:1 http://bd.archive.ubuntu.com/ubuntu focal InRelease
Get:2 http://bd.archive.ubuntu.com/ubuntu focal-updates InRelease [128 kB]
Hit:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  InRelease
Hit:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.30/deb  InRelease
Get:5 http://bd.archive.ubuntu.com/ubuntu focal-backports InRelease [128 kB]
Get:6 http://bd.archive.ubuntu.com/ubuntu focal-security InRelease [128 kB]
Get:7 http://bd.archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages [3,836 kB]
Get:8 http://bd.archive.ubuntu.com/ubuntu focal-updates/main Translation-en [585 kB]
Get:9 http://bd.archive.ubuntu.com/ubuntu focal-updates/main amd64 c-n-f Metadata [18.0 kB]
Get:10 http://bd.archive.ubuntu.com/ubuntu focal-updates/restricted amd64 Packages [3,672 kB]
Get:11 http://bd.archive.ubuntu.com/ubuntu focal-updates/restricted Translation-en [514 kB]
Get:12 http://bd.archive.ubuntu.com/ubuntu focal-updates/restricted amd64 c-n-f Metadata [604 B]
Get:13 http://bd.archive.ubuntu.com/ubuntu focal-updates/universe amd64 Packages [1,260 kB]
Get:14 http://bd.archive.ubuntu.com/ubuntu focal-updates/universe Translation-en [303 kB]
Get:15 http://bd.archive.ubuntu.com/ubuntu focal-updates/universe amd64 c-n-f Metadata [29.3 kB]
Get:16 http://bd.archive.ubuntu.com/ubuntu focal-updates/multiverse amd64 Packages [29.7 kB]
Get:17 http://bd.archive.ubuntu.com/ubuntu focal-updates/multiverse Translation-en [8,316 B]
Get:18 http://bd.archive.ubuntu.com/ubuntu focal-updates/multiverse amd64 c-n-f Metadata [688 B]
Get:19 http://bd.archive.ubuntu.com/ubuntu focal-security/main amd64 Packages [3,433 kB]
Get:20 http://bd.archive.ubuntu.com/ubuntu focal-security/main amd64 c-n-f Metadata [14.5 kB]
Get:21 http://bd.archive.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [3,492 kB]
Get:22 http://bd.archive.ubuntu.com/ubuntu focal-security/restricted Translation-en [488 kB]
Get:23 http://bd.archive.ubuntu.com/ubuntu focal-security/restricted amd64 c-n-f Metadata [584 B]
Get:24 http://bd.archive.ubuntu.com/ubuntu focal-security/universe amd64 Packages [1,036 kB]
Get:25 http://bd.archive.ubuntu.com/ubuntu focal-security/universe Translation-en [220 kB]
Get:26 http://bd.archive.ubuntu.com/ubuntu focal-security/universe amd64 c-n-f Metadata [22.5 kB]
Get:27 http://bd.archive.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [26.6 kB]
Get:28 http://bd.archive.ubuntu.com/ubuntu focal-security/multiverse Translation-en [6,448 B]
Get:29 http://bd.archive.ubuntu.com/ubuntu focal-security/multiverse amd64 c-n-f Metadata [604 B]
Fetched 19.4 MB in 30s (637 kB/s)                                              
Reading package lists... Done
root@worker:~# apt-get install -y kubeadm-'1.31.7-1.1'
Reading package lists... Done
Building dependency tree       
Reading state information... Done
E: Unable to locate package kubeadm-1.31.7-1.1
E: Couldn't find any package by glob 'kubeadm-1.31.7-1.1'
E: Couldn't find any package by regex 'kubeadm-1.31.7-1.1'
root@worker:~# apt-get install -y kubeadm='1.31.7-1.1'
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages will be upgraded:
  kubeadm
1 upgraded, 0 newly installed, 0 to remove and 13 not upgraded.
Need to get 11.5 MB of archives.
After this operation, 422 kB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubeadm 1.31.7-1.1 [11.5 MB]
Fetched 11.5 MB in 5s (2,158 kB/s)  
(Reading database ... 110254 files and directories currently installed.)
Preparing to unpack .../kubeadm_1.31.7-1.1_amd64.deb ...
Unpacking kubeadm (1.31.7-1.1) over (1.31.1-1.1) ...
Setting up kubeadm (1.31.7-1.1) ...
root@worker:~# apt-mark hold kubeadm
kubeadm set on hold.
root@worker:~# kubeadm upgrade node
[upgrade] Reading configuration from the cluster...
[upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[preflight] Running pre-flight checks
[preflight] Skipping prepull. Not a control plane node.
[upgrade] Skipping phase. Not a control plane node.
[upgrade] Skipping phase. Not a control plane node.
[upgrade] Backing up kubelet config file to /etc/kubernetes/tmp/kubeadm-kubelet-config862048109/config.yaml
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade] The configuration for this node was successfully updated!
[upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
root@worker:~# kubectl upgrade node
error: unknown command "upgrade" for "kubectl"
root@worker:~# kubeadm upgrade node
kubeadm
root@worker:~# kubeadm upgrade node
[upgrade] Reading configuration from the cluster...
[upgrade] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[preflight] Running pre-flight checks
[preflight] Skipping prepull. Not a control plane node.
[upgrade] Skipping phase. Not a control plane node.
[upgrade] Skipping phase. Not a control plane node.
[upgrade] Backing up kubelet config file to /etc/kubernetes/tmp/kubeadm-kubelet-config2213270566/config.yaml
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[upgrade] The configuration for this node was successfully updated!
[upgrade] Now you should go ahead and upgrade the kubelet package using your package manager.
root@worker:~# apt-mark unhold kubelet kubectl
Canceled hold on kubelet.
Canceled hold on kubectl.
root@worker:~# apt-get install -y kubelet='1.31.7-1.1' kubectl='1.31.7-1.1'
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages will be upgraded:
  kubectl kubelet
2 upgraded, 0 newly installed, 0 to remove and 11 not upgraded.
Need to get 26.6 MB of archives.
After this operation, 938 kB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubectl 1.31.7-1.1 [11.3 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubelet 1.31.7-1.1 [15.3 MB]
Fetched 26.6 MB in 11s (2,340 kB/s)                                            
(Reading database ... 110254 files and directories currently installed.)
Preparing to unpack .../kubectl_1.31.7-1.1_amd64.deb ...
Unpacking kubectl (1.31.7-1.1) over (1.31.1-1.1) ...
Preparing to unpack .../kubelet_1.31.7-1.1_amd64.deb ...
Unpacking kubelet (1.31.7-1.1) over (1.31.1-1.1) ...
Setting up kubectl (1.31.7-1.1) ...
Setting up kubelet (1.31.7-1.1) ...
root@worker:~# apt-mark hold kubelet kubectl
kubelet set on hold.
kubectl set on hold.
root@worker:~# systemctl daemon-reload 
root@worker:~# systemctl restart kubelet

➜  update-cluster git:(main) ✗ kubectl uncordon worker 
node/worker uncordoned
➜  update-cluster git:(main) ✗ k get nodes
NAME     STATUS   ROLES           AGE   VERSION
master   Ready    control-plane   20d   v1.31.7
worker   Ready    <none>          20d   v1.31.7
