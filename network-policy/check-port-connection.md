bash```
kubectl -n myapp exec database-67c5bccd6c-hsb5d -- curl -s 10.105.63.127:8080 | tr -d '\n'
                                                   wget --spider --timeout=1 nginx
```
## Get Service and POD network CIRD
```bash
➜  kubectl cluster-info dump | grep -m 1 service-cluster-ip-range
                            "--service-cluster-ip-range=10.96.0.0/12",
➜  kubectl get node master -o jsonpath='{.spec.podCIDR}'
192.168.0.0/24 
```
## Check service with temprary pod
```bash
k -n default run nginx1 --image=nginx:1.21.5-alpine --restart=Never -i --rm  -- curl microservice1.app.svc.cluster.local
```

## Some command for check nwtwork policy
```bash
# these should work
k -n space1 exec app1-0 -- curl -m 1 microservice1.space2.svc.cluster.local
k -n space1 exec app1-0 -- curl -m 1 microservice2.space2.svc.cluster.local
k -n space1 exec app1-0 -- nslookup tester.default.svc.cluster.local
k -n kube-system exec -it validate-checker-pod -- curl -m 1 app1.space1.svc.cluster.local

# these should not work
k -n space1 exec app1-0 -- curl -m 1 tester.default.svc.cluster.local
k -n kube-system exec -it validate-checker-pod -- curl -m 1 microservice1.space2.svc.cluster.local
k -n kube-system exec -it validate-checker-pod -- curl -m 1 microservice2.space2.svc.cluster.local
k -n default run nginx --image=nginx:1.21.5-alpine --restart=Never -i --rm  -- curl -m 1 microservice1.space2.svc.cluster.local
```
## A pod thats have nc,curl,nslookup command.
```plaintext
nginx:1.21.5-alpine
```