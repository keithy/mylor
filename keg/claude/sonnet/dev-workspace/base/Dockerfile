FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal system essentials (let mise handle dev tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    sudo \
    vim \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install mise
RUN curl -fsSL https://mise.jdx.dev/install.sh | sh -s -- -y
ENV PATH="/root/.local/share/mise/bin:$PATH"

# Create dev user with sudo access
RUN useradd -m -u 1000 dev && \
    usermod -aG sudo dev && \
    echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev

# Switch to dev user
USER dev
WORKDIR /home/dev

# Install mise for dev user
RUN curl -fsSL https://mise.jdx.dev/install.sh | sh -s -- -y
ENV PATH="/home/dev/.local/share/mise/bin:$PATH"

# Copy mise configurations
COPY --chown=dev:dev mise/ ./mise/

# Install tools from mise configuration
RUN if [ -f ./mise/config.toml ]; then \
        mise install && \
        mise current; \
    fi

# Set up mise activation in shell profiles
RUN echo 'eval "$(mise activate bash)"' >> ~/.bashrc && \
    echo 'eval "$(mise activate zsh)"' >> ~/.zshrc 2>/dev/null || true

# Create workspace directory
RUN mkdir -p /home/dev/workspace

# Copy bootstrap scripts if they exist
COPY --chown=dev:dev bootstrap/ ./bootstrap/ 2>/dev/null || true
RUN if [ -d ./bootstrap ]; then chmod -R +x ./bootstrap; fi

WORKDIR /home/dev/workspace

# Default command that activates mise environment
CMD ["bash", "-c", "eval $(mise env -s bash) && exec bash"]