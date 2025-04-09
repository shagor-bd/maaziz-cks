controlplane ~ ➜  cat nginx-latest.yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-latest
  labels:
    tier: nginx-latest
spec:
  # modify replicas according to your case
  replicas: 1
  selector:
    matchLabels:
      tier: nginx-latest
  template:
    metadata:
      labels:
        tier: nginx-latest
    spec:
      containers:
      - name: nginx-latest
        image: nginx




Let us now deploy an Image Policy Webhook server.

Deploy it using the file image-policy-webhook.yaml


This will deploy the simple webhook endpoint server and expose it as a service.



controlplane ~ ➜  cat image-policy-webhook.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app: image-bouncer-webhook
  name: image-bouncer-webhook
spec:
  type: NodePort
  ports:
    - name: https
      port: 443
      targetPort: 1323
      protocol: "TCP"
      nodePort: 30080
  selector:
    app: image-bouncer-webhook
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: image-bouncer-webhook
spec:
  selector:
    matchLabels:
      app: image-bouncer-webhook
  template:
    metadata:
      labels:
        app: image-bouncer-webhook
    spec:
      containers:
        - name: image-bouncer-webhook
          imagePullPolicy: Always
          image: "kainlite/kube-image-bouncer:latest"
          args:
            - "--cert=/etc/admission-controller/tls/tls.crt"
            - "--key=/etc/admission-controller/tls/tls.key"
            - "--debug"
            - "--registry-whitelist=docker.io,registry.k8s.io"
          volumeMounts:
            - name: tls
              mountPath: /etc/admission-controller/tls
      volumes:
        - name: tls
          secret:
            secretName: tls-image-bouncer-webhook

controlplane ~ ➜  cat server.csr
-----BEGIN CERTIFICATE REQUEST-----
MIIBozCCAUgCAQAwXTEVMBMGA1UEChMMc3lzdGVtOm5vZGVzMUQwQgYDVQQDEztz
eXN0ZW06bm9kZTppbWFnZS1ib3VuY2VyLXdlYmhvb2suZGVmYXVsdC5wb2QuY2x1
c3Rlci5sb2NhbDBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABEUsGZ1Zj6vJywzZ
4dY0YjQBr0O6TKSLgtCH0V5UlFl1SKnWxBg6av23sH0XWmPxXeVqcHsVHmquVawd
BS5ClDGggYgwgYUGCSqGSIb3DQEJDjF4MHYwdAYDVR0RBG0wa4IVaW1hZ2UtYm91
bmNlci13ZWJob29rgiFpbWFnZS1ib3VuY2VyLXdlYmhvb2suZGVmYXVsdC5zdmOC
L2ltYWdlLWJvdW5jZXItd2ViaG9vay5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2Fs
MAoGCCqGSM49BAMCA0kAMEYCIQCbPl3nqDvPFiYsRxPnXFTQ7egiDnJyEhGIoDdk
96wtNwIhAOFVRnO/2516QSj1xfn2BGOACFArWb0EtumD6JzNF2he
-----END CERTIFICATE REQUEST-----

controlplane ~ ➜  cat server-key.pem
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIICau1K3jtzg1g+UsTBXfCX2m/T3J0cM/m+nAheJjBXroAoGCCqGSM49
AwEHoUQDQgAERSwZnVmPq8nLDNnh1jRiNAGvQ7pMpIuC0IfRXlSUWXVIqdbEGDpq
/bewfRdaY/Fd5WpwexUeaq5VrB0FLkKUMQ==
-----END EC PRIVATE KEY-----

controlplane ~ ➜  






We have added an AdmissionConfiguration file admission_configuration.yaml and a Kubeconfig file admission_kube_config.yaml under /etc/kubernetes/pki/

There are some fixes to be done so that it works with ImagePolicyWebhook.


Fix those two YAML files.



admission_configuration.yaml is correct?

admission_kube_config.yaml is correct?




controlplane ~ ➜  cd /etc/kubernetes/pki/

controlplane /etc/kubernetes/pki ➜  ls
admission_configuration.yaml  apiserver-etcd-client.key     ca.crt              front-proxy-ca.key      sa.pub
admission_kube_config.yaml    apiserver.key                 ca.key              front-proxy-client.crt  server.crt
apiserver.crt                 apiserver-kubelet-client.crt  etcd                front-proxy-client.key
apiserver-etcd-client.crt     apiserver-kubelet-client.key  front-proxy-ca.crt  sa.key

controlplane /etc/kubernetes/pki ➜  cat admission_configuration.yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: <PATH_TO_KUBECONFIG>
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: false

controlplane /etc/kubernetes/pki ➜  cat admission_kube_config.yaml 
admission_configuration.yaml  apiserver-kubelet-client.crt  front-proxy-ca.key
admission_kube_config.yaml    apiserver-kubelet-client.key  front-proxy-client.crt
apiserver.crt                 ca.crt                        front-proxy-client.key
apiserver-etcd-client.crt     ca.key                        sa.key
apiserver-etcd-client.key     etcd/                         sa.pub
apiserver.key                 front-proxy-ca.crt            server.crt

controlplane /etc/kubernetes/pki ➜  cat admission_kube_config.yaml 
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/pki/server.crt
    server: https://image-bouncer-webhook:<NODE_PORT>/image_policy
  name: bouncer_webhook
contexts:
- context:
    cluster: bouncer_webhook
    user: api-server
  name: bouncer_validator
current-context: bouncer_validator
preferences: {}
users:
- name: api-server
  user:
    client-certificate: /etc/kubernetes/pki/apiserver.crt
    client-key:  /etc/kubernetes/pki/apiserver.key

controlplane /etc/kubernetes/pki ➜ 






Enable the ImagePolicyWebhook admission controller as final step so that our image policy validation can take place in API server.
You need to specify admission-control-config-file as well for this controller


-

admission-control-config-file: /etc/kubernetes/pki/admission_configuration.yaml

Note: Once you update kube-apiserver yaml, please wait for a few minutes for the kube-apiserver to restart completely.



/etc/kubernetes/manifests/kube-apiserver.yaml should look like below after update
    - --enable-admission-plugins=NodeRestriction,ImagePolicyWebhook
    - --admission-control-config-file=/etc/kubernetes/pki/admission_configuration.yaml


controlplane /etc/kubernetes/manifests ➜  cat kube-apiserver.yaml | grep -A2 -B2 admission-control-config-file
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    - --admission-control-config-file=/etc/kubernetes/pki/admission_configuration.yaml
    image: registry.k8s.io/kube-apiserver:v1.32.0
    imagePullPolicy: IfNotPresent









controlplane ~ ➜  k get secrets tls-image-bouncer-webhook -oyaml
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURBRENDQWVpZ0F3SUJBZ0lSQUl4VSswR0ZqdG4zaEdjcC9wYzVkQjR3RFFZSktvWklodmNOQVFFTEJRQXcKRlRFVE1CRUdBMVVFQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBME1EUXhNREk0TVROYUZ3MHlOakEwTURReApNREk0TVROYU1GMHhGVEFUQmdOVkJBb1RESE41YzNSbGJUcHViMlJsY3pGRU1FSUdBMVVFQXhNN2MzbHpkR1Z0Ck9tNXZaR1U2YVcxaFoyVXRZbTkxYm1ObGNpMTNaV0pvYjI5ckxtUmxabUYxYkhRdWNHOWtMbU5zZFhOMFpYSXUKYkc5allXd3dXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBUnE1d3l4cVljcGZrTUcvMm1HTTgxaQpuWWdPYmlGWGtEcnJTTkZvQUF3aUZtZzYrWWRtOEhBN0JmRU1vOHlEM0t6ZVhvYVkzRFBvOGt5TEhNdzlKY1ExCm80SE5NSUhLTUE0R0ExVWREd0VCL3dRRUF3SUZvREFUQmdOVkhTVUVEREFLQmdnckJnRUZCUWNEQVRBTUJnTlYKSFJNQkFmOEVBakFBTUI4R0ExVWRJd1FZTUJhQUZQRmc1SzlCL21RZ1JEZFdPcEdGbnpzQnBmZW9NSFFHQTFVZApFUVJ0TUd1Q0ZXbHRZV2RsTFdKdmRXNWpaWEl0ZDJWaWFHOXZhNEloYVcxaFoyVXRZbTkxYm1ObGNpMTNaV0pvCmIyOXJMbVJsWm1GMWJIUXVjM1pqZ2k5cGJXRm5aUzFpYjNWdVkyVnlMWGRsWW1odmIyc3VaR1ZtWVhWc2RDNXoKZG1NdVkyeDFjM1JsY2k1c2IyTmhiREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBdUtveCs3N21BZWNRb0RPWApwOXVGNC9EMWNIaHUyMnBCVzZoaUlQdFNESnVHekJjNzNLNUZicE0wY3c1STNML2tROExSNlYyK0lGbXB1M3MwClZSYm1SSkx6ZlhVV0syQmRxVzRGSklEOFRFN3RUbEJDcHgzQWE0cHdWeno0R2NQd3B2ZVVhY1BlWWpDQUNMVlEKUTBUOU9DR012STB2dStlcTBSbGhnd3hyeUpiYkQ0azdyTWowdFhQakRad0F4SW1EblNnMXBDd0dpd3pNcDJOLwpudnBkbnZuVlVEcDN2MG5pd0J6a1YzbnRzc09PTjZLL1ZXNlRqQ1lQU1JwZFl6L2gwNnYyNndYemZaeHBtSitGCjlkbXhYbmVmQ1AwOVZTRjlQeWtJNUZ1ZDVJRnpscWROZFg2TGVjY3NwZEtKMm9PWk1CRy9qTzJtMzJCeGEzeGYKOFBUMnZnPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
  tls.key: LS0tLS1CRUdJTiBFQyBQUklWQVRFIEtFWS0tLS0tCk1IY0NBUUVFSUplNWxRU21GZGxyaUZuOWpzWjR1SFJGVXU1VWEyQi9raVlTZlp0bUF3UHhvQW9HQ0NxR1NNNDkKQXdFSG9VUURRZ0FFYXVjTXNhbUhLWDVEQnY5cGhqUE5ZcDJJRG00aFY1QTY2MGpSYUFBTUloWm9Pdm1IWnZCdwpPd1h4REtQTWc5eXMzbDZHbU53ejZQSk1peHpNUFNYRU5RPT0KLS0tLS1FTkQgRUMgUFJJVkFURSBLRVktLS0tLQo=
kind: Secret
metadata:
  creationTimestamp: "2025-04-04T10:33:13Z"
  name: tls-image-bouncer-webhook
  namespace: default
  resourceVersion: "1011"
  uid: b0aadf9f-8829-4c26-8a99-60b4e32a55f7
type: kubernetes.io/tls






controlplane ~ ➜  k get csr image-bouncer-webhook.default -oyaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"certificates.k8s.io/v1","kind":"CertificateSigningRequest","metadata":{"annotations":{},"name":"image-bouncer-webhook.default"},"spec":{"request":"LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQm9qQ0NBVWdDQVFBd1hURVZNQk1HQTFVRUNoTU1jM2x6ZEdWdE9tNXZaR1Z6TVVRd1FnWURWUVFERXp0egplWE4wWlcwNmJtOWtaVHBwYldGblpTMWliM1Z1WTJWeUxYZGxZbWh2YjJzdVpHVm1ZWFZzZEM1d2IyUXVZMngxCmMzUmxjaTVzYjJOaGJEQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJHcm5ETEdwaHlsK1F3Yi8KYVlZenpXS2RpQTV1SVZlUU91dEkwV2dBRENJV2FEcjVoMmJ3Y0RzRjhReWp6SVBjck41ZWhwamNNK2p5VElzYwp6RDBseERXZ2dZZ3dnWVVHQ1NxR1NJYjNEUUVKRGpGNE1IWXdkQVlEVlIwUkJHMHdhNElWYVcxaFoyVXRZbTkxCmJtTmxjaTEzWldKb2IyOXJnaUZwYldGblpTMWliM1Z1WTJWeUxYZGxZbWh2YjJzdVpHVm1ZWFZzZEM1emRtT0MKTDJsdFlXZGxMV0p2ZFc1alpYSXRkMlZpYUc5dmF5NWtaV1poZFd4MExuTjJZeTVqYkhWemRHVnlMbXh2WTJGcwpNQW9HQ0NxR1NNNDlCQU1DQTBnQU1FVUNJQXVsbkYzdlA3NmJKaTd4RzRCNXFEaWNaTmRNUEgzRE54NUtiTlRPCmhzWVRBaUVBb3crOEtXZkZFeFBHTXJKMWd0Nmg5ZTc3dXNOdFRBLzFEdm1MenNUdDkzZz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==","signerName":"kubernetes.io/kubelet-serving","usages":["digital signature","key encipherment","server auth"]}}
  creationTimestamp: "2025-04-04T10:33:13Z"
  name: image-bouncer-webhook.default
  resourceVersion: "1010"
  uid: 191f51e3-1991-4213-96b9-e1f24adbe39b
spec:
  extra:
    authentication.kubernetes.io/credential-id:
    - X509SHA256=00cf374d3b3c04ec699f0784213c23e53e70a27b46dd2d0c2fd7f94356e34c9f
  groups:
  - kubeadm:cluster-admins
  - system:authenticated
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQm9qQ0NBVWdDQVFBd1hURVZNQk1HQTFVRUNoTU1jM2x6ZEdWdE9tNXZaR1Z6TVVRd1FnWURWUVFERXp0egplWE4wWlcwNmJtOWtaVHBwYldGblpTMWliM1Z1WTJWeUxYZGxZbWh2YjJzdVpHVm1ZWFZzZEM1d2IyUXVZMngxCmMzUmxjaTVzYjJOaGJEQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJHcm5ETEdwaHlsK1F3Yi8KYVlZenpXS2RpQTV1SVZlUU91dEkwV2dBRENJV2FEcjVoMmJ3Y0RzRjhReWp6SVBjck41ZWhwamNNK2p5VElzYwp6RDBseERXZ2dZZ3dnWVVHQ1NxR1NJYjNEUUVKRGpGNE1IWXdkQVlEVlIwUkJHMHdhNElWYVcxaFoyVXRZbTkxCmJtTmxjaTEzWldKb2IyOXJnaUZwYldGblpTMWliM1Z1WTJWeUxYZGxZbWh2YjJzdVpHVm1ZWFZzZEM1emRtT0MKTDJsdFlXZGxMV0p2ZFc1alpYSXRkMlZpYUc5dmF5NWtaV1poZFd4MExuTjJZeTVqYkhWemRHVnlMbXh2WTJGcwpNQW9HQ0NxR1NNNDlCQU1DQTBnQU1FVUNJQXVsbkYzdlA3NmJKaTd4RzRCNXFEaWNaTmRNUEgzRE54NUtiTlRPCmhzWVRBaUVBb3crOEtXZkZFeFBHTXJKMWd0Nmg5ZTc3dXNOdFRBLzFEdm1MenNUdDkzZz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0tCg==
  signerName: kubernetes.io/kubelet-serving
  usages:
  - digital signature
  - key encipherment
  - server auth
  username: kubernetes-admin
status:
  certificate: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURBRENDQWVpZ0F3SUJBZ0lSQUl4VSswR0ZqdG4zaEdjcC9wYzVkQjR3RFFZSktvWklodmNOQVFFTEJRQXcKRlRFVE1CRUdBMVVFQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBME1EUXhNREk0TVROYUZ3MHlOakEwTURReApNREk0TVROYU1GMHhGVEFUQmdOVkJBb1RESE41YzNSbGJUcHViMlJsY3pGRU1FSUdBMVVFQXhNN2MzbHpkR1Z0Ck9tNXZaR1U2YVcxaFoyVXRZbTkxYm1ObGNpMTNaV0pvYjI5ckxtUmxabUYxYkhRdWNHOWtMbU5zZFhOMFpYSXUKYkc5allXd3dXVEFUQmdjcWhrak9QUUlCQmdncWhrak9QUU1CQndOQ0FBUnE1d3l4cVljcGZrTUcvMm1HTTgxaQpuWWdPYmlGWGtEcnJTTkZvQUF3aUZtZzYrWWRtOEhBN0JmRU1vOHlEM0t6ZVhvYVkzRFBvOGt5TEhNdzlKY1ExCm80SE5NSUhLTUE0R0ExVWREd0VCL3dRRUF3SUZvREFUQmdOVkhTVUVEREFLQmdnckJnRUZCUWNEQVRBTUJnTlYKSFJNQkFmOEVBakFBTUI4R0ExVWRJd1FZTUJhQUZQRmc1SzlCL21RZ1JEZFdPcEdGbnpzQnBmZW9NSFFHQTFVZApFUVJ0TUd1Q0ZXbHRZV2RsTFdKdmRXNWpaWEl0ZDJWaWFHOXZhNEloYVcxaFoyVXRZbTkxYm1ObGNpMTNaV0pvCmIyOXJMbVJsWm1GMWJIUXVjM1pqZ2k5cGJXRm5aUzFpYjNWdVkyVnlMWGRsWW1odmIyc3VaR1ZtWVhWc2RDNXoKZG1NdVkyeDFjM1JsY2k1c2IyTmhiREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBdUtveCs3N21BZWNRb0RPWApwOXVGNC9EMWNIaHUyMnBCVzZoaUlQdFNESnVHekJjNzNLNUZicE0wY3c1STNML2tROExSNlYyK0lGbXB1M3MwClZSYm1SSkx6ZlhVV0syQmRxVzRGSklEOFRFN3RUbEJDcHgzQWE0cHdWeno0R2NQd3B2ZVVhY1BlWWpDQUNMVlEKUTBUOU9DR012STB2dStlcTBSbGhnd3hyeUpiYkQ0azdyTWowdFhQakRad0F4SW1EblNnMXBDd0dpd3pNcDJOLwpudnBkbnZuVlVEcDN2MG5pd0J6a1YzbnRzc09PTjZLL1ZXNlRqQ1lQU1JwZFl6L2gwNnYyNndYemZaeHBtSitGCjlkbXhYbmVmQ1AwOVZTRjlQeWtJNUZ1ZDVJRnpscWROZFg2TGVjY3NwZEtKMm9PWk1CRy9qTzJtMzJCeGEzeGYKOFBUMnZnPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
  conditions:
  - lastTransitionTime: "2025-04-04T10:33:13Z"
    lastUpdateTime: "2025-04-04T10:33:13Z"
    message: This CSR was approved by kubectl certificate approve.
    reason: KubectlApprove
    status: "True"
    type: Approved





➜  image-policy-webhook git:(main) ✗ k apply -f certificate-generate.yaml
certificatesigningrequest.certificates.k8s.io/tls-image-bouncer-webhook created
➜  image-policy-webhook git:(main) ✗ k get csr                           
NAME                        AGE   SIGNERNAME                      REQUESTOR          REQUESTEDDURATION   CONDITION
tls-image-bouncer-webhook   3s    kubernetes.io/kubelet-serving   kubernetes-admin   <none>              Pending
➜  image-policy-webhook git:(main) ✗ k get csr
NAME                        AGE   SIGNERNAME                      REQUESTOR          REQUESTEDDURATION   CONDITION
tls-image-bouncer-webhook   49s   kubernetes.io/kubelet-serving   kubernetes-admin   <none>              Pending
➜  image-policy-webhook git:(main) ✗ k certificate approve image-policy-webhook    
Error from server (NotFound): certificatesigningrequests.certificates.k8s.io "image-policy-webhook" not found
➜  image-policy-webhook git:(main) ✗ k certificate approve tls-image-bouncer-webhook                    
certificatesigningrequest.certificates.k8s.io/tls-image-bouncer-webhook approved



controlplane /etc/kubernetes/pki ✖ k exec -it image-bouncer-webhook-5545f49cd4-cnw8w -- sh
~ $ cat /etc/resolv.conf 
search default.svc.cluster.local svc.cluster.local cluster.local sxldf3s3eta3lxk7.svc.cluster.local us-central1-a.c.kk-lab-prod.internal c.kk-lab-prod.internal google.internal
nameserver 172.20.0.10
options ndots:5
~ $ 
