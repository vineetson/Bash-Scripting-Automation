## GCS Per-File Mover: A Mission-Critical Solution for Rate-Limited Workflows 🚀

This folder contains a specialized Bash script designed for a common but critical challenge in cloud computing: **transferring files to a system with strict rate limits.** While traditional scripts focus on speed, this tool prioritizes control and reliability, making it a cornerstone for resilient data pipelines.

### Why This Script is Indispensable for Large-Scale Scenarios

In modern, distributed systems, not all data destinations can handle a flood of incoming files at once. Many third-party APIs, data warehouses, and even internal services have per-second or per-minute limits to maintain stability. Attempting a naive bulk transfer will result in failed requests, corrupted data streams, and service-wide disruptions.

This script solves that problem by providing a **surgical approach to data transfer** . By introducing a deliberate, configurable delay, it ensures that your data arrives at its destination at a controlled pace, perfectly aligning with the receiving system's capacity.

**Real-world Applications & Programming Examples:**

- **API Ingestion** : Send files to a machine learning API for processing, where the API has a limit of one request every 30 seconds.
- **IoT Data Pipelines** : Transfer sensor data from a GCS bucket to an analytics platform that can only ingest data at a fixed rate, preventing bottlenecks.
- **Legacy System Integration** : Migrate data to an older, on-premise system with limited bandwidth, ensuring a steady flow without overwhelming the network.

This script isn't just a simple file mover; it's a **proactive solution for managing data flow in complex ecosystems** . It turns a potential point of failure into a predictable and reliable stage of your pipeline.

---

### ⚙️ `gcs_per_file_mover.sh`

This script is a highly optimized, single-purpose utility, perfect for automated post-processing or data pipeline workflows. It processes each file individually, waits for a specified duration, and then moves on to the next one.

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

### 🔒 IAM Permissions for Production

For a service account to successfully run this script, it needs the following IAM permissions on the respective buckets:

- **Source Bucket (`your-source-bucket`)** :
- `storage.objects.list`: Required for `gsutil ls` to get the list of files.
- `storage.objects.get`: Required for `gsutil cp` to read the object data.
- **Destination Bucket (`your-destination-bucket`)** :
- `storage.objects.create`: Required for `gsutil cp` to write the new object.

For ease of use, you can grant the **Storage Object Admin** role on both buckets. For a production environment, it is a best practice to create a **custom role** with only these specific permissions to adhere to the principle of least privilege.
