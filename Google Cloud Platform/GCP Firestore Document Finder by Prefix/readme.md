### 📂 GCP Firestore Document Finder

This Python script is an efficient and robust solution for querying documents in Google Cloud Firestore. It is designed to find and retrieve documents where the document ID starts with a specified prefix, leveraging a server-side query for optimal performance and cost-effectiveness.

---

### 🚀 Getting Started

#### **Prerequisites**

- **Python 3.x** : The script is written in Python 3.
- **Google Cloud SDK** : Ensure you've authenticated with your GCP project by running `gcloud auth login` and set your project with `gcloud config set project [YOUR_PROJECT_ID]`. The script uses **Application Default Credentials (ADC)** for secure, seamless authentication.
- **Environment Variables** : The script relies on environment variables for configuration, which is a best practice for production workloads. You'll need to set the following:
- `PROJECT_ID`: Your Google Cloud Project ID.
- `DATABASE_ID`: The ID of your Firestore database (e.g., `(default)`).
- `COLLECTION`: The name of the collection to query.

#### **Setup**

1. **Create a virtual environment** to manage dependencies:
   **Bash**

   ```
   python -m venv venv
   ```

2. **Activate the environment** :
   **Bash**

```
   # On macOS/Linux
   source venv/bin/activate
   # On Windows
   venv\Scripts\activate
```

1. **Install the necessary library** :
   **Bash**

```
   pip install google-cloud-firestore
```

---

### 💻 How It Works

The script is a comprehensive example of a production-ready Firestore client.

1. **Centralized Configuration** : All configuration is managed in a `Config` class, loading values from environment variables. This pattern allows for easy changes across different environments without modifying the source code.
2. **Singleton Client** : The `get_firestore_client()` function uses a singleton pattern. This means it creates a single instance of the Firestore client and reuses it for all subsequent calls, preventing redundant initialization and improving performance.
3. **Efficient Server-Side Query** : This is the most crucial part of the script's optimization. Instead of streaming the entire collection and filtering documents locally, the script performs a **server-side range query** . It orders documents by their ID (`__name__`) and uses `start_at` and `end_before` to retrieve only the documents whose IDs fall within the desired prefix range. This drastically reduces read operations and cost, especially for large collections.
4. **Logging** : The script uses Python's `logging` module to provide structured, time-stamped log messages. This is a key practice for automation, as logs can be easily monitored and debugged in a production environment, distinguishing between informational messages (`INFO`), non-critical issues (`WARNING`), and failures (`ERROR`).

---

### 🔑 IAM Permissions

For the user or service account running the script to successfully query documents, it needs the following IAM permissions on the Firestore database:

- `datastore.documents.get`
- `datastore.documents.list`

The most common way to grant these permissions is by assigning one of the following predefined IAM roles:

- **`roles/datastore.viewer`** : Grants read-only access to all Firestore data.
- **`roles/datastore.user`** : Grants read/write access to Firestore data.

For a production environment, it is highly recommended to create a **custom IAM role** that includes only the specific permissions needed by your workload, following the principle of least privilege.

---

### ⚙️ Usage

1. Set the required environment variables.
2. Run the script from your terminal:
   **Bash**

   ```
   PROJECT_ID="your-project" DATABASE_ID="(default)" COLLECTION="your-collection" python GCP_firestore_doc_finder.py
   ```
