## ☁️ `gcs-move-by-date.sh`

This script provides a robust and efficient way to move objects between Google Cloud Storage (GCS) buckets based on their creation date. It's ideal for data lifecycle management, archival, and cleanup.

### How it Works

1. **Configuration & Pre-checks** : The script first verifies that `gsutil` is installed and that the specified source and destination buckets exist.
2. **User Input** : It prompts you for a start and end date to define the range for files to be moved.
3. **Object Filtering** : It uses `gsutil ls -l` to list all objects recursively in the source bucket, then filters this list to identify files created within the specified date range.
4. **Parallel Execution** : To ensure maximum efficiency for large-scale operations, the script uses `gsutil -m cp` to **copy** the identified files in parallel to the destination bucket.
5. **Data Deletion** : After a successful copy, it uses `gsutil -m rm` to **delete** the original files from the source bucket, completing the "move" operation.
6. **Robust Logging** : All actions and outcomes are logged to a timestamped file for auditing and troubleshooting.

### ⚙️ Usage

1. **Clone the repository** :
   **Bash**

```
   git clone https://github.com/your-username/your-repo.git
   cd your-repo
```

1. **Edit the script** :
   Open `gcs-move-by-date.sh` and update the `SOURCE_BUCKET` and `DESTINATION_BUCKET` variables with your bucket names.
   **Bash**

```
   # --- Configuration ---
   SOURCE_BUCKET="your-source-bucket"
   DESTINATION_BUCKET="your-destination-bucket"
```

1. **Run the script** :
   Execute the script from your terminal and follow the prompts.
   **Bash**

```
   bash gcs-move-by-date.sh
```

---

## 🔒 IAM Permissions for Production

For a service account to successfully run this script in a production environment, it needs the following IAM roles on the respective buckets:

- **Source Bucket (`your-source-bucket`)** :
- **Storage Object Viewer** : Required for the `gsutil ls -l` command to read file metadata.
- **Storage Object Deleter** : Required for the `gsutil rm` command to delete the original files.
- **Destination Bucket (`your-destination-bucket`)** :
- **Storage Object Creator** : Required for the `gsutil cp` command to write new objects to the bucket.

> **Note** : For simplicity, you could grant the **Storage Object Admin** role on both buckets, as it includes all the necessary permissions. However, for a principle of least privilege, grant the specific roles listed above.
