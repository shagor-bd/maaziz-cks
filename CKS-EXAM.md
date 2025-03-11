# Domains & Competencies

<table style="width:100%; table-layout:fixed;">
  <tr>
    <th style="width:70%;">Cluster Setup</th>
    <th style="width:30%;">15%</th>
  </tr>
  <tr>
    <td>Use Network security policies to restrict cluster level access</td>
    <td></td>
  </tr>
  <tr>
    <td>Use CIS benchmark to review the security configuration of Kubernetes components (etcd, kubelet, kubedns, kubeapi)</td>
    <td></td>
  </tr>
  <tr>
    <td>Properly set up Ingress with TLS</td>
    <td></td>
  </tr>
  <tr>
    <td>Protect node metadata and endpoints</td>
    <td></td>
  </tr>
  <tr>
    <td>Verify platform binaries before deploying</td>
    <td></td>
  </tr>
</table>

<table style="width:100%; table-layout:fixed;">
  <tr>
    <th style="width:70%;">Cluster Hardening</th>
    <th style="width:30%;">15%</th>
  </tr>
  <tr>
    <td style="width:70%">Use Role Based Access Controls to minimize exposure</td>
    <td></td>
  </tr>
  <tr>
    <td style="width:70%">Exercise caution in using service accounts e.g. disable defaults, minimize permissions on newly created ones</td>
    <td></td>
  </tr>
  <tr>
    <td style="width:70%">Restrict access to Kubernetes API</td>
    <td></td>
  </tr>
  <tr>
    <td style="width:70%">Upgrade Kubernetes to avoid vulnerabilities</td>
    <td></td>
  </tr>
</table>

<table style="width:100%; table-layout:fixed;">
  <tr>
    <th style="width:70%;">System Hardening</th>
    <th style="width:30%;">10%</th>
  </tr>
  <tr>
    <td>Minimize host OS footprint (reduce attack surface)</td>
    <td></td>
  </tr>
  <tr>
    <td>Using least-privilege identity and access management</td>
    <td></td>
  </tr>
  <tr>
    <td>Minimize external access to the network</td>
    <td></td>
  </tr>
  <tr>
    <td>Appropriately use kernel hardening tools such as AppArmor, seccomp</td>
    <td></td>
  </tr>
</table>

<table style="width:100%; table-layout:fixed;">
  <tr>
    <th style="width:70%;">Minimize Microservice Vulnerabilities</th>
    <th style="width:30%;">20%</th>
  </tr>
  <tr>
    <td>Use appropriate pod security standards</td>
    <td></td>
  </tr>
  <tr>
    <td>Manage Kubernetes secrets</td>
    <td></td>
  </tr>
  <tr>
    <td>Understand and implement isolation techniques (multi-tenancy, sandboxed containers, etc.)</td>
    <td></td>
  </tr>
  <tr>
    <td>Implement Pod-to-Pod encryption using Cilium</td>
    <td></td>
  </tr>
</table>

<table style="width:100%; table-layout:fixed;">
  <tr>
    <th style="width:70%;">Supply Chain Security</th>
    <th style="width:30%;">20%</th>
  </tr>
  <tr>
    <td>Minimize base image footprint</td>
    <td></td>
  </tr>
  <tr>
    <td>Understand your supply chain (e.g. SBOM, CI/CD, artifact repositories)</td>
    <td></td>
  </tr>
  <tr>
    <td>Secure your supply chain (permitted registries, sign and validate artifacts, etc.)</td>
    <td></td>
  </tr>
  <tr>
    <td>Perform static analysis of user workloads and container images (e.g. Kubesec, KubeLinter)</td>
    <td></td>
  </tr>
</table>

<table style="width:100%; table-layout:fixed;">
  <tr>
    <th style="width:70%;">Monitoring, Logging and Runtime Security</th>
    <th style="width:30%;">20%</th>
  </tr>
  <tr>
    <td>Perform behavioral analytics to detect malicious activities</td>
    <td></td>
  </tr>
  <tr>
    <td>Detect threats within physical infrastructure, apps, networks, data, users and workloads</td>
    <td></td>
  </tr>
  <tr>
    <td>Investigate and identify phases of attack and bad actors within the environment</td>
    <td></td>
  </tr>
  <tr>
    <td>Ensure immutability of containers at runtime</td>
    <td></td>
  </tr>
  <tr>
    <td>Use Kubernetes audit logs to monitor access</td>
    <td></td>
  </tr>
</table>