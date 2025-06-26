# MacBook M4 Max Development Environment Setup

This repository contains a comprehensive setup script and configuration files for setting up a new MacBook M4 Max for software development.

## Features

- **Automated Installation**: Interactive script to install and configure development tools
- **Configuration Manager TUI**: Interactive terminal UI for selecting and deploying configurations
- **Tailscale Integration**: Connect to your "box-net" network
- **Multiple Development Environments**: Python, Node.js, Go, Rust, Java, and more
- **Modern Terminal Setup**: Zsh + Oh My Zsh + Powerlevel10k
- **Developer Tools**: Cursor IDE, Warp Terminal, Neo4j, Docker, and more
- **Configuration Management**: Organized dotfiles for easy version control
- **Knowledge Graph Integration**: All configurations tracked in Neo4j

## Quick Start

1. Clone this repository to your new Mac:
   ```bash
   git clone https://github.com/yourusername/mac-setup.git
   cd mac-setup
   ```

2. Run the main setup script:
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

## Directory Structure

```
mac-setup/
├── scripts/
│   ├── setup.sh              # Main setup script
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
└── docs/
    ├── integration-guide.md  # How everything works together
    ├── powerlevel10k-visual.md # Terminal theme examples
    ├── knowledge-graph-guide.md # Knowledge graph storage guide
    ├── git-github-setup.md   # Detailed Git/GitHub setup instructions
    └── git-quick-reference.md # Git commands quick reference
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

## Customization

- Edit configuration files in the `configs/` directory
- Modify the setup script to add/remove tools
- Create a `.zshrc.local` file for machine-specific settings
- Use the generated Brewfile to replicate setup on other machines

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
```

See `scripts/VALIDATION_README.md` for detailed usage.

## Troubleshooting

If you encounter issues:

1. Check that you're running on macOS (Apple Silicon preferred)
2. Ensure you have a stable internet connection
3. Run individual functions from the setup script
4. Check the logs for specific error messages

## Contributing

Feel free to fork this repository and customize it for your needs. Pull requests for improvements are welcome!

## License

MIT License - feel free to use and modify as needed.
