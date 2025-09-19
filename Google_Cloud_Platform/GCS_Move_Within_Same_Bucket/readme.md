## Bash GCS Object Mover

This folder contains a simple, yet powerful, Bash script for moving a single object between folders within the same Google Cloud Storage (GCS) bucket.

---

### ⚙️ `gcs_move_by_folder.sh`

This script is a highly optimized, single-purpose utility, perfect for automated post-processing or data pipeline workflows. It's concise, fast, and leverages the power of the `gsutil` command-line tool.

### How it Works

1. **Configuration** : The script starts by defining key variables like the `BUCKET_NAME`, `SOURCE_FOLDER`, `DESTINATION_FOLDER`, and `OBJECT_NAME`.
2. **Pre-checks** : It first verifies that `gsutil` is installed and then uses `gsutil ls` to confirm the **existence of the source object** . This prevents errors and ensures the script only proceeds if the file is where it's expected to be.
3. **Atomic Move** : The core of the script is the `gsutil mv` command. When a move occurs within the same bucket, `gsutil` performs an **atomic server-side rename** . This is a highly efficient operation that changes the object's metadata without re-copying the data, which is a major performance benefit for large files.
4. **Logging** : The script includes custom logging functions to provide clear, timestamped output for each step.
5. **Error Handling** : It checks the exit code of the `gsutil mv` command to determine if the move was successful, providing a clear final status.

---

### 🚀 **Beyond the Basics: Why this Script is a Foundation for Your Data Pipelines**

While this script handles a single object, its real power lies in its **versatility and reusability** as a foundational component in larger, more complex automation scenarios.

- **Event-Driven Workflows** : You can integrate this script with **Cloud Functions** or **Cloud Workflows** that are triggered by events, such as a new file being uploaded. For example, when a new raw file lands in `gs://my-bucket/raw/`, a Cloud Function could execute this script to move it to `gs://my-bucket/processed/` and then trigger downstream processing.
- **Batch Processing Jobs** : Embed this script within a **Kubernetes Job** or a **Cloud Run** service to handle a list of files. Your main application could generate a list of files that need to be processed, and the script would iterate through them, performing a reliable, atomic move for each one.
- **Production-Ready Auditing** : The script's robust logging and explicit error handling make it perfect for production environments. You can easily parse its output to track which files were successfully processed and which ones failed, building a reliable audit trail for your data pipeline.

This script isn't just for a single task; it's a **mission-critical building block** for any data engineer or DevOps professional looking to build resilient, automated workflows on GCP.

---

### 🛠️ Requirements & Usage

1. **Prerequisites** :

- A Linux/macOS environment with Bash.
- Google Cloud SDK installed and authenticated on your machine.

1. Configuration:
   Open the gcs_move_by_folder.sh script and update the configuration variables at the top of the file with your bucket and folder names.

   ```
   # --- Configuration ---
   BUCKET_NAME="your-bucket-name"
   SOURCE_FOLDER="raw/"
   DESTINATION_FOLDER="processed/"
   OBJECT_NAME="your-file.txt"
   ```

2. Run the Script:
   Execute the script directly from your terminal.

   ```
   bash gcs_move_by_folder.sh
   ```

---

### 🔒 IAM Permissions Requirements

For a service account to successfully run this script, it needs the following IAM permissions on the GCS bucket:

- **`storage.objects.list`** : To check for the object's existence.
- **`storage.objects.get`** : To read the object's metadata for the move.
- **`storage.objects.create`** : To write the new object entry at the destination path.
- **`storage.objects.delete`** : To remove the original object.

For simplicity, you can grant the **Storage Object Admin** role on the bucket, which includes all these permissions. For a production environment, it's a best practice to create a **custom role** with only these specific permissions to adhere to the principle of least privilege.
