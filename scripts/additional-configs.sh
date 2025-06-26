#!/usr/bin/env bash

# This script creates additional configuration files for your development environment

# Create configuration directory
mkdir -p ~/.config

# ==========================
# Global .gitignore
# ==========================

cat > ~/.gitignore_global << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent
.AppleDB
.AppleDesktop
Network Trash Folder
Temporary Items
.apdisk

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/
*.cab
*.msi
*.msm
*.msp
*.lnk

# Linux
*~
.fuse_hidden*
.directory
.Trash-*
.nfs*

# IDEs and Editors
.idea/
.vscode/
*.swp
*.swo
*~
.project
.classpath
.c9/
*.launch
.settings/
*.sublime-workspace
.history/

# Vim
[._]*.s[a-v][a-z]
[._]*.sw[a-p]
[._]s[a-rt-v][a-z]
[._]ss[a-gi-z]
[._]sw[a-p]
Session.vim
.netrwhist
tags
[._]*.un~

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.pytest_cache/
.coverage
.tox/
.mypy_cache/
.dmypy.json
dmypy.json

# JavaScript/Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.eslintcache
.node_repl_history
*.tgz
.yarn-integrity
.next/
.nuxt/
dist/
.cache/
.parcel-cache/

# Go
*.exe
*.dll
*.so
*.dylib
*.test
*.out
vendor/
Godeps/

# Rust
target/
Cargo.lock
**/*.rs.bk

# Java
*.class
*.log
*.jar
*.war
*.nar
*.ear
*.zip
*.tar.gz
*.rar
hs_err_pid*

# Logs
logs/
*.log

# Environment files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Databases
*.sqlite
*.sqlite3
*.db

# Backup files
*.bak
*.backup

# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log
*.tfvars
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc
EOF

# ==========================
# Git commit message template
# ==========================

cat > ~/.gitmessage << 'EOF'
# <type>(<scope>): <subject> (50 chars)

# <body> (72 chars per line)

# <footer>

# Type can be:
#   feat:     A new feature
#   fix:      A bug fix
#   docs:     Documentation only changes
#   style:    Changes that do not affect the meaning of the code
#   refactor: A code change that neither fixes a bug nor adds a feature
#   perf:     A code change that improves performance
#   test:     Adding missing tests or correcting existing tests
#   build:    Changes that affect the build system or external dependencies
#   ci:       Changes to our CI configuration files and scripts
#   chore:    Other changes that don't modify src or test files
#   revert:   Reverts a previous commit
#
# Scope is optional and can be anything specifying the place of the commit change.
#
# Subject should use the imperative, present tense: "change" not "changed" nor "changes"
# Don't capitalize the first letter
# No dot (.) at the end
#
# Body should include the motivation for the change and contrast this with previous behavior.
#
# Footer should contain any information about Breaking Changes and is also the place to
# reference GitHub issues that this commit closes.
#
# Breaking Changes should start with the word BREAKING CHANGE: with a space or two newlines.
EOF

# ==========================
# SSH config template
# ==========================

mkdir -p ~/.ssh
cat > ~/.ssh/config << 'EOF'
# SSH Configuration File

# Global settings
Host *
    # Use SSH key agent
    AddKeysToAgent yes
    UseKeychain yes
    # Keep connections alive
    ServerAliveInterval 60
    ServerAliveCountMax 30
    # Reuse connections
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
    # Security
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    HashKnownHosts yes
    # Compression
    Compression yes

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519

# Example server config
# Host myserver
#     HostName 192.168.1.100
#     User myusername
#     Port 22
#     IdentityFile ~/.ssh/myserver_key
#     ForwardAgent yes
EOF

# Create SSH sockets directory
mkdir -p ~/.ssh/sockets
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config

# ==========================
# Prettier configuration
# ==========================

cat > ~/.prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "arrowParens": "always",
  "bracketSpacing": true,
  "endOfLine": "lf",
  "jsxBracketSameLine": false,
  "jsxSingleQuote": false,
  "proseWrap": "preserve",
  "quoteProps": "as-needed",
  "htmlWhitespaceSensitivity": "css"
}
EOF

# ==========================
# ESLint configuration
# ==========================

cat > ~/.eslintrc.json << 'EOF'
{
  "env": {
    "browser": true,
    "es2021": true,
    "node": true
  },
  "extends": [
    "eslint:recommended"
  ],
  "parserOptions": {
    "ecmaVersion": "latest",
    "sourceType": "module"
  },
  "rules": {
    "indent": ["error", 2],
    "linebreak-style": ["error", "unix"],
    "quotes": ["error", "single"],
    "semi": ["error", "always"],
    "no-unused-vars": ["warn"],
    "no-console": ["warn"],
    "eqeqeq": ["error", "always"],
    "curly": ["error", "all"],
    "brace-style": ["error", "1tbs"],
    "comma-dangle": ["error", "always-multiline"],
    "no-trailing-spaces": ["error"],
    "arrow-parens": ["error", "always"],
    "prefer-const": ["error"],
    "no-var": ["error"]
  }
}
EOF

# ==========================
# Alacritty terminal config (alternative to Warp)
# ==========================

mkdir -p ~/.config/alacritty
cat > ~/.config/alacritty/alacritty.yml << 'EOF'
# Alacritty Configuration

window:
  padding:
    x: 10
    y: 10
  decorations: buttonless
  opacity: 0.95

font:
  normal:
    family: "JetBrains Mono"
    style: Regular
  bold:
    family: "JetBrains Mono"
    style: Bold
  italic:
    family: "JetBrains Mono"
    style: Italic
  size: 14.0

colors:
  # Dracula theme
  primary:
    background: '#282a36'
    foreground: '#f8f8f2'
  cursor:
    text: '#44475a'
    cursor: '#f8f8f2'
  selection:
    text: '#f8f8f2'
    background: '#44475a'
  normal:
    black:   '#000000'
    red:     '#ff5555'
    green:   '#50fa7b'
    yellow:  '#f1fa8c'
    blue:    '#bd93f9'
    magenta: '#ff79c6'
    cyan:    '#8be9fd'
    white:   '#bfbfbf'
  bright:
    black:   '#4d4d4d'
    red:     '#ff6e67'
    green:   '#5af78e'
    yellow:  '#f4f99d'
    blue:    '#caa9fa'
    magenta: '#ff92d0'
    cyan:    '#9aedfe'
    white:   '#e6e6e6'

cursor:
  style:
    shape: Block
    blinking: Off

shell:
  program: /bin/zsh
  args:
    - --login

key_bindings:
  - { key: V,        mods: Command,       action: Paste }
  - { key: C,        mods: Command,       action: Copy  }
  - { key: Q,        mods: Command,       action: Quit  }
  - { key: W,        mods: Command,       action: Quit  }
  - { key: N,        mods: Command,       action: SpawnNewInstance }
EOF

# ==========================
# Useful shell scripts
# ==========================

# Create a bin directory for custom scripts
mkdir -p ~/bin

# Quick backup script
cat > ~/bin/backup << 'EOF'
#!/usr/bin/env bash
# Quick backup script for important files

BACKUP_DIR="$HOME/Backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup important directories
echo "Backing up to $BACKUP_DIR..."
rsync -av --progress ~/.ssh/ "$BACKUP_DIR/ssh/"
rsync -av --progress ~/.gnupg/ "$BACKUP_DIR/gnupg/"
rsync -av --progress ~/.config/ "$BACKUP_DIR/config/"
rsync -av --progress ~/.dotfiles/ "$BACKUP_DIR/dotfiles/"

# Create a list of installed brew packages
brew bundle dump --file="$BACKUP_DIR/Brewfile" --force

echo "Backup complete!"
EOF

# Project initialization script
cat > ~/bin/project-init << 'EOF'
#!/usr/bin/env bash
# Initialize a new project with common files

if [ -z "$1" ]; then
    echo "Usage: project-init <project-name> [type]"
    echo "Types: node, python, go, rust"
    exit 1
fi

PROJECT_NAME=$1
PROJECT_TYPE=${2:-general}

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize git
git init

# Create common files
echo "# $PROJECT_NAME" > README.md
cp ~/.gitignore_global .gitignore
touch .env.example

# Create basic directory structure
mkdir -p src tests docs

# Type-specific initialization
case $PROJECT_TYPE in
    node)
        npm init -y
        npm install --save-dev typescript @types/node eslint prettier
        cp ~/.eslintrc.json .
        cp ~/.prettierrc .
        ;;
    python)
        python3 -m venv venv
        source venv/bin/activate
        pip install black flake8 pytest
        echo "venv/" >> .gitignore
        ;;
    go)
        go mod init "github.com/$(git config user.name)/$PROJECT_NAME"
        ;;
    rust)
        cargo init
        ;;
esac

echo "Project $PROJECT_NAME initialized!"
EOF

# Make scripts executable
chmod +x ~/bin/*

# Add ~/bin to PATH if not already there
if ! echo $PATH | grep -q "$HOME/bin"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
fi

echo "Additional configuration files created successfully!"
echo "Don't forget to:"
echo "1. Configure your SSH keys: ssh-keygen -t ed25519 -C 'your.email@example.com'"
echo "2. Add your SSH key to GitHub/GitLab"
echo "3. Set up GPG for commit signing if desired"
echo "4. Customize the configuration files to your preferences"
