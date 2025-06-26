#!/bin/bash

# git-commit-helper.sh - Intelligent commit message generator for mac-setup
# This script analyzes changed files and suggests appropriate commit messages

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get git status
if ! git diff --cached --name-only &> /dev/null; then
    echo "Not a git repository or no git found"
    exit 1
fi

# Check if there are staged changes
STAGED_FILES=$(git diff --cached --name-only)
if [ -z "$STAGED_FILES" ]; then
    echo -e "${YELLOW}No staged files found. Stage files with 'git add' first.${NC}"
    exit 1
fi

echo -e "${BLUE}Analyzing staged changes...${NC}\n"

# Analyze what's changed
BREWFILE_CHANGED=false
SCRIPT_CHANGED=false
CONFIG_CHANGED=false
DOC_CHANGED=false
CHANGED_CATEGORIES=""

# Check each staged file
while IFS= read -r file; do
    if [[ "$file" == "Brewfile" ]]; then
        BREWFILE_CHANGED=true
    elif [[ "$file" == scripts/* ]]; then
        SCRIPT_CHANGED=true
    elif [[ "$file" == configs/* ]]; then
        CONFIG_CHANGED=true
        # Extract config category
        if [[ "$file" =~ configs/([^/]+)/ ]]; then
            category="${BASH_REMATCH[1]}"
            if [[ ! "$CHANGED_CATEGORIES" =~ "$category" ]]; then
                CHANGED_CATEGORIES="$CHANGED_CATEGORIES $category"
            fi
        fi
    elif [[ "$file" == docs/* ]] || [[ "$file" == "README.md" ]]; then
        DOC_CHANGED=true
    fi
done <<< "$STAGED_FILES"

# Generate commit message suggestions
echo -e "${GREEN}Suggested commit messages based on your changes:${NC}\n"

if $BREWFILE_CHANGED; then
    # Try to detect what was added/removed from Brewfile
    ADDED_TOOLS=$(git diff --cached Brewfile | grep '^+[^+]' | grep -E '(brew|cask) "' | sed 's/.*"\([^"]*\)".*/\1/' | tr '\n' ', ' | sed 's/, $//')
    REMOVED_TOOLS=$(git diff --cached Brewfile | grep '^-[^-]' | grep -E '(brew|cask) "' | sed 's/.*"\([^"]*\)".*/\1/' | tr '\n' ', ' | sed 's/, $//')
    
    if [ -n "$ADDED_TOOLS" ]; then
        echo "feat: Add new tools to Brewfile"
        echo -e "   ${YELLOW}Added: $ADDED_TOOLS${NC}"
    fi
    if [ -n "$REMOVED_TOOLS" ]; then
        echo "chore: Remove tools from Brewfile"  
        echo -e "   ${YELLOW}Removed: $REMOVED_TOOLS${NC}"
    fi
    if [ -z "$ADDED_TOOLS" ] && [ -z "$REMOVED_TOOLS" ]; then
        echo "chore: Update Brewfile"
    fi
    echo
fi

if $SCRIPT_CHANGED; then
    # Check which scripts changed
    CHANGED_SCRIPTS=$(echo "$STAGED_FILES" | grep '^scripts/' | xargs -I {} basename {} | tr '\n' ', ' | sed 's/, $//')
    echo "scripts: Update $CHANGED_SCRIPTS"
    
    # Specific script messages
    if echo "$STAGED_FILES" | grep -q "setup.sh"; then
        echo "feat: Update main setup script"
    fi
    if echo "$STAGED_FILES" | grep -q "config-manager"; then
        echo "feat: Enhance Configuration Manager"
    fi
    if echo "$STAGED_FILES" | grep -q "validate"; then
        echo "scripts: Add/update validation scripts"
    fi
    echo
fi

if $CONFIG_CHANGED; then
    # Generate messages based on config categories
    for category in $CHANGED_CATEGORIES; do
        case $category in
            shell)
                echo "config: Update shell configurations"
                ;;
            terminal)
                echo "config: Update terminal emulator configs"
                ;;
            editors)
                echo "config: Update editor configurations"
                ;;
            git)
                echo "config: Update Git configuration"
                ;;
            languages)
                echo "config: Update programming language configs"
                ;;
            database)
                echo "config: Update database tool configurations"
                ;;
            cloud)
                echo "config: Update cloud tool configurations"
                ;;
            *)
                echo "config: Update $category configurations"
                ;;
        esac
    done
    echo
fi

if $DOC_CHANGED; then
    # Check which docs changed
    if echo "$STAGED_FILES" | grep -q "README.md"; then
        echo "docs: Update README"
    fi
    if echo "$STAGED_FILES" | grep -q "docs/"; then
        CHANGED_DOCS=$(echo "$STAGED_FILES" | grep '^docs/' | xargs -I {} basename {} .md | tr '\n' ', ' | sed 's/, $//')
        echo "docs: Update documentation ($CHANGED_DOCS)"
    fi
    echo
fi

# Show staged files
echo -e "${BLUE}Staged files:${NC}"
git status --short | grep '^[AM]'
echo

# Interactive commit
read -p "Enter your commit message (or press Enter to exit): " commit_msg

if [ -n "$commit_msg" ]; then
    git commit -m "$commit_msg"
    echo -e "\n${GREEN}✓ Committed successfully!${NC}"
else
    echo -e "\n${YELLOW}Commit cancelled. Your changes are still staged.${NC}"
fi
