Manually sign the CSR with the K8s CA file to generate the CRT at /root/60099.crt .

Create a new context for kubectl named 60099@internal.users which uses this CRT to connect to K8s.


Tip 1

openssl x509 -req -in XXX -CA XXX -CAkey XXX -CAcreateserial -out XXX -days 500

Tip 2

find /etc/kubernetes/pki | grep ca

Solution 1

openssl x509 -req -in 60099.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out 60099.crt -days 500

Solution 2

k config set-credentials 60099@internal.users --client-key=60099.key --client-certificate=60099.crt
k config set-context 60099@internal.users --cluster=kubernetes --user=60099@internal.users
k config get-contexts
k config use-context 60099@internal.users
k get ns # fails because no permissions, but shows the correct username returned






Ref:
https://kubernetes.io/docs/tasks/tls/certificate-issue-client-csr/
