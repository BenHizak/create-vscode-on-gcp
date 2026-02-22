#!/usr/bin/env bash
# delete.sh — Delete the GCP development VM.
# Usage: ./delete.sh

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

echo "==> This will permanently delete VM '$INSTANCE_NAME' in zone '$GCP_ZONE'."
read -rp "    Type the instance name to confirm: " CONFIRM

if [[ "$CONFIRM" != "$INSTANCE_NAME" ]]; then
  echo "==> Name did not match. Aborted."
  exit 1
fi

echo "==> Deleting VM '$INSTANCE_NAME'..."
gcloud compute instances delete "$INSTANCE_NAME" \
  --project="$GCP_PROJECT" \
  --zone="$GCP_ZONE" \
  --quiet

echo "==> VM '$INSTANCE_NAME' has been deleted."
echo ""
echo "    Note: The firewall rule '$FIREWALL_RULE_NAME' was NOT deleted."
echo "    To remove it: gcloud compute firewall-rules delete $FIREWALL_RULE_NAME --project=$GCP_PROJECT"
