#!/bin/bash
set -euo pipefail

echo "=== Web Development User Setup ==="

# Create user
echo "Creating user: ${USER:-dev}"
useradd -m -u ${UID:-1000} ${USER:-dev}
usermod -aG sudo ${USER:-dev}
echo "${USER:-dev} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER:-dev}

# Install mise as user
echo "Installing mise for ${USER:-dev}..."
su - ${USER:-dev} -c 'curl -fsSL https://mise.jdx.dev/install.sh | sh -s -- -y'

# Install tools via mise as user
echo "Installing web development tools via mise..."
su - ${USER:-dev} -c 'export PATH="$HOME/.local/share/mise/bin:$PATH" && mise install'

# Set up Node.js environment
echo "Setting up Node.js development environment..."
su - ${USER:-dev} -c 'npm config set fund false && npm config set audit false'

# Create project template directories
su - ${USER:-dev} -c 'mkdir -p ~/templates/{react,vue,vanilla}'

# Create development shortcuts and shell setup
echo "Creating development shortcuts..."
su - ${USER:-dev} -c 'cat >> ~/.bashrc << EOF
alias create-react="npm create vite@latest \$1 -- --template react-ts"
alias create-vue="npm create vue@latest \$1 -- --typescript --router --pinia"
alias dev-server="npm run dev"
eval "\$(mise activate bash)"
EOF'

# Create workspace directory
mkdir -p /home/${USER:-dev}/workspace

# Set permissions
echo "Setting permissions..."
chown -R ${USER:-dev}:${USER:-dev} /home/${USER:-dev}

echo "=== Web development user setup completed ==="