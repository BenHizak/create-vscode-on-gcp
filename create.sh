#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/config.sh" ]]; then
  echo "ERROR: config.sh not found. Copy config.sh.example to config.sh and fill in your values."
  exit 1
fi
source "$SCRIPT_DIR/config.sh"

echo "Project : $GCP_PROJECT"
echo "Zone    : $GCP_ZONE"
echo "Instance: $INSTANCE_NAME"

# Firewall rule
if ! gcloud compute firewall-rules describe "$FIREWALL_RULE_NAME" --project="$GCP_PROJECT" &>/dev/null; then
  echo "Creating firewall rule '$FIREWALL_RULE_NAME'..."
  gcloud compute firewall-rules create "$FIREWALL_RULE_NAME" \
    --project="$GCP_PROJECT" \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --target-tags=development \
    --description="SSH access for development instances"
fi

# Create VM
echo "Checking VM '$INSTANCE_NAME' presence..."
if gcloud compute instances describe "$INSTANCE_NAME" \
     --project="$GCP_PROJECT" \
     --zone="$GCP_ZONE" &>/dev/null; then
  echo "==> VM '$INSTANCE_NAME' already exists."
  
  # Ensure it is running
  STATUS=$(gcloud compute instances describe "$INSTANCE_NAME" \
    --project="$GCP_PROJECT" \
    --zone="$GCP_ZONE" \
    --format="value(status)")
  
  if [[ "$STATUS" != "RUNNING" ]]; then
    echo "==> VM status is $STATUS. Starting it now..."
    gcloud compute instances start "$INSTANCE_NAME" \
      --project="$GCP_PROJECT" \
      --zone="$GCP_ZONE"
  else
    echo "==> VM is already RUNNING."
  fi
else
  echo "==> Creating VM '$INSTANCE_NAME'..."
  gcloud compute instances create "$INSTANCE_NAME" \
    --project="$GCP_PROJECT" \
    --zone="$GCP_ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --accelerator="type=nvidia-tesla-t4,count=1" \
    --maintenance-policy=TERMINATE \
    --restart-on-failure \
    --image-family="$IMAGE_FAMILY" \
    --image-project="$IMAGE_PROJECT" \
    --boot-disk-size="$DISK_SIZE" \
    --boot-disk-type="$DISK_TYPE" \
    --tags=development \
    --labels=environment=development \
    --metadata=install-nvidia-driver=True
fi

echo "Done. Run ./connect.sh to open VSCode."
