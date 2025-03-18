# Properly set up Ingress with TLS

In exam you dont need to install Ingress controller.

## Installation with Manifests 
Link `https://kubernetes.github.io/ingress-nginx/deploy/`

For exam preparation we will use below manifest  
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml
```
```bash
#Output
namespace/ingress-nginx created
serviceaccount/ingress-nginx created
configmap/ingress-nginx-controller created
clusterrole.rbac.authorization.k8s.io/ingress-nginx created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx created
role.rbac.authorization.k8s.io/ingress-nginx created
rolebinding.rbac.authorization.k8s.io/ingress-nginx created
service/ingress-nginx-controller-admission created
service/ingress-nginx-controller created
deployment.apps/ingress-nginx-controller created
ingressclass.networking.k8s.io/nginx created
validatingwebhookconfiguration.admissionregistration.k8s.io/ingress-nginx-admission created
serviceaccount/ingress-nginx-admission created
clusterrole.rbac.authorization.k8s.io/ingress-nginx-admission created
clusterrolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
role.rbac.authorization.k8s.io/ingress-nginx-admission created
rolebinding.rbac.authorization.k8s.io/ingress-nginx-admission created
job.batch/ingress-nginx-admission-create created
job.batch/ingress-nginx-admission-patch created

root@master:~# kubectl get ingressclasses.networking.k8s.io 
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       4m21s    # Ingress class name --nginx-- we will use this later

root@master:~# kubectl get pod,deploy,svc -n ingress-nginx 
NAME                                           READY   STATUS      RESTARTS   AGE
pod/ingress-nginx-admission-create-q2s2t       0/1     Completed   0          33m
pod/ingress-nginx-admission-patch-l76dq        0/1     Completed   0          33m
pod/ingress-nginx-controller-974f4cbd8-dgks5   1/1     Running     0          33m

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ingress-nginx-controller   1/1     1            1           33m

NAME                                         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
service/ingress-nginx-controller             LoadBalancer   10.109.106.144   <pending>     80:30159/TCP,443:32025/TCP   33m  # Connect from outside we need the nodeport of ingress-nginx-controller 30259 for insecure and 32025 for secure.
service/ingress-nginx-controller-admission   ClusterIP      10.99.121.64     <none>        443/TCP                      33m

```
## Create certificate 
For secure communication we need certificate. In exam you dont need to create certificate. It will be available in the node.
For test follow below steps.
```bash
➜ openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
...+.+..+......+.+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.....+.................+...+.+...+..+.+.....+...+.+..............+....+...+..+.+..+....+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*......+......+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
.....+...+.+.....+.+...........+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*...+.........+..+..........+.....+...+.+..+....+......+.....+....+........+.......+.....+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*.......+.....................+..........+..+...+................+.....+......+....+...+......+.....+....+.....+.+.....+.+.....+......+....+...............+...+...........+............+.........+...+.+..+...................+.....+...+.......+.....+......+....+......+..............+....+..+...+...................+.....+..........+.....+.......+......+..............+....+..+..........+............+...+........+......+......+....+.....+.............+.....+................+.....+.......+..+...+....+......+.....+...+.+...+...+.....+..........+.....+.......+......+.....+....+...+...+..+...+....+..+...+.............+.....+...+.+.....+.............+...+..................+.................+...............+...+.........+......+............+.......+...+..............+.........+.......+...+......+...+....................+...+.........+.+..+................+...........+.+.........+...+...........+....+........+.......+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:BD
State or Province Name (full name) [Some-State]:Dhaka
Locality Name (eg, city) []:Dhaka
Organization Name (eg, company) [Internet Widgits Pty Ltd]:CKS-Exam
Organizational Unit Name (eg, section) []:   
Common Name (e.g. server FQDN or YOUR name) []:cksexam.com   # This is important for certificate. note this for future.
Email Address []:
```

After run the command you will get below 2 file in running directory
```bash
➜ ls
cert.pem  key.pem

# For get some details about pem(certificate) file
➜ openssl x509 -in cert.pem -noout -text 
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            4f:64:85:dd:ba:00:77:9a:62:23:bf:a9:72:1b:70:fc:be:65:d9:06
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = BD, ST = Dhaka, L = Dhaka, O = CKS-Exam, CN = cksexam.com   # Make sure 
        Validity
            Not Before: Mar 16 19:06:28 2025 GMT
            Not After : Mar 16 19:06:28 2026 GMT
        Subject: C = BD, ST = Dhaka, L = Dhaka, O = CKS-Exam, CN = cksexam.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (4096 bit)
                Modulus:
                    00:8b:c7:84:c9:cd:26:d7:c5:03:00:59:11:e2:e6:
----------------------------------------------------------------
```

## Create without TLS ingress with `nginx ingress controller`
```bash
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: insecure-ingress
  namespace: myapp
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx             # This is the ingress class name
  rules:
  - http:
      paths:
      - path: /frontend
        pathType: Prefix
        backend:
          service: 
            name: frontend-service
            port:
              number: 80

      - path: /backend
        pathType: Prefix
        backend:
          service: 
            name: backend-service
            port:
              number: 8080
```
### For test the connectivity
```bash
curl http://cksexam.com:30159/frontend -v --resolve cksexam.com:30159:192.168.0.112

# Or

curl -H "Host: cksexam.com" http://192.168.0.112:30159/frontend -v
```


## Create with TLS ingress with `nginx ingress controller`

For create ingress with TLS we must first create secret with the certificate we generated.
```bash
$ kubectl create secret tls tls-secret --cert=cert.pem --key=key.pem 
secret/tls-secret created

$ kubectl get secrets tls-secret -oyaml
apiVersion: v1
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZqVENDQTNXZ0F3SUJBZ0lVVDJTRjNib0FkNXBpSTcrcGNodHcvTDVsMlFZd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1ZqRUxNQWtHQTFVRUJoTUNRa1F4RGpBTUJnTlZCQWdNQlVSb1lXdGhNUTR3REFZRFZRUUhEQVZFYUdGcgpZVEVSTUE4R0ExVUVDZ3dJUTB0VExVVjRZVzB4RkRBU0JnTlZCQU1NQzJOcmMyVjRZVzB1WTI5dE1CNFhEVEkxCk1ETXhOakU1TURZeU9Gb1hEVEkyTURNeE5qRTVNRFl5T0Zvd1ZqRUxNQWtHQTFVRUJoTUNRa1F4RGpBTUJnTlYKQkFnTUJVUm9ZV3RoTVE0d0RBWURWUVFIREFWRWFHRnJZVEVSTUE4R0ExVUVDZ3dJUTB0VExVVjRZVzB4RkRBUwpCZ05WQkFNTUMyTnJjMlY0WVcwdVkyOXRNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QU1JSUNDZ0tDCkFnRUFpOGVFeWMwbTE4VURBRmtSNHVZTW00cUl3RmZwTzhXL1hTM2JBTjZIYlhmZlMxV0pRUnA5a2FOZlJ3RzEKQmsyempuSjRLQzI1S1VxdHkrc2ZpNk8rMzhGTHplblQ2ZEVZanB3RkJUNkJXejdjZkRtWFdNUndSR25HUjlOQQo3SC9VY0RJUGlWVWJtSS9iWXhBWUNVZnhLWWtrOGcrTnFQOW1sTmkySzRIeVNCNUh5c3lHdHNPa3g2aU5jVWhGCkg0QVZMbmhNNHVuYmJtSnRGUjVPQzJ0dFM0WHdBZFVXZmZKRjV1MUFqcEVGTmw5Y1FyVHZEMDg2eXYyS0NtNUEKbVZob3NESU16MDZvRnBjOVArREl5aGc0ZWJUMVg4K1RGWUtnSHNNbTZIalZ4TVZhWlM3c3I2bTRCOGVuVm9ZKwpyQnQ1bHYxQXdGS08zQnNWSytuMlJIN0trc3p4bzFuOHc5cEM5TVFWRVVaT3Qra21PUHpEeFV1dHkxQjhGZVRxCkd6OHBlL1pvd1E5NXl3YUVYbzlqcDcrTTVlTTczcXk0NDNTMWV1bkloTUpXOVN2Ky94QkF6NGZsTUVVanhIa00Kd2t5cWszQjRSdkhTQ2w4S0laWEhmSkdvQjlGTDNnSlpteWRwQVZMT294NWExOXRJT1NDYzJqVDRnZUxYSVEvagpJOHA0Qyt0MzByU0JpekVXT1YwZEhQSjRKWVpqc2cycTlSVzd6WHhzZElQWWdNb1JwdXFudVRISkM3YTJCOUpSCitpSXpMeG5oaEJPMW1VOTNPa0Z4UjNOcElHaVJXQkp1UnRkbUNpbFEwd0I0V0hIVzczVDJTSVdOb2dMWDVxUjkKcTcwTzVBM1RwNUtac3BmaGdzc3grZ2tmOXpyZzQ1NWR1MjdMdVNyQTNNRDRCNk1DQXdFQUFhTlRNRkV3SFFZRApWUjBPQkJZRUZJb3FndWR0TEVHbGN2SnBrOXEyMFNtK1huMnZNQjhHQTFVZEl3UVlNQmFBRklvcWd1ZHRMRUdsCmN2SnBrOXEyMFNtK1huMnZNQThHQTFVZEV3RUIvd1FGTUFNQkFmOHdEUVlKS29aSWh2Y05BUUVMQlFBRGdnSUIKQUNJOGJidzMwZ0JJenVPTnNlcFh3ckk0VkFOV0hYU3pxT3UwQ0t5aEpmMWxFZGFNVFYybEc1enBoa0VVYk12WQoyUzJ5MWoxWE1seUsyUXJLYzk3S1RyUG40NHFMTnpzQWxmNEI5cTR5OWNKNHZ0OU9saVhlZm1pK3ZFdi9zaU9ICjdFL3IxTUd2TkJOSjF1S05ic3pOdFRyZEVsQUR5TXhUWjQ0YXpqUnJ0RUlGRmhqcytKdDZER0YxRWRyUzZDc04KR3RsZWxTYTFhR3k5OE0wUXpVTE80TUxsSFJGdkxpQWs4clFTN2dKd1hKb2RmZW5MZ0Z1RkZTVm1hcEVlNXRmNQp3NjRjVEdIWWlsUEh4aFk0WWlPQ3liRGM3clpxODdqYlpldnZVc0xTT0hRWGxUcDN2UjB2NTZVc1pjMWRRYlEyCmpURFpxZ2F5VzdnN2VUcFNORnNOdHNNbWY4Q0NTMWEydlErYjFSSVc5Wnh3RW13bDYyVmtJd05FNi9HWWo5bVQKRCtrT3hNV05WZllvemp4ZzZnZklGS1U0QWJuOVp4Q3g5dzFidkhNaHRxSjVNOURFOEF4eHVSTDIxdnBiclJZawpVUVl5c2dWSC9ybVVlT1pDczVpNmt4RVRrUkMyYzQ2MFJXMnRhVVpIQUhjdEFWc2ZvaCsyeFYyMTFpVSsvc0pjClJDbU1MNUM2VXdseGJKbGUxVFBnTm43OE5WbklLTmxwN0owRzl3Snh4MnBlOUJmZUZnL1NwdWZpRk9RNm9kTFAKZ0NJSlV3UXF5M29uNXozYjRydGFvNno3YXY2U01vcCtpRTZ4RVZnSDNwa1VzMy9EdWpVNTZOMzBHYVB1eStCRQpQVmR1SUEyKzZrcG4vbzlpUkt3Vm5LZENPdlB6cWF4bXh5aDE5SXNuN2REUwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
  tls.key: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUpRZ0lCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQ1N3d2dna29BZ0VBQW9JQ0FRQ0x4NFRKelNiWHhRTUEKV1JIaTVneWJpb2pBVitrN3hiOWRMZHNBM29kdGQ5OUxWWWxCR24yUm8xOUhBYlVHVGJPT2NuZ29MYmtwU3EzTAo2eCtMbzc3ZndVdk42ZFBwMFJpT25BVUZQb0ZiUHR4OE9aZFl4SEJFYWNaSDAwRHNmOVJ3TWcrSlZSdVlqOXRqCkVCZ0pSL0VwaVNUeUQ0Mm8vMmFVMkxZcmdmSklIa2ZLeklhMnc2VEhxSTF4U0VVZmdCVXVlRXppNmR0dVltMFYKSGs0TGEyMUxoZkFCMVJaOThrWG03VUNPa1FVMlgxeEN0TzhQVHpySy9Zb0tia0NaV0dpd01nelBUcWdXbHowLwo0TWpLR0RoNXRQVmZ6NU1WZ3FBZXd5Ym9lTlhFeFZwbEx1eXZxYmdIeDZkV2hqNnNHM21XL1VEQVVvN2NHeFVyCjZmWkVmc3FTelBHaldmekQya0wweEJVUlJrNjM2U1k0L01QRlM2M0xVSHdWNU9vYlB5bDc5bWpCRDNuTEJvUmUKajJPbnY0emw0enZlckxqamRMVjY2Y2lFd2xiMUsvNy9FRURQaCtVd1JTUEVlUXpDVEtxVGNIaEc4ZElLWHdvaApsY2Q4a2FnSDBVdmVBbG1iSjJrQlVzNmpIbHJYMjBnNUlKemFOUGlCNHRjaEQrTWp5bmdMNjNmU3RJR0xNUlk1ClhSMGM4bmdsaG1PeURhcjFGYnZOZkd4MGc5aUF5aEdtNnFlNU1ja0x0cllIMGxINklqTXZHZUdFRTdXWlQzYzYKUVhGSGMya2dhSkZZRW01RzEyWUtLVkRUQUhoWWNkYnZkUFpJaFkyaUF0Zm1wSDJydlE3a0RkT25rcG15bCtHQwp5ekg2Q1IvM091RGpubDI3YnN1NUtzRGN3UGdIb3dJREFRQUJBb0lDQUI0aHJ1clBtaGwyUXp6ZWRvQWFoa283ClZWcGRPUTVsQk9rQnV3Mlhhc3M2eFh4WVhvT1Z3YzdVMEhPZWx4YmFSaVFsWWVpTFhyaGJmRmFTZzFUWFFneTYKL3V2UEJac0lNNHArY0lpZVhrVThxa3Z2SUVTRzZBcWZZSnBZSEUwL0N4ejZkYVh0bmtySGJBd1JTcFVwbUgrVApMRTh2OGlJbG1FZnE1VzVBajJsamVhZHFhbm5ZZDl1QVpxa3VZcFExU0p1aFhEV29JdURMUCtlSEJsem8xZ0VyClNMOGtYN3Bic1J6a05QL21uQ0NKOHZvQVJlNWZibldXclJ5dGdxaHJ5Zmw5ZUl4eDBNTTU2LzZxcHE0R0JacWEKMnpCQnIxdTZNbWtmT1hKd3BlaEtnTCtDRzR5TWdmclBXNi9IdFpmbFBsTkJtYVU3eHNjRTRZMzdXOWFOSEg2eQpOOWFBNVg1OHFpV2tSdjhva2Y0NEd3R1dzMktqbGJTMVhrK25abWtCbGV3N05WbDYrV2YrVVNmY0wrRmVFWkhKCmxRTFl2aDg4eUhWeXI3MUJUQ25SYUVpTXZwUnlaYi9QSE1nMS9oU3pzNjJlTmwvS3ZuRW8vNEwwMWxCK0M1TnkKbVI4QnIxSUtwNEhDTmM0S05kRDJFd20vVm55WVBjaUNZbTJRLzBaeVJueVYyS0dnRmpUdFdwa0dDYlNPZnlrTwpLWlJXTlQ4MnRMeWNOaEE1YlZGcGpSck0rTFNxN3hSYlpCOGllRVJmZjk1ZzNzR1VxaDY5SFRuR1paM0xzbkJOCkVDK1VqVE5uT2Y3UHFGdjl0MHVlYlRscHdSU1JBcWtnbE83Y2JFVml5VGdHU0hyUFFvSHhuVk1EWTUrdzQwbUgKZVFndk9KM3NBaVQ2eUtXUXMybjFBb0lCQVFDOWMwNldGTGNtM21ZY0RLcCtHN2dUWHMvZWFiTHpqMGUvVjRURAo4ak8zVXBobEtBM2txU0loYWJhN2JHd2V4Y0Q2eGNwaElWWWdoRmh4L2RPS0VXeThqZ1E3S21QSlhwbC9JTVlxClNLMFNPTzNKSjlzaFR3MVlYVlVXclBWNm0xbE9yaEY4Q1Vid2tTLzQxbFlLVEpEanoxTlRzSmQraHVlM25mZncKRnlzS3FOZ2pQZkx1K0NvYlpBNFlidzM0cmhLYzRCWmZBcDNTemdlUEVBSHVIOFlyZ2dQUy9nVGRadFNlaEJzQwpmV1VJc2NBQjVVVHQ2YVJDd1pEY3pXaXNoTjVjU1ZJcDFneHdYbUViYzNLa1k2TzRJUThFa1FPVGZZMDZVUkVOCmx5VzUrWGZYYTl6MFFvMmZlOWoyVkVhUTVCNGpRTUttcjVQczdINEJZdWpYYXZVSEFvSUJBUUM4NFhKL1AwamkKdjdDUHdmVmZXL2NKSTFDeWV0aUgzR2VEeVp3V2hVaWhZYjMwbmJXK1d4TkFFVGgyQ3JpQjl2NlVmbDdydFByOAo2UHVoOXRwNjNkcDFFelMrM29pQWp2bWYxR3JZZWxaWEFScE90cE9SczMxNXcvTGxvQ1RIWHlQV3FLMnlJZnN3CkVLVlZGZEwvdnI0T3pYcXNXTUpxQVB5V200dzhsWmV2VkcvbzI0VXNYWko5WFMwWWxENXVIc2N3WkFZWFBWYngKOTJxc0g1NGNaTTVScGNQZkVtYzVQQUNpSVV5QmFqZUNzUnBHaHFCTm1xNEZlSmFDVjRZM0ozTVZIOTF6S0k5cQp2eHE5bGtiMlVhaHEzc1RaeHN4UWcwV2E2Q0puMlFTYUpSZHFydnhvNmpWTnk0a2NXWUphYyt5S1JpTjdVQVBICnRUcEJ3VkgvWjYyRkFvSUJBQWtqK1JTd3B5Mk82V3BOQ2lUUGZaQWhzUEhRTTd3Z201dVZ3MmdZMVhudzJEMTUKTTBKbkRxaUNDemo3d0RPejR0MjJrVThpWnA5bkEwVnNzN29qb1JWdjNMQm1HUzVzREFmZ011OXpWalpjM013cAp5aDdQUzV1SjFVTWswU3M3TjVIZVFDVzE1T0JTZ1BnR2oxd3IyWW5FUlFieXJEeUVrY1dBTDZnNzFlM0x1N0huCm1VTUNZalcwSENIOXFiVG40U29FZmMvVHRuMm5SeUlWNmFIdGtvZ2kyOEJnVlNmQmdGeXRqd2dOdU1RMG4wajQKSU4xQnVwVWw5YkZSajgxVEU4OXNFalRHaVE4YTNxQ09iMmVURHlFaEp6SlhOTTcyN2N0MGdkZ2dCTWYyUzF2dgpibGV5cGxhZGlSaEpkS1lrKzNkRDlxQklOR0RvQUNSYysxTDViQjBDZ2dFQVlMb3J3cEtNSnVMMzdvYnJ1OHdDCjlNRUxJSHZjeTZiSnRDblpMNGRPTEtjN2Vqd1J5TXduVFpZRURoOXJZZE0xaUtJMnhnckd4aUlpUzAxNWtaWnYKdTZqOFNBcjZhS3ZQbGxSWDYwaXJVcDhUODk5NEx4TjJYSmRHbXVXcU1CZSs2TDAxUnBZMFp1Yi9aRlZxMnVHNQp2eWJuZmI5dXdJNkV6RFFZV3laWXFjZGFFQ3ZyUlU4ZUorbEJvT2E2R2ZiVkZ5a0NIWUNpT0FQMnN2TDJLNkJNCk1HL3RvUjF4azFQeEZ4WnFjWlFOblhaSStIa1ZPdWpOMmF0cG1KSnQvMnpLZUxUNjJYQ2FFWmFRZ1NxbWFKcGsKMzJYNTlYVGpTUkFRNDBXaDZRQ3daS2crRjdwSk5RbE1CdTBHNkdmR1k4QWVFS25lbmRYYU9ibkxmY1VjMHVrcgphUUtDQVFFQXNkMEtLbHNjODNPY0dVNG5hNm5qSjVvajhVTXpLbllwRVhSS3FnY2hrTis1eUhwMDBmLzUzNEJVClAvVkNIZXhJSlNBUHVDc09GV3lkL2xWR0VnTUkrSDl1S2VlUFF5WmppRXB4Z2NIZHV5aitMeHBHT0U2dUJReFEKUGtJcWVNWFo4S0dGR3Fkcnlid3laaVlOWW05RnM1aHQ5RGZJT2FhNytxMFpuZ25qWHJpdzhPbG1ZTWtnb3RJMgp5OTczN2JYelJiQ3hKL3JONjVmRWhvREhHMG5YRXlUcjBYYm9DbFpKKzVqN0xRUnJCTmdmN0tub2t1cWthaGM2CmlnZGpUaDdTWWtmUWJ1WmFoa1NWVENES1Z1ZDM4NWRjZ0o1QTAxTWk4RGRaZmdPcnNKYmluQzg2VlBSRFY4VzIKa0w5c0FXVEFiemJ3bFlNaWFEdnNENzYvMTBwZEZBPT0KLS0tLS1FTkQgUFJJVkFURSBLRVktLS0tLQo=
kind: Secret
metadata:
  creationTimestamp: "2025-03-17T09:36:09Z"
  name: tls-secret
  namespace: default
  resourceVersion: "4979"
  uid: 7c726c9f-7bd9-4bd1-a91e-dd8ce7c60091
type: kubernetes.io/tls

# tls.crt and tls.key are base64 encoded
```
Now create secure ingress for myapp

```bash
 cat myapp-ingress-secure.yaml 
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-secure-ingress
  namespace: myapp
spec:
  tls:
  - hosts:
      - cksexam.com
    secretName: tls-secret   # TLS Secret we created with crt and key file 
  rules:
  - host: cksexam.com
    http:
      paths:
      - path: /frontend
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 80
      - path: /backend
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 8080
```

### For test the secure connectivity
```bash
curl https://cksexam.com:32025/frontend 
# This will not work because we dont have DNS record entry and for temporary name resolution we can use below command

curl https://cksexam.com:32025/frontend --resolve cksexam.com:32025:192.168.0.112 -kv

# Or

curl -H "Host: cksexam.com" https://192.168.0.112:32025/frontend -v

# Also check with /backend
```





## Ref:
https://kubernetes.io/docs/concepts/services-networking/ingress/