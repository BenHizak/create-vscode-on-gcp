# create-vscode-on-gcp

Bash scripts to spin up a GPU-powered GCP VM and connect to it with **VSCode Remote SSH** (no browser required).

| Script | Purpose |
|--------|---------|
| `create.sh` | Create the VM, create firewall rule if it doesn't exist |
| `connect.sh` | Configure SSH and print VSCode Remote SSH connection instructions |
| `delete.sh` | Permanently delete the VM (with confirmation) |

## VM specs

| Property | Value |
|----------|-------|
| Image | `pytorch-2-7-cu128-ubuntu-2404` (Deep Learning VM — PyTorch 2.7, CUDA 12.8, Ubuntu 24.04) |
| GPU | NVIDIA T4 (1×) |
| Default machine type | `n1-standard-4` |
| Default region/zone | `us-east1` / `us-east1-d` |
| Instance tag | `development` |
| Instance label | `environment=development` |

---

## Prerequisites

1. **gcloud CLI** installed and authenticated on Ubuntu/WSL2:
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```
2. **T4 GPU quota** — by default GCP projects have 0 GPU quota.  
   Request an increase at:  
   `IAM & Admin → Quotas → filter "NVIDIA T4 GPUs" in your target region → Edit Quotas`  
   Set the value to at least **1**.

3. **VSCode** with the [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) extension:
   ```bash
   code --install-extension ms-vscode-remote.remote-ssh
   ```

---

## Setup

```bash
# 1. Clone the repo (if you haven't already)
git clone https://github.com/BenHizak/create-vscode-on-gcp.git
cd create-vscode-on-gcp

# 2. Create your local config (this file is git-ignored)
cp config.sh.example config.sh

# 3. Edit config.sh and fill in your GCP project ID and preferences
#    (GCP_PROJECT is the only required change)
nano config.sh

# 4. Make scripts executable
chmod +x create.sh connect.sh delete.sh
```

---

## Usage

### Create the VM

```bash
./create.sh
```

This will:
- Create a firewall rule `allow-ssh-development` (TCP 22, target-tag `development`) if it doesn't already exist.
- Create the VM with a T4 GPU and the Deep Learning VM image.

### Connect via VSCode Remote SSH

```bash
./connect.sh
```

This will:
- Run `gcloud compute config-ssh` to add the instance to `~/.ssh/config`.
- Print the exact host name and steps to open it in VSCode.

### Delete the VM

```bash
./delete.sh
```

You will be asked to type the instance name to confirm deletion.

---

## Security

- **`config.sh` is git-ignored** — it contains your GCP project ID and is never committed.
- The firewall rule only opens TCP 22 (SSH) and restricts access to instances tagged `development`.
- No passwords or service-account keys are stored in the repository.


### Setup (once locally):
1.  Make sure your local SSH agent is running and has your GitHub SSH key:
    ```bash
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519  # or path to your GitHub key
    ```
2.  Enable agent forwarding in your SSH config. Your VM connection will automatically use it if you add `ForwardAgent yes` to the specific host in `~/.ssh/config` after running `./connect.sh`.

    Example `~/.ssh/config`:
    ```ssh
    Host vscode-dev1.us-east1-d.wazoo-vscode
        HostName 34.123.45.67
        IdentityFile ~/.ssh/google_compute_engine
        User Wazoo
        ForwardAgent yes
    ```

3.  Alternatively, in VS Code settings, ensure `Remote-SSH: Enable Agent Forwarding` is checked (it is by default).
