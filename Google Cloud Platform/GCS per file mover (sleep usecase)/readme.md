## GCS Per-File Mover

This folder contains a specialized Bash script designed to transfer files between Google Cloud Storage (GCS) buckets with a mandatory delay after each file.

---

### ⚙️ `gcs_per_file_mover.sh`

This script is useful for scenarios where you need to **rate-limit** data ingestion or processing. Unlike standard bulk transfers, this script processes each file individually, waits for a specified duration, and then moves on to the next one. This is crucial for interacting with APIs or services that have strict per-second or per-minute transaction limits.

### Why Use a Sleep Delay?

In many real-world programming scenarios, services (like APIs, databases, or third-party systems) impose **rate limits** to prevent abuse and ensure fair usage. For example, a data processing API might only allow 10 requests per second. If you transfer a batch of 100 files and then immediately trigger an API call for each one, you would exceed the limit and cause the API to return errors.

Real-world Example:

Imagine you have a bucket of audio files that need to be sent to a speech-to-text API. This API has a limit of 1 file processed per 30 seconds. By using the sleep 30 command in this script, you can ensure that each file is transferred and then a processing job is triggered at a rate the API can handle, preventing service disruption and failed jobs.

---

### How it Works

1. **Configuration** : The script is configured with variables for the `SOURCE_BUCKET`, `DEST_BUCKET`, and `SLEEP_TIME`.
2. **Pre-checks** : It first verifies that `gsutil` is installed and that both the source and destination buckets exist and are accessible.
3. **File-by-File Copy** : It uses a `while` loop to iterate through every file in the source bucket. For each file, it executes the `gsutil cp` command.
4. **Mandatory Delay** : After a successful copy, the script pauses for the duration specified by the `SLEEP_TIME` variable. This delay is the core feature of the script, enabling rate-limited transfers.
5. **Robust Logging** : The script uses dedicated functions to provide clear, timestamped logs for each step, including success and failure messages.
6. **Error Handling** : If a file transfer fails for any reason, the script logs the error and aborts the entire process, preventing partial or incomplete transfers.

---

### 🛠️ Requirements & Usage

1. **Prerequisites** :

- A Linux/macOS environment with Bash.
- Google Cloud SDK installed and authenticated on your machine.

1. Configuration:
   Open the gcs_per_file_mover.sh script and update the configuration variables at the top of the file with your bucket names and desired sleep time.

   ```
   # --- Configuration ---
   SOURCE_BUCKET="gs://your-source-bucket"
   DEST_BUCKET="gs://your-destination-bucket"
   SLEEP_TIME=30 # Sleep time in seconds between each file transfer
   ```

2. Run the Script:
   Execute the script from your terminal:

   ```
   bash gcs_per_file_mover.sh
   ```

---

### 🔒 IAM Permissions Requirements:

For a service account to successfully run this script, it needs the following IAM permissions on the respective buckets:

- **Source Bucket (`your-source-bucket`)** :
- `storage.objects.list`: Required for `gsutil ls` to get the list of files.
- `storage.objects.get`: Required for `gsutil cp` to read the object data.
- **Destination Bucket (`your-destination-bucket`)** :
- `storage.objects.create`: Required for `gsutil cp` to write the new object.

For ease of use, you can grant the **Storage Object Admin** role on both buckets. For a production environment, it is a best practice to create a **custom role** with only these specific permissions to adhere to the principle of least privilege.
