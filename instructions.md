
# goal: create a VM machine on gcloud for purpose of coding with vscode.

- environment: google cloud (GCP)
- image: pytorch-2-7-cu128-ubuntu-2404-nvidia-570
- make sure we have a basic T4 GPU (quote needs to be configured)
- prefer us-east-1 but other places are also OK
- do not recommend working with the browser.
- make sure to use instance environment tag: Development
- assume we are running on ubuntu WSL2 with gcloud command line tools installed
- this is a public repo store all environment variables safely (e.g. gcp project name.)

## GitHub Credentials
To avoid having to reconnect to GitHub every time, use **SSH Agent Forwarding**. This lets the VM "talk" back to your local machine's SSH agent to authenticate with GitHub.


## Bash Scripts:
`create.sh` - provisions the machine and creates firewall rule if it doesn't already exist.
`connect.sh` - connects to the environment using VS Code Remote-SSH.
`delete.sh` - deletes the VM to stop incurring costs.
`config.sh` - contains all environment variables and secrets (not committed).
