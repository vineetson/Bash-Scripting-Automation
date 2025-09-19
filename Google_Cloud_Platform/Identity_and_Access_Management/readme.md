# **GCP IAM Role Manager** ✨

This repository contains a powerful and idempotent shell script designed to streamline the process of granting and revoking common developer and administrator IAM permissions in Google Cloud Platform (GCP). It's a fundamental tool for managing access with consistency and security. 🛡️

### **Production-Ready & Highly Adaptable**

This script is a solid foundation for your IAM management. It's built on principles of **idempotency** , **robust error handling** , and **flexible configuration** , which are essential for any production environment.

While the script comes with a predefined set of common roles, its true power lies in its **modularity** . You can easily modify the `project_roles` array to suit your specific security needs. For example, you can add or remove roles to create a custom IAM profile for different teams, such as Data Scientists, Developers, or Auditors.

**How to Tweak for Your Use Case:**

- **Customize Roles:** Simply edit the `project_roles` array in the script to include the exact permissions required by a team.
- **Add New Scopes:** You could extend the `--scope` option to handle additional resource types like Cloud SQL, Cloud Functions, or BigQuery datasets.
- **Integrate with Automation:** The script's CLI-friendly design makes it perfect for integrating into your CI/CD pipelines, where it can automatically grant or revoke permissions as part of your deployment process.

This script is more than just a tool; it's a secure and adaptable template for managing your cloud identity and access with confidence.

---

## 🚀 **Prerequisites**

Before using this script, ensure you have:

1. The **Google Cloud SDK** installed.
2. Authenticated with `gcloud`: `gcloud auth login`.
3. Set your default project: `gcloud config set project [YOUR_PROJECT_ID]`. (Alternatively, you can use the `--project` flag with the script).
4. The `iam.sh` script is executable: `chmod +x iam.sh`.

---

## 📖 **Usage**

The basic syntax for the script is:

```bash
./iam.sh [OPTIONS] <MEMBER>
```

**`<MEMBER>`**: The principal to whom permissions will be assigned or revoked.

- **Format**: `user:email@domain.com`, `group:email@domain.com`, or `serviceAccount:email@project.iam.gserviceaccount.com`.

---

## 🔧 **Options**

| Flag              | Description                                                   | Required?                            |
| :---------------- | :------------------------------------------------------------ | :----------------------------------- |
| `-a`, `--account` | The email of the service account the member can act as.       | Yes, for `sa` or `all` scopes.       |
| `-o`, `--scope`   | The scope of permissions:`project`, `sa`, or `all` (default). | No                                   |
| `-p`, `--project` | The GCP Project ID to apply permissions to.                   | No (uses `gcloud config` if omitted) |
| `-r`, `--remove`  | Revoke permissions instead of granting them.                  | No                                   |
| `-h`, `--help`    | Display the help menu.                                        | No                                   |

---

## 💡 **Scenarios & Examples**

Here are some common scenarios for using the `iam.sh` script.

### **✅ Granting Permissions**

#### 1\. Grant All Permissions (Project + Service Account)

This is the most common use case. It grants a member a set of useful project-level roles and allows them to act as a specific service account.

```bash
./iam.sh --account [SERVICE_ACCOUNT_EMAIL] user:[MEMBER_EMAIL]
```

**Example:**

```bash
./iam.sh --account my-runtime-sa@my-project.iam.gserviceaccount.com user:dev-user@example.com
```

#### 2\. Grant Only Project-Level Roles

This grants roles like Artifact Registry Writer, Storage Object User, Viewer, and VPC Access Admin without granting service account impersonation rights.

```bash
./iam.sh --scope project user:[MEMBER_EMAIL]
```

**Example:**

```bash
./iam.sh --scope project user:auditor@example.com
```

#### 3\. Grant Only Service Account User Role

This allows a member to act as (impersonate) a service account, which is essential for services like Cloud Run and for CI/CD pipelines. ⚙️

```bash
./iam.sh --scope sa --account [SERVICE_ACCOUNT_EMAIL] user:[MEMBER_EMAIL]
```

**Example:**

```bash
./iam.sh --scope sa --account my-runtime-sa@my-project.iam.gserviceaccount.com serviceAccount:deployer-sa@my-project.iam.gserviceaccount.com
```

---

### **🗑️ Revoking Permissions**

To revoke permissions, simply add the `--remove` flag to the grant commands.

#### 1\. Revoke All Permissions (Project + Service Account)

This removes all roles managed by this script from the member.

```bash
./iam.sh --remove --account [SERVICE_ACCOUNT_EMAIL] user:[MEMBER_EMAIL]
```

**Example:**

```bash
./iam.sh --remove --account my-runtime-sa@my-project.iam.gserviceaccount.com user:ex-developer@example.com
```

#### 2\. Revoke Only Project-Level Roles

This removes the project-level roles but leaves the service account user role intact.

```bash
./iam.sh --remove --scope project user:[MEMBER_EMAIL]
```

**Example:**

```bash
./iam.sh --remove --scope project user:dev-user@example.com
```

#### 3\. Revoke Only Service Account User Role

This removes the member's ability to impersonate the specified service account.

```bash
./iam.sh --remove --scope sa --account [SERVICE_ACCOUNT_EMAIL] user:[MEMBER_EMAIL]
```

**Example:**

```bash
./iam.sh --remove --scope sa --account my-runtime-sa@my-project.iam.gserviceaccount.com user:dev-user@example.com
```

---

### **⚙️ Advanced Usage**

#### Specifying a Project

If you want to run the script against a project other than your default configured one, use the `--project` flag.

```bash
./iam.sh --project [OTHER_PROJECT_ID] --account [SERVICE_ACCOUNT_EMAIL] user:[MEMBER_EMAIL]
```

#### Using Different Member Types

The script works with users, groups, and service accounts. Just change the prefix.

- **Group**:

```bash
./iam.sh --account [SA_EMAIL] group:my-dev-team@example.com
```

- **Service Account**:

```bash
./iam.sh --account [SA_EMAIL] serviceAccount:another-sa@my-project.iam.gserviceaccount.com
```
