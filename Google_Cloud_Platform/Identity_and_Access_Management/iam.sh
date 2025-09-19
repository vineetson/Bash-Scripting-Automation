#!/bin/bash

# A production-ready script to assign a broad set of developer and admin roles in GCP.
# This script is idempotent. Running it multiple times with the same
# parameters will not cause any errors.

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# --- Constants and Colors ---
SCRIPT_NAME="$(basename "$0")"
# Using tput for colors to make it more portable
if [[ -t 1 ]]; then
    COLOR_GREEN=$(tput setaf 2)
    COLOR_RED=$(tput setaf 1)
    COLOR_RESET=$(tput sgr0)
else
    COLOR_GREEN=""
    COLOR_RED=""
    COLOR_RESET=""
fi

# --- Functions ---

# Print usage information
usage() {
    cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS] <MEMBER>
Assigns or revokes developer and admin IAM roles for a principal.

Arguments:
  MEMBER                Principal to grant roles to (e.g., user:name@example.com).

Options:
  -p, --project <ID>    GCP project ID (uses gcloud config if not set).
  -a, --account <EMAIL> Service account email. Required for 'sa' or 'all' scopes.
  -o, --scope <SCOPE>   Scope of permissions: 'project', 'sa', or 'all' (default).
  -r, --remove          Revoke roles instead of granting them.
  -h, --help            Display this help and exit.

Example:
  # Grant project and service account roles
  ${SCRIPT_NAME} --account SA_EMAIL@project.iam.gserviceaccount.com user:dev@foo.com
  # Grant only project-level roles
  ${SCRIPT_NAME} --scope project user:dev@foo.com
EOF
    exit 1
}

# Log messages
info() { echo "${COLOR_GREEN}[INFO]${COLOR_RESET} $1"; }
error() { echo "${COLOR_RED}[ERROR]${COLOR_RESET} $1" >&2; exit 1; }

# --- Main Logic ---
main() {
    command -v gcloud &> /dev/null || error "'gcloud' not found. Please install Google Cloud SDK."

    # Default values
    local project_id="" member="" runtime_sa=""
    local remove_roles=false
    local scope="all"

    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -p|--project) project_id="$2"; shift 2 ;;
            -a|--account) runtime_sa="$2"; shift 2 ;;
            -o|--scope)
                scope="$2"
                [[ ! "$scope" =~ ^(all|project|sa)$ ]] && error "Invalid scope '$2'. Must be 'all', 'project', or 'sa'."
                shift 2
                ;;
            -r|--remove) remove_roles=true; shift ;;
            -h|--help) usage ;;
            -*) error "Unknown option: $1" ;;
            *)
                if [[ -z "${member}" ]]; then member="$1"; else error "Unexpected argument: $1"; fi
                shift ;;
        esac
    done

    # --- Input Validation ---
    [[ -z "${member}" ]] && error "Missing required argument: MEMBER. See --help."
    [[ "${member}" =~ ^(user|group|serviceAccount):.+@.+\..+ ]] || error "Invalid MEMBER format."

    if [[ "$scope" =~ ^(all|sa)$ ]]; then
        [[ -z "${runtime_sa}" ]] && error "Service account email must be provided with --account for scope '${scope}'."
        [[ ! "${runtime_sa}" =~ ^.+@.+\.iam\.gserviceaccount\.com$ ]] && error "Invalid service account email format for --account."
    fi

    # If project_id is not set via flag, get it from gcloud config
    if [[ -z "${project_id}" ]]; then
        project_id=$(gcloud config get-value project 2>/dev/null)
        [[ -z "${project_id}" ]] && error "Project ID not found. Use -p or 'gcloud config set project'."
    fi

    # --- Roles Configuration ---
    local project_roles=("roles/artifactregistry.writer" "roles/storage.objectUser" "roles/viewer" "roles/vpcaccess.admin")

    # --- Granting/Revoking Roles ---
    local action_verb="Granting" success_verb="assigned" gcloud_command="add-iam-policy-binding"
    $remove_roles && { action_verb="Revoking"; success_verb="revoked"; gcloud_command="remove-iam-policy-binding"; }

    if [[ "$scope" =~ ^(all|project)$ ]]; then
        info "${action_verb} ${#project_roles[@]} project-level roles to '${member}' on project '${project_id}'..."
        for role in "${project_roles[@]}"; do
            info "  - ${action_verb} ${role}..."
            gcloud projects "${gcloud_command}" "${project_id}" --member="${member}" --role="${role}" --condition=None --quiet || true
        done
    fi

    if [[ "$scope" =~ ^(all|sa)$ ]]; then
        info "${action_verb} Service Account User (roles/iam.serviceAccountUser) to '${member}' on service account '${runtime_sa}'..."
        gcloud iam service-accounts "${gcloud_command}" "${runtime_sa}" --project="${project_id}" --member="${member}" --role="roles/iam.serviceAccountUser" --quiet || true
    fi

    echo
    info "✅ Success! Operation completed."
    case "$scope" in
        project) info "Project roles were ${success_verb} for ${member}." ;;
        sa) info "Service Account User role was ${success_verb} for ${member} on ${runtime_sa}." ;;
        all) info "Project and Service Account User roles were ${success_verb} for ${member}." ;;
    esac
}

# Run the main function
main "$@"