![Falco](../images/falco-horizontal-color.png)
# Falco 

## Task

|  **Falco, sysdig**             |                                                                                                                                                                                                                                       |
| :-----------------: |:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     Task weight     | 6%                                                                                                                                                                                                                                                      |                                                                                            |
| Acceptance criteria | use `falco` or `sysdig`, prepare logs in format:<br/><br/>`time-with-nanosconds,container-id,container-name,user-name,kubernetes-namespace,kubernetes-pod-name`<br/><br/>for pod with image `nginx` and store log to `/var/work/tests/artifacts/12/log` |
---

## Install Falco or Sysdig in Worker Node

### Falco

```bash
#!/bin/bash
echo " *** worker node"

curl -s https://falco.org/repo/falcosecurity-packages.asc | apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" \ | tee -a /etc/apt/sources.list.d/falcosecurity.list
apt-get update

apt search linux-headers-$(uname -r)
apt-get -y install linux-headers-$(uname -r)
apt-get install -y falco=0.33.1

systemctl status falco
```
Falco logs will store in `/var/log/syslog`

### Sysdig
If falco installed and running in the worker nodes, disable the falco service
```bash
systemctl disable falco
systemctl stop falco
```

```bash
#!/bin/bash
echo " *** worker node 02"

curl -s https://download.sysdig.com/DRAIOS-GPG-KEY.public | sudo apt-key add -
curl -s -o /etc/apt/sources.list.d/draios.list https://download.sysdig.com/stable/deb/draios.list
apt-get update
apt-get -y install sysdig
```
## Task preparation

```bash
kubectl label nodes worker work_type=falco
kubectl apply -f https://raw.githubusercontent.com/shagor-bd/maaziz-cks/refs/heads/main/falco/task.yaml
```
```plaintext
namespace/blue-team created
deployment.apps/deployment1 created
deployment.apps/deployment1 created
deployment.apps/deployment2 created
deployment.apps/deployment3 created
```
Now chage the the logs as per the requirement, Need to update as per below falco configure.

**Check the falco configuration file**, run below command in worker node
```bash
$ cat falco.yaml | grep rules_file -A3
rules_file:
  - /etc/falco/falco_rules.yaml
  - /etc/falco/falco_rules.local.yaml
  - /etc/falco/rules.d
```
**For any custom rule** we can put in `falco_rules.local.yaml` or we can create custom `yaml` file under `rules.d`

Let add below rules `/etc/falco/falco_rules.local.yaml` 

```
# /etc/falco/falco_rules.local.yaml
- rule: Write below etc
  desc: an attempt to write to any file below /etc
  condition: write_etc_common
  output: "System /etc/passwd file opened for writing (%user.name,%container.name,%container.id,%k8s.pod.name,%k8s.ns.name,%evt.time)"
  priority: ERROR
  tags: [filesystem, mitre_persistence]

- rule: Launch Package Management Process in Container
  desc: Package management process ran inside container
  condition: >
    spawned_process
    and container
    and user.name != "_apt"
    and package_mgmt_procs
    and not package_mgmt_ancestor_procs
    and not user_known_package_manager_in_container
    and not pkg_mgmt_in_kube_proxy
  output: >
    Package management process launched in container (%user.name,%container.name,%container.id,%k8s.pod.name,%k8s.ns.name,%evt.time)
  priority: WARNING
  tags: [process, mitre_persistence]
```
**Also we can run below command for check the falco logs**

```bash
falco -U | grep httpd    # httpd is a pod name
```

**After that we can find the logs like below**

```plaintext
Apr 18 17:37:39 worker falco: 17:37:39.312219720: Error System /etc/passwd file opened for writing (<NA>,app,a5bacfdabc94,deployment2-bdcf48846-6t8nz,default,17:37:39.312219720)
Apr 18 17:37:39 worker falco: 17:37:39.315067828: Error System /etc/passwd file opened for writing (<NA>,httpd,f5990f1e0a6d,deployment1-5b48784cd6-9hzhj,default,17:37:39.315067828)
Apr 18 17:37:39 worker falco: 17:37:39.315736638: Error System /etc/passwd file opened for writing (<NA>,app,952f298a0053,deployment2-bdcf48846-969ng,default,17:37:39.315736638)
Apr 18 17:37:39 worker falco: 17:37:39.332855161: Error System /etc/passwd file opened for writing (<NA>,httpd,5ec5f06d892e,deployment1-5b48784cd6-dlz2b,blue-team,17:37:39.332855161)
Apr 18 17:37:48 worker falco: 17:37:48.253581779: Warning Package management process launched in container (<NA>,app,5e7307b4e570,deployment4-56c8977b6c-9lg6f,default,17:37:48.253581779)
Apr 18 17:37:51 worker falco: 17:37:51.237424351: Warning Package management process launched in container (<NA>,app,5e7307b4e570,deployment4-56c8977b6c-9lg6f,default,17:37:51.237424351)
Apr 18 17:37:51 worker falco[41961]: 17:37:48.253581779: Warning Package management process launched in container (<NA>,app,5e7307b4e570,deployment4-56c8977b6c-9lg6f,default,17:37:48.253581779)
Apr 18 17:37:51 worker falco[41961]: 17:37:51.237424351: Warning Package management process launched in container (<NA>,app,5e7307b4e570,deployment4-56c8977b6c-9lg6f,default,17:37:51.237424351)
```
**Scale down the deployment**
```bash
kubectl -n default scale deployments.apps deployment1 --replicas=0
kubectl -n default scale deployments.apps deployment2 --replicas=0
kubectl -n default scale deployments.apps deployment3 --replicas=0
kubectl -n default scale deployments.apps deployment4 --replicas=0
kubectl -n blue-team scale deployments.apps deployment1 --replicas=0
```


### References:

https://falco.org/docs/reference/rules/supported-fields<br>
https://falco.org/docs/getting-started/installation/</br>
https://github.com/falcosecurity/charts/tree/master/falco</br>
https://falco.org/docs/rules/supported-fields/</br>
https://falco.org/docs/rules/default-macros/</br>
https://falco.org/docs/configuration/</br>
