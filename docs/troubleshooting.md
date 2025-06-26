# Troubleshooting Guide

## Common Issues and Solutions

### Installation Issues

#### Homebrew Installation Fails
**Problem**: Homebrew installation script fails or hangs.

**Solution**:
```bash
# Check if you have Xcode Command Line Tools
xcode-select -p

# If not installed, install them
xcode-select --install

# Try installing Homebrew again
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# For Apple Silicon Macs, ensure PATH is correct
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

#### Node.js/NVM Issues
**Problem**: `nvm: command not found` after installation.

**Solution**:
```bash
# Add NVM to your shell profile
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Source your profile
source ~/.zshrc

# Verify installation
nvm --version
```

### Terminal Issues

#### Powerlevel10k Icons Not Displaying
**Problem**: Seeing boxes or question marks instead of icons.

**Solution**:
1. Install a Nerd Font:
   ```bash
   brew tap homebrew/cask-fonts
   brew install --cask font-meslo-lg-nerd-font
   ```

2. Configure your terminal to use the font:
   - **Warp**: Settings → Appearance → Font → MesloLGS NF
   - **iTerm2**: Preferences → Profiles → Text → Font → MesloLGS NF
   - **VS Code**: Add to settings.json:
     ```json
     "terminal.integrated.fontFamily": "'MesloLGS NF'"
     ```

#### Zsh Slow Startup
**Problem**: Terminal takes long to start.

**Solution**:
```bash
# Profile your zsh startup
zsh -xvs

# Or use zprof
# Add to beginning of ~/.zshrc
zmodload zsh/zprof

# Add to end of ~/.zshrc
zprof

# Common fixes:
# 1. Use Powerlevel10k instant prompt
# 2. Lazy load NVM:
export NVM_LAZY_LOAD=true

# 3. Remove unnecessary plugins from .zshrc
```

### Git Issues

#### GPG Signing Fails
**Problem**: `error: gpg failed to sign the data`

**Solution**:
```bash
# Install GPG
brew install gnupg

# Generate a new GPG key
gpg --full-generate-key

# List keys
gpg --list-secret-keys --keyid-format=long

# Configure Git
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true

# Add to ~/.zshrc
export GPG_TTY=$(tty)
```

#### Git Credentials Not Saving
**Problem**: Keep being asked for GitHub password.

**Solution**:
```bash
# Configure credential helper
git config --global credential.helper osxkeychain

# For GitHub, use Personal Access Token or SSH
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key
pbcopy < ~/.ssh/id_ed25519.pub
# Add to GitHub: Settings → SSH and GPG keys
```

### Development Environment Issues

#### Python Virtual Environment Not Activating
**Problem**: `activate: command not found`

**Solution**:
```bash
# Create virtual environment correctly
python3 -m venv venv

# Activate (note the source command)
source venv/bin/activate  # Not just 'activate'

# For fish shell
source venv/bin/activate.fish

# Using alias from .zshrc
venv  # Creates venv
activate  # Activates it
```

#### Docker Desktop Not Starting
**Problem**: Docker Desktop fails to start or crashes.

**Solution**:
1. Reset Docker Desktop:
   ```bash
   # Quit Docker Desktop
   # Remove settings
   rm -rf ~/Library/Group\ Containers/group.com.docker
   rm -rf ~/Library/Containers/com.docker.docker
   rm -rf ~/.docker
   ```

2. Reinstall:
   ```bash
   brew uninstall --cask docker
   brew install --cask docker
   ```

3. Check virtualization:
   ```bash
   sysctl -a | grep -E "machdep.cpu.features|VMX"
   ```

### VS Code/Cursor Issues

#### Extensions Not Working
**Problem**: Extensions installed but not functioning.

**Solution**:
```bash
# Clear extension cache
rm -rf ~/Library/Application\ Support/Code/CachedExtensionVSIXs

# For Cursor
rm -rf ~/Library/Application\ Support/Cursor/CachedExtensionVSIXs

# Reinstall extensions
code --install-extension <extension-id>
```

#### Settings Sync Not Working
**Problem**: Settings not syncing between machines.

**Solution**:
1. Sign out and sign back in
2. Check Settings Sync status: `Cmd+Shift+P` → "Settings Sync: Show Log"
3. Reset sync data: `Cmd+Shift+P` → "Settings Sync: Reset Extension State"

### Tailscale Issues

#### Cannot Connect to Network
**Problem**: Tailscale not connecting to "box-net".

**Solution**:
```bash
# Check status
tailscale status

# Restart Tailscale
sudo tailscale down
sudo tailscale up

# Re-authenticate
tailscale up --force-reauth

# Check logs
log stream --predicate 'subsystem == "com.tailscale.ipn.macos"'
```

### Neo4j Issues

#### Neo4j Won't Start
**Problem**: `neo4j start` fails.

**Solution**:
```bash
# Check if Java is installed
java -version

# Install Java if missing
brew install --cask temurin@17

# Check Neo4j logs
neo4j console

# Common fix: Clear database lock
rm -f /usr/local/var/neo4j/data/databases/neo4j/store_lock

# Set proper permissions
sudo chown -R $(whoami) /usr/local/var/neo4j
```

### Performance Issues

#### Mac Running Slow After Setup
**Problem**: System performance degraded.

**Solution**:
1. Check running processes:
   ```bash
   htop  # or top
   ```

2. Disable unnecessary startup items:
   ```bash
   # List login items
   osascript -e 'tell application "System Events" to get the name of every login item'
   ```

3. Reset SMC and NVRAM:
   - Shut down Mac
   - Press and hold power button for 10 seconds
   - Release and wait a few seconds
   - Press power button to turn on

4. Check disk space:
   ```bash
   df -h
   ncdu /  # Interactive disk usage
   ```

### Shell Configuration Issues

#### Aliases Not Working
**Problem**: Custom aliases not recognized.

**Solution**:
```bash
# Check if .zshrc is being loaded
echo "echo 'zshrc loaded'" >> ~/.zshrc
# Open new terminal - should see message

# Ensure aliases are defined after Oh My Zsh
# Move custom aliases to end of .zshrc

# Or create separate alias file
echo "source ~/.aliases" >> ~/.zshrc
```

#### PATH Issues
**Problem**: Commands not found despite being installed.

**Solution**:
```bash
# Check current PATH
echo $PATH | tr ':' '\n'

# Common PATH additions for Apple Silicon
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

# Verify tool location
which <tool-name>
brew list <tool-name>
```

## General Debugging Steps

### 1. Check Installation Logs
```bash
# Homebrew logs
brew doctor
brew config

# Check last installation
brew log <package>
```

### 2. Verify Dependencies
```bash
# Check all dependencies for a package
brew deps --tree <package>

# Check what depends on a package
brew uses --installed <package>
```

### 3. Environment Variables
```bash
# Print all environment variables
env | sort

# Check specific variable
echo $VARIABLE_NAME

# Temporarily set variable
export VARIABLE_NAME=value
```

### 4. Permission Issues
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew

# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
```

## Getting Help

### Commands for Help
```bash
# Man pages
man <command>

# Built-in help
<command> --help
<command> -h

# Homebrew formula info
brew info <package>

# Find which package provides a command
brew which-formula <command>
```

### Useful Resources
- Homebrew: https://docs.brew.sh
- Oh My Zsh: https://github.com/ohmyzsh/ohmyzsh/wiki
- Powerlevel10k: https://github.com/romkatv/powerlevel10k
- Warp Docs: https://docs.warp.dev
- Tailscale Docs: https://tailscale.com/kb

### Community Support
- Homebrew Discourse: https://discourse.brew.sh
- Stack Overflow: https://stackoverflow.com/questions/tagged/macos
- Reddit: r/MacOS, r/homebrew
- GitHub Issues for specific tools

## Reset and Recovery

### Complete Reset
If all else fails, you can reset and start over:

```bash
# Backup current setup
brew bundle dump --file=~/Desktop/Brewfile.backup

# Uninstall Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Remove configurations
mv ~/.zshrc ~/.zshrc.backup
mv ~/.gitconfig ~/.gitconfig.backup

# Start fresh with the setup script
./setup.sh
```

Remember: Most issues can be solved by:
1. Restarting the terminal
2. Running `source ~/.zshrc`
3. Checking the logs
4. Verifying PATH and environment variables
