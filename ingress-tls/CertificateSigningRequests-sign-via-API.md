Here we are first creating a CSR and then we'll sign this using the K8s Api.

The idea here is to create a new "user" that can communicate with K8s.

For this now:

Create a new KEY at /root/60099.key for user named 60099@internal.users
Create a CSR at /root/60099.csr for the KEY

Explanation

Users in K8s are managed via CRTs and the CN/CommonName field in them. The cluster CA needs to sign these CRTs.

This can be achieved with the following procedure:

Create a KEY (Private Key) file
Create a CSR (CertificateSigningRequest) file for that KEY
Create a CRT (Certificate) by signing the CSR. Done using the CA (Certificate Authority) of the cluster

Tip

openssl genrsa -out XXX 2048

openssl req -new -key XXX -out XXX

Solution

openssl genrsa -out 60099.key 2048

openssl req -new -key 60099.key -out 60099.csr
# set Common Name = 60099@internal.users








Create a K8s CertificateSigningRequest resource named 60099@internal.users and which sends the /root/60099.csr to the API.

Let the K8s API sign the CertificateSigningRequest.

Download the CRT file to /root/60099.crt .

Create a new context for kubectl named 60099@internal.users which uses this CRT to connect to K8s.


CertificateSigningRequest template

apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: {{NAME}} # ADD
spec:
  groups:
  - system:authenticated
  request: {{BASE_64_ENCODED_CSR}} # ADD
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth

Solution

Convert the CSR file into base64


cat 60099.csr | base64 -w 0

Copy it into the YAML


apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: 60099@internal.users # ADD
spec:
  groups:
  - system:authenticated
  request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFV... # ADD
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth

Create and approve


k -f csr.yaml create

k get csr # pending

k certificate approve 60099@internal.users

k get csr # approved

k get csr 60099@internal.users -ojsonpath="{.status.certificate}" | base64 -d > 60099.crt


Use the CRT

k config set-credentials 60099@internal.users --client-key=60099.key --client-certificate=60099.crt
k config set-context 60099@internal.users --cluster=kubernetes --user=60099@internal.users
k config get-contexts
k config use-context 60099@internal.users
k get ns # fails because no permissions, but shows the correct username returned




Ref:
https://kubernetes.io/docs/tasks/tls/certificate-issue-client-csr/
