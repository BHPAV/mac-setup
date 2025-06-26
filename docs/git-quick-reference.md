# Git Quick Reference for Mac Setup

## Initial Setup (One Time)

### Quick Start with Script
```bash
# Run the automated setup script
chmod +x scripts/git-init-upload.sh
./scripts/git-init-upload.sh
```

### Manual Setup
```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Initialize repository
git init
git add .
git commit -m "Initial commit"

# Create and push to GitHub
gh repo create mac-setup --public --source=. --remote=origin --push
```

## Daily Workflow

### Check Status
```bash
# See what's changed
git status

# See detailed changes
git diff

# See changes in staged files
git diff --cached
```

### Stage and Commit Changes
```bash
# Stage all changes
git add .

# Stage specific files
git add Brewfile
git add configs/shell/zshrc

# Commit with message
git commit -m "Update Zsh configuration"

# Stage and commit in one command
git commit -am "Update configurations"
```

### Push Changes
```bash
# Push to GitHub
git push

# Push a new branch
git push -u origin feature/new-configs
```

## Common Scenarios

### After Installing New Tools
```bash
# Update Brewfile
brew bundle dump --force

# Commit changes
git add Brewfile
git commit -m "Add new tools: [tool names]"
git push
```

### After Modifying Configurations
```bash
# See what changed
git status

# Review changes
git diff configs/

# Commit specific config
git add configs/terminal/warp-preferences.yaml
git commit -m "Update Warp terminal preferences"
git push
```

### Adding New Documentation
```bash
git add docs/new-guide.md
git commit -m "docs: Add guide for [topic]"
git push
```

### Creating a Feature Branch
```bash
# Create and switch to new branch
git checkout -b feature/add-rust-configs

# Make changes, then commit
git add configs/languages/rust/
git commit -m "feat: Add Rust development configs"

# Push the branch
git push -u origin feature/add-rust-configs

# Create pull request
gh pr create
```

## Commit Message Convention

Use conventional commits for clarity:

```bash
# Features
git commit -m "feat: Add Docker configuration"

# Bug fixes
git commit -m "fix: Correct path in setup script"

# Documentation
git commit -m "docs: Update README with new tools"

# Maintenance
git commit -m "chore: Update Brewfile"

# Configuration changes
git commit -m "config: Add Neovim LSP settings"

# Scripts
git commit -m "scripts: Add validation for configs"
```

## Useful Aliases

Add these to your `~/.gitconfig`:

```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.last 'log -1 HEAD'
git config --global alias.unstage 'reset HEAD --'
```

## Sync with Latest Changes

```bash
# Get latest changes
git pull

# If you have local changes
git stash
git pull
git stash pop
```

## Undo Operations

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Discard all local changes
git reset --hard HEAD

# Remove file from staging
git reset HEAD file.txt

# Revert a pushed commit
git revert [commit-hash]
```

## View History

```bash
# View commit history
git log --oneline

# View last 5 commits
git log --oneline -5

# View commits with changes
git log -p

# View commits for specific file
git log -- Brewfile
```

## Tags and Releases

```bash
# Create a version tag
git tag -a v1.0.0 -m "Initial stable release"
git push origin v1.0.0

# Create GitHub release
gh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes here"

# List tags
git tag -l
```

## Troubleshooting

### Push Rejected
```bash
# Pull and merge first
git pull origin main

# Or rebase
git pull --rebase origin main

# Then push
git push
```

### Accidentally Committed Sensitive Data
```bash
# If not pushed yet
git reset --soft HEAD~1
# Edit file to remove sensitive data
git add .
git commit -m "Remove sensitive information"

# If already pushed (requires force push)
# Use with caution!
git filter-branch --tree-filter 'rm -f path/to/sensitive/file' HEAD
git push --force
```

### Wrong Branch
```bash
# Switch back to main
git checkout main

# Move uncommitted changes to new branch
git stash
git checkout -b correct-branch
git stash pop
```

## GitHub CLI Shortcuts

```bash
# View repository in browser
gh repo view --web

# Create issue
gh issue create

# List pull requests
gh pr list

# Check workflow runs
gh run list
```

## Best Practices for Mac Setup

1. **Commit Often**: Small, logical commits are easier to manage
2. **Pull Before Push**: Always sync before pushing changes
3. **Use Branches**: Test major changes in feature branches
4. **Write Clear Messages**: Future you will thank present you
5. **Don't Commit Secrets**: Use .gitignore and review before committing

## Emergency Contacts

```bash
# Get help
git help [command]

# View this guide
cat docs/git-quick-reference.md

# View full guide
open docs/git-github-setup.md
```

Remember: Git is your friend! It keeps your configurations safe and tracks their evolution over time.
