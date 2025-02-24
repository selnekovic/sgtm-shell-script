#!/bin/bash

# Created by Julius Selnekovic | Artisma
# The script is based on Simo Ahava's script
# https://github.com/sahava/sgtm-cloud-run-shell/blob/main/cr-script.sh

DOCKER_IMAGE_URL="gcr.io/cloud-tagging-10302018/gtm-cloud-image:stable"
WELCOME_MESSAGE="""Please input the following information to set up your tagging server. To use the recommended setting leave blank."""

trap "exit" INT
set -e

# Prompt for service name input with a default or recommended value
set_service_name() {
  echo "Service Name (Recommended: sgtm-server-eu): "
  read service_name

  # Use the suggested value if input is empty
  if [[ -z "${service_name}" ]]; then
    service_name="sgtm-server-eu"
  fi
}


# Prompt for container configuration input with a default or required value
set_container_configuration() {
  while [[ -z "${container_configuration}" ]]; do
    echo "Container Config (Required): "
    read container_configuration

    if [[ "${container_configuration}" == 'null' ]]; then
      echo "Container config cannot be 'null'."
    fi
  done
}

# Prompt for confirmation to continue with default "no"
confirmation() {
  while true; do
    echo "$1"
    read confirmation
    confirmation="$(echo "${confirmation}" | tr '[:upper:]' '[:lower:]')"
    if [[ -z "${confirmation}" || "${confirmation}" == 'n' ]]; then
      exit 0
    fi
    if [[ "${confirmation}" == "y" ]]; then
      break
    fi
  done
}

# Deploy production service
deploy_production_service() {
    echo ""
    echo "Deploying production service..."
    google_cloud_project_id=$(gcloud config list --format 'value(core.project)')
    production_service_url=$(gcloud run deploy ${service_name}-prod --image ${DOCKER_IMAGE_URL} \
        --platform managed \
        --timeout 60 \
        --cpu 1 \
        --memory 512Mi \
        --allow-unauthenticated \
        --min-instances 1 \
        --max-instances 4 \
        --region "${current_region}" \
        --set-env-vars GOOGLE_CLOUD_PROJECT="${google_cloud_project_id}" \
        --set-env-vars PREVIEW_SERVER_URL="${debug_service_url}" \
        --set-env-vars CONTAINER_CONFIG="${container_configuration}" \
        --format=json | jq -r '.status.url')
}

# Deploy debug service
deploy_debug_service() {
    echo ""
    echo "Deploying debug service..."
    debug_service_url=$(gcloud run deploy ${service_name}-preview --image ${DOCKER_IMAGE_URL} \
        --cpu 1 \
        --memory 256Mi \
        --allow-unauthenticated \
        --min-instances 0 \
        --max-instances 1 \
        --region "${current_region}" \
        --set-env-vars RUN_AS_PREVIEW_SERVER=true \
        --set-env-vars CONTAINER_CONFIG="${container_configuration}" \
        --format=json | jq -r '.status.url')
    deploy_production_service
}

# Main execution
echo "${WELCOME_MESSAGE}"
set_service_name
set_container_configuration

echo ""
echo "Your configured settings are: "
echo "Service Name: ${service_name}"
echo "Container Config: ${container_configuration}"

# Prompt before proceeding
echo ""
confirmation "Do you wish to continue? (y/N): "
deploy_debug_service

# Final output
echo ""
echo "Deployment is complete."
echo "Production server test: "
echo "${production_service_url}/healthy"
exit 0
