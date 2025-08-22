#!/bin/bash
set -euo pipefail

echo "=== DevOps User Setup ==="

# Create user
echo "Creating user: ${USER:-dev}"
useradd -m -u ${UID:-1000} ${USER:-dev}
usermod -aG sudo ${USER:-dev}
echo "${USER:-dev} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER:-dev}

# Install mise as user
echo "Installing mise for ${USER:-dev}..."
su - ${USER:-dev} -c 'curl -fsSL https://mise.jdx.dev/install.sh | sh -s -- -y'

# Install tools via mise as user
echo "Installing DevOps tools via mise..."
su - ${USER:-dev} -c 'export PATH="$HOME/.local/share/mise/bin:$PATH" && mise install'

# Set up infrastructure directories
echo "Setting up DevOps directories..."
su - ${USER:-dev} -c 'mkdir -p ~/.kube ~/.config/k9s ~/.terraform.d/plugins ~/.ansible/{collections,roles}'
su - ${USER:-dev} -c 'mkdir -p ~/infrastructure/{terraform,ansible,kubernetes} ~/scripts/{deployment,monitoring,backup}'
su - ${USER:-dev} -c 'mkdir -p ~/.aws ~/.azure ~/.config/gcloud'

# Create development shortcuts and shell setup
echo "Creating DevOps shortcuts..."
su - ${USER:-dev} -c 'cat >> ~/.bashrc << EOF
alias tf="terraform"
alias k="kubectl" 
alias kns="kubectl config set-context --current --namespace"
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias docker-clean="docker system prune -af"
source <(kubectl completion bash 2>/dev/null || true)
source <(helm completion bash 2>/dev/null || true)
eval "\$(mise activate bash)"
EOF'

# Create workspace directory
mkdir -p /home/${USER:-dev}/workspace

# Set permissions
echo "Setting permissions..."
chown -R ${USER:-dev}:${USER:-dev} /home/${USER:-dev}

echo "=== DevOps user setup completed ==="