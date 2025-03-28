  204  kubectl create secret generic my-secret --from-literal=key1=supersecret
  205  k get secrets 
  206  ETCDCTL_API=3 etcdctl    --cacert=/etc/kubernetes/pki/etcd/ca.crt      --cert=/etc/kubernetes/pki/etcd/server.crt    --key=/etc/kubernetes/pki/etcd/server.key     get /registry/secrets/default/my-secret | hexdump -C
  207  ETCDCTL_API=3 etcdctl    --cacert=/etc/kubernetes/pki/etcd/ca.crt      --cert=/etc/kubernetes/pki/etcd/server.crt    --key=/etc/kubernetes/pki/etcd/server.key     get /registry/secrets/default/my-secret 
  208  head -c 32 /dev/urandom | base64
  209  vim enc.yaml
  210  mkdir /etc/kubernetes/enc
  211  mv enc.yaml /etc/kubernetes/enc/
  212  vim /etc/kubernetes/manifests/kube-apiserver.yaml \
  213  vim /etc/kubernetes/manifests/kube-apiserver.yaml
  214  k get pod
  215  crictl ps
  216  watchcrictl ps 
  217  watch crictl ps 
  218  vim /etc/kubernetes/manifests/kube-apiserver.yaml
  219  watch crictl ps 
  220  k get pod
  221  kubectl create secret generic my-secret-1 --from-literal=key1=supersecret
  222  ETCDCTL_API=3 etcdctl    --cacert=/etc/kubernetes/pki/etcd/ca.crt      --cert=/etc/kubernetes/pki/etcd/server.crt    --key=/etc/kubernetes/pki/etcd/server.key     get /registry/secrets/default/my-secret-1
  223  ETCDCTL_API=3 etcdctl    --cacert=/etc/kubernetes/pki/etcd/ca.crt      --cert=/etc/kubernetes/pki/etcd/server.crt    --key=/etc/kubernetes/pki/etcd/server.key     get /registry/secrets/default/my-secret
  224  k get secrets 
  225  ETCDCTL_API=3 etcdctl    --cacert=/etc/kubernetes/pki/etcd/ca.crt      --cert=/etc/kubernetes/pki/etcd/server.crt    --key=/etc/kubernetes/pki/etcd/server.key     get /registry/secrets/default/tls-secret
  226  kubectl get secrets --all-namespaces -o json | kubectl replace -f -
  227* ETCDCTL_API=3 etcdctl    --cacert=/etc/kubernetes/pki/etcd/ca.crt      --cert=/etc/kubernetes/pki/etcd/server.crt    --key=/etc/kubernetes/pki/etcd/server.key     get /registry/secrets/default/tls-secret-
  228  ETCDCTL_API=3 etcdctl    --cacert=/etc/kubernetes/pki/etcd/ca.crt      --cert=/etc/kubernetes/pki/etcd/server.crt    --key=/etc/kubernetes/pki/etcd/server.key     get /registry/secrets/default/my-secret-1
  229  ETCDCTL_API=3 etcdctl    --cacert=/etc/kubernetes/pki/etcd/ca.crt      --cert=/etc/kubernetes/pki/etcd/server.crt    --key=/etc/kubernetes/pki/etcd/server.key     get /registry/secrets/default/my-secret

