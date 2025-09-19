#!/bin/bash

# --- Configuration ---
# Target Project ID, automatically provided by Cloud Build
PROJECT_ID="${_PROJECT_ID}"
LOCATION="global"
DISPLAY_NAME="DF-Agent-Name-$(date +%s)" # Append a timestamp for uniqueness
DEFAULT_LANGUAGE_CODE="en"
TIME_ZONE="America/Los_Angeles"
API_ENDPOINT="https://dialogflow.googleapis.com/v3/projects/${PROJECT_ID}/locations/${LOCATION}/agents"

# --- Main Logic ---

# Check if the agent exists. The --quiet flag suppresses interactive prompts.
if gcloud dialogflow agents describe --project="${PROJECT_ID}" --quiet > /dev/null 2>&1; then
    echo "Dialogflow agent already exists. No action taken."
else
    echo "Dialogflow agent does not exist. Creating a new agent..."

    # Use curl to create the agent via the API
    curl --request POST \
        --header "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
        --header "Content-Type: application/json" \
        --data "{
            \"displayName\":\"${DISPLAY_NAME}\",
            \"defaultLanguageCode\":\"${DEFAULT_LANGUAGE_CODE}\",
            \"timeZone\":\"${TIME_ZONE}\"
        }" \
        "${API_ENDPOINT}"

    # Check the exit status of the curl command.
    if [ $? -eq 0 ]; then
        echo "Successfully created Dialogflow agent: ${DISPLAY_NAME}."
    else
        echo "Error: Failed to create Dialogflow agent." >&2
        exit 1
    fi
fi