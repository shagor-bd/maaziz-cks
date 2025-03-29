# Open Policy Agent OPA



## OPA in Kubenetes

Integration of OPA (Open Policy Agent) with Kubernetes using the Gatekeeper approach. This method leverages the OPA Constraint Framework alongside Kubernetes admission controllers for enhanced policy enforcement and governance.

### Installing OPA Gatekeeper

Deploying OPA Gatekeeper is simple. Execute the following command to apply the Gatekeeper specification files:
```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/v3.14.0/deploy/gatekeeper.yaml
```

After deployment, verify that all Gatekeeper components are installed and running in the `gatekeeper-system` namespace:

```bash
kubectl get all -n gatekeeper-system
```

Find the API server of `ConstraintTemplate`
```bash
kubectl get crd constrainttemplates.templates.gatekeeper.sh -oyaml | grep -A12 conversion
```
Output
```plaintext
  conversion:
    strategy: None
  group: templates.gatekeeper.sh                # This will be the API name
  names:
    kind: ConstraintTemplate
    listKind: ConstraintTemplateList
    plural: constrainttemplates
    singular: constrainttemplate
  scope: Cluster
  versions:
  - name: v1                                    # This will be the version
    schema:
      openAPIV3Schema:
```



For Policy we need to follow below steps

`ConstraintTemplate` -> `And name mention in the ConstraintTemplate metadata name`

In `ConstraintTemplate` we also provide the static analysis Rules for `OPA`

```bash
$ k get crd | grep const
constraintpodstatuses.status.gatekeeper.sh            2025-03-28T16:44:32Z
constrainttemplatepodstatuses.status.gatekeeper.sh    2025-03-28T16:44:32Z
constrainttemplates.templates.gatekeeper.sh           2025-03-28T16:44:32Z
k8salwaysdeny.constraints.gatekeeper.sh               2025-03-28T17:38:54Z















## OPA for Server
### Install OPA 

Begin by downloading the OPA binary, making it executable, and starting the OPA server using the -s flag. By default, OPA listens on port 8181 and has an open API without built-in authentication or authorization:

Go to `https://github.com/open-policy-agent/opa/releases` and find the required version for installation.

```bash
curl -L -o opa https://github.com/open-policy-agent/opa/releases/download/v0.38.1/opa_linux_amd64
chmod 755 ./opa
./opa run -s
{"addrs":[":8181"],"diagnostic-addrs":[],"level":"info","msg":"Initializing server.","time":"2025-03-27T16:30:05Z"}
{"current_version":"0.38.1","download_opa":"https://openpolicyagent.org/downloads/v1.3.0/opa_linux_amd64","latest_version":"1.3.0","level":"info","msg":"OPA is out of date.","release_notes":"https://github.com/open-policy-agent/opa/releases/tag/v1.3.0","time":"2025-03-27T16:30:05Z"}
```

#### Simple Rego file

```bash
$ cat example.rego 
package httpapi.authz
import input
default allow = 
allow {
 input.path == "home"
 input.user == "Kedar"
 } 
```

Check the exmaple.rego file

```bash
./opa test example.rego
1 error occurred during loading: example.rego:3: rego_parse_error: illegal default rule (value cannot contain var)
        default allow = 
        ^
```
Resolve error

Set `default allow = false` in `example.rego`. Run the `./opa test example.rego` command again and file is now error free.

Run Below command to import example.rego in OPA


```bash
curl -X PUT --data-binary @example.rego http://localhost:8181/v1/policies/samplepolicy
{}
```
