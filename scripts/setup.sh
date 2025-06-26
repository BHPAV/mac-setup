#!/usr/bin/env bash

# ================================================================
# MacBook M4 Max Development Environment Setup Script
# ================================================================
# This script automates the setup of a new MacBook M4 Max with:
# - Tailscale network connection
# - Multiple development environments
# - Essential developer tools
# - Your specific tools: Cursor IDE, Warp Terminal, Neo4j
# ================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# ================================================================
# Pre-flight checks
# ================================================================
preflight_checks() {
    log "Running pre-flight checks..."
    
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check architecture (M4 Max should be arm64)
    if [[ "$(uname -m)" != "arm64" ]]; then
        warning "This script is optimized for Apple Silicon (arm64) but detected $(uname -m)"
    fi
    
    # Check if script is run with sudo (we don't want that)
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root/sudo"
        exit 1
    fi
    
    log "Pre-flight checks passed!"
}

# ================================================================
# Xcode Command Line Tools
# ================================================================
install_xcode_cli() {
    log "Checking Xcode Command Line Tools..."
    
    if ! xcode-select -p &> /dev/null; then
        log "Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait for installation
        until xcode-select -p &> /dev/null; do
            sleep 5
        done
        
        log "Xcode Command Line Tools installed!"
    else
        log "Xcode Command Line Tools already installed"
    fi
    
    # Accept license if needed
    if ! sudo xcodebuild -license status &> /dev/null; then
        log "Accepting Xcode license..."
        sudo xcodebuild -license accept
    fi
}

# ================================================================
# Homebrew Installation
# ================================================================
install_homebrew() {
    log "Checking Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        log "Homebrew already installed"
        brew update
    fi
}

# ================================================================
# Essential System Tools
# ================================================================
install_essential_tools() {
    log "Installing essential system tools..."
    
    brew install \
        coreutils \
        findutils \
        gnu-tar \
        gnu-sed \
        gawk \
        gnutls \
        gnu-getopt \
        grep \
        wget \
        curl \
        git \
        git-lfs \
        gh \
        jq \
        yq \
        tree \
        htop \
        ncdu \
        ripgrep \
        fd \
        fzf \
        bat \
        exa \
        tmux \
        neovim \
        stow
        
    # Git configuration
    log "Configuring Git..."
    read -p "Enter your Git name: " git_name
    read -p "Enter your Git email: " git_email
    
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global pull.rebase false
}

# ================================================================
# Tailscale Installation and Setup
# ================================================================
install_tailscale() {
    log "Installing Tailscale..."
    
    # Install Tailscale (Standalone variant recommended)
    if ! command -v tailscale &> /dev/null; then
        # Download and install the standalone variant
        curl -fsSL https://pkgs.tailscale.com/stable/tailscale-latest-macos.pkg -o /tmp/tailscale.pkg
        sudo installer -pkg /tmp/tailscale.pkg -target /
        rm /tmp/tailscale.pkg
        
        log "Tailscale installed!"
    else
        log "Tailscale already installed"
    fi
    
    # Start Tailscale
    log "Starting Tailscale..."
    
    # Check if Tailscale is running
    if ! tailscale status &> /dev/null; then
        # Launch Tailscale app
        open -a Tailscale
        
        warning "Please complete Tailscale setup in the GUI and connect to your 'box-net' network"
        warning "Press Enter when you've connected to continue..."
        read -r
    else
        info "Tailscale is already running"
        tailscale status
    fi
}

# ================================================================
# Shell Configuration (Zsh + Oh My Zsh)
# ================================================================
setup_shell() {
    log "Setting up shell environment..."
    
    # Install Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log "Oh My Zsh already installed"
    fi
    
    # Install Powerlevel10k theme
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    fi
    
    # Install useful Oh My Zsh plugins
    plugins=(
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-completions"
    )
    
    for plugin in "${plugins[@]}"; do
        plugin_name=$(basename "$plugin")
        if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name" ]; then
            git clone "https://github.com/$plugin" \
                "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin_name"
        fi
    done
}

# ================================================================
# Development Tools Installation
# ================================================================
install_dev_tools() {
    log "Installing development tools..."
    
    # Terminal and IDE Tools
    log "Installing Warp Terminal..."
    brew install --cask warp
    
    log "Installing Cursor IDE..."
    brew install --cask cursor
    
    # Other useful development tools
    brew install --cask \
        visual-studio-code \
        iterm2 \
        docker \
        postman \
        insomnia \
        tableplus \
        rectangle \
        alfred \
        raycast
}

# ================================================================
# Programming Languages Setup
# ================================================================
setup_python() {
    log "Setting up Python development environment..."
    
    # Install Python and related tools
    brew install python@3.12 python@3.11
    brew install pipx
    
    # Ensure pipx path is in shell
    pipx ensurepath
    
    # Install essential Python tools
    pipx install poetry
    pipx install black
    pipx install flake8
    pipx install mypy
    pipx install pytest
    pipx install virtualenv
    pipx install ipython
    pipx install jupyter
    pipx install pipenv
}

setup_nodejs() {
    log "Setting up Node.js development environment..."
    
    # Install Node Version Manager (nvm)
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    fi
    
    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest LTS Node
    nvm install --lts
    nvm use --lts
    nvm alias default node
    
    # Install global npm packages
    npm install -g \
        yarn \
        pnpm \
        typescript \
        ts-node \
        nodemon \
        pm2 \
        vercel \
        netlify-cli
}

setup_go() {
    log "Setting up Go development environment..."
    
    brew install go
    
    # Set up Go workspace
    mkdir -p "$HOME/go/{bin,src,pkg}"
    
    # Add to shell config
    echo 'export GOPATH=$HOME/go' >> ~/.zshrc
    echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.zshrc
}

setup_rust() {
    log "Setting up Rust development environment..."
    
    if ! command -v rustc &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Install useful Rust tools
    cargo install \
        cargo-edit \
        cargo-watch \
        cargo-make \
        tokei \
        ripgrep \
        bat \
        exa
}

setup_java() {
    log "Setting up Java development environment..."
    
    # Install multiple JDK versions
    brew install --cask temurin@21
    brew install --cask temurin@17
    brew install --cask temurin@11
    
    # Install build tools
    brew install maven gradle ant
    
    # Install jenv for Java version management
    brew install jenv
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(jenv init -)"' >> ~/.zshrc
}

# ================================================================
# Database Tools
# ================================================================
setup_databases() {
    log "Setting up database tools..."
    
    # Neo4j Desktop
    log "Installing Neo4j Desktop..."
    brew install --cask neo4j
    
    # Neo4j Community Edition (via Homebrew)
    brew install neo4j
    
    # Other databases
    brew install postgresql@16
    brew install mysql
    brew install redis
    brew install mongodb-community
    
    # Database clients
    brew install --cask dbeaver-community
    brew install --cask mongodb-compass
    brew install --cask redis-insight
}

# ================================================================
# Cloud and DevOps Tools
# ================================================================
setup_cloud_tools() {
    log "Setting up cloud and DevOps tools..."
    
    # AWS
    brew install awscli
    brew install aws-sam-cli
    
    # Google Cloud
    brew install --cask google-cloud-sdk
    
    # Azure
    brew install azure-cli
    
    # Terraform and Infrastructure as Code
    brew install terraform
    brew install terragrunt
    brew install ansible
    brew install packer
    
    # Kubernetes
    brew install kubectl
    brew install kubectx
    brew install kubernetes-cli
    brew install helm
    brew install minikube
    brew install kind
    brew install k9s
    
    # Container tools
    brew install podman
    brew install buildah
    brew install skopeo
}

# ================================================================
# macOS System Preferences
# ================================================================
configure_macos() {
    log "Configuring macOS preferences..."
    
    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    
    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    
    # Save screenshots to a specific directory
    mkdir -p "$HOME/Screenshots"
    defaults write com.apple.screencapture location -string "$HOME/Screenshots"
    
    # Restart affected services
    killall Finder
    killall Dock
}

# ================================================================
# Dotfiles Setup
# ================================================================
setup_dotfiles() {
    log "Setting up dotfiles..."
    
    DOTFILES_DIR="$HOME/.dotfiles"
    
    # Create dotfiles structure
    mkdir -p "$DOTFILES_DIR"/{git,shell,vim,tmux,config}
    
    # Create basic .gitignore
    cat > "$DOTFILES_DIR/.gitignore" << 'EOF'
.DS_Store
*.swp
*.swo
*~
.idea/
.vscode/
EOF

    # Create installation script
    cat > "$DOTFILES_DIR/install.sh" << 'EOF'
#!/usr/bin/env bash
# Dotfiles installation script

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create symlinks
link_file() {
    local src=$1 dst=$2
    
    if [ -f "$dst" ] || [ -d "$dst" ] || [ -L "$dst" ]; then
        mv "$dst" "${dst}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    ln -s "$src" "$dst"
    echo "Linked $src to $dst"
}

# Link shell files
for file in "$DOTFILES_DIR"/shell/*; do
    link_file "$file" "$HOME/.$(basename "$file")"
done

# Link git files
for file in "$DOTFILES_DIR"/git/*; do
    link_file "$file" "$HOME/.$(basename "$file")"
done

echo "Dotfiles installed!"
EOF

    chmod +x "$DOTFILES_DIR/install.sh"
    
    info "Dotfiles directory created at $DOTFILES_DIR"
    info "Add your configuration files and run $DOTFILES_DIR/install.sh to symlink them"
}

# ================================================================
# Brewfile Generation
# ================================================================
generate_brewfile() {
    log "Generating Brewfile for future reference..."
    
    BREWFILE_PATH="$HOME/.dotfiles/Brewfile"
    
    # Dump current Homebrew state
    brew bundle dump --file="$BREWFILE_PATH" --force
    
    info "Brewfile saved to $BREWFILE_PATH"
    info "You can restore this setup on another Mac with: brew bundle --file=$BREWFILE_PATH"
}

# ================================================================
# Main Installation Flow
# ================================================================
main() {
    clear
    echo "============================================"
    echo "   MacBook M4 Max Dev Setup Script"
    echo "============================================"
    echo
    
    # Run pre-flight checks
    preflight_checks
    
    # Core system setup
    install_xcode_cli
    install_homebrew
    install_essential_tools
    
    # Tailscale setup
    echo
    read -p "Install and configure Tailscale? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_tailscale
    fi
    
    # Shell setup
    echo
    read -p "Setup Zsh with Oh My Zsh? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_shell
    fi
    
    # Development tools
    echo
    read -p "Install development tools (Warp, Cursor, etc.)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_dev_tools
    fi
    
    # Programming languages
    echo
    echo "Select programming languages to install:"
    
    read -p "Install Python development environment? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && setup_python
    
    read -p "Install Node.js development environment? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && setup_nodejs
    
    read -p "Install Go development environment? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && setup_go
    
    read -p "Install Rust development environment? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && setup_rust
    
    read -p "Install Java development environment? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && setup_java
    
    # Databases
    echo
    read -p "Install database tools (Neo4j, PostgreSQL, etc.)? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_databases
    fi
    
    # Cloud tools
    echo
    read -p "Install cloud and DevOps tools? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_cloud_tools
    fi
    
    # macOS configuration
    echo
    read -p "Apply macOS system preferences? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        configure_macos
    fi
    
    # Dotfiles
    echo
    read -p "Set up dotfiles directory structure? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_dotfiles
    fi
    
    # Generate Brewfile
    generate_brewfile
    
    echo
    log "Setup complete! 🎉"
    echo
    echo "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Configure your dotfiles in ~/.dotfiles"
    echo "3. Sign in to your applications (Warp, Cursor, etc.)"
    echo "4. Start Neo4j with: neo4j start"
    echo "5. Connect to Tailscale network if you haven't already"
    echo
    echo "Your Brewfile has been saved to ~/.dotfiles/Brewfile"
    echo "You can use it to replicate this setup on another Mac!"
}

# Run main function
main "$@"
