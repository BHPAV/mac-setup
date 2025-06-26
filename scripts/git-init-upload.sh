#!/bin/bash

# git-init-upload.sh - Automated Git initialization and GitHub upload script
# This script helps automate the process of initializing a Git repository
# and uploading it to GitHub for the mac-setup project

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check for git
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed. Please run: brew install git"
        exit 1
    fi
    print_success "Git is installed"
    
    # Check for gh (optional but recommended)
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI is not installed. Install with: brew install gh"
        echo "You can still continue, but some features will be unavailable."
        read -p "Continue without GitHub CLI? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        GH_AVAILABLE=false
    else
        print_success "GitHub CLI is installed"
        GH_AVAILABLE=true
    fi
}

configure_git() {
    print_header "Git Configuration"
    
    # Check if already configured
    if git config --global user.name &> /dev/null && git config --global user.email &> /dev/null; then
        echo "Current Git configuration:"
        echo "  Name: $(git config --global user.name)"
        echo "  Email: $(git config --global user.email)"
        read -p "Keep current configuration? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_success "Using existing Git configuration"
            return
        fi
    fi
    
    # Configure Git
    read -p "Enter your full name: " git_name
    read -p "Enter your email: " git_email
    
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    
    print_success "Git configured successfully"
}

setup_ssh_key() {
    print_header "SSH Key Setup"
    
    SSH_KEY="$HOME/.ssh/id_ed25519"
    
    # Check if SSH key already exists
    if [ -f "$SSH_KEY" ]; then
        print_warning "SSH key already exists at $SSH_KEY"
        read -p "Use existing SSH key? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_success "Using existing SSH key"
            return
        fi
    fi
    
    # Generate new SSH key
    echo "Generating new SSH key..."
    ssh-keygen -t ed25519 -C "$(git config --global user.email)" -f "$SSH_KEY"
    
    # Start SSH agent and add key
    eval "$(ssh-agent -s)" &> /dev/null
    ssh-add "$SSH_KEY"
    
    print_success "SSH key generated and added to agent"
    
    # Copy to clipboard
    if command -v pbcopy &> /dev/null; then
        pbcopy < "$SSH_KEY.pub"
        print_success "Public key copied to clipboard"
    else
        echo "Public key:"
        cat "$SSH_KEY.pub"
    fi
    
    # Add to GitHub if gh is available
    if [ "$GH_AVAILABLE" = true ]; then
        read -p "Add SSH key to GitHub now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh auth login
        fi
    else
        echo
        print_warning "Please add the SSH key to GitHub manually:"
        echo "1. Go to https://github.com/settings/keys"
        echo "2. Click 'New SSH key'"
        echo "3. Paste the key (already in clipboard)"
        echo
        read -p "Press Enter when you've added the key to GitHub..."
    fi
}

create_gitignore() {
    print_header "Creating .gitignore"
    
    if [ -f .gitignore ]; then
        print_warning ".gitignore already exists"
        read -p "Overwrite? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
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
    
    print_success ".gitignore created"
}

initialize_repository() {
    print_header "Initializing Git Repository"
    
    # Check if already a git repository
    if [ -d .git ]; then
        print_warning "This is already a Git repository"
        read -p "Reinitialize? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
        rm -rf .git
    fi
    
    # Initialize repository
    git init
    print_success "Git repository initialized"
    
    # Create .gitignore if it doesn't exist
    if [ ! -f .gitignore ]; then
        create_gitignore
    fi
    
    # Add files
    echo "Adding files to repository..."
    git add .
    
    # Show status
    echo
    echo "Files to be committed:"
    git status --short
    echo
    
    read -p "Proceed with initial commit? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Skipping commit. You can commit manually later."
        return
    fi
    
    # Make initial commit
    git commit -m "Initial commit: MacBook M4 Max development setup

- Automated setup script for development environment
- Configuration Manager TUI for easy config deployment  
- 50+ configuration files for various tools
- Comprehensive documentation
- Knowledge graph integration
- Validation scripts for Brewfile consistency"
    
    print_success "Initial commit created"
}

create_github_repo() {
    print_header "Creating GitHub Repository"
    
    if [ "$GH_AVAILABLE" = false ]; then
        print_warning "GitHub CLI not available. Please create the repository manually:"
        echo "1. Go to https://github.com/new"
        echo "2. Name: mac-setup"
        echo "3. Do NOT initialize with README, .gitignore, or license"
        echo "4. Create repository"
        echo
        read -p "Enter your GitHub username: " github_username
        echo
        echo "After creating, run:"
        echo "  git remote add origin git@github.com:$github_username/mac-setup.git"
        echo "  git branch -M main"
        echo "  git push -u origin main"
        return
    fi
    
    # Check if remote already exists
    if git remote get-url origin &> /dev/null; then
        print_warning "Remote 'origin' already exists"
        git remote -v
        read -p "Continue with existing remote? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    # Get repository details
    read -p "Repository name (default: mac-setup): " repo_name
    repo_name=${repo_name:-mac-setup}
    
    read -p "Make repository public? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        visibility="--public"
    else
        visibility="--private"
    fi
    
    # Create repository
    echo "Creating GitHub repository..."
    if gh repo create "$repo_name" $visibility \
        --description "MacBook M4 Max development environment setup with automated scripts and configurations" \
        --source=. \
        --remote=origin; then
        print_success "GitHub repository created successfully"
    else
        print_error "Failed to create GitHub repository"
        return 1
    fi
}

push_to_github() {
    print_header "Pushing to GitHub"
    
    # Ensure we're on main branch
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        print_warning "Renaming branch from '$current_branch' to 'main'"
        git branch -M main
    fi
    
    # Push to GitHub
    echo "Pushing to GitHub..."
    if git push -u origin main; then
        print_success "Successfully pushed to GitHub"
        
        # Open in browser if gh is available
        if [ "$GH_AVAILABLE" = true ]; then
            read -p "Open repository in browser? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                gh repo view --web
            fi
        fi
    else
        print_error "Failed to push to GitHub"
        echo "You may need to push manually with: git push -u origin main"
    fi
}

main() {
    echo -e "${BLUE}Mac Setup - Git & GitHub Initialization Script${NC}"
    echo "This script will help you initialize Git and upload to GitHub"
    echo
    
    # Check we're in the right directory
    if [ ! -f "Brewfile" ] || [ ! -d "scripts" ] || [ ! -d "configs" ]; then
        print_error "This doesn't appear to be the mac-setup directory"
        print_error "Please run this script from the root of your mac-setup project"
        exit 1
    fi
    
    check_prerequisites
    configure_git
    setup_ssh_key
    initialize_repository
    create_github_repo
    push_to_github
    
    print_header "Setup Complete!"
    echo "Your mac-setup repository is now on GitHub."
    echo
    echo "Next steps:"
    echo "  - Regularly commit and push your configuration changes"
    echo "  - Consider creating releases for major updates"
    echo "  - Share the repository URL with other machines"
    echo
    echo "Useful commands:"
    echo "  git status          # Check what's changed"
    echo "  git add .           # Stage all changes"
    echo "  git commit -m '...' # Commit changes"
    echo "  git push            # Push to GitHub"
    echo
    print_success "Happy coding!"
}

# Run main function
main
