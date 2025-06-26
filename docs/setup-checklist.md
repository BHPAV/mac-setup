# MacBook M4 Max Setup Checklist

## Pre-Setup
- [ ] Backup important data from old machine
- [ ] Note down software licenses and keys
- [ ] Export browser bookmarks
- [ ] Save SSH keys and GPG keys
- [ ] Document any custom configurations

## Initial macOS Setup
- [ ] Complete macOS initial setup wizard
- [ ] Sign in with Apple ID
- [ ] Enable FileVault disk encryption
- [ ] Configure Touch ID / Face ID
- [ ] Set computer name: `System Settings > General > Sharing > Computer Name`
- [ ] Enable Firewall: `System Settings > Network > Firewall`

## Run Setup Script
- [ ] Clone this repository
- [ ] Make setup script executable: `chmod +x scripts/setup.sh`
- [ ] Run main setup: `./scripts/setup.sh`
- [ ] Follow all interactive prompts

## Deploy Configurations
- [ ] Install Python rich library: `pip3 install rich`
- [ ] Run configuration manager: `./scripts/config-manager.py`
- [ ] Check all requirements: `./scripts/config-manager.py --check`
- [ ] Deploy essential configs:
  - [ ] Shell configuration (bash/zsh/fish)
  - [ ] Git configuration
  - [ ] Terminal emulator config
  - [ ] Editor configuration
- [ ] Verify backups created in `.config-backups/`

## Core Tools Verification
- [ ] Homebrew installed: `brew --version`
- [ ] Git configured: `git config --list`
- [ ] Zsh is default shell: `echo $SHELL`
- [ ] Oh My Zsh installed: `echo $ZSH`
- [ ] Powerlevel10k theme active

## Development Environments
### Terminal Setup
- [ ] Warp terminal launches
- [ ] Powerlevel10k configured (run `p10k configure` if needed)
- [ ] Tmux installed: `tmux -V`
- [ ] FZF working: `Ctrl+R` for history

### Python
- [ ] Python installed: `python3 --version`
- [ ] Pip updated: `pip3 --version`
- [ ] Pipx working: `pipx --version`
- [ ] Virtual environment works: `python3 -m venv test && rm -rf test`

### Node.js
- [ ] NVM installed: `nvm --version`
- [ ] Node installed: `node --version`
- [ ] NPM working: `npm --version`
- [ ] Yarn installed: `yarn --version`

### Go
- [ ] Go installed: `go version`
- [ ] GOPATH set: `echo $GOPATH`
- [ ] Go binaries in PATH: `echo $PATH | grep -q go/bin`

### Rust
- [ ] Rust installed: `rustc --version`
- [ ] Cargo working: `cargo --version`
- [ ] Rustup installed: `rustup --version`

### Java
- [ ] Java installed: `java -version`
- [ ] Multiple JDKs available: `jenv versions`
- [ ] Maven installed: `mvn -version`
- [ ] Gradle installed: `gradle --version`

## Applications
- [ ] Cursor IDE launches and signs in
- [ ] VS Code launches (optional)
- [ ] Docker Desktop running: `docker ps`
- [ ] Warp terminal configured with AI features

## Database Tools
- [ ] Neo4j Desktop installed
- [ ] Neo4j service works: `neo4j start`
- [ ] PostgreSQL installed: `psql --version`
- [ ] MySQL installed: `mysql --version`
- [ ] Redis installed: `redis-cli --version`

## Cloud Tools
- [ ] AWS CLI: `aws --version`
- [ ] Google Cloud SDK: `gcloud --version`
- [ ] Azure CLI: `az --version`
- [ ] Terraform: `terraform --version`
- [ ] Kubectl: `kubectl version --client`

## Network Setup
- [ ] Tailscale installed
- [ ] Connected to "box-net" network
- [ ] Can access network resources
- [ ] SSH keys generated: `ls ~/.ssh/id_*`

## Git Configuration
- [ ] User name set: `git config user.name`
- [ ] User email set: `git config user.email`
- [ ] Global gitignore configured
- [ ] Commit signing configured (optional)
- [ ] Git aliases working: `git aliases`

## Shell Configuration
- [ ] Aliases working: `alias | grep -E "gs|ga|gc"`
- [ ] Functions available: `type mkcd`
- [ ] PATH includes custom directories
- [ ] Local binaries directory: `ls ~/bin`
- [ ] Starship prompt installed: `starship --version`
- [ ] Shell configs deployed via Config Manager

## Security Setup
- [ ] SSH key added to GitHub/GitLab
- [ ] GPG key configured (optional)
- [ ] Two-factor authentication enabled on:
  - [ ] GitHub
  - [ ] Google
  - [ ] Apple ID
  - [ ] Other critical services

## macOS Settings Applied
- [ ] Hidden files visible in Finder
- [ ] File extensions shown
- [ ] Fast key repeat enabled
- [ ] Screenshots saved to ~/Screenshots
- [ ] Tap to click enabled

## Dotfiles Repository
- [ ] Initialize dotfiles repo: `cd ~/.dotfiles && git init`
- [ ] Add remote: `git remote add origin <your-repo-url>`
- [ ] Commit initial configuration
- [ ] Push to remote repository

## Application Preferences
- [ ] Use Config Manager to deploy app configs:
  - [ ] Warp terminal configuration
  - [ ] VS Code/Cursor settings and keybindings
  - [ ] Alacritty/Kitty terminal configs
  - [ ] Neovim/Vim configurations
  - [ ] Database client configs (psql, mysql)
  - [ ] Cloud tool configs (aws, gcloud)
- [ ] Configure browser bookmarks and extensions
- [ ] Set up password manager
- [ ] Configure cloud storage sync

## Testing
- [ ] Create test project: `project-init test-app node`
- [ ] Test Git workflow: clone, commit, push
- [ ] Test Docker: `docker run hello-world`
- [ ] Test each programming language with hello world
- [ ] Test database connections

## Backup Creation
- [ ] Run backup script: `~/bin/backup`
- [ ] Generate Brewfile: `brew bundle dump`
- [ ] Document any manual configurations
- [ ] Store licenses and keys securely

## Optional Customizations
- [ ] Configure Raycast/Alfred workflows
- [ ] Set up custom keyboard shortcuts
- [ ] Install additional VS Code extensions
- [ ] Configure VPN settings
- [ ] Set up Time Machine backups

## Final Verification
- [ ] All daily-use applications installed
- [ ] Development workflow tested
- [ ] Network connectivity verified
- [ ] Performance is acceptable
- [ ] No error messages in terminal startup

## Post-Setup Maintenance
- [ ] Schedule regular Homebrew updates
- [ ] Enable automatic macOS updates
- [ ] Configure backup strategy
- [ ] Document any custom changes
- [ ] Share setup with team (if applicable)

## Notes Section
Use this space to document any specific configurations or issues encountered:

```
Date: _______________

Custom configurations:
- 
- 
- 

Issues resolved:
- 
- 
- 

Additional software installed:
- 
- 
- 
```

## Quick Health Check Commands
Run these to verify everything is working:

```bash
# System check
brew doctor
echo "Shell: $SHELL"
echo "PATH entries: $(echo $PATH | tr ':' '\n' | wc -l)"

# Configuration check
./scripts/config-manager.py --list | grep -E "✓|✗" | sort | uniq -c

# Development tools
echo "Python: $(python3 --version)"
echo "Node: $(node --version)"
echo "Go: $(go version)"
echo "Rust: $(rustc --version)"
echo "Java: $(java -version 2>&1 | head -1)"

# Services
docker ps
tailscale status
neo4j status
```

Remember: This checklist is comprehensive - not everything may apply to your specific needs!
