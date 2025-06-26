#!/usr/bin/env bash

# ================================================================
# MacBook M4 Max Development Environment Setup Script (Improved)
# ================================================================
# This script automates the setup of a new MacBook M4 Max with:
# - Modular installation choices via environment variables
# - Interactive confirmation prompts
# - Dry-run mode for testing
# - Comprehensive post-install checks
# - Backup functionality for existing files
# ================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/mac-setup.env"
BACKUP_DIR="$HOME/.mac-setup-backups/$(date +%Y%m%d_%H%M%S)"
INSTALL_LOG="$HOME/.mac-setup-install.log"
DRY_RUN=false
INTERACTIVE=true
BACKUP_FILES=true

# Installation tracking
INSTALLED_COMPONENTS=()
FAILED_COMPONENTS=()
SKIPPED_COMPONENTS=()

# ================================================================
# Logging and Output Functions
# ================================================================
log() {
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[$timestamp]${NC} $1" | tee -a "$INSTALL_LOG"
}

error() {
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[ERROR][$timestamp]${NC} $1" | tee -a "$INSTALL_LOG" >&2
}

warning() {
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[WARNING][$timestamp]${NC} $1" | tee -a "$INSTALL_LOG"
}

info() {
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[INFO][$timestamp]${NC} $1" | tee -a "$INSTALL_LOG"
}

success() {
    local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[SUCCESS][$timestamp]${NC} $1" | tee -a "$INSTALL_LOG"
}

dry_run_info() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${PURPLE}[DRY RUN]${NC} $1"
    fi
}

# ================================================================
# Configuration Loading
# ================================================================
load_config() {
    log "Loading configuration..."
    
    # Check if config file exists
    if [ ! -f "$CONFIG_FILE" ]; then
        warning "Configuration file not found: $CONFIG_FILE"
        info "Creating from template..."
        if [ -f "$PROJECT_ROOT/mac-setup.env.template" ]; then
            cp "$PROJECT_ROOT/mac-setup.env.template" "$CONFIG_FILE"
            info "Created $CONFIG_FILE from template"
            info "Please edit the configuration file and run the script again"
            exit 1
        else
            error "Template file not found. Please create $CONFIG_FILE manually"
            exit 1
        fi
    fi
    
    # Load configuration
    source "$CONFIG_FILE"
    
    # Set defaults for missing variables
    INTERACTIVE=${INTERACTIVE_MODE:-true}
    DRY_RUN=${DRY_RUN_MODE:-false}
    BACKUP_FILES=${BACKUP_EXISTING_FILES:-true}
    
    log "Configuration loaded successfully"
}

# ================================================================
# Interactive Functions
# ================================================================
confirm() {
    local message="$1"
    local default="${2:-y}"
    
    if [ "$DRY_RUN" = true ]; then
        dry_run_info "Would prompt: $message (default: $default)"
        return 0
    fi
    
    if [ "$INTERACTIVE" = false ]; then
        return 0
    fi
    
    local prompt="$message"
    if [ "$default" = "y" ]; then
        prompt="$prompt (Y/n): "
    else
        prompt="$prompt (y/N): "
    fi
    
    read -p "$prompt" -n 1 -r
    echo
    
    if [ "$default" = "y" ]; then
        [[ $REPLY =~ ^[Nn]$ ]] && return 1
    else
        [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
    fi
    
    return 0
}

confirm_destructive() {
    local message="$1"
    local file="$2"
    
    if [ "$DRY_RUN" = true ]; then
        dry_run_info "Would prompt for destructive change: $message"
        return 0
    fi
    
    if [ "$INTERACTIVE" = false ]; then
        warning "Skipping confirmation for destructive change: $message"
        return 0
    fi
    
    echo -e "${YELLOW}⚠️  WARNING: This will modify $file${NC}"
    confirm "$message" "n"
}

# ================================================================
# Installation Tracking
# ================================================================
track_installation() {
    local component="$1"
    local status="$2"
    
    case "$status" in
        "installed")
            INSTALLED_COMPONENTS+=("$component")
            success "$component installed successfully"
            ;;
        "failed")
            FAILED_COMPONENTS+=("$component")
            error "$component installation failed"
            ;;
        "skipped")
            SKIPPED_COMPONENTS+=("$component")
            info "$component installation skipped"
            ;;
    esac
}

# ================================================================
# Pre-flight Checks
# ================================================================
preflight_checks() {
    log "Running pre-flight checks..."
    
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        error "This script is designed for macOS only"
        exit 1
    fi
    
    # Check architecture
    if [[ "$(uname -m)" != "arm64" ]]; then
        warning "This script is optimized for Apple Silicon (arm64) but detected $(uname -m)"
        confirm "Continue anyway?" "n" || exit 1
    fi
    
    # Check if script is run with sudo
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root/sudo"
        exit 1
    fi
    
    # Check disk space
    local available_space=$(df -h "$HOME" | awk 'NR==2 {print $4}' | sed 's/Gi//')
    if [ "$available_space" -lt 10 ]; then
        warning "Low disk space: ${available_space}Gi available"
        confirm "Continue with installation?" "n" || exit 1
    fi
    
    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        error "No internet connectivity detected"
        exit 1
    fi
    
    log "Pre-flight checks passed!"
}

# ================================================================
# Xcode Command Line Tools
# ================================================================
install_xcode_cli() {
    if [ "${INSTALL_XCODE_CLI:-true}" != "true" ]; then
        track_installation "Xcode CLI Tools" "skipped"
        return 0
    fi
    
    log "Checking Xcode Command Line Tools..."
    
    if ! xcode-select -p &> /dev/null; then
        if [ "$DRY_RUN" = true ]; then
            dry_run_info "Would install Xcode Command Line Tools"
            track_installation "Xcode CLI Tools" "installed"
            return 0
        fi
        
        log "Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait for installation
        until xcode-select -p &> /dev/null; do
            sleep 5
        done
        
        # Accept license if needed
        if ! sudo xcodebuild -license status &> /dev/null; then
            log "Accepting Xcode license..."
            sudo xcodebuild -license accept
        fi
        
        track_installation "Xcode CLI Tools" "installed"
    else
        log "Xcode Command Line Tools already installed"
        track_installation "Xcode CLI Tools" "installed"
    fi
}

# ================================================================
# Homebrew Installation
# ================================================================
install_homebrew() {
    if [ "${INSTALL_HOMEBREW:-true}" != "true" ]; then
        track_installation "Homebrew" "skipped"
        return 0
    fi
    
    log "Checking Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        if [ "$DRY_RUN" = true ]; then
            dry_run_info "Would install Homebrew"
            track_installation "Homebrew" "installed"
            return 0
        fi
        
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon
        if [[ "$(uname -m)" == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        track_installation "Homebrew" "installed"
    else
        log "Homebrew already installed"
        if [ "$DRY_RUN" = false ]; then
            brew update
        fi
        track_installation "Homebrew" "installed"
    fi
}

# ================================================================
# Essential System Tools
# ================================================================
install_essential_tools() {
    if [ "${INSTALL_ESSENTIAL_TOOLS:-true}" != "true" ]; then
        track_installation "Essential Tools" "skipped"
        return 0
    fi
    
    log "Installing essential system tools..."
    
    local essential_formulae=(
        coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-getopt
        grep wget curl git git-lfs gh jq yq tree htop ncdu
        ripgrep fd fzf bat exa tmux neovim stow
    )
    
    if [ "$DRY_RUN" = true ]; then
        dry_run_info "Would install: ${essential_formulae[*]}"
        track_installation "Essential Tools" "installed"
        return 0
    fi
    
    if brew install "${essential_formulae[@]}"; then
        track_installation "Essential Tools" "installed"
        
        # Git configuration
        if [ -n "${GIT_NAME:-}" ] && [ -n "${GIT_EMAIL:-}" ]; then
            git config --global user.name "$GIT_NAME"
            git config --global user.email "$GIT_EMAIL"
        else
            log "Configuring Git..."
            read -p "Enter your Git name: " git_name
            read -p "Enter your Git email: " git_email
            
            git config --global user.name "$git_name"
            git config --global user.email "$git_email"
        fi
        
        git config --global init.defaultBranch main
        git config --global pull.rebase false
    else
        track_installation "Essential Tools" "failed"
    fi
}

# ================================================================
# Post-Install Checks
# ================================================================
post_install_checks() {
    log "Running post-install checks..."
    
    echo
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}           INSTALLATION SUMMARY${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo
    
    # Check Xcode CLI Tools
    if xcode-select -p &> /dev/null; then
        success "✅ Xcode CLI Tools installed"
    else
        error "❌ Xcode CLI Tools not found"
    fi
    
    # Check Homebrew
    if command -v brew &> /dev/null; then
        local brew_version=$(brew --version | head -n1)
        local formula_count=$(brew list --formula | wc -l | tr -d ' ')
        local cask_count=$(brew list --cask | wc -l | tr -d ' ')
        success "✅ Homebrew $brew_version installed"
        info "   📦 $formula_count formulae, $cask_count casks installed"
    else
        error "❌ Homebrew not found"
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        local git_version=$(git --version)
        success "✅ $git_version installed"
        if git config --global user.name &> /dev/null; then
            info "   👤 Configured as: $(git config --global user.name)"
        fi
    else
        error "❌ Git not found"
    fi
    
    # Installation statistics
    echo
    echo -e "${CYAN}Installation Statistics:${NC}"
    echo -e "  ✅ Successfully installed: ${#INSTALLED_COMPONENTS[@]}"
    echo -e "  ❌ Failed installations: ${#FAILED_COMPONENTS[@]}"
    echo -e "  ⏭️  Skipped installations: ${#SKIPPED_COMPONENTS[@]}"
    
    if [ ${#FAILED_COMPONENTS[@]} -gt 0 ]; then
        echo
        echo -e "${YELLOW}Failed components:${NC}"
        for component in "${FAILED_COMPONENTS[@]}"; do
            echo -e "  ❌ $component"
        done
    fi
    
    if [ ${#SKIPPED_COMPONENTS[@]} -gt 0 ]; then
        echo
        echo -e "${BLUE}Skipped components:${NC}"
        for component in "${SKIPPED_COMPONENTS[@]}"; do
            echo -e "  ⏭️  $component"
        done
    fi
    
    # Next steps
    echo
    echo -e "${CYAN}Next Steps:${NC}"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Sign in to your applications (Warp, Cursor, etc.)"
    echo "  3. Start Neo4j with: neo4j start"
    echo "  4. Connect to Tailscale network if you haven't already"
    echo "  5. Configure your dotfiles in ~/.dotfiles"
}

# ================================================================
# Main Installation Flow
# ================================================================
main() {
    # Initialize log file
    echo "Mac Setup Installation Log - $(date)" > "$INSTALL_LOG"
    
    clear
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}   MacBook M4 Max Dev Setup Script${NC}"
    echo -e "${CYAN}           (Improved Version)${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo
    
    # Load configuration
    load_config
    
    # Show configuration summary
    if [ "$DRY_RUN" = true ]; then
        echo -e "${PURPLE}🔍 DRY RUN MODE - No actual changes will be made${NC}"
        echo
    fi
    
    if [ "$INTERACTIVE" = false ]; then
        echo -e "${YELLOW}⚠️  NON-INTERACTIVE MODE - No prompts will be shown${NC}"
        echo
    fi
    
    # Run pre-flight checks
    preflight_checks
    
    # Core system setup
    install_xcode_cli
    install_homebrew
    install_essential_tools
    
    # Post-install checks
    post_install_checks
    
    echo
    success "Setup complete! 🎉"
    echo
    info "Installation log saved to: $INSTALL_LOG"
}

# Run main function
main "$@" 