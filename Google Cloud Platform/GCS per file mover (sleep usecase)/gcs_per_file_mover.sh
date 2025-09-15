#!/bin/bash

# --- Configuration ---
SOURCE_BUCKET="gs://source-bucket-path"
DEST_BUCKET="gs://destination-bucket-path"
SLEEP_TIME=30 # Sleep time in seconds between each file transfer

# --- Main Script ---

# Define logging functions
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - INFO - $1"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ERROR - $1" >&2
    exit 1
}

# --- Pre-checks ---
# Ensure gsutil is available
if ! command -v gsutil &> /dev/null; then
    log_error "gsutil is not installed. Please install Google Cloud SDK."
fi

# Validate source and destination buckets
if ! gsutil ls "${SOURCE_BUCKET}" &> /dev/null; then
    log_error "Source bucket '${SOURCE_BUCKET}' not found or inaccessible."
fi

if ! gsutil ls "${DEST_BUCKET}" &> /dev/null; then
    log_error "Destination bucket '${DEST_BUCKET}' not found or inaccessible."
fi

# --- Main Logic ---
log_info "Starting file copy from ${SOURCE_BUCKET} to ${DEST_BUCKET} with a ${SLEEP_TIME}s delay after each file."

# Use process substitution to avoid subshell issues with a while loop.
# This ensures variables like success/failure counts are preserved.
SUCCESS_COUNT=0
FAILURE_COUNT=0
TOTAL_FILES=0

while read -r file_path; do
    TOTAL_FILES=$((TOTAL_FILES+1))
    log_info "Copying file: ${file_path}..."

    # Use gsutil cp with error handling
    gsutil cp "${file_path}" "${DEST_BUCKET}"
    if [ $? -eq 0 ]; then
        log_info "Successfully copied: ${file_path}"
        SUCCESS_COUNT=$((SUCCESS_COUNT+1))
    else
        log_error "Failed to copy: ${file_path}. Aborting."
        FAILURE_COUNT=$((FAILURE_COUNT+1))
    fi

    # The required delay
    if [ ${TOTAL_FILES} -gt 0 ]; then
        log_info "Sleeping for ${SLEEP_TIME} seconds..."
        sleep "${SLEEP_TIME}"
    fi

done < <(gsutil ls -r "${SOURCE_BUCKET}")

log_info "Copy operation summary:"
log_info "Total files processed: ${TOTAL_FILES}"
log_info "Successfully copied: ${SUCCESS_COUNT}"
log_info "Failed to copy: ${FAILURE_COUNT}"

if [ ${FAILURE_COUNT} -eq 0 ]; then
    log_info "All files copied successfully! 🎉"
else
    log_error "Some files failed to copy. Please check the logs."
fi