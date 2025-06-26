# MacBook M4 Max Development Environment Setup

This repository contains a comprehensive setup script and configuration files for setting up a new MacBook M4 Max for software development.

## Features

- **Automated Installation**: Interactive script to install and configure development tools
- **Modular Installation**: Choose what to install via configuration file
- **Configuration Manager TUI**: Interactive terminal UI for selecting and deploying configurations
- **Tailscale Integration**: Connect to your "box-net" network
- **Multiple Development Environments**: Python, Node.js, Go, Rust, Java, and more
- **Modern Terminal Setup**: Zsh + Oh My Zsh + Powerlevel10k
- **Developer Tools**: Cursor IDE, Warp Terminal, Neo4j, Docker, and more
- **Configuration Management**: Organized dotfiles for easy version control
- **Knowledge Graph Integration**: All configurations tracked in Neo4j
- **Comprehensive Validation**: Post-install verification and health checks

## Quick Start

### Option 1: Improved Setup Script (Recommended)

1. Clone this repository to your new Mac:
   ```bash
   git clone https://github.com/yourusername/mac-setup.git
   cd mac-setup
   ```

2. Configure your installation:
   ```bash
   # Copy and customize the configuration template
   cp mac-setup.env.template mac-setup.env
   # Edit mac-setup.env to choose what to install
   ```

3. Run the improved setup script:
   ```bash
   chmod +x scripts/setup-improved.sh
   ./scripts/setup-improved.sh
   ```

4. Validate your installation:
   ```bash
   chmod +x scripts/validate-installation.sh
   ./scripts/validate-installation.sh
   ```

### Option 2: Original Setup Script

1. Clone this repository to your new Mac:
   ```bash
   git clone https://github.com/yourusername/mac-setup.git
   cd mac-setup
   ```

2. Run the original setup script:
   ```bash
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

3. Use the Configuration Manager to deploy configs:
   ```bash
   # Python version (recommended)
   pip3 install rich
   ./scripts/config-manager.py
   
   # Or shell version
   ./scripts/config-manager.sh
   ```

4. Follow the interactive prompts to customize your installation.

### First Time Setup?

If you're setting up this repository for the first time:

```bash
# Use the automated Git setup script
chmod +x scripts/git-init-upload.sh
./scripts/git-init-upload.sh
```

Or see the [detailed Git setup guide](docs/git-github-setup.md).

## What's New: Usability Improvements

The improved setup script (`scripts/setup-improved.sh`) introduces several enhancements:

### 🎯 Modular Installation
- **Configuration-driven**: Edit `mac-setup.env` to choose what to install
- **Granular control**: Enable/disable individual components (e.g., skip Azure CLI)
- **Custom packages**: Add your own Homebrew formulae, npm packages, etc.

### 🔍 Enhanced Interactivity
- **Confirmation prompts**: Special warnings for destructive changes
- **Dry-run mode**: Preview installation without making changes
- **Non-interactive mode**: Perfect for automated deployments

### ✅ Comprehensive Validation
- **Post-install checks**: Verify all components are working correctly
- **Detailed reporting**: Success/failure statistics with actionable feedback
- **Health monitoring**: System requirements, disk space, network connectivity

### 🛡️ Safety Features
- **Automatic backups**: Timestamped backups before overwriting files
- **Error handling**: Graceful degradation and clear error messages
- **Logging**: Complete installation log with timestamps

See [Usability Improvements Guide](docs/usability-improvements.md) for detailed information.

## Directory Structure

```
mac-setup/
├── scripts/
│   ├── setup-improved.sh     # Improved setup script (recommended)
│   ├── setup.sh              # Original setup script
│   ├── validate-installation.sh # Post-install validation
│   ├── config-manager.py    # Configuration Manager TUI (Python)
│   ├── config-manager.sh    # Configuration Manager TUI (Shell)
│   ├── additional-configs.sh # Additional configuration setup
│   ├── backup.sh            # Backup utility
│   ├── project-init.sh      # Project initialization tool
│   ├── validate-brewfile.sh # Brewfile validation (simple)
│   ├── validate-brewfile-graph.py # Brewfile-Graph sync validation
│   ├── git-init-upload.sh   # Automated Git/GitHub setup
│   └── git-commit-helper.sh # Intelligent commit message helper
├── configs/                  # 50+ configuration files
│   ├── shell/               # Shell configurations (bash, zsh, fish, starship)
│   ├── terminal/            # Terminal emulators (alacritty, kitty, warp)
│   ├── editors/             # Editor configs (neovim, vscode, vim)
│   ├── dev-tools/           # Development tools (git, lazygit, docker)
│   ├── languages/           # Language configs (rust, python, node)
│   ├── database/            # Database clients (psql, mysql, pgcli)
│   ├── cloud/               # Cloud tools (aws, gcloud, terraform)
│   ├── monitoring/          # System monitoring (htop, bat, ripgrep)
│   ├── system/              # System utilities (karabiner, yabai)
│   └── security/            # Security tools (ssh, gpg)
├── mac-setup.env.template   # Configuration template
└── docs/
    ├── usability-improvements.md # Usability improvements guide
    ├── integration-guide.md  # How everything works together
    ├── powerlevel10k-visual.md # Terminal theme examples
    ├── knowledge-graph-guide.md # Knowledge graph storage guide
    ├── git-github-setup.md   # Detailed Git/GitHub setup instructions
    └── git-quick-reference.md # Git commands quick reference
```

## Configuration Options

The improved setup script supports extensive customization via `mac-setup.env`:

### Core Settings
```bash
INTERACTIVE_MODE=true      # Enable/disable user prompts
DRY_RUN_MODE=false         # Preview mode without installation
BACKUP_EXISTING_FILES=true # Automatic file backups
```

### Installation Toggles
```bash
INSTALL_XCODE_CLI=true     # Xcode Command Line Tools
INSTALL_HOMEBREW=true      # Homebrew package manager
INSTALL_PYTHON=true        # Python development environment
INSTALL_NODEJS=true        # Node.js development environment
INSTALL_GO=false           # Skip Go installation
INSTALL_RUST=true          # Rust development environment
INSTALL_JAVA=false         # Skip Java installation
```

### Development Tools
```bash
INSTALL_WARP_TERMINAL=true # Warp terminal emulator
INSTALL_CURSOR_IDE=true    # Cursor IDE
INSTALL_DOCKER=true        # Docker Desktop
INSTALL_NEO4J_DESKTOP=true # Neo4j Desktop
```

### Cloud and DevOps
```bash
INSTALL_AWS_CLI=true       # AWS Command Line Interface
INSTALL_AZURE_CLI=false    # Skip Azure CLI
INSTALL_GOOGLE_CLOUD_SDK=true # Google Cloud SDK
INSTALL_TERRAFORM=true     # Terraform
INSTALL_KUBECTL=true       # Kubernetes CLI
```

### Custom Packages
```bash
CUSTOM_BREW_FORMULAE="htop ncdu"     # Additional Homebrew formulae
CUSTOM_NPM_PACKAGES="typescript ts-node" # Additional npm packages
CUSTOM_PIP_PACKAGES="requests pandas"    # Additional Python packages
```

## Usage Examples

### Basic Installation
```bash
# Copy and edit configuration
cp mac-setup.env.template mac-setup.env
# Edit mac-setup.env to customize installation

# Run setup
./scripts/setup-improved.sh
```

### Dry-Run Mode
```bash
# Test configuration without installing
DRY_RUN_MODE=true ./scripts/setup-improved.sh
```

### Non-Interactive Mode
```bash
# Automated installation (no prompts)
INTERACTIVE_MODE=false ./scripts/setup-improved.sh
```

### Post-Install Validation
```bash
# Validate installation
./scripts/validate-installation.sh
```

## What Gets Installed

### Core Tools
- Homebrew (package manager)
- Xcode Command Line Tools
- Git with enhanced configuration
- Essential GNU utilities

### Terminal Environment
- Zsh with Oh My Zsh framework
- Powerlevel10k theme
- Fuzzy finder (fzf)
- Modern CLI replacements (ripgrep, bat, exa, etc.)
- Tmux for terminal multiplexing

### Development Tools
- **Cursor IDE**: AI-powered code editor
- **Warp Terminal**: Modern terminal with AI features
- **VS Code**: Popular code editor
- **Docker Desktop**: Containerization
- Various API clients and database tools

### Programming Languages
- **Python**: Multiple versions with Poetry, pipx, virtual environments
- **Node.js**: Via NVM with npm, yarn, pnpm
- **Go**: Latest version with workspace setup
- **Rust**: Via rustup with cargo tools
- **Java**: Multiple JDK versions with jenv

### Databases
- **Neo4j**: Desktop and Community Edition
- PostgreSQL, MySQL, Redis, MongoDB
- Database GUI clients

### Cloud & DevOps
- AWS, Google Cloud, Azure CLIs
- Terraform, Ansible, Packer
- Kubernetes tools (kubectl, helm, k9s)
- Container tools (Docker, Podman)

## Configuration Manager TUI

The Configuration Manager provides an interactive way to deploy configurations:

### Python Version (Recommended)
```bash
pip3 install rich
./scripts/config-manager.py
```

**Features:**
- Beautiful terminal interface with rich formatting
- Browse configurations by category
- Select multiple configs to deploy at once
- Automatic backup before overwriting
- Requirement checking
- Progress bars and status indicators

### Shell Version
```bash
./scripts/config-manager.sh
```

**Features:**
- No Python dependencies required
- Works with dialog/whiptail or basic menus
- Same core functionality as Python version
- Quick deploy option for common configs

### Usage Examples
```bash
# List all configurations
./scripts/config-manager.py --list

# Deploy specific configuration
./scripts/config-manager.py --deploy "Starship Prompt"

# Deploy entire category
./scripts/config-manager.py --category shell

# Check all requirements
./scripts/config-manager.py --check
```

## Configuration Files

All configuration files are designed to work together seamlessly:

- **Shell**: Aliases, functions, and environment setup (bash, zsh, fish, nushell)
- **Terminal**: GPU-accelerated terminals with consistent themes
- **Editors**: LSP-enabled configs for neovim, extensive VS Code settings
- **Git**: Extensive aliases, delta integration, and workflow improvements
- **Development Tools**: Optimized configs for lazygit, GitHub CLI, Docker
- **Cloud & DevOps**: Pre-configured AWS, GCP, Azure, and Kubernetes tools
- **System Enhancements**: Window managers, keyboard customization, text expansion

## Post-Installation

After running the setup script:

1. **Restart your terminal** or run `source ~/.zshrc`
2. **Connect to Tailscale** and join your "box-net" network
3. **Sign in to applications** (Warp, Cursor, etc.)
4. **Configure SSH keys**:
   ```bash
   ssh-keygen -t ed25519 -C "your.email@example.com"
   ```
5. **Set up your dotfiles repository** for version control
6. **Validate installation** with `./scripts/validate-installation.sh`

## Customization

- Edit configuration files in the `configs/` directory
- Modify the setup script to add/remove tools
- Create a `.zshrc.local` file for machine-specific settings
- Use the generated Brewfile to replicate setup on other machines
- Customize `mac-setup.env` for your specific needs

## Maintenance

Keep your system updated:
```bash
# Update Homebrew packages
brew update && brew upgrade

# Update programming language tools
npm update -g
pip install --upgrade pip
rustup update

# Clean up old versions
brew cleanup
docker system prune -af
```

### Validation Scripts

Ensure consistency between Brewfile and Knowledge Graph:

```bash
# Quick Brewfile inventory
./scripts/validate-brewfile.sh

# Full validation with Neo4j knowledge graph
pip install neo4j
export NEO4J_PASSWORD=your_password
python scripts/validate-brewfile-graph.py

# Post-install validation
./scripts/validate-installation.sh
```

See `scripts/VALIDATION_README.md` for detailed usage.

## Troubleshooting

If you encounter issues:

1. Check that you're running on macOS (Apple Silicon preferred)
2. Ensure you have a stable internet connection
3. Run individual functions from the setup script
4. Check the logs for specific error messages
5. Use the validation script to identify problems
6. Review the [usability improvements guide](docs/usability-improvements.md)

## Contributing

Feel free to fork this repository and customize it for your needs. Pull requests for improvements are welcome!

## License

MIT License - feel free to use and modify as needed.
