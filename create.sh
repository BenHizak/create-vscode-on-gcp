#!/usr/bin/env bash
# create.sh — Provision a GCP VM with a T4 GPU for VSCode Remote SSH development.
# Usage: ./create.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Load config ────────────────────────────────────────────────────────────────
if [[ ! -f "$SCRIPT_DIR/config.sh" ]]; then
  echo "ERROR: config.sh not found."
  echo "       Copy config.sh.example to config.sh and fill in your values."
  exit 1
fi
# shellcheck source=config.sh.example
source "$SCRIPT_DIR/config.sh"

echo "==> Project : $GCP_PROJECT"
echo "==> Zone    : $GCP_ZONE"
echo "==> Instance: $INSTANCE_NAME"
echo ""

# ── Firewall rule ──────────────────────────────────────────────────────────────
if gcloud compute firewall-rules describe "$FIREWALL_RULE_NAME" \
     --project="$GCP_PROJECT" &>/dev/null; then
  echo "==> Firewall rule '$FIREWALL_RULE_NAME' already exists — skipping."
else
  echo "==> Creating firewall rule '$FIREWALL_RULE_NAME' (TCP 22, target-tag: development)..."
  gcloud compute firewall-rules create "$FIREWALL_RULE_NAME" \
    --project="$GCP_PROJECT" \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:22 \
    --target-tags=development \
    --description="Allow SSH access to instances tagged 'development'"
  echo "==> Firewall rule created."
fi

# ── Create VM ──────────────────────────────────────────────────────────────────
echo ""
echo "==> Creating VM '$INSTANCE_NAME' (this may take a few minutes)..."

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

echo ""
echo "==> VM '$INSTANCE_NAME' is ready."
echo "==> Run ./connect.sh to set up VSCode Remote SSH and connect."
