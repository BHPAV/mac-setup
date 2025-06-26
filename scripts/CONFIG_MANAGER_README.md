# Configuration Manager TUI

This directory contains interactive Terminal User Interface (TUI) tools for managing Mac setup configurations.

## 🎯 Overview

The Configuration Manager provides an interactive way to:
- Browse available configurations by category
- Select which configurations to deploy
- Check tool requirements before deployment
- Create backups of existing configurations
- Deploy configurations with a single command

## 🛠️ Available Versions

### 1. Python Version (`config-manager.py`)

A feature-rich TUI built with Python and the `rich` library.

#### Features:
- Beautiful, modern terminal interface
- Interactive navigation with keyboard shortcuts
- Progress bars for deployment
- Backup management system
- Requirement checking
- Command-line arguments for automation

#### Installation:
```bash
# Install required dependency
pip3 install rich

# Make executable
chmod +x scripts/config-manager.py
```

#### Usage:
```bash
# Interactive TUI mode
./scripts/config-manager.py

# List all configurations
./scripts/config-manager.py --list

# Deploy specific configuration
./scripts/config-manager.py --deploy "Starship Prompt"

# Deploy entire category
./scripts/config-manager.py --category shell

# Check all requirements
./scripts/config-manager.py --check
```

#### Navigation:
- **Arrow Keys/j/k**: Navigate up/down
- **Enter/→**: Select item
- **Space**: Toggle selection
- **a**: Select all in view
- **n**: Deselect all in view
- **d**: Deploy selected
- **b**: Backup menu
- **q**: Quit/Back

### 2. Shell Version (`config-manager.sh`)

A lightweight alternative using bash with optional dialog/whiptail support.

#### Features:
- Works without Python dependencies
- Falls back to basic menus if dialog/whiptail not available
- Same core functionality as Python version
- Quick deploy option for common configs

#### Installation:
```bash
# Make executable
chmod +x scripts/config-manager.sh

# Optional: Install dialog for better UI
brew install dialog
```

#### Usage:
```bash
# Run the TUI
./scripts/config-manager.sh
```

#### Menu Options:
1. **Browse by Category**: Select and deploy individual configs
2. **Deploy All in Category**: Deploy all configs in a category
3. **Show All Configurations**: View status of all configs
4. **Check Requirements**: Verify required tools are installed
5. **Backup Installed Configs**: Create backups of current configs
6. **Quick Deploy Common**: Deploy commonly used configurations

## 📁 Configuration Structure

Configurations are organized by category:

```
configs/
├── shell/          # Shell configurations (bash, zsh, fish)
├── terminal/       # Terminal emulators (alacritty, kitty, warp)
├── editors/        # Text editors (neovim, vscode, vim)
├── dev-tools/      # Development tools (git, lazygit, direnv)
├── languages/      # Language tools (rust, python, node)
├── database/       # Database clients (psql, mysql, pgcli)
├── cloud/          # Cloud tools (aws, gcloud, terraform)
├── monitoring/     # System monitoring (htop, bat, ripgrep)
├── system/         # System utilities (karabiner, yabai)
└── security/       # Security tools (ssh, gpg)
```

## 🔄 Backup System

Both versions include automatic backup functionality:

- Backups are created before overwriting existing configs
- Stored in `.config-backups/` with timestamps
- Original files can be restored if needed

## 🚀 Quick Start

1. **Check Requirements**:
   ```bash
   ./scripts/config-manager.py --check
   ```

2. **Deploy Common Configurations**:
   ```bash
   # Using Python version
   ./scripts/config-manager.py --category shell --category dev-tools

   # Using shell version (option 6)
   ./scripts/config-manager.sh
   ```

3. **Interactive Selection**:
   ```bash
   # Launch TUI and browse categories
   ./scripts/config-manager.py
   ```

## 📋 Available Configurations

### Essential Configurations:
- **Git**: Version control settings and aliases
- **Starship**: Cross-shell prompt
- **Zsh/Bash/Fish**: Shell configurations
- **tmux**: Terminal multiplexer
- **Neovim/Vim**: Text editor configurations

### Development Tools:
- **Lazygit**: Terminal UI for git
- **GitHub CLI**: GitHub from the terminal
- **Docker**: Container configuration
- **AWS/GCloud/Azure**: Cloud CLI configs

### System Enhancements:
- **Karabiner**: Keyboard customization
- **yabai/skhd**: Tiling window manager
- **AeroSpace**: i3-like window management

## ⚠️ Important Notes

1. **Always backup existing configurations** before deploying new ones
2. **Check requirements** to ensure tools are installed
3. **Review configurations** before deploying to production systems
4. Some configurations may require additional setup (see tool documentation)

## 🔧 Customization

To add new configurations:

1. Add the config file to the appropriate `configs/` subdirectory
2. Update the configuration definitions in the manager scripts
3. Add to the knowledge graph using the documented process

## 📚 Related Documentation

- [Configuration Overview](../configs/README.md)
- [AI LLM Guide](../docs/ai-llm-guide.md)
- [Setup Checklist](../docs/setup-checklist.md)
