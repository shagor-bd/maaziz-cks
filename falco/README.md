![Falco](../images/falco-horizontal-color.png)
# Falco 

## Task

|       **12**        | **Falco, sysdig**                                                                                                                                                                                                                                       |
| :-----------------: |:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     Task weight     | 6%                                                                                                                                                                                                                                                      |
|       Cluster       | default                                                                                                                                                                                                                                                 |
| Acceptance criteria | use `falco` or `sysdig`, prepare logs in format:<br/><br/>`time-with-nanosconds,container-id,container-name,user-name,kubernetes-namespace,kubernetes-pod-name`<br/><br/>for pod with image `nginx` and store log to `/var/work/tests/artifacts/12/log` |
---

## Install Falco or Sysdig in Worker Node

### Falco

```bash
#!/bin/bash
echo " *** worker node 02"

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


```






### References:

https://falco.org/docs/getting-started/installation/

https://github.com/falcosecurity/charts/tree/master/falco

https://falco.org/docs/rules/supported-fields/

https://falco.org/docs/rules/default-macros/

https://falco.org/docs/configuration/
