#!/bin/bash

# --- Configuration ---
SOURCE_BUCKET="demo-bucket-src"
DESTINATION_BUCKET="demo-bucket-mv"
GCP_PROJECT_ID="your-gcp-project"

# --- Pre-checks ---
# Ensure gsutil is installed and authenticated
if ! command -v gsutil &> /dev/null; then
    echo "gsutil could not be found. Please install Google Cloud SDK."
    echo "Refer to: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if source bucket exists and is accessible
if ! gsutil ls "gs://${SOURCE_BUCKET}" &> /dev/null; then
    echo "Error: Source bucket 'gs://${SOURCE_BUCKET}' does not exist or you don't have permissions."
    exit 1
fi

# Check if destination bucket exists and is accessible
if ! gsutil ls "gs://${DESTINATION_BUCKET}" &> /dev/null; then
    echo "Error: Destination bucket 'gs://${DESTINATION_BUCKET}' does not exist or you don't have permissions."
    exit 1
fi

# --- Get Date Range Input ---
read -p "Enter the START DATE (YYYY-MM-DD) for moving data: " START_DATE
read -p "Enter the END DATE (YYYY-MM-DD) for moving data: " END_DATE

# Validate date format (basic check)
if ! [[ "$START_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || ! [[ "$END_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Error: Invalid date format. Please use YYYY-MM-DD. Operation cancelled."
    exit 1
fi

# Convert input dates to Unix timestamps for comparison
START_TS=$(date -d "${START_DATE} 00:00:00" +%s 2>/dev/null)
END_TS=$(date -d "${END_DATE} 23:59:59" +%s 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "Error: Could not parse dates. Please ensure they are valid. Operation cancelled."
    exit 1
fi

# --- Confirmation before moving ---
read -p "Are you sure you want to MOVE data created between ${START_DATE} and ${END_DATE} from gs://${SOURCE_BUCKET} to gs://${DESTINATION_BUCKET}? (yes/no): " CONFIRMATION
if [[ ! "$CONFIRMATION" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Operation cancelled by user."
    exit 0
fi

# --- Perform the move operation with date filtering ---
echo "Starting data move for objects created between ${START_DATE} and ${END_DATE}..."

LOG_FILE="gsutil_move_by_date_$(date +%Y%m%d%H%M%S).log"
echo "Log file for this operation: ${LOG_FILE}" | tee "${LOG_FILE}"

# Use a temporary file to store the list of files to move.
# This prevents an array from holding a massive number of entries, which can
# lead to memory issues on systems with limited resources.
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT # Ensure the temporary file is removed on script exit

echo "Listing and filtering objects by creation date..." | tee -a "${LOG_FILE}"

# Use 'gsutil ls -l' to get detailed object information
while read -r line; do
    # Check if the line is a valid object entry
    if [[ "$line" =~ ^[[:space:]][0-9]+[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z[[:space:]]+gs://. ]]; then
        CREATION_DATE_STR=$(echo "$line" | awk '{print $2}')
        OBJECT_PATH=$(echo "$line" | awk '{print $3}')
        OBJECT_TS=$(date -d "$CREATION_DATE_STR" +%s 2>/dev/null)

        if [ $? -eq 0 ]; then
            if (( OBJECT_TS >= START_TS && OBJECT_TS <= END_TS )); then
                # Write the source and destination paths to the temp file
                DEST_OBJECT_PATH=$(echo "$OBJECT_PATH" | sed "s|gs://${SOURCE_BUCKET}|gs://${DESTINATION_BUCKET}|")
                echo "${OBJECT_PATH} ${DEST_OBJECT_PATH}" >> "${TMP_FILE}"
            fi
        fi
    fi
done < <(gsutil ls -l "gs://${SOURCE_BUCKET}/**")

FILE_COUNT=$(wc -l < "${TMP_FILE}")

if [ "${FILE_COUNT}" -eq 0 ]; then
    echo "No files found within the specified date range: ${START_DATE} to ${END_DATE}. No action taken." | tee -a "${LOG_FILE}"
    exit 0
fi

echo "Found ${FILE_COUNT} files to move within the date range." | tee -a "${LOG_FILE}"
echo "Performing move operation..." | tee -a "${LOG_FILE}"

# --- OPTIMIZATION ---
# Using 'gsutil -m cp' followed by 'gsutil -m rm' is a more scalable and
# efficient method for moving a large number of files.
# The `-m` flag enables multithreading, significantly speeding up the transfer.

# Step 1: Copy all files in parallel
echo "Step 1/2: Copying files in parallel..." | tee -a "${LOG_FILE}"
# Use a separate temporary file for source paths only
SOURCE_PATHS_TMP=$(mktemp)
awk '{print $1}' "${TMP_FILE}" > "${SOURCE_PATHS_TMP}"
gsutil -m cp $(cat "${SOURCE_PATHS_TMP}") "gs://${DESTINATION_BUCKET}/" 2>&1 | tee -a "${LOG_FILE}"
COPY_RESULT=$?
rm -f "${SOURCE_PATHS_TMP}"

if [ $COPY_RESULT -ne 0 ]; then
    echo "Warning: Some files may have failed to copy. Check the log for details. Aborting delete step." | tee -a "${LOG_FILE}"
    exit 1
fi

# Step 2: Remove source files in parallel
echo "Step 2/2: Deleting original files in parallel..." | tee -a "${LOG_FILE}"
gsutil -m rm $(awk '{print $1}' "${TMP_FILE}") 2>&1 | tee -a "${LOG_FILE}"
DELETE_RESULT=$?

if [ $DELETE_RESULT -ne 0 ]; then
    echo "Warning: Some files may have failed to be deleted from the source. Please check your source bucket." | tee -a "${LOG_FILE}"
fi

echo "" | tee -a "${LOG_FILE}"
echo "Move operation summary:" | tee -a "${LOG_FILE}"
echo "Total files identified for move: ${FILE_COUNT}" | tee -a "${LOG_FILE}"
echo "Note: `gsutil -m` reports success/failure on the overall operation, not per file." | tee -a "${LOG_FILE}"
echo "Please inspect the log file '${LOG_FILE}' for detailed results." | tee -a "${LOG_FILE}"

if [ ${COPY_RESULT} -eq 0 ] && [ ${DELETE_RESULT} -eq 0 ]; then
    echo "All identified files moved successfully! 🎉"
    echo "Remember to verify the contents of your destination bucket: gsutil ls gs://${DESTINATION_BUCKET}/"
    echo "And optionally, verify the source bucket is empty: gsutil ls gs://${SOURCE_BUCKET}/"
else
    echo "Warning: The move operation completed with some failures. Please check the logs for details. ⚠️"
fi