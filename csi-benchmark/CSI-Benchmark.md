# CSI Benchmark
In exam we dont need to install `kube-bench`. We need to fixed any `warning` or `critical` issue for `etcd`, `kubelet`, `kubedns`, `kubeapi` etc.

Installation link `https://aquasecurity.github.io/kube-bench/v0.6.5/installation/`

## Run `kube-bench` with binary file

kube-bench is a tool that checks whether Kubernetes is deployed securely by running the checks documented in the CIS Kubernetes Benchmark.
```bash
curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.4.0/kube-bench_0.4.0_linux_amd64.tar.gz -o kube-bench_0.4.0_linux_amd64.tar.gz
tar -xvf kube-bench_0.4.0_linux_amd64.tar.gz
```

Run a kube-bench test now and see the results

Run below command to run kube bench
```bash
 ./kube-bench --config-dir `pwd`/cfg --config `pwd`/cfg/config.yaml
```

## Run `kube-bench` with docker/podman

Docker image `https://hub.docker.com/r/aquasec/kube-bench`

```bash
docker run --rm -v `pwd`:/host aquasec/kube-bench:latest install
./kube-bench
```

## After run the `kube-bench` we need to fix the critical issue

Need to resovle below problem
```plaintext
1.1.12 Ensure that the etcd data directory ownership is set to etcd:etcd (Automated)

# Resolution
1.1.12 On the etcd server node, get the etcd data directory, passed as an argument --data-dir,
from the command 'ps -ef | grep etcd'.
Run the below command (based on the etcd data directory found above).
For example, chown etcd:etcd /var/lib/etcd

If user not exist please create the user and run the chown command.
```

Now run `kube-bench` again. You can see `1.1.12` will be `PASS`