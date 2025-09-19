
# 🚀 **GCP Automation with Shell/Bash**

This repository is your essential toolkit for automating common, yet mission-critical, tasks across Google Cloud Platform (GCP). It contains a collection of robust, production-ready Bash scripts designed to streamline your workflows, optimize costs, and enhance the reliability of your data pipelines.

---

### **💡 Why This Repo?**

In cloud infrastructure, a well-placed script can save you significant time and money. Our scripts leverage native GCP tools like **`gsutil`** to perform tasks directly and efficiently. They are simple to integrate into cron jobs, Cloud Functions, or CI/CD pipelines, making them a perfect choice for DevOps professionals and system administrators.

---

### **📁 The Scripts**

The scripts are organized by their function and purpose. Each directory contains a script and a detailed **`README.md`** file with instructions, prerequisites, and IAM permissions.
<br>

- **Google_Cloud_Platform**
    - **[Dialogflow_Agent_Creation](https://github.com/vineetson/Bash-Scripting-Automation/tree/master/Google_Cloud_Platform/Dialogflow_Agent_Creation)**
        - Automate the provisioning of a new Dialogflow agent, a crucial step for conversational AI projects.
    - **[GCS_Bucket_Creation](https://github.com/vineetson/Bash-Scripting-Automation/tree/master/Google_Cloud_Platform/GCS_Bucket_Creation)**
        - An idempotent solution to automatically create a Google Cloud Storage bucket via a CI/CD pipeline.
    - **[GCS_Move_Objects_By_Date](https://github.com/vineetson/Bash-Scripting-Automation/tree/master/Google_Cloud_Platform/GCS_Move_Objects_By_Date)**
        - A powerful script for **automated data lifecycle management**, ideal for archiving data to save costs.
    - **[GCS_Move_Within_Same_Bucket](https://github.com/vineetson/Bash-Scripting-Automation/tree/master/Google_Cloud_Platform/GCS_Move_Within_Same_Bucket)**
        - A script that provides a simple and reliable way to move a single object from one "folder" to another within the same GCS bucket.
    - **[GCS_Per_File_Mover_Sleep_Usecase](https://github.com/vineetson/Bash-Scripting-Automation/tree/master/Google_Cloud_Platform/GCS_Per_File_Mover_Sleep_Usecase)**
        - A specialized tool for **rate-limited data ingestion**. It introduces a configurable sleep delay between file transfers to ensure a controlled and reliable data flow.
    - **[Identity_and_Access_Management](https://github.com/vineetson/Shell-Scripting-Automation/tree/master/Google_Cloud_Platform/Identity_and_Access_Management)**
        - A **production-ready, idempotent solution** for managing IAM roles in GCP. It automates granting or revoking project and service account permissions, making it an essential tool for standardizing access in CI/CD pipelines.

---

### **🔒 IAM & Security**

Each script's **`README.md`** provides a detailed breakdown of the  **minimum required IAM permissions** . For all production workloads, it is strongly recommended to create a **custom IAM role** to follow the principle of least privilege, thereby minimizing your security footprint.

Explore the scripts and start automating your GCP environment today!
