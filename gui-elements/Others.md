# `kubectl proxy`

`kubectl proxy` is a command used to create a local proxy to the Kubernetes API server. This allows you to interact with the Kubernetes API directly from your local machine without requiring authentication for each request.

### **Basic Usage**
```sh
kubectl proxy
```
This starts a proxy server on `http://127.0.0.1:8001/` by default, forwarding requests to the Kubernetes API server.

### **Use Cases**
1. **Accessing the Kubernetes API locally**  
   With `kubectl proxy` running, you can interact with the API using tools like `curl` or directly in a browser.
   ```sh
   curl http://127.0.0.1:8001/api/v1/nodes
   ```
   This fetches details of all nodes in the cluster.

2. **Accessing Kubernetes Dashboard**  
   If the Kubernetes Dashboard is deployed, you can access it via:
   ```sh
   http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
   ```

3. **Interacting with Resources Without Authentication**  
   Since the proxy uses your existing `kubectl` credentials, it removes the need to manually provide authentication headers.

### **Advanced Options**
- **Specify a different port**  
  ```sh
  kubectl proxy --port=9000
  ```
- **Allow access from other hosts** (bind to all interfaces)  
  ```sh
  kubectl proxy --address=0.0.0.0 --accept-hosts='.*'
  ```
- **Enable API filtering for security**  
  ```sh
  kubectl proxy --disable-filter=false
  ```

### **Stopping the Proxy**
Simply press `Ctrl+C` in the terminal running `kubectl proxy` to stop it.



# `kubectl port-forword` 

`kubectl port-forward` is a command used to forward a port from a local machine to a pod, service, or deployment inside a Kubernetes cluster. This is useful for accessing applications running inside the cluster without exposing them via a service or ingress.

---

## **Basic Syntax**
```sh
kubectl port-forward <resource-type>/<resource-name> <local-port>:<remote-port>
```
- `<resource-type>`: Can be `pod`, `service`, or `deployment`
- `<resource-name>`: The name of the pod, service, or deployment
- `<local-port>`: The port on your local machine
- `<remote-port>`: The port in the container (inside the pod)

---

## **Examples**

### **1. Forward a Port from a Pod**
If you have a pod named `my-pod` running an application on port `8080`, forward it to your local machine’s port `9090`:
```sh
kubectl port-forward pod/my-pod 9090:8080
```
Now, you can access the application at `http://localhost:9090`.

---

### **2. Forward a Port from a Service**
If a service named `my-service` exposes port `80`, you can forward it to your local machine’s port `8080`:
```sh
kubectl port-forward service/my-service 8080:80
```
This allows you to access the service as if it were running locally.

---

### **3. Forward a Port from a Deployment**
To forward a port from a deployment named `my-deployment`:
```sh
kubectl port-forward deployment/my-deployment 5000:5000
```
This will forward traffic to one of the pods in the deployment.

---

## **Use Cases**
- Debugging applications running inside Kubernetes without exposing them.
- Accessing internal services (like databases) securely.
- Testing API endpoints of a running application.

---

## **Stopping Port Forwarding**
Simply press `Ctrl+C` in the terminal to stop forwarding.

# Expose K8S Dashboard with Ingress Controller

We can expose both secure and insecure way k8s Dashboard. Check the ingress for more.