# Create a Service Account

Create a new Service Account named `my-service-account` in the `default` namespace.

Create a `secret` named `my-service-account-token` to store the token.
Associate the secret with the Service Account.

- Answer

To create the Service Account using the defined Service Account in a YAML file serviceaccount.yaml, use the following configuration:
```yaml
#serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
secrets:
  - name: my-service-account-token
---
apiVersion: v1
kind: Secret
metadata:
  name: my-service-account-token
  namespace: default
  annotations:
    kubernetes.io/service-account.name: "my-service-account"
type: kubernetes.io/service-account-token
```
Apply the YAML file using the following command:
```bash
kubectl apply -f serviceaccount.yaml
```

## Retrieve the token associated with the `my-service-account` Service Account.

- Get the name of the secret associated with the Service Account.
```bash
SECRET_NAME=$(kubectl get serviceaccount my-service-account -o jsonpath='{.secrets[0].name}')
```
- Extract the token from the secret and decode it.
```bash
kubectl get secret $SECRET_NAME -o jsonpath='{.data.token}' | base64 --decode
```


## Create a Role and RoleBinding to grant the Service Account specific permissions to access pods in the `default` namespace.

**Role**
- Role name: `pod-reader`
- Namespace: `default`
- Rules:
  - Resources: `pods`
  - Verbs: `get`, `list`, `watch`

**Role Binding**
- Role binding name: `read-pods`
- Namespace: `default`
- Subject: ServiceAccount `my-service-account` in namespace `default`
- RoleRef: `Role` named `pod-reader`

```bash
kubectl -n default create role pod-reader --verb=get,list,watch --resource=pods
kubectl -n default create rolebinding read-pods --role=pod-reader --serviceaccount=default:my-service-account
```

## Access the Kubernetes API Server
Use the retrieved token to access the Kubernetes API server and retrieve the list of pods.

- Use `curl` to make an HTTPS request to the API server.
- Include the token in the `Authorization` header.
- Use the cluster's CA certificate for SSL verification.

Note: Replace `<token>` with your actual Service Account token and `<api-server-endpoint>` with your API server's endpoint.

**Get the API Server Endpoint:**
```bash
APISERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
```
**Get the CA Certificate:**
```bash
CACERT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.certificate-authority}')
```
- If the CA certificate is embedded in your kubeconfig, extract it:
  ```bash
  kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode > ca.crt
  ```

**Retrieve the Token:**
```bash
SECRET_NAME=$(kubectl get serviceaccount my-service-account -o jsonpath='{.secrets[0].name}')
TOKEN=$(kubectl get secret $SECRET_NAME -o jsonpath='{.data.token}' | base64 --decode)
```
**Use `curl` to Access the API Server:**
```
curl --cacert ca.crt -H "Authorization: Bearer $TOKEN" "$APISERVER/api/v1/namespaces/default/pods"
```

- Output
  ```json
    {
      "kind": "PodList",
      "apiVersion": "v1",
      "metadata": {
        "resourceVersion": "3190"
      },
      "items": [
        {
          "metadata": {
            "name": "nginx-5869d7778c-f6w5w",
            "generateName": "nginx-5869d7778c-",
            "namespace": "default",
            "uid": "5087c019-77cd-4a72-9347-36a737565ae3",
            "resourceVersion": "2613",
            "creationTimestamp": "2025-04-12T13:52:29Z",
            "labels": {
              "app": "nginx",
              "pod-template-hash": "5869d7778c"
            },
            "ownerReferences": [
              {
                "apiVersion": "apps/v1",
                "kind": "ReplicaSet",
                "name": "nginx-5869d7778c",
                "uid": "f90bfe24-f861-426a-b8ef-84bc2a429daa",
                "controller": true,
                "blockOwnerDeletion": true
              }
            ],
            "managedFields": [
              {
                "manager": "kube-controller-manager",
                "operation": "Update",
                "apiVersion": "v1",
                "time": "2025-04-12T13:52:29Z",
                "fieldsType": "FieldsV1",
                "fieldsV1": {
                  "f:metadata": {
                    "f:generateName": {},
                    "f:labels": {
                      ".": {},
                      "f:app": {},
                      "f:pod-template-hash": {}
                    },
                    "f:ownerReferences": {
                      ".": {},
                      "k:{\"uid\":\"f90bfe24-f861-426a-b8ef-84bc2a429daa\"}": {}
                    }
                  },
                  "f:spec": {
                    "f:containers": {
                      "k:{\"name\":\"nginx\"}": {
                        ".": {},
                        "f:image": {},
                        "f:imagePullPolicy": {},
                        "f:name": {},
                        "f:resources": {},
                        "f:terminationMessagePath": {},
                        "f:terminationMessagePolicy": {}
                      }
                    },
                    "f:dnsPolicy": {},
                    "f:enableServiceLinks": {},
                    "f:restartPolicy": {},
                    "f:schedulerName": {},
                    "f:securityContext": {},
                    "f:terminationGracePeriodSeconds": {}
                  }
                }
              },
              {
                "manager": "kubelet",
                "operation": "Update",
                "apiVersion": "v1",
                "time": "2025-04-12T13:52:35Z",
                "fieldsType": "FieldsV1",
                "fieldsV1": {
                  "f:status": {
                    "f:conditions": {
                      "k:{\"type\":\"ContainersReady\"}": {
                        ".": {},
                        "f:lastProbeTime": {},
                        "f:lastTransitionTime": {},
                        "f:status": {},
                        "f:type": {}
                      },
                      "k:{\"type\":\"Initialized\"}": {
                        ".": {},
                        "f:lastProbeTime": {},
                        "f:lastTransitionTime": {},
                        "f:status": {},
                        "f:type": {}
                      },
                      "k:{\"type\":\"PodReadyToStartContainers\"}": {
                        ".": {},
                        "f:lastProbeTime": {},
                        "f:lastTransitionTime": {},
                        "f:status": {},
                        "f:type": {}
                      },
                      "k:{\"type\":\"Ready\"}": {
                        ".": {},
                        "f:lastProbeTime": {},
                        "f:lastTransitionTime": {},
                        "f:status": {},
                        "f:type": {}
                      }
                    },
                    "f:containerStatuses": {},
                    "f:hostIP": {},
                    "f:hostIPs": {},
                    "f:phase": {},
                    "f:podIP": {},
                    "f:podIPs": {
                      ".": {},
                      "k:{\"ip\":\"172.17.0.4\"}": {
                        ".": {},
                        "f:ip": {}
                      }
                    },
                    "f:startTime": {}
                  }
                },
                "subresource": "status"
              }
            ]
          },
          "spec": {
            "volumes": [
              {
                "name": "kube-api-access-v6j4p",
                "projected": {
                  "sources": [
                    {
                      "serviceAccountToken": {
                        "expirationSeconds": 3607,
                        "path": "token"
                      }
                    },
                    {
                      "configMap": {
                        "name": "kube-root-ca.crt",
                        "items": [
                          {
                            "key": "ca.crt",
                            "path": "ca.crt"
                          }
                        ]
                      }
                    },
                    {
                      "downwardAPI": {
                        "items": [
                          {
                            "path": "namespace",
                            "fieldRef": {
                              "apiVersion": "v1",
                              "fieldPath": "metadata.namespace"
                            }
                          }
                        ]
                      }
                    }
                  ],
                  "defaultMode": 420
                }
              }
            ],
            "containers": [
              {
                "name": "nginx",
                "image": "nginx",
                "resources": {},
                "volumeMounts": [
                  {
                    "name": "kube-api-access-v6j4p",
                    "readOnly": true,
                    "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount"
                  }
                ],
                "terminationMessagePath": "/dev/termination-log",
                "terminationMessagePolicy": "File",
                "imagePullPolicy": "Always"
              }
            ],
            "restartPolicy": "Always",
            "terminationGracePeriodSeconds": 30,
            "dnsPolicy": "ClusterFirst",
            "serviceAccountName": "default",
            "serviceAccount": "default",
            "nodeName": "controlplane",
            "securityContext": {},
            "schedulerName": "default-scheduler",
            "tolerations": [
              {
                "key": "node.kubernetes.io/not-ready",
                "operator": "Exists",
                "effect": "NoExecute",
                "tolerationSeconds": 300
              },
              {
                "key": "node.kubernetes.io/unreachable",
                "operator": "Exists",
                "effect": "NoExecute",
                "tolerationSeconds": 300
              }
            ],
            "priority": 0,
            "enableServiceLinks": true,
            "preemptionPolicy": "PreemptLowerPriority"
          },
          "status": {
            "phase": "Running",
            "conditions": [
              {
                "type": "PodReadyToStartContainers",
                "status": "True",
                "lastProbeTime": null,
                "lastTransitionTime": "2025-04-12T13:52:35Z"
              },
              {
                "type": "Initialized",
                "status": "True",
                "lastProbeTime": null,
                "lastTransitionTime": "2025-04-12T13:52:29Z"
              },
              {
                "type": "Ready",
                "status": "True",
                "lastProbeTime": null,
                "lastTransitionTime": "2025-04-12T13:52:35Z"
              },
              {
                "type": "ContainersReady",
                "status": "True",
                "lastProbeTime": null,
                "lastTransitionTime": "2025-04-12T13:52:35Z"
              },
              {
                "type": "PodScheduled",
                "status": "True",
                "lastProbeTime": null,
                "lastTransitionTime": "2025-04-12T13:52:29Z"
              }
            ],
            "hostIP": "192.168.28.24",
            "hostIPs": [
              {
                "ip": "192.168.28.24"
              }
            ],
            "podIP": "172.17.0.4",
            "podIPs": [
              {
                "ip": "172.17.0.4"
              }
            ],
            "startTime": "2025-04-12T13:52:29Z",
            "containerStatuses": [
              {
                "name": "nginx",
                "state": {
                  "running": {
                    "startedAt": "2025-04-12T13:52:35Z"
                  }
                },
                "lastState": {},
                "ready": true,
                "restartCount": 0,
                "image": "docker.io/library/nginx:latest",
                "imageID": "docker.io/library/nginx@sha256:09369da6b10306312cd908661320086bf87fbae1b6b0c49a1f50ba531fef2eab",
                "containerID": "containerd://a3a63ba51552859ad973c7bf3b495056be01607da0eeffaf9feb2cc77db6f0b8",
                "started": true,
                "volumeMounts": [
                  {
                    "name": "kube-api-access-v6j4p",
                    "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                    "readOnly": true,
                    "recursiveReadOnly": "Disabled"
                  }
                ]
              }
            ],
            "qosClass": "BestEffort"
          }
        }
      ]
    }
  ```




Ref: 

https://kubernetes.io/docs/tasks/administer-cluster/access-cluster-api/