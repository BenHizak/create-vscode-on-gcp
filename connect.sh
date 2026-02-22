#!/usr/bin/env bash
# connect.sh — Configure VSCode Remote SSH and connect to the development VM.
# Usage: ./connect.sh
#
# Requires: VSCode with the "Remote - SSH" extension installed.
#   Install: code --install-extension ms-vscode-remote.remote-ssh

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

# ── Verify instance is running ─────────────────────────────────────────────────
STATUS=$(gcloud compute instances describe "$INSTANCE_NAME" \
  --project="$GCP_PROJECT" \
  --zone="$GCP_ZONE" \
  --format="value(status)")

if [[ "$STATUS" != "RUNNING" ]]; then
  echo "==> Instance '$INSTANCE_NAME' is not running (status: $STATUS)."
  echo "    Start it with: gcloud compute instances start $INSTANCE_NAME --zone=$GCP_ZONE --project=$GCP_PROJECT"
  exit 1
fi

# ── Add gcloud hosts to ~/.ssh/config ─────────────────────────────────────────
echo "==> Updating ~/.ssh/config with gcloud SSH host entries..."
gcloud compute config-ssh --project="$GCP_PROJECT"

SSH_HOST="${INSTANCE_NAME}.${GCP_ZONE}.${GCP_PROJECT}"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Connect with VSCode Remote SSH (no browser required)"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "  1. Make sure the Remote-SSH extension is installed:"
echo "       code --install-extension ms-vscode-remote.remote-ssh"
echo ""
echo "  2. Open VSCode and press Ctrl+Shift+P, then run:"
echo "       Remote-SSH: Connect to Host..."
echo ""
echo "  3. Select (or type) the host:"
echo "       $SSH_HOST"
echo ""
echo "  ── Or open directly from this terminal: ─────────────────"
echo "       code --remote ssh-remote+$SSH_HOST /home/\$(whoami)"
echo ""
echo "  ── Or plain SSH (e.g. for tmux / terminal work): ────────"
echo "       ssh $SSH_HOST"
echo ""
