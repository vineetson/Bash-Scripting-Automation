# ☁️ **GCP Bucket Provisioning Automation**

This repository contains a simple, yet robust, solution for automating the creation of Google Cloud Storage (GCS) buckets. Designed for DevOps and SRE teams, this script ensures that your bucket provisioning is idempotent, auditable, and seamlessly integrated into your CI/CD pipelines.

---

### 🚀 **Why Automate Bucket Creation?**

Manually creating GCS buckets for every project or environment is slow, error-prone, and doesn't scale. This solution transforms bucket provisioning into a **code-driven, automated process** .

- **Idempotency** : The script checks if a bucket already exists before attempting to create it. This is a crucial feature that allows you to run the script multiple times without causing errors, making it perfect for CI/CD pipelines.
- **Infrastructure as Code (IaC)** : By defining your bucket creation logic in a script and managing it in a repository, you treat your infrastructure as a version-controlled asset.
- **Scalability** : This setup is the foundational building block for larger, more complex automation scenarios. You can easily extend this to create multiple buckets for different environments (e.g., development, staging, production) or for different teams. This is a stepping stone to full-fledged IaC using tools like Terraform or Pulumi.

---

### ⚙️ **How it Works**

This solution combines a simple Bash script with a Cloud Build configuration file to automate the bucket creation process.

- **Bash Script (`bucket.sh`)** :

1. It validates that the required project ID and bucket name are provided.
2. It uses `gcloud storage buckets describe` to **silently check** for the existence of the bucket.
3. If the bucket is not found, it proceeds to create it using `gcloud storage buckets create`.
4. It includes robust error handling to ensure the script exits with a non-zero code upon failure, which is crucial for automated pipelines.

- **Cloud Build (`cloudbuild.yaml`)** :

1. This file defines a two-step build process.
2. **Step 1** : It makes the `bucket.sh` script executable using `chmod +x`. This ensures the script has the necessary permissions to run within the Cloud Build environment.
3. **Step 2** : It executes the `bucket.sh` script, which handles the bucket creation logic. The Cloud Build environment automatically provides the necessary authentication and permissions.

---

### 🛠️ **Requirements & Usage**

1. **Prerequisites** :

- A Google Cloud project with the **Cloud Build API** and **Cloud Storage API** enabled.
- A repository with the provided `bucket.sh` and `cloudbuild.yaml` files.
- The service account for Cloud Build must have the necessary permissions.

1. IAM Permissions:
   The Cloud Build service account (typically [PROJECT_NUMBER]@cloudbuild.gserviceaccount.com) needs the following IAM role to create buckets:

   - **Storage Admin (`roles/storage.admin`)** : This role grants full control over GCS buckets and objects. This is the simplest way to grant the necessary permissions.
   - For a more secure, **principle of least privilege** approach, you can create a custom role with `storage.buckets.create` and `storage.buckets.get` permissions.

2. Run the Pipeline:
   Trigger the Cloud Build pipeline, either manually from the GCP Console or automatically via a Git commit. The pipeline will execute the steps in cloudbuild.yaml to create your GCS bucket.

   ```
   # Example gcloud command to submit a build
   gcloud builds submit --config=cloudbuild.yaml .
   ```
