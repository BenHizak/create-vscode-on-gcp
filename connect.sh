#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/config.sh" ]]; then
  echo "ERROR: config.sh not found. Copy config.sh.example to config.sh and fill in your values."
  exit 1
fi
source "$SCRIPT_DIR/config.sh"

# ── Check Instance ─────────────────────────────────────────────────────────────
echo "==> Checking instance '$INSTANCE_NAME' status..."

if ! gcloud compute instances describe "$INSTANCE_NAME" \
       --project="$GCP_PROJECT" \
       --zone="$GCP_ZONE" &>/dev/null; then
  echo "ERROR: Instance '$INSTANCE_NAME' does not exist."
  echo "       Run ./create.sh first to provision it."
  exit 1
fi

STATUS=$(gcloud compute instances describe "$INSTANCE_NAME" \
  --project="$GCP_PROJECT" \
  --zone="$GCP_ZONE" \
  --format="value(status)")

if [[ "$STATUS" != "RUNNING" ]]; then
  echo "==> Instance '$INSTANCE_NAME' is $STATUS. Starting it now..."
  gcloud compute instances start "$INSTANCE_NAME" \
    --project="$GCP_PROJECT" \
    --zone="$GCP_ZONE"
  
  # Wait briefly for it to be ready
  sleep 5
fi

# ── Setup SSH & Connect ────────────────────────────────────────────────────────
# Populate ~/.ssh/config with gcloud SSH host entries
gcloud compute config-ssh --project="$GCP_PROJECT" --quiet

SSH_HOST="${INSTANCE_NAME}.${GCP_ZONE}.${GCP_PROJECT}"

echo "Opening VSCode connected to $SSH_HOST..."
echo "Tip: To pass GitHub credentials via SSH Agent Forwarding, run 'ssh-add ~/.ssh/id_ed25519' before connecting."
code --remote "ssh-remote+$SSH_HOST" /home/"$USER"
