#!/usr/bin/env bash

# ================================================================
# Mac Setup Installation Validation Script
# ================================================================
# This script validates the installation of all components
# and provides a comprehensive status report
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

# Validation results
PASSED_CHECKS=()
FAILED_CHECKS=()
WARNING_CHECKS=()
INFO_CHECKS=()

# ================================================================
# Logging Functions
# ================================================================
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

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# ================================================================
# Validation Functions
# ================================================================
check_passed() {
    local check="$1"
    PASSED_CHECKS+=("$check")
    success "✅ $check"
}

check_failed() {
    local check="$1"
    local message="$2"
    FAILED_CHECKS+=("$check")
    error "❌ $check: $message"
}

check_warning() {
    local check="$1"
    local message="$2"
    WARNING_CHECKS+=("$check")
    warning "⚠️  $check: $message"
}

check_info() {
    local check="$1"
    local message="$2"
    INFO_CHECKS+=("$check")
    info "ℹ️  $check: $message"
}

# ================================================================
# System Checks
# ================================================================
check_system() {
    log "Checking system requirements..."
    
    # Check macOS version
    local os_version=$(sw_vers -productVersion)
    check_passed "macOS $os_version"
    
    # Check architecture
    local arch=$(uname -m)
    if [ "$arch" = "arm64" ]; then
        check_passed "Apple Silicon (arm64) architecture"
    else
        check_warning "Architecture" "Detected $arch (optimized for arm64)"
    fi
    
    # Check disk space
    local available_space=$(df -h "$HOME" | awk 'NR==2 {print $4}' | sed 's/Gi//')
    if [ "$available_space" -gt 20 ]; then
        check_passed "Disk space: ${available_space}Gi available"
    elif [ "$available_space" -gt 10 ]; then
        check_warning "Disk space" "${available_space}Gi available (recommended: >20Gi)"
    else
        check_failed "Disk space" "Only ${available_space}Gi available"
    fi
    
    # Check internet connectivity
    if ping -c 1 8.8.8.8 &> /dev/null; then
        check_passed "Internet connectivity"
    else
        check_failed "Internet connectivity" "Cannot reach external network"
    fi
}

# ================================================================
# Core Tools Validation
# ================================================================
check_core_tools() {
    log "Checking core development tools..."
    
    # Check Xcode CLI Tools
    if xcode-select -p &> /dev/null; then
        local xcode_path=$(xcode-select -p)
        check_passed "Xcode CLI Tools: $xcode_path"
    else
        check_failed "Xcode CLI Tools" "Not installed"
    fi
    
    # Check Homebrew
    if command -v brew &> /dev/null; then
        local brew_version=$(brew --version | head -n1)
        local formula_count=$(brew list --formula | wc -l | tr -d ' ')
        local cask_count=$(brew list --cask | wc -l | tr -d ' ')
        check_passed "Homebrew: $brew_version"
        check_info "Homebrew packages" "$formula_count formulae, $cask_count casks"
    else
        check_failed "Homebrew" "Not installed"
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        local git_version=$(git --version)
        check_passed "Git: $git_version"
        
        # Check Git configuration
        if git config --global user.name &> /dev/null; then
            local git_name=$(git config --global user.name)
            local git_email=$(git config --global user.email)
            check_passed "Git configuration: $git_name <$git_email>"
        else
            check_warning "Git configuration" "User name/email not set"
        fi
    else
        check_failed "Git" "Not installed"
    fi
}

# ================================================================
# Essential Tools Validation
# ================================================================
check_essential_tools() {
    log "Checking essential development tools..."
    
    local essential_tools=(
        "coreutils" "findutils" "gnu-tar" "gnu-sed" "gawk"
        "grep" "wget" "curl" "jq" "yq" "tree" "htop" "ncdu"
        "ripgrep" "fd" "fzf" "bat" "exa" "tmux" "neovim"
    )
    
    local missing_tools=()
    
    for tool in "${essential_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            check_passed "$tool"
        else
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        check_warning "Missing essential tools" "${missing_tools[*]}"
    fi
}

# ================================================================
# Programming Languages Validation
# ================================================================
check_programming_languages() {
    log "Checking programming languages..."
    
    # Check Python
    if command -v python3 &> /dev/null; then
        local python_version=$(python3 --version)
        check_passed "Python: $python_version"
        
        # Check pipx
        if command -v pipx &> /dev/null; then
            check_passed "pipx"
        else
            check_warning "pipx" "Not installed"
        fi
        
        # Check common Python tools
        local python_tools=("poetry" "black" "flake8" "mypy" "pytest" "ipython")
        for tool in "${python_tools[@]}"; do
            if command -v "$tool" &> /dev/null; then
                check_passed "Python tool: $tool"
            else
                check_info "Python tool" "$tool not installed"
            fi
        done
    else
        check_failed "Python" "Not installed"
    fi
    
    # Check Node.js
    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        local npm_version=$(npm --version)
        check_passed "Node.js: $node_version"
        check_passed "npm: $npm_version"
        
        # Check common Node.js tools
        local node_tools=("yarn" "pnpm" "typescript" "ts-node" "nodemon")
        for tool in "${node_tools[@]}"; do
            if command -v "$tool" &> /dev/null; then
                check_passed "Node.js tool: $tool"
            else
                check_info "Node.js tool" "$tool not installed"
            fi
        done
    else
        check_failed "Node.js" "Not installed"
    fi
    
    # Check Go
    if command -v go &> /dev/null; then
        local go_version=$(go version)
        check_passed "Go: $go_version"
        
        # Check GOPATH
        if [ -n "${GOPATH:-}" ]; then
            check_passed "GOPATH: $GOPATH"
        else
            check_warning "GOPATH" "Not set"
        fi
    else
        check_failed "Go" "Not installed"
    fi
    
    # Check Rust
    if command -v rustc &> /dev/null; then
        local rust_version=$(rustc --version)
        check_passed "Rust: $rust_version"
        
        # Check cargo
        if command -v cargo &> /dev/null; then
            check_passed "Cargo"
        else
            check_failed "Cargo" "Not installed"
        fi
    else
        check_failed "Rust" "Not installed"
    fi
    
    # Check Java
    if command -v java &> /dev/null; then
        local java_version=$(java -version 2>&1 | head -n1)
        check_passed "Java: $java_version"
        
        # Check javac
        if command -v javac &> /dev/null; then
            check_passed "Java compiler"
        else
            check_warning "Java compiler" "Not found"
        fi
    else
        check_failed "Java" "Not installed"
    fi
}

# ================================================================
# Development Tools Validation
# ================================================================
check_development_tools() {
    log "Checking development tools..."
    
    # Check terminal emulators
    local terminals=(
        "Warp Terminal" "/Applications/Warp.app"
        "Cursor IDE" "/Applications/Cursor.app"
        "VS Code" "/Applications/Visual Studio Code.app"
        "iTerm2" "/Applications/iTerm.app"
    )
    
    for i in $(seq 0 2 $((${#terminals[@]} - 1))); do
        local name="${terminals[$i]}"
        local path="${terminals[$((i+1))]}"
        
        if [ -d "$path" ]; then
            check_passed "$name"
        else
            check_info "$name" "Not installed"
        fi
    done
    
    # Check Docker
    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version)
        check_passed "Docker: $docker_version"
        
        # Check if Docker is running
        if docker info &> /dev/null; then
            check_passed "Docker daemon running"
        else
            check_warning "Docker daemon" "Not running"
        fi
    else
        check_failed "Docker" "Not installed"
    fi
    
    # Check database tools
    local db_tools=(
        "Neo4j" "neo4j"
        "PostgreSQL" "psql"
        "MySQL" "mysql"
        "Redis" "redis-cli"
    )
    
    for i in $(seq 0 2 $((${#db_tools[@]} - 1))); do
        local name="${db_tools[$i]}"
        local command="${db_tools[$((i+1))]}"
        
        if command -v "$command" &> /dev/null; then
            check_passed "$name"
        else
            check_info "$name" "Not installed"
        fi
    done
}

# ================================================================
# Cloud Tools Validation
# ================================================================
check_cloud_tools() {
    log "Checking cloud and DevOps tools..."
    
    # Check cloud CLIs
    local cloud_tools=(
        "AWS CLI" "aws"
        "Google Cloud SDK" "gcloud"
        "Azure CLI" "az"
        "Terraform" "terraform"
        "kubectl" "kubectl"
        "Helm" "helm"
    )
    
    for i in $(seq 0 2 $((${#cloud_tools[@]} - 1))); do
        local name="${cloud_tools[$i]}"
        local command="${cloud_tools[$((i+1))]}"
        
        if command -v "$command" &> /dev/null; then
            local version=$("$command" --version 2>/dev/null | head -n1 || echo "installed")
            check_passed "$name: $version"
        else
            check_info "$name" "Not installed"
        fi
    done
    
    # Check container tools
    local container_tools=("podman" "buildah" "skopeo")
    for tool in "${container_tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            check_passed "$tool"
        else
            check_info "$tool" "Not installed"
        fi
    done
}

# ================================================================
# Network Tools Validation
# ================================================================
check_network_tools() {
    log "Checking network tools..."
    
    # Check Tailscale
    if command -v tailscale &> /dev/null; then
        check_passed "Tailscale CLI"
        
        # Check Tailscale status
        if tailscale status &> /dev/null; then
            local status=$(tailscale status --json | jq -r '.BackendState' 2>/dev/null || echo "unknown")
            if [ "$status" = "Running" ]; then
                check_passed "Tailscale connected"
            else
                check_warning "Tailscale" "Status: $status"
            fi
        else
            check_warning "Tailscale" "Not running"
        fi
    else
        check_failed "Tailscale" "Not installed"
    fi
}

# ================================================================
# Shell Configuration Validation
# ================================================================
check_shell_config() {
    log "Checking shell configuration..."
    
    # Check Zsh
    if command -v zsh &> /dev/null; then
        local zsh_version=$(zsh --version | head -n1)
        check_passed "Zsh: $zsh_version"
        
        # Check Oh My Zsh
        if [ -d "$HOME/.oh-my-zsh" ]; then
            check_passed "Oh My Zsh"
        else
            check_warning "Oh My Zsh" "Not installed"
        fi
        
        # Check Powerlevel10k
        if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
            check_passed "Powerlevel10k theme"
        else
            check_info "Powerlevel10k" "Not installed"
        fi
    else
        check_failed "Zsh" "Not installed"
    fi
    
    # Check shell configuration files
    local shell_files=(".zshrc" ".zprofile" ".zshenv")
    for file in "${shell_files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            check_passed "Shell config: $file"
        else
            check_info "Shell config" "$file not found"
        fi
    done
}

# ================================================================
# Configuration Files Validation
# ================================================================
check_config_files() {
    log "Checking configuration files..."
    
    # Check if configuration file exists
    if [ -f "$CONFIG_FILE" ]; then
        check_passed "Configuration file: mac-setup.env"
    else
        check_warning "Configuration file" "mac-setup.env not found"
    fi
    
    # Check dotfiles directory
    if [ -d "$HOME/.dotfiles" ]; then
        check_passed "Dotfiles directory"
        
        # Check Brewfile
        if [ -f "$HOME/.dotfiles/Brewfile" ]; then
            check_passed "Brewfile"
        else
            check_info "Brewfile" "Not found"
        fi
    else
        check_info "Dotfiles directory" "Not created"
    fi
}

# ================================================================
# Summary Report
# ================================================================
generate_summary() {
    echo
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}           VALIDATION SUMMARY${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo
    
    # Statistics
    local total_checks=$((${#PASSED_CHECKS[@]} + ${#FAILED_CHECKS[@]} + ${#WARNING_CHECKS[@]} + ${#INFO_CHECKS[@]}))
    local success_rate=$(echo "scale=1; ${#PASSED_CHECKS[@]} * 100 / $total_checks" | bc 2>/dev/null || echo "0")
    
    echo -e "${CYAN}Validation Statistics:${NC}"
    echo -e "  ✅ Passed: ${#PASSED_CHECKS[@]}"
    echo -e "  ❌ Failed: ${#FAILED_CHECKS[@]}"
    echo -e "  ⚠️  Warnings: ${#WARNING_CHECKS[@]}"
    echo -e "  ℹ️  Info: ${#INFO_CHECKS[@]}"
    echo -e "  📊 Success Rate: ${success_rate}%"
    echo
    
    # Failed checks
    if [ ${#FAILED_CHECKS[@]} -gt 0 ]; then
        echo -e "${RED}Failed Checks:${NC}"
        for check in "${FAILED_CHECKS[@]}"; do
            echo -e "  ❌ $check"
        done
        echo
    fi
    
    # Warning checks
    if [ ${#WARNING_CHECKS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Warning Checks:${NC}"
        for check in "${WARNING_CHECKS[@]}"; do
            echo -e "  ⚠️  $check"
        done
        echo
    fi
    
    # Recommendations
    if [ ${#FAILED_CHECKS[@]} -eq 0 ] && [ ${#WARNING_CHECKS[@]} -eq 0 ]; then
        echo -e "${GREEN}🎉 All critical components are properly installed!${NC}"
    elif [ ${#FAILED_CHECKS[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  Installation mostly successful with some warnings${NC}"
    else
        echo -e "${RED}❌ Some critical components failed to install${NC}"
    fi
    
    echo
    echo -e "${CYAN}Next Steps:${NC}"
    if [ ${#FAILED_CHECKS[@]} -gt 0 ]; then
        echo "  1. Review failed checks above"
        echo "  2. Re-run the setup script for missing components"
        echo "  3. Check the installation log for detailed error messages"
    fi
    echo "  4. Restart your terminal to apply all changes"
    echo "  5. Configure your development environment"
    echo "  6. Test your tools and workflows"
}

# ================================================================
# Main Function
# ================================================================
main() {
    clear
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}   Mac Setup Installation Validation${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo
    
    # Run all validation checks
    check_system
    check_core_tools
    check_essential_tools
    check_programming_languages
    check_development_tools
    check_cloud_tools
    check_network_tools
    check_shell_config
    check_config_files
    
    # Generate summary
    generate_summary
}

# Run main function
main "$@" 