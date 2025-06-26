# Improved Setup Script Quick Reference

## 🚀 Quick Start

```bash
# 1. Configure installation
cp mac-setup.env.template mac-setup.env
# Edit mac-setup.env to customize

# 2. Run improved setup
./scripts/setup-improved.sh

# 3. Validate installation
./scripts/validate-installation.sh
```

## ⚙️ Configuration Options

### Core Settings
```bash
INTERACTIVE_MODE=true      # User prompts (true/false)
DRY_RUN_MODE=false         # Preview mode (true/false)
BACKUP_EXISTING_FILES=true # Auto backup (true/false)
```

### Installation Toggles
```bash
# Core System
INSTALL_XCODE_CLI=true
INSTALL_HOMEBREW=true
INSTALL_ESSENTIAL_TOOLS=true

# Programming Languages
INSTALL_PYTHON=true
INSTALL_NODEJS=true
INSTALL_GO=false           # Skip Go
INSTALL_RUST=true
INSTALL_JAVA=false         # Skip Java

# Development Tools
INSTALL_WARP_TERMINAL=true
INSTALL_CURSOR_IDE=true
INSTALL_DOCKER=true
INSTALL_NEO4J_DESKTOP=true

# Cloud Tools
INSTALL_AWS_CLI=true
INSTALL_AZURE_CLI=false    # Skip Azure
INSTALL_GOOGLE_CLOUD_SDK=true
INSTALL_TERRAFORM=true
INSTALL_KUBECTL=true
```

### Custom Packages
```bash
CUSTOM_BREW_FORMULAE="htop ncdu"
CUSTOM_NPM_PACKAGES="typescript ts-node"
CUSTOM_PIP_PACKAGES="requests pandas"
CUSTOM_CARGO_PACKAGES="cargo-edit"
```

## 🎯 Usage Modes

### Interactive Mode (Default)
```bash
./scripts/setup-improved.sh
# Prompts for confirmation on destructive changes
```

### Dry-Run Mode
```bash
DRY_RUN_MODE=true ./scripts/setup-improved.sh
# Shows what would be installed without making changes
```

### Non-Interactive Mode
```bash
INTERACTIVE_MODE=false ./scripts/setup-improved.sh
# No prompts - perfect for automation
```

### Combined Modes
```bash
# Preview automated installation
DRY_RUN_MODE=true INTERACTIVE_MODE=false ./scripts/setup-improved.sh
```

## ✅ Validation Commands

### Post-Install Validation
```bash
./scripts/validate-installation.sh
```

### Quick System Check
```bash
# Check core tools
command -v brew && echo "✅ Homebrew" || echo "❌ Homebrew"
command -v git && echo "✅ Git" || echo "❌ Git"
command -v python3 && echo "✅ Python" || echo "❌ Python"
```

### Manual Component Checks
```bash
# Check specific tools
brew list | grep -E "(python|node|go|rust)"
which aws az gcloud terraform kubectl

# Check applications
ls /Applications/ | grep -E "(Warp|Cursor|Docker|Neo4j)"
```

## 📊 Validation Output

### Success Indicators
```
✅ Xcode CLI Tools: /Library/Developer/CommandLineTools
✅ Homebrew: Homebrew 4.1.0
✅ Python: Python 3.12.0
✅ Docker: Docker version 24.0.0
```

### Warning Indicators
```
⚠️  Disk space: 15Gi available (recommended: >20Gi)
⚠️  Docker daemon: Not running
⚠️  Git configuration: User name/email not set
```

### Error Indicators
```
❌ Azure CLI: Not installed
❌ Java: Not installed
❌ Internet connectivity: Cannot reach external network
```

## 🔧 Troubleshooting

### Common Issues

#### Configuration File Not Found
```bash
# Create from template
cp mac-setup.env.template mac-setup.env
# Edit the file and run again
```

#### Permission Issues
```bash
# Make scripts executable
chmod +x scripts/*.sh
```

#### Network Issues
```bash
# Check connectivity
ping -c 1 8.8.8.8
# Check DNS
nslookup github.com
```

#### Disk Space Issues
```bash
# Check available space
df -h ~
# Clean up Homebrew
brew cleanup
```

### Log Files
```bash
# Installation log
cat ~/.mac-setup-install.log

# Backup directory
ls ~/.mac-setup-backups/
```

## 🎨 Customization Examples

### Minimal Python Setup
```bash
# mac-setup.env
INSTALL_XCODE_CLI=true
INSTALL_HOMEBREW=true
INSTALL_ESSENTIAL_TOOLS=true
INSTALL_PYTHON=true
INSTALL_NODEJS=false
INSTALL_GO=false
INSTALL_RUST=false
INSTALL_JAVA=false
INSTALL_AZURE_CLI=false
```

### Full Stack Development
```bash
# mac-setup.env
INSTALL_PYTHON=true
INSTALL_NODEJS=true
INSTALL_GO=true
INSTALL_RUST=true
INSTALL_JAVA=true
INSTALL_DOCKER=true
INSTALL_AWS_CLI=true
INSTALL_TERRAFORM=true
INSTALL_KUBECTL=true
CUSTOM_PIP_PACKAGES="fastapi uvicorn sqlalchemy"
CUSTOM_NPM_PACKAGES="typescript ts-node nodemon"
```

### DevOps Focused
```bash
# mac-setup.env
INSTALL_PYTHON=true
INSTALL_GO=true
INSTALL_DOCKER=true
INSTALL_AWS_CLI=true
INSTALL_AZURE_CLI=true
INSTALL_GOOGLE_CLOUD_SDK=true
INSTALL_TERRAFORM=true
INSTALL_KUBECTL=true
INSTALL_HELM=true
CUSTOM_BREW_FORMULAE="k9s kubectx kind"
```

## 📝 Best Practices

### 1. Always Use Dry-Run First
```bash
DRY_RUN_MODE=true ./scripts/setup-improved.sh
```

### 2. Backup Existing Configurations
```bash
# The script does this automatically, but you can also:
cp ~/.zshrc ~/.zshrc.backup
cp ~/.gitconfig ~/.gitconfig.backup
```

### 3. Validate After Installation
```bash
./scripts/validate-installation.sh
```

### 4. Keep Configuration in Version Control
```bash
# Add your customized config
git add mac-setup.env
git commit -m "Add custom mac-setup configuration"
```

### 5. Use Non-Interactive for Automation
```bash
# Perfect for CI/CD or automated deployments
INTERACTIVE_MODE=false ./scripts/setup-improved.sh
```

## 🔄 Migration from Original Script

### For Existing Users
```bash
# 1. Backup current setup (automatic)
./scripts/setup-improved.sh

# 2. Create configuration from current state
# Edit mac-setup.env based on what you have installed

# 3. Validate current installation
./scripts/validate-installation.sh
```

### Configuration Migration
```bash
# Analyze current installation
brew list > current_brew_packages.txt
npm list -g > current_npm_packages.txt
pip list > current_pip_packages.txt

# Use these to create your mac-setup.env
```

## 📚 Additional Resources

- [Usability Improvements Guide](usability-improvements.md)
- [Integration Guide](integration-guide.md)
- [Troubleshooting Guide](troubleshooting.md)
- [Git Setup Guide](git-github-setup.md)

## 🆘 Getting Help

### Check Logs
```bash
tail -f ~/.mac-setup-install.log
```

### Run Validation
```bash
./scripts/validate-installation.sh
```

### Review Configuration
```bash
# Check your settings
grep -E "^(INSTALL_|CUSTOM_)" mac-setup.env
```

### Common Commands
```bash
# Reinstall specific component
brew reinstall python@3.12

# Update all tools
brew update && brew upgrade

# Clean up
brew cleanup
docker system prune -af
``` 