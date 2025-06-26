#!/usr/bin/env bash

# System Information Script
# Displays comprehensive system information for debugging

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}===================================${NC}"
echo -e "${BLUE}     System Information Report${NC}"
echo -e "${BLUE}===================================${NC}"
echo

# System Info
echo -e "${GREEN}System Information:${NC}"
echo "Hostname: $(hostname)"
echo "macOS Version: $(sw_vers -productVersion)"
echo "Build: $(sw_vers -buildVersion)"
echo "Architecture: $(uname -m)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime | sed 's/.*up //' | sed 's/,.*//')"
echo

# Hardware Info
echo -e "${GREEN}Hardware Information:${NC}"
echo "Model: $(sysctl -n hw.model)"
echo "CPU: $(sysctl -n machdep.cpu.brand_string)"
echo "Cores: $(sysctl -n hw.ncpu)"
echo "Memory: $(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 )) GB"
echo

# Disk Space
echo -e "${GREEN}Disk Space:${NC}"
df -h / | tail -1 | awk '{print "Used: " $3 " / " $2 " (" $5 " full)"}'
echo

# Network
echo -e "${GREEN}Network Information:${NC}"
echo "Hostname: $(hostname)"
echo "Local IP: $(ipconfig getifaddr en0 2>/dev/null || echo "Not connected")"
echo "Public IP: $(curl -s https://api.ipify.org || echo "Cannot determine")"
echo "Tailscale: $(tailscale status --json 2>/dev/null | jq -r .Self.TailscaleIPs[0] 2>/dev/null || echo "Not connected")"
echo

# Development Tools
echo -e "${GREEN}Development Tools:${NC}"

# Shell
echo -e "${PURPLE}Shell:${NC}"
echo "Current Shell: $SHELL"
echo "Zsh Version: $(zsh --version | cut -d' ' -f2)"
[ -d "$HOME/.oh-my-zsh" ] && echo "Oh My Zsh: Installed" || echo "Oh My Zsh: Not installed"
[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ] && echo "Powerlevel10k: Installed" || echo "Powerlevel10k: Not installed"
echo

# Package Managers
echo -e "${PURPLE}Package Managers:${NC}"
command -v brew &> /dev/null && echo "Homebrew: $(brew --version | head -1)" || echo "Homebrew: Not installed"
command -v npm &> /dev/null && echo "NPM: $(npm --version)" || echo "NPM: Not installed"
command -v pip3 &> /dev/null && echo "Pip: $(pip3 --version | cut -d' ' -f2)" || echo "Pip: Not installed"
echo

# Programming Languages
echo -e "${PURPLE}Programming Languages:${NC}"
command -v python3 &> /dev/null && echo "Python: $(python3 --version)" || echo "Python: Not installed"
command -v node &> /dev/null && echo "Node.js: $(node --version)" || echo "Node.js: Not installed"
command -v go &> /dev/null && echo "Go: $(go version | cut -d' ' -f3)" || echo "Go: Not installed"
command -v rustc &> /dev/null && echo "Rust: $(rustc --version | cut -d' ' -f2)" || echo "Rust: Not installed"
command -v java &> /dev/null && echo "Java: $(java -version 2>&1 | head -1 | cut -d'"' -f2)" || echo "Java: Not installed"
echo

# Databases
echo -e "${PURPLE}Databases:${NC}"
command -v psql &> /dev/null && echo "PostgreSQL: $(psql --version | cut -d' ' -f3)" || echo "PostgreSQL: Not installed"
command -v mysql &> /dev/null && echo "MySQL: $(mysql --version | cut -d' ' -f4)" || echo "MySQL: Not installed"
command -v redis-cli &> /dev/null && echo "Redis: $(redis-cli --version | cut -d' ' -f2)" || echo "Redis: Not installed"
command -v neo4j &> /dev/null && echo "Neo4j: Installed" || echo "Neo4j: Not installed"
echo

# Cloud Tools
echo -e "${PURPLE}Cloud Tools:${NC}"
command -v aws &> /dev/null && echo "AWS CLI: $(aws --version | cut -d' ' -f1 | cut -d'/' -f2)" || echo "AWS CLI: Not installed"
command -v gcloud &> /dev/null && echo "Google Cloud: $(gcloud --version | head -1 | cut -d' ' -f4)" || echo "Google Cloud: Not installed"
command -v az &> /dev/null && echo "Azure CLI: $(az --version | head -1 | cut -d' ' -f2)" || echo "Azure CLI: Not installed"
command -v terraform &> /dev/null && echo "Terraform: $(terraform --version | head -1 | cut -d' ' -f2)" || echo "Terraform: Not installed"
echo

# Container Tools
echo -e "${PURPLE}Container/Orchestration:${NC}"
command -v docker &> /dev/null && echo "Docker: $(docker --version | cut -d' ' -f3 | tr -d ',')" || echo "Docker: Not installed"
command -v kubectl &> /dev/null && echo "Kubectl: $(kubectl version --client --short 2>/dev/null | cut -d' ' -f3)" || echo "Kubectl: Not installed"
echo

# Git Configuration
echo -e "${GREEN}Git Configuration:${NC}"
echo "User: $(git config user.name) <$(git config user.email)>"
echo "Default Branch: $(git config init.defaultBranch)"
echo "GPG Signing: $(git config commit.gpgsign || echo "false")"
echo

# Environment Variables
echo -e "${GREEN}Key Environment Variables:${NC}"
echo "EDITOR: ${EDITOR:-not set}"
echo "VISUAL: ${VISUAL:-not set}"
echo "GOPATH: ${GOPATH:-not set}"
echo "NVM_DIR: ${NVM_DIR:-not set}"
echo "JAVA_HOME: ${JAVA_HOME:-not set}"
echo

# PATH Analysis
echo -e "${GREEN}PATH Analysis:${NC}"
echo "Number of PATH entries: $(echo $PATH | tr ':' '\n' | wc -l)"
echo "Homebrew in PATH: $(echo $PATH | grep -q "/opt/homebrew" && echo "Yes" || echo "No")"
echo "User bin in PATH: $(echo $PATH | grep -q "$HOME/bin" && echo "Yes" || echo "No")"
echo

# Running Services
echo -e "${GREEN}Running Services:${NC}"
if command -v brew &> /dev/null; then
    services=$(brew services list 2>/dev/null | grep -E "started|running" | awk '{print $1}' | tr '\n' ', ' | sed 's/,$//')
    [ -n "$services" ] && echo "Homebrew services: $services" || echo "No Homebrew services running"
fi

# Check Docker
if command -v docker &> /dev/null && docker ps &> /dev/null; then
    containers=$(docker ps --format "table {{.Names}}" | tail -n +2 | wc -l)
    echo "Docker containers running: $containers"
fi
echo

# Potential Issues
echo -e "${YELLOW}Potential Issues:${NC}"
issues=0

# Check for Rosetta 2 (for Apple Silicon)
if [[ $(uname -m) == "arm64" ]]; then
    if ! pgrep oahd &> /dev/null; then
        echo "- Rosetta 2 may not be installed (needed for x86 apps)"
        ((issues++))
    fi
fi

# Check Homebrew health
if command -v brew &> /dev/null; then
    if ! brew doctor &> /dev/null; then
        echo "- Homebrew has issues (run 'brew doctor' for details)"
        ((issues++))
    fi
fi

# Check if .zshrc exists
if [ ! -f "$HOME/.zshrc" ]; then
    echo "- .zshrc file not found"
    ((issues++))
fi

# Check SSH keys
if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "- No SSH keys found"
    ((issues++))
fi

[ $issues -eq 0 ] && echo "No issues detected!"
echo

echo -e "${BLUE}===================================${NC}"
echo -e "${BLUE}        End of Report${NC}"
echo -e "${BLUE}===================================${NC}"
