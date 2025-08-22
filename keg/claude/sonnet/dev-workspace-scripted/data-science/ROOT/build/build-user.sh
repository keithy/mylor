#!/bin/bash
set -euo pipefail

echo "=== Data Science User Setup ==="

# Create user
echo "Creating user: ${USER:-dev}"
useradd -m -u ${UID:-1000} ${USER:-dev}
usermod -aG sudo ${USER:-dev}
echo "${USER:-dev} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER:-dev}

# Install mise as user
echo "Installing mise for ${USER:-dev}..."
su - ${USER:-dev} -c 'curl -fsSL https://mise.jdx.dev/install.sh | sh -s -- -y'

# Install tools via mise as user
echo "Installing data science tools via mise..."
su - ${USER:-dev} -c 'export PATH="$HOME/.local/share/mise/bin:$PATH" && mise install'

# Set up Python environment
echo "Setting up Python data science environment..."
su - ${USER:-dev} -c 'python3 -m pip install --upgrade pip'

# Create Jupyter configuration directory and setup
echo "Setting up Jupyter Lab..."
su - ${USER:-dev} -c 'mkdir -p ~/.jupyter'
su - ${USER:-dev} -c 'cat > ~/.jupyter/jupyter_lab_config.py << EOF
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
c.ServerApp.token = ""
c.ServerApp.password = ""
EOF'

# Create common data directories
su - ${USER:-dev} -c 'mkdir -p ~/data/{raw,processed,external} ~/notebooks/{exploratory,final} ~/models ~/R/library'

# Create development shortcuts and shell setup
echo "Creating data science shortcuts..."
su - ${USER:-dev} -c 'cat >> ~/.bashrc << EOF
alias jlab="jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root"
alias jnb="jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root"
eval "\$(mise activate bash)"
EOF'

# Create workspace directory
mkdir -p /home/${USER:-dev}/workspace

# Set permissions
echo "Setting permissions..."
chown -R ${USER:-dev}:${USER:-dev} /home/${USER:-dev}

echo "=== Data science user setup completed ==="