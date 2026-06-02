FROM nvidia/cuda:12.4.1-base-ubuntu22.04

# Set non-interactive mode for apt and default shell
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/usr/bin/zsh

# Install system dependencies
RUN apt update && \
    apt install -y \
    curl \
    git \
    git-lfs \
    gcc \
    socat \
    make \
    unzip \
    ripgrep \
    fd-find \
    tmux \
    gh \
    bat \
    zsh \
    nvtop \
    btop \
    && rm -rf /var/lib/apt/lists/*

# Install Oh My Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc && \
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc

# Install Zellij (Modern Terminal Workspace)
RUN curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz | tar -xz && \
    mv zellij /usr/local/bin/zellij

# Install Neovim (Latest Stable)
RUN curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz && \
    rm -rf /opt/nvim && \
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz && \
    ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

# Install uv
ENV UV_INSTALL_DIR="/usr/local/bin"
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Node.js 22 and AI CLI tools
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt install -y nodejs && \
    npm install -g @google/gemini-cli \
    @github/copilot \
    @openai/codex && \
    curl -fsSL https://claude.ai/install.sh | bash && \
    rm -rf /var/lib/apt/lists/*

# Setup LazyVim
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

# Set Environment Variables and Aliases
ENV TERM=xterm-256color
ENV DVC_CACHE_DIR=/root/nas/cache/dvc
RUN echo "alias ll='ls -l'" >> /root/.zshrc && \
    echo "alias cat='batcat --style=plain --paging=never'" >> /root/.zshrc && \
    echo "alias bat='batcat --style=plain'" >> /root/.zshrc

WORKDIR /workspace

# Default command
CMD ["/usr/bin/zsh"]
