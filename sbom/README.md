# Software Bill of Materials (SBOM)

In the **Certified Kubernetes Security Specialist (CKS)** exam, understanding **Software Bill of Materials (SBOM)** is crucial since it helps in maintaining transparency and security in your container images. SBOMs are increasingly important for identifying vulnerabilities and ensuring compliance.

## **What is an SBOM?**  
An **SBOM** is a detailed list of all components, libraries, and dependencies within a software application. It helps to:
- Track open source and third-party components.
- Identify vulnerabilities.
- Maintain compliance.

---
**SBOM have 2 format**
- SPDX
- CycloneDX

## SPDX Format
SPDX is a comprehensive SBOM format that organizes information into several key sections to ensure thorough documentation of software packages.

### Overview
The SPDX format is structured into the following sections:

1. **Document Information:** Contains metadata about the SPDX document, including creator details, creation date, and version.
2. **Relationships:** Defines how various components of the SBOM interrelate (e.g., file-to-package or dependency relationships).
3. **Package Information:** Provides specific software package details such as name, version, supplier, and verification information (e.g., checksums).
4. **Snippets:** Captures smaller sections of code or components, including excerpts from open-source libraries.
5. **File Information:** Tracks individual files within the package.
6. **Additional Metadata:** Offers extra details like notes, licensing information, and review records to ensure the SBOM’s accuracy.


## CycloneDX Format
CycloneDX is designed as a lightweight SBOM format that places special emphasis on security and compliance. It is particularly useful for identifying vulnerabilities and managing component dependencies.

### Overview
Key sections in the CycloneDX format include:

1. **BOM Metadata:** Contains general information about the SBOM such as version, timestamp, and creator details.
2. **Components List:** Enumerates the individual parts or modules within the software.
3. **Vulnerabilities:** Lists known security vulnerabilities associated with the components.
4. **Software Services:** Details any services associated with the software.
5. **Annotations:** Provides additional notes or contextual information.
6. **Dependencies and Extensions:** Offers further insights into component dependencies and extended metadata.

## Comparison Between SPDX and CycloneDX
Both SPDX and CycloneDX are powerful SBOM formats, each with their own set of strengths. The table below summarizes their key differences:

|Feature|	SPDX|	CycloneDX|
|-------|-------|------------|
|**Format & Complexity** |	Extensive metadata with focus on licensing and compliance. Available in JSON and RDF formats. |	Lightweight format focusing on security and vulnerabilities. Available in JSON and XML formats.|
|**Security Focus** |	Detailed license data and compliance metrics.|	Emphasizes vulnerability tracking and dependency management. |
|**Ease of Use** |	More complex due to extensive metadata coverage.|	Simpler and more focused on security and compliance. |

---

## Overview of the SBOM Process
The SBOM process is comprised of the following key steps:

- Generate the SBOM.
- Securely store the SBOM.
- Scan the SBOM for vulnerabilities.
- Analyze the scan results.
- Remediate the identified issues.
- Continuously monitor the SBOM.
- Two key formats dominate in the SBOM space: SPDX and CycloneDX.

### **Tools You Should Know:**  
For the CKS exam, you may encounter tools for generating and analyzing SBOMs:
1. **Syft** - Generate SBOMs from container images.  
2. **Grype** - Scan for vulnerabilities using SBOMs.  
3. **Trivy** - Integrated SBOM generation and vulnerability scanning.  
4. **kubectl** - Not directly for SBOM, but used in conjunction with container security practices.  

---

## 📝 **Practice Example 1: Generate an SBOM using Syft**  

### **Scenario:**  
You have a Docker image called `app:latest`, and you need to generate its SBOM.

---

### **Steps:**  
1. **Install Syft:**  
   ```bash
   curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
   ```
   
2. **Generate SBOM:**  
   ```bash
   # Basic json format
   syft myapp:latest -o json > myapp-sbom.json
   # Generate in SPDX json format
   syft app:latest -o spdx-json > app-spdx.json
   # Generate in CycloneDX json format
   syft app:latest -o cyclonedx-json > app-cyclonedx.json
   ```
   
3. **Inspect the SBOM:**  
   ```bash
   cat myapp-sbom.json | jq '.artifacts[] | {name: .name, version: .version, type: .type}'
   ```
   
### **What to look for:**  
- Ensure the SBOM contains all installed packages and dependencies.  
- Check for libraries that may have known vulnerabilities.  

---

## 📝 **Practice Example 2: Vulnerability Scan using Grype with SBOM**  

### **Scenario:**  
You need to scan the SBOM from the previous example for vulnerabilities.

---

### **Steps:**  
1. **Install Grype:**  
   ```bash
   curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
   ```
   
2. **Scan the SBOM:**  
   ```bash
   grype sbom:./myapp-sbom.json
   ```
   
### **What to look for:**  
- Identify any **Critical** or **High** vulnerabilities.  
- Take note of the affected package versions.  

---

## 📝 **Practice Example 3: Automate SBOM Generation in CI/CD**  

### **Scenario:**  
Automate SBOM generation for each Docker build using a CI/CD pipeline.  

#### **Pipeline Step Example (GitLab CI):**  
```yaml
generate_sbom:
  stage: build
  image: anchore/syft
  script:
    - syft myapp:latest -o cyclonedx-json > myapp-sbom.json
  artifacts:
    paths:
      - myapp-sbom.json
```

### **What to look for:**  
- Verify that the SBOM is generated and stored as an artifact.  
- Make sure the pipeline fails if critical vulnerabilities are detected.  

---

## 💡 **CKS Exam Tips:**  
1. **Be Fast:** Use one-liners to generate and scan SBOMs.  
2. **Be Accurate:** Always verify the content of your SBOM to ensure completeness.  
3. **Understand Formats:** Familiarize yourself with common SBOM formats like **CycloneDX** and **SPDX**.  
4. **Be Practical:** Know how to automate SBOM generation and integrate it with CI/CD.  

