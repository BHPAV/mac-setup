#!/usr/bin/env bash

# Update All Development Tools
# This script updates all installed development tools and packages

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo -e "${BLUE}===================================${NC}"
echo -e "${BLUE}   Development Tools Updater${NC}"
echo -e "${BLUE}===================================${NC}"
echo

# Update Homebrew
if command -v brew &> /dev/null; then
    log "Updating Homebrew..."
    brew update
    
    log "Upgrading Homebrew packages..."
    brew upgrade
    
    log "Cleaning up Homebrew..."
    brew cleanup -s
    brew doctor || warning "Homebrew doctor reported issues"
    
    # Update Homebrew Cask applications
    log "Updating Cask applications..."
    brew upgrade --cask
    
    echo
else
    warning "Homebrew not installed"
fi

# Update Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    log "Updating Oh My Zsh..."
    (cd "$HOME/.oh-my-zsh" && git pull origin master)
    echo
fi

# Update Powerlevel10k
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    log "Updating Powerlevel10k theme..."
    (cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" && git pull)
    echo
fi

# Update Zsh plugins
plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
if [ -d "$plugins_dir" ]; then
    log "Updating Zsh plugins..."
    for plugin in "$plugins_dir"/*; do
        if [ -d "$plugin/.git" ]; then
            plugin_name=$(basename "$plugin")
            echo "  Updating $plugin_name..."
            (cd "$plugin" && git pull)
        fi
    done
    echo
fi

# Update Python packages
if command -v pip3 &> /dev/null; then
    log "Updating pip..."
    pip3 install --upgrade pip
    
    if command -v pipx &> /dev/null; then
        log "Updating pipx packages..."
        pipx upgrade-all
    fi
    echo
fi

# Update Node.js via NVM
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    log "Checking for Node.js updates..."
    source "$HOME/.nvm/nvm.sh"
    
    # Get current version
    current_node=$(nvm current)
    
    # Check for new LTS
    latest_lts=$(nvm ls-remote --lts | tail -1 | awk '{print $1}')
    
    if [ "$current_node" != "$latest_lts" ]; then
        info "New Node.js LTS available: $latest_lts (current: $current_node)"
        read -p "Install new LTS version? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            nvm install --lts
            nvm alias default node
        fi
    else
        info "Node.js is up to date: $current_node"
    fi
    echo
fi

# Update global npm packages
if command -v npm &> /dev/null; then
    log "Updating global npm packages..."
    npm update -g
    
    # Update npm itself
    npm install -g npm@latest
    echo
fi

# Update Rust
if command -v rustup &> /dev/null; then
    log "Updating Rust toolchain..."
    rustup update
    echo
fi

# Update Go tools
if command -v go &> /dev/null; then
    log "Updating Go tools..."
    # Update commonly used Go tools
    go install -v golang.org/x/tools/gopls@latest 2>/dev/null || true
    go install -v github.com/go-delve/delve/cmd/dlv@latest 2>/dev/null || true
    echo
fi

# Update Ruby gems
if command -v gem &> /dev/null; then
    log "Updating Ruby gems..."
    gem update --system
    gem update
    echo
fi

# Update VS Code extensions
if command -v code &> /dev/null; then
    log "Updating VS Code extensions..."
    code --list-extensions | xargs -L 1 code --install-extension
    echo
fi

# Update Docker images
if command -v docker &> /dev/null && docker ps &> /dev/null; then
    log "Cleaning up Docker..."
    docker system prune -af --volumes || warning "Docker cleanup failed"
    echo
fi

# Update tmux plugins
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    log "Updating tmux plugins..."
    "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
    echo
fi

# Update Neovim plugins (if using vim-plug)
if command -v nvim &> /dev/null && [ -f "$HOME/.config/nvim/init.vim" ]; then
    log "Updating Neovim plugins..."
    nvim +PlugUpdate +qall
    echo
fi

# Check for macOS updates
log "Checking for macOS updates..."
softwareupdate --list

# Summary
echo
echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}        Update Complete!${NC}"
echo -e "${GREEN}===================================${NC}"
echo
info "All development tools have been updated."
info "You may need to restart your terminal for some changes to take effect."
echo

# Show versions
echo -e "${BLUE}Current Versions:${NC}"
command -v python3 &> /dev/null && echo "Python: $(python3 --version)"
command -v node &> /dev/null && echo "Node.js: $(node --version)"
command -v go &> /dev/null && echo "Go: $(go version | awk '{print $3}')"
command -v rustc &> /dev/null && echo "Rust: $(rustc --version | awk '{print $2}')"
command -v docker &> /dev/null && echo "Docker: $(docker --version | awk '{print $3}' | tr -d ',')"

echo
log "Consider running 'brew cleanup' periodically to free up disk space."
