#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -f "$SCRIPT_DIR/config.sh" ]] || { echo "error: config.sh not found — copy config.sh.example to config.sh"; exit 1; }
source "$SCRIPT_DIR/config.sh"

log()  { echo "  $*"; }
info() { echo ""; echo "▸ $*"; }
die()  { echo ""; echo "error: $*" >&2; exit 1; }

echo "project : $GCP_PROJECT"
echo "zone    : $GCP_ZONE"
echo "instance: $INSTANCE_NAME"

# ── Check instance exists ───────────────────────────────────────────────────────
info "Instance check"

if ! gcloud compute instances describe "$INSTANCE_NAME" \
       --project="$GCP_PROJECT" --zone="$GCP_ZONE" &>/dev/null; then
  log "instance '$INSTANCE_NAME' does not exist — nothing to delete"
  exit 0
fi

# ── Confirm ─────────────────────────────────────────────────────────────────────
echo ""
echo "  This will permanently delete '$INSTANCE_NAME'."
read -rp "  Type the instance name to confirm: " CONFIRM
[[ "$CONFIRM" == "$INSTANCE_NAME" ]] || die "name did not match — aborted"

# ── Delete ──────────────────────────────────────────────────────────────────────
info "Deleting instance"
gcloud compute instances delete "$INSTANCE_NAME" \
  --project="$GCP_PROJECT" \
  --zone="$GCP_ZONE" \
  --async 

log "deletion queued (running in background)"
echo ""
echo "  note: firewall rule '$FIREWALL_RULE_NAME' was kept (shared resource)"
echo "  to remove: gcloud compute firewall-rules delete $FIREWALL_RULE_NAME --project=$GCP_PROJECT"
