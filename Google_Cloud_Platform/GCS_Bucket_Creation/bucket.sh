#!/bin/bash

# --- Configuration ---
# Your Google Cloud project ID
# This can be passed via Cloud Build's substitution variables
PROJECT_ID="${PROJECT_ID}"
# The desired GCS location
LOCATION="us-central1"
# The globally unique bucket name
BUCKET_NAME="demo-bucket-$(date +%s)"

# --- Pre-checks ---
# Ensure project ID and bucket name are provided
if [[ -z "$PROJECT_ID" || -z "$BUCKET_NAME" ]]; then
    echo "Error: PROJECT_ID or BUCKET_NAME is not set." >&2
    exit 1
fi

# --- Main Logic ---
echo "Checking for bucket: gs://${BUCKET_NAME} in project ${PROJECT_ID}..."

# Use a silent check for bucket existence.
# The `2>&1` redirects stderr to stdout, and `> /dev/null` discards all output.
# The exit code ($?) is the only thing we care about.
if gcloud storage buckets describe "gs://${BUCKET_NAME}" --project="${PROJECT_ID}" --quiet > /dev/null 2>&1; then
    echo "Bucket gs://${BUCKET_NAME} already exists. No action taken."
else
    # Check if the bucket name is valid
    if ! [[ "$BUCKET_NAME" =~ ^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$ ]]; then
        echo "Error: Invalid bucket name format. Bucket names must be between 3 and 63 characters, contain only lowercase letters, numbers, hyphens, and underscores, and start and end with a letter or number." >&2
        exit 1
    fi

    echo "Bucket gs://${BUCKET_NAME} does not exist. Creating now..."
    # The --quiet flag suppresses the "Are you sure?" prompt.
    gcloud storage buckets create "gs://${BUCKET_NAME}" --project="${PROJECT_ID}" --location="${LOCATION}" --quiet
    
    # Check if the bucket creation was successful
    if [ $? -eq 0 ]; then
        echo "Successfully created bucket gs://${BUCKET_NAME}."
    else
        echo "Error: Failed to create bucket gs://${BUCKET_NAME}." >&2
        exit 1
    fi
fi