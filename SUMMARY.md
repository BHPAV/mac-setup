# Mac Setup Repository Structure

This repository contains a comprehensive macOS development environment setup with 40+ files organized for easy navigation and use.

## 📁 Repository Overview

```
mac-setup/
├── 📄 README.md                    # Main documentation
├── 📄 Brewfile                     # Homebrew package manifest  
├── 📄 .env.template                # Environment variables template
├── 📄 .gitignore                   # Git ignore rules
├── 📂 .github/
│   └── 📂 workflows/
│       └── 📄 validate.yml         # CI/CD validation
├── 📂 scripts/                     # Executable scripts
│   ├── 📄 setup.sh                 # Main setup script
│   ├── 📄 additional-configs.sh    # Additional configurations
│   ├── 📄 backup.sh               # Backup utility
│   ├── 📄 project-init.sh         # Project initialization
│   ├── 📄 system-info.sh          # System information tool
│   └── 📄 update-all.sh           # Update all tools
├── 📂 configs/                     # Configuration files
│   ├── 📂 shell/
│   │   └── 📄 zshrc               # Zsh configuration
│   ├── 📂 git/
│   │   ├── 📄 gitconfig           # Git configuration
│   │   ├── 📄 gitignore_global    # Global gitignore
│   │   └── 📄 gitmessage          # Commit template
│   ├── 📂 editors/
│   │   └── 📄 vscode-settings.json # VS Code/Cursor settings
│   ├── 📂 terminal/
│   │   ├── 📄 warp-preferences.yaml # Warp configuration
│   │   └── 📄 tmux.conf           # Tmux configuration
│   ├── 📄 ssh_config              # SSH configuration
│   ├── 📄 prettierrc.json         # Prettier rules
│   └── 📄 eslintrc.json           # ESLint rules
└── 📂 docs/                        # Documentation
    ├── 📄 integration-guide.md     # How everything works together
    ├── 📄 powerlevel10k-visual.md  # Terminal theme guide
    ├── 📄 knowledge-graph-guide.md # Knowledge storage guide
    ├── 📄 troubleshooting.md       # Common issues & solutions
    ├── 📄 setup-checklist.md       # Setup verification
    └── 📄 quick-reference.md       # Keyboard shortcuts & commands
```

## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/mac-setup.git
   cd mac-setup
   ```

2. **Run the setup:**
   ```bash
   chmod +x scripts/*.sh
   ./scripts/setup.sh
   ```

3. **Follow the checklist:**
   Open `docs/setup-checklist.md` and verify each step

## 📋 What's Included

### Scripts (6 files)
- **setup.sh**: Main automated setup script
- **additional-configs.sh**: Creates extra config files
- **backup.sh**: Backs up important files
- **project-init.sh**: Initialize new projects
- **system-info.sh**: Display system information
- **update-all.sh**: Update all development tools

### Configurations (11 files)
- Shell, Git, Editor, Terminal configurations
- All pre-configured for seamless integration
- Supports Warp, VS Code, Cursor, Tmux, and more

### Documentation (6 files)
- Complete integration guide
- Visual examples of Powerlevel10k
- Knowledge graph storage instructions
- Troubleshooting guide
- Setup checklist
- Quick reference card

## 🔧 Key Features

1. **Automated Installation**
   - Interactive setup process
   - Modular installation options
   - Safe and idempotent

2. **Development Environments**
   - Python (Poetry, pipx, virtualenv)
   - Node.js (NVM, npm, yarn, pnpm)
   - Go (workspace setup)
   - Rust (rustup, cargo)
   - Java (multiple JDKs, jenv)

3. **Modern Terminal**
   - Zsh + Oh My Zsh + Powerlevel10k
   - AI-powered tools (Warp, Cursor)
   - Extensive aliases and functions

4. **Cloud & DevOps**
   - AWS, GCP, Azure CLIs
   - Docker, Kubernetes tools
   - Terraform, Ansible

5. **Database Tools**
   - Neo4j (Desktop + CLI)
   - PostgreSQL, MySQL, Redis
   - GUI clients

## 🛠️ Maintenance

### Regular Updates
```bash
# Update everything
./scripts/update-all.sh

# Check system status
./scripts/system-info.sh

# Backup configurations
./scripts/backup.sh
```

### Version Control
```bash
# Save your customizations
cd ~/.dotfiles
git add .
git commit -m "Update configurations"
git push
```

## 📝 Customization

1. **Fork this repository**
2. **Modify configurations** in the `configs/` directory
3. **Add your own scripts** to `scripts/`
4. **Update the Brewfile** with your tools
5. **Document changes** in the README

## 🔒 Security Notes

- Never commit `.env` files
- Use `.env.template` as a guide
- Store secrets in a password manager
- Enable 2FA on all services
- Regular security updates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run validation: `shellcheck scripts/*.sh`
5. Submit a pull request

## 📚 Resources

- [Homebrew Documentation](https://docs.brew.sh)
- [Oh My Zsh Wiki](https://github.com/ohmyzsh/ohmyzsh/wiki)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Warp Documentation](https://docs.warp.dev)
- [Tailscale KB](https://tailscale.com/kb)

## 📜 License

MIT License - See LICENSE file for details

---

**Remember**: This setup is opinionated and comprehensive. Feel free to pick and choose what works for you!

For questions or issues, please open a GitHub issue or refer to the troubleshooting guide.
