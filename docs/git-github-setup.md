# Git and GitHub Setup Guide

This guide provides detailed instructions for initializing a Git repository and uploading your Mac setup to GitHub.

## Prerequisites

Before starting, ensure you have:
- Git installed (`brew install git`)
- A GitHub account (create one at https://github.com)
- GitHub CLI installed (`brew install gh`) - optional but recommended

## Step 1: Configure Git

First, set up your Git identity:

```bash
# Set your name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify your configuration
git config --global --list
```

## Step 2: Generate SSH Key (Recommended)

Using SSH keys is more secure than HTTPS authentication:

```bash
# Generate a new SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# When prompted:
# - Press Enter to accept default file location
# - Enter a secure passphrase (optional but recommended)

# Start the SSH agent
eval "$(ssh-agent -s)"

# Add your SSH key to the agent
ssh-add ~/.ssh/id_ed25519

# Copy the public key to clipboard
pbcopy < ~/.ssh/id_ed25519.pub
```

## Step 3: Add SSH Key to GitHub

### Option A: Using GitHub CLI (Easiest)
```bash
# Authenticate with GitHub CLI
gh auth login

# Select:
# - GitHub.com
# - SSH
# - Use existing SSH key
# - Select your key
# - Login with browser
```

### Option B: Manual Method
1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Title: "MacBook M4 Max" (or your machine name)
4. Key type: "Authentication Key"
5. Paste your public key (already in clipboard)
6. Click "Add SSH key"

## Step 4: Initialize Local Repository

Navigate to your mac-setup directory and initialize Git:

```bash
cd ~/path/to/mac-setup

# Initialize Git repository
git init

# Check current status
git status
```

## Step 5: Create .gitignore

Create a `.gitignore` file to exclude sensitive or unnecessary files:

```bash
cat > .gitignore << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*

# Thumbnails
Thumbs.db

# Environment files
.env
.env.local
.env.*.local

# Logs
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Dependencies
node_modules/
.npm
.yarn

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
ENV/
.venv

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# Temporary files
*.tmp
*.temp
*.bak
*.backup
*.old

# Private/Sensitive
secrets/
private/
*.pem
*.key
id_rsa*
id_ed25519*

# Neo4j credentials if stored locally
neo4j-credentials.txt
*-password.txt

# Custom exclusions for mac-setup
configs/private/
configs/work/
.env.production
EOF

# Review the .gitignore
cat .gitignore
```

## Step 6: Prepare for First Commit

Review and stage your files:

```bash
# See what will be included
git status

# Add all files (respecting .gitignore)
git add .

# Or add specific files/directories
git add README.md
git add scripts/
git add configs/
git add docs/
git add Brewfile

# Review what's staged
git status
git diff --cached
```

## Step 7: Make First Commit

```bash
# Create your initial commit
git commit -m "Initial commit: MacBook M4 Max development setup

- Automated setup script for development environment
- Configuration Manager TUI for easy config deployment
- 50+ configuration files for various tools
- Comprehensive documentation
- Knowledge graph integration
- Validation scripts for Brewfile consistency"

# Verify the commit
git log --oneline
```

## Step 8: Create GitHub Repository

### Option A: Using GitHub CLI (Recommended)
```bash
# Create a new repository
gh repo create mac-setup --public --description "MacBook M4 Max development environment setup with automated scripts and configurations"

# This will:
# - Create the repository on GitHub
# - Add it as 'origin' remote
# - Set up tracking
```

### Option B: Using Web Interface
1. Go to https://github.com/new
2. Repository name: `mac-setup`
3. Description: "MacBook M4 Max development environment setup with automated scripts and configurations"
4. Choose: Public or Private
5. DO NOT initialize with README, .gitignore, or license
6. Click "Create repository"

Then add the remote:
```bash
# Replace 'yourusername' with your GitHub username
git remote add origin git@github.com:yourusername/mac-setup.git
```

## Step 9: Push to GitHub

```bash
# Push your main branch
git push -u origin main

# If your default branch is 'master', rename it first:
git branch -M main
git push -u origin main
```

## Step 10: Verify Upload

```bash
# Open repository in browser
gh repo view --web

# Or manually visit:
# https://github.com/yourusername/mac-setup
```

## Best Practices for Mac Setup Repository

### 1. Security Considerations
```bash
# Never commit sensitive information
# Before each commit, review:
git diff --cached

# If you accidentally commit sensitive data:
# Remove it from history (before pushing!)
git reset --soft HEAD~1
# Edit files to remove sensitive data
git add .
git commit -m "Remove sensitive information"
```

### 2. Organizing Commits
```bash
# Make logical, atomic commits
git add scripts/
git commit -m "feat: Add validation scripts for Brewfile"

git add docs/git-github-setup.md
git commit -m "docs: Add Git and GitHub setup instructions"

git add configs/terminal/warp-preferences.yaml
git commit -m "config: Add Warp terminal preferences"
```

### 3. Using Branches
```bash
# Create a feature branch
git checkout -b feature/add-rust-configs

# Make changes and commit
git add configs/languages/rust/
git commit -m "feat: Add Rust development configurations"

# Push the branch
git push -u origin feature/add-rust-configs

# Create a pull request
gh pr create --title "Add Rust development configurations" --body "Adds cargo config and rustfmt settings"
```

### 4. Keeping Repository Updated
```bash
# Regular maintenance
git pull origin main
brew bundle dump --force  # Update Brewfile
git add Brewfile
git commit -m "chore: Update Brewfile with latest packages"
git push
```

### 5. Tags and Releases
```bash
# Create a version tag
git tag -a v1.0.0 -m "Initial stable release"
git push origin v1.0.0

# Create a GitHub release
gh release create v1.0.0 --title "Mac Setup v1.0.0" --notes "Initial release with full configuration set"
```

## Troubleshooting

### SSH Connection Issues
```bash
# Test SSH connection
ssh -T git@github.com

# If it fails, check:
# 1. SSH key is added to agent
ssh-add -l

# 2. Correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Push Rejected
```bash
# If push is rejected, pull first:
git pull origin main --rebase
git push

# Or if you're sure your version is correct:
git push --force-with-lease
```

### Large File Issues
```bash
# If you have large files, use Git LFS
brew install git-lfs
git lfs install

# Track large files
git lfs track "*.dmg"
git lfs track "*.pkg"
git add .gitattributes
git commit -m "Configure Git LFS"
```

## Additional Resources

- [GitHub Documentation](https://docs.github.com)
- [Pro Git Book](https://git-scm.com/book)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Conventional Commits](https://www.conventionalcommits.org/)

## Quick Reference Commands

```bash
# Initialize and upload in one go (after SSH setup)
cd ~/mac-setup
git init
git add .
git commit -m "Initial commit"
gh repo create mac-setup --public --source=. --remote=origin --push
```

Remember to regularly commit and push your changes to keep your configurations backed up and version controlled!
