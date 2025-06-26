# Mac Setup Configurations Overview

This directory contains configuration files for various tools and applications used in the Mac setup. Each configuration is tracked in the knowledge graph and can be deployed to the appropriate location.

## Directory Structure

```
configs/
├── cloud/           # Cloud provider and infrastructure tools
├── containers/      # Container and orchestration tools
├── database/        # Database client configurations
├── dev-tools/       # Development tools and utilities
├── docs/            # Documentation and note-taking apps
├── editors/         # Text editors and IDEs
├── git/             # Git configuration (existing)
├── languages/       # Programming language tools
├── monitoring/      # System monitoring and debugging
├── security/        # Security and authentication
├── shell/           # Shell configurations
├── system/          # System utilities and window managers
└── terminal/        # Terminal emulators
```

## Configuration Categories

### 1. Shell Configurations (`shell/`)
- **starship.toml** - Fast, customizable prompt for any shell
- **bashrc** - Bash shell configuration
- **bash_profile** - Bash login shell configuration  
- **config.fish** - Fish shell configuration
- **config.nu** - Nushell configuration
- **zshrc** - Zsh configuration (existing)

### 2. Editor Configurations (`editors/`)
- **init.lua** - Neovim configuration with LSP and plugins
- **vimrc** - Classic Vim configuration
- **vscode-settings.json** - VS Code settings (existing)
- **vscode-keybindings.json** - VS Code keyboard shortcuts
- **helix-config.toml** - Helix editor configuration
- **sublime-preferences.json** - Sublime Text preferences

### 3. Terminal Configurations (`terminal/`)
- **alacritty.yml** - Alacritty GPU-accelerated terminal
- **kitty.conf** - Kitty terminal with graphics support
- **wezterm.lua** - WezTerm multiplexing terminal
- **hyper.js** - Hyper web-tech terminal
- **tmux.conf** - Terminal multiplexer (existing)
- **warp-preferences.yaml** - Warp terminal (existing)

### 4. Development Tools (`dev-tools/`)
- **lazygit.yml** - Lazygit terminal UI for git
- **gh-config.yml** - GitHub CLI configuration
- **docker-config.json** - Docker CLI settings
- **direnvrc** - Directory-based environment variables

### 5. Programming Languages (`languages/`)
- **cargo-config.toml** - Rust/Cargo configuration
- **npmrc** - NPM package manager
- **pip.conf** - Python pip configuration
- **poetry-config.toml** - Poetry Python package manager
- **bundle-config** - Ruby Bundler configuration

### 6. Security & SSH (`security/`)
- **ssh_config** - SSH client configuration (moved from root)
- **gpg.conf** - GnuPG configuration
- **1password-ssh-agent.toml** - 1Password SSH integration

### 7. System & Productivity (`system/`)
- **karabiner.json** - Keyboard customization
- **yabairc** - Tiling window manager
- **skhdrc** - Hotkey daemon for yabai
- **aerospace.toml** - Modern tiling window manager
- **espanso-base.yml** - Text expander snippets

### 8. Database Tools (`database/`)
- **psqlrc** - PostgreSQL client configuration
- **my.cnf** - MySQL client configuration
- **mongorc.js** - MongoDB shell configuration
- **pgcli-config** - PostgreSQL CLI with auto-completion
- **litecli-config** - SQLite CLI with auto-completion

### 9. Cloud & DevOps (`cloud/`)
- **aws-config** - AWS CLI profiles and settings
- **gcloud-config** - Google Cloud SDK configuration
- **azure-config** - Azure CLI configuration
- **terraformrc** - Terraform CLI configuration
- **kube-config** - Kubernetes contexts and clusters

### 10. Monitoring & Debugging (`monitoring/`)
- **htoprc** - htop process viewer
- **btop.conf** - btop resource monitor
- **bat-config** - bat syntax highlighting
- **ripgreprc** - ripgrep search configuration
- **fdignore** - fd find ignore patterns

### 11. Container & Virtualization (`containers/`)
- **containers.conf** - Podman configuration
- **colima.yaml** - Container runtime on macOS
- **k9s-config.yml** - Kubernetes TUI

### 12. Documentation & Notes (`docs/`)
- **obsidian.json** - Obsidian note-taking
- **logseq-config.edn** - Logseq knowledge base
- **zettlr-config.json** - Zettlr markdown editor

## Usage

### Deploying Configurations

To deploy a configuration file to its proper location:

```bash
# Example: Deploy starship configuration
cp configs/shell/starship.toml ~/.config/starship.toml

# Example: Deploy neovim configuration
mkdir -p ~/.config/nvim
cp configs/editors/init.lua ~/.config/nvim/init.lua
```

### Adding New Configurations

1. Create the configuration file in the appropriate subdirectory
2. Add a Configuration node to the knowledge graph:
   ```cypher
   CREATE (conf:Configuration {
     name: 'Config Name',
     file_path: '~/path/to/config',
     source_path: 'configs/category/filename',
     purpose: 'What it configures',
     key_features: ['feature1', 'feature2'],
     created: datetime()
   })
   ```
3. Connect to the tool it configures:
   ```cypher
   MATCH (conf:Configuration {name: 'Config Name'})
   MATCH (tool:Tool {tool_key: 'tool-key'})
   CREATE (conf)-[:CONFIGURES]->(tool)
   ```

### Querying Configurations

Find all configurations:
```cypher
MATCH (c:Configuration)
RETURN c.name, c.file_path, c.purpose
ORDER BY c.name
```

Find what a tool is configured by:
```cypher
MATCH (t:Tool)<-[:CONFIGURES]-(c:Configuration)
RETURN t.name, collect(c.name) as configurations
```

## Best Practices

1. **Documentation**: Include comments in configuration files explaining non-obvious settings
2. **Defaults**: Start with sensible defaults that work out of the box
3. **Customization**: Make it easy to customize by clearly marking sections
4. **Version Control**: Track all configurations in git
5. **Consistency**: Use consistent formatting and structure across similar tools
6. **Testing**: Test configurations before committing
7. **Backup**: Keep backups of existing configurations before replacing

## Notes

- Some configurations may require the tool to be installed first
- Paths starting with `~` refer to the user's home directory
- Some configurations may need additional setup (like installing plugins)
- Always check the tool's documentation for the latest configuration options
