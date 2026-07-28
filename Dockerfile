FROM nvidia/cuda:12.4.1-base-ubuntu22.04

# Set non-interactive mode for apt and default shell
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/usr/bin/zsh

# agnoster draws its prompt with multi-byte glyphs, which zsh cannot render
# under the image's default ASCII locale.
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

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
    npm install -g @github/copilot \
    @openai/codex && \
    curl -fsSL https://claude.ai/install.sh | bash && \
    rm -rf /var/lib/apt/lists/*

# Install Antigravity CLI (agy), the successor to the retired Gemini CLI.
# Ships as a standalone binary, so it is moved next to the other manual installs.
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash && \
    mv /root/.local/bin/agy /usr/local/bin/agy

# Setup LazyVim
RUN git clone https://github.com/LazyVim/starter /root/.config/nvim && \
    rm -rf /root/.config/nvim/.git

# System deps for headless Chromium (Playwright). The Playwright *package*
# and browser binary itself are installed later into the project's uv venv
# (persisted on HDD_PATH, see docker-compose.yml) - only the apt-level shared
# libraries need to live in the image. Using an ephemeral `uv run --with`
# environment to invoke `playwright install-deps` avoids hardcoding the long,
# version-specific apt package list by hand.
RUN uv run --with playwright==1.61.0 playwright install-deps chromium && \
    rm -rf /var/lib/apt/lists/* /root/.cache/uv /root/.local/share/uv

# Set Environment Variables and Aliases
ENV TERM=xterm-256color
ENV DVC_CACHE_DIR=/hdd/cache/dvc
# "docker compose exec -t" injects the client's TERM into the exec environment,
# which overrides the ENV above. Set it back from the shell rc, unless a
# multiplexer has already picked a TERM of its own.
RUN echo '[[ $TERM == *-256color || $TERM == tmux* || $TERM == screen* ]] || export TERM=xterm-256color' >> /root/.zshrc && \
    echo "alias ll='ls -l'" >> /root/.zshrc && \
    echo "alias cat='batcat --style=plain --paging=never'" >> /root/.zshrc && \
    echo "alias bat='batcat --style=plain'" >> /root/.zshrc

WORKDIR /workspace

# Default command
CMD ["/usr/bin/zsh"]
