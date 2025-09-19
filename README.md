
# 🚀 **GCP Automation with Shell/Bash**

This repository is your essential toolkit for automating common, yet mission-critical, tasks across Google Cloud Platform (GCP). It contains a collection of robust, production-ready Bash scripts designed to streamline your workflows, optimize costs, and enhance the reliability of your data pipelines.

---

### **💡 Why This Repo?**

In cloud infrastructure, a well-placed script can save you significant time and money. Our scripts leverage native GCP tools like **`gsutil`** to perform tasks directly and efficiently. They are simple to integrate into cron jobs, Cloud Functions, or CI/CD pipelines, making them a perfect choice for DevOps professionals and system administrators.

---

### **📁 The Scripts**

The scripts are organized by their function and purpose. Each directory contains a script and a detailed **`README.md`** file with instructions, prerequisites, and IAM permissions.

* [Cloud Storage](https://github.com/vineetson/Bash-Scripting-Automation/tree/master/Google%20Cloud%20Platform/Cloud%20Storage)
  * **`gcs-move-by-date.sh`** : A powerful script for  **automated data lifecycle management** . It efficiently moves objects between buckets based on their creation date, ideal for cost-saving archival strategies. It uses **`gsutil -m`** for highly efficient, parallelized transfers.
* [GCS Move Within A Bucket](https://github.com/vineetson/Bash-Scripting-Automation/tree/master/Google%20Cloud%20Platform/GCS%20Move%20Within%20A%20Bucket)
  * **`gcs-move-within-a-bucket.sh`** : A versatile script for  **intra-bucket operations** . It provides a simple and reliable way to move a single object from one "folder" to another within the same GCS bucket. It leverages **`gsutil mv`** for an  **atomic, server-side rename** , which is the fastest way to move large files without re-copying data.
* [GCS per file mover (sleep usecase)](https://github.com/vineetson/Bash-Scripting-Automation/tree/master/Google%20Cloud%20Platform/GCS%20per%20file%20mover%20(sleep%20usecase))
  * **`gcs-per-file-mover.sh`** : A specialized script for  **rate-limited data ingestion** . This is a mission-critical tool for data pipelines where the receiving system has strict API limits. It introduces a configurable sleep delay between each file transfer to ensure a controlled and reliable data flow.

---

### **🔒 IAM & Security**

Each script's **`README.md`** provides a detailed breakdown of the  **minimum required IAM permissions** . For all production workloads, we strongly recommend creating a **custom IAM role** to follow the principle of least privilege, thereby minimizing your security footprint.

Explore the scripts and start automating your GCP environment today!
