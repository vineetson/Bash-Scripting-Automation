# GCS Data Lifecyle Manager 🗓️

This folder contains a powerful Bash script for a common yet critical cloud task: **automating data lifecycle management on Google Cloud Storage (GCS).** This tool provides a robust and efficient way to move objects between buckets based on their creation date, making it an essential part of any data archival, cleanup, or backup strategy.

---

### 🎯 **The Strategic Advantage of Automation**

This script isn't just a simple utility; it's a  **proactive solution for managing your cloud spend and ensuring data hygiene at scale** . For any organization handling large volumes of data, this automation becomes a cornerstone of their cloud strategy.

* **Financial Discipline** : Avoid the hidden costs of outdated data. By automatically tiering objects to cheaper storage classes (e.g., Coldline or Archive), you proactively manage your budget and prevent unnecessary cloud spending.
* **Operational Excellence** : Replace manual, error-prone data archiving tasks with a reliable, auditable, and automated process. This frees up engineering time to focus on higher-value tasks.
* **Scalability & Performance** : The use of `gsutil -m` provides a parallelized approach to data movement, ensuring that even a terabyte-scale transfer is completed efficiently.  This built-in performance is what distinguishes it from simple, single-threaded scripts.

This **script** is a powerful example of how a small investment in automation can yield significant returns in cost savings, compliance, and operational efficiency, making it an indispensable tool for any data-driven organization.

### ⚙️ How it Works

1. **Configuration & Pre-checks** : The script first verifies that `gsutil` is installed and that the specified source and destination buckets exist.
2. **User Input** : It prompts you for a start and end date to define the range for files to be moved.
3. **Object Filtering** : It uses `gsutil ls -l` to list all objects recursively in the source bucket, then filters this list to identify files created within the specified date range.
4. **Parallel Execution** : To ensure maximum efficiency for large-scale operations, the script uses `gsutil -m cp` to **copy** the identified files in parallel to the destination bucket.
5. **Data Deletion** : After a successful copy, it uses `gsutil -m rm` to **delete** the original files from the source bucket, completing the "move" operation.
6. **Robust Logging** : All actions and outcomes are logged to a timestamped file for auditing and troubleshooting.

---

### 🛠️ Usage

1. **Clone the repository** :
   **Bash**

```
   git clone https://github.com/vineetson/Bash-Scripting-Automation.git
   cd Google Cloud Platform/Cloud Storage
```

1. Edit the script:
   Open gcs-move-by-date.sh and update the SOURCE_BUCKET and DESTINATION_BUCKET variables with your bucket names.
   **Bash**

   ```
   # --- Configuration ---
   SOURCE_BUCKET="your-source-bucket"
   DESTINATION_BUCKET="your-destination-bucket"
   ```
2. Run the script:
   Execute the script from your terminal and follow the prompts.
   **Bash**

   ```
   bash gcs-move-by-date.sh
   ```

---

### 🔒 IAM Permissions for Production

For a service account to successfully run this script in a production environment, it needs the following IAM permissions on the respective buckets:

* **Source Bucket (`your-source-bucket`)** :
* **Storage Object Viewer** : Required for the `gsutil ls -l` command to read file metadata.
* **Storage Object Deleter** : Required for the `gsutil rm` command to delete the original files.
* **Destination Bucket (`your-destination-bucket`)** :
* **Storage Object Creator** : Required for the `gsutil cp` command to write new objects to the bucket.

> **Note** : For simplicity, you could grant the **Storage Object Admin** role on both buckets, as it includes all the necessary permissions. However, for the  **principle of least privilege** —a security best practice that limits an entity's permissions to only what's absolutely necessary—it is highly recommended to create a **custom IAM role** with only the specific permissions listed above. This minimizes the attack surface and safeguards your data.
