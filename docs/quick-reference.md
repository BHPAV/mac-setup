# Quick Reference Card

## Essential Keyboard Shortcuts

### Warp Terminal
| Shortcut | Action |
|----------|--------|
| `Cmd+T` | New tab |
| `Cmd+D` | Split pane vertically |
| `Cmd+Shift+D` | Split pane horizontally |
| `Cmd+W` | Close pane |
| `Cmd+G` | AI command search |
| `Cmd+Shift+C` | Copy block |
| `Cmd+K` | Clear screen |
| `Cmd+R` | Search history |
| `Cmd+`` ` | Global hotkey (Quake mode) |

### VS Code / Cursor
| Shortcut | Action |
|----------|--------|
| `Cmd+P` | Quick file open |
| `Cmd+Shift+P` | Command palette |
| `Cmd+B` | Toggle sidebar |
| `Cmd+/` | Toggle comment |
| `Cmd+D` | Select next occurrence |
| `Cmd+Shift+L` | Select all occurrences |
| `Option+Up/Down` | Move line up/down |
| `Cmd+Shift+K` | Delete line |
| `Cmd+Enter` | Insert line below |
| `F5` | Start debugging |

### Tmux
| Shortcut | Action |
|----------|--------|
| `Ctrl+a c` | New window |
| `Ctrl+a "` | Split horizontally |
| `Ctrl+a %` | Split vertically |
| `Ctrl+a arrow` | Navigate panes |
| `Ctrl+a d` | Detach session |
| `Ctrl+a s` | List sessions |
| `Ctrl+a ,` | Rename window |
| `Ctrl+a z` | Zoom/unzoom pane |
| `Ctrl+a [` | Enter copy mode |
| `Ctrl+a ]` | Paste |

### FZF (Fuzzy Finder)
| Shortcut | Action |
|----------|--------|
| `Ctrl+R` | Search command history |
| `Ctrl+T` | Find files |
| `Alt+C` | Change directory |
| `Tab` | Select multiple items |
| `Ctrl+/` | Toggle preview |

## Git Aliases

### Basic Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Show status |
| `ga` | `git add` | Stage changes |
| `gc` | `git commit` | Commit changes |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull from remote |
| `gd` | `git diff` | Show differences |
| `gco` | `git checkout` | Switch branches |
| `gb` | `git branch` | List branches |

### Advanced Operations
| Alias | Command | Description |
|-------|---------|-------------|
| `glog` | `git log --oneline --graph` | Pretty log |
| `gwip` | `git commit -am "WIP"` | Quick WIP commit |
| `gundo` | `git reset --soft HEAD^` | Undo last commit |
| `gcleanup` | Remove merged branches | Clean branches |
| `grecent` | Show recent branches | By activity |

## Shell Functions

### File Operations
| Command | Description |
|---------|-------------|
| `mkcd <dir>` | Create and enter directory |
| `extract <archive>` | Extract any archive type |
| `fe` | Fuzzy find and edit file |
| `backup` | Backup important files |

### Development
| Command | Description |
|---------|-------------|
| `project-init <name> [type]` | Initialize new project |
| `gclone <url>` | Clone and enter repo |
| `dexec` | Docker exec with selection |
| `kcontext` | Switch K8s context |

## Docker Commands

| Alias | Full Command | Description |
|-------|--------------|-------------|
| `d` | `docker` | Docker shortcut |
| `dc` | `docker-compose` | Compose shortcut |
| `dps` | `docker ps` | List containers |
| `dex` | `docker exec -it` | Execute in container |

## Kubernetes Commands

| Alias | Full Command | Description |
|-------|--------------|-------------|
| `k` | `kubectl` | Kubectl shortcut |
| `kgp` | `kubectl get pods` | List pods |
| `kgs` | `kubectl get services` | List services |
| `kaf` | `kubectl apply -f` | Apply config |

## System Commands

| Command | Description |
|---------|-------------|
| `reload` | Reload shell configuration |
| `path` | Display PATH entries |
| `myip` | Show public IP address |
| `ll` | Enhanced ls with git info |

## Tailscale Commands

| Command | Description |
|---------|-------------|
| `ts` | Tailscale CLI |
| `ts up` | Connect to network |
| `ts down` | Disconnect |
| `ts status` | Show connection status |

## Package Management

### Homebrew
| Command | Description |
|---------|-------------|
| `brew update` | Update Homebrew |
| `brew upgrade` | Upgrade all packages |
| `brew cleanup` | Remove old versions |
| `brew bundle` | Install from Brewfile |

### Language-Specific
| Command | Description |
|---------|-------------|
| `npm update -g` | Update global npm packages |
| `pip install --upgrade pip` | Update pip |
| `rustup update` | Update Rust toolchain |
| `nvm install --lts` | Install latest Node LTS |

## Quick Setup Commands

### New Machine
```bash
# Clone your dotfiles
git clone https://github.com/you/dotfiles ~/.dotfiles

# Run setup
cd ~/.dotfiles && ./install.sh

# Install from Brewfile
brew bundle --file=~/.dotfiles/Brewfile
```

### Daily Workflow
```bash
# Start work session
tmux new -s work
ts up
cd ~/Projects

# Update everything
brew update && brew upgrade
npm update -g
```

## Visual Indicators

### Powerlevel10k Git Status
| Symbol | Meaning |
|--------|---------|
| `✓` | Clean repository |
| `✗` | Uncommitted changes |
| `+` | Staged changes |
| `*` | Modified files |
| `⇡` | Commits to push |
| `⇣` | Commits to pull |
| `!` | Untracked files |

### Command Status
| Indicator | Meaning |
|-----------|---------|
| Green `❯` | Last command succeeded |
| Red `❯` | Last command failed |
| `⏱ 2m 5s` | Execution time |
