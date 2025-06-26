#!/usr/bin/env bash

# Mac Setup Configuration Manager - Shell Version
# Interactive TUI for selecting and deploying configurations
# Uses dialog/whiptail for UI (falls back to basic menus if not available)

set -e

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIGS_DIR="$PROJECT_ROOT/configs"
BACKUP_DIR="$PROJECT_ROOT/.config-backups"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for dialog or whiptail
if command -v dialog &> /dev/null; then
    DIALOG_CMD="dialog"
elif command -v whiptail &> /dev/null; then
    DIALOG_CMD="whiptail"
else
    DIALOG_CMD=""
fi

# Configuration definitions
declare -A CONFIG_CATEGORIES=(
    ["shell"]="Shell Configurations"
    ["terminal"]="Terminal Emulators"
    ["editors"]="Text Editors & IDEs"
    ["dev-tools"]="Development Tools"
    ["languages"]="Programming Languages"
    ["database"]="Database Tools"
    ["cloud"]="Cloud & DevOps"
    ["monitoring"]="Monitoring & Search"
    ["system"]="System Utilities"
    ["security"]="Security Tools"
)

# Configuration mappings
declare -A CONFIGS
declare -A CONFIG_DEST
declare -A CONFIG_DESC
declare -A CONFIG_REQUIRES

# Shell configurations
CONFIGS["shell,starship"]="shell/starship.toml"
CONFIG_DEST["shell,starship"]="$HOME/.config/starship.toml"
CONFIG_DESC["shell,starship"]="Fast, customizable prompt"
CONFIG_REQUIRES["shell,starship"]="starship"

CONFIGS["shell,bash"]="shell/bashrc"
CONFIG_DEST["shell,bash"]="$HOME/.bashrc"
CONFIG_DESC["shell,bash"]="Bash configuration"
CONFIG_REQUIRES["shell,bash"]="bash"

CONFIGS["shell,fish"]="shell/config.fish"
CONFIG_DEST["shell,fish"]="$HOME/.config/fish/config.fish"
CONFIG_DESC["shell,fish"]="Fish shell configuration"
CONFIG_REQUIRES["shell,fish"]="fish"

CONFIGS["shell,zsh"]="shell/zshrc"
CONFIG_DEST["shell,zsh"]="$HOME/.zshrc"
CONFIG_DESC["shell,zsh"]="Zsh configuration"
CONFIG_REQUIRES["shell,zsh"]="zsh"

# Terminal configurations
CONFIGS["terminal,alacritty"]="terminal/alacritty.yml"
CONFIG_DEST["terminal,alacritty"]="$HOME/.config/alacritty/alacritty.yml"
CONFIG_DESC["terminal,alacritty"]="GPU-accelerated terminal"
CONFIG_REQUIRES["terminal,alacritty"]="alacritty"

CONFIGS["terminal,kitty"]="terminal/kitty.conf"
CONFIG_DEST["terminal,kitty"]="$HOME/.config/kitty/kitty.conf"
CONFIG_DESC["terminal,kitty"]="Feature-rich GPU terminal"
CONFIG_REQUIRES["terminal,kitty"]="kitty"

CONFIGS["terminal,tmux"]="terminal/tmux.conf"
CONFIG_DEST["terminal,tmux"]="$HOME/.tmux.conf"
CONFIG_DESC["terminal,tmux"]="Terminal multiplexer"
CONFIG_REQUIRES["terminal,tmux"]="tmux"

# Editor configurations
CONFIGS["editors,neovim"]="editors/init.lua"
CONFIG_DEST["editors,neovim"]="$HOME/.config/nvim/init.lua"
CONFIG_DESC["editors,neovim"]="Modern Neovim with LSP"
CONFIG_REQUIRES["editors,neovim"]="nvim"

CONFIGS["editors,vscode"]="editors/vscode-settings.json"
CONFIG_DEST["editors,vscode"]="$HOME/Library/Application Support/Code/User/settings.json"
CONFIG_DESC["editors,vscode"]="VS Code settings"
CONFIG_REQUIRES["editors,vscode"]="code"

# Git configurations
CONFIGS["dev-tools,git"]="git/gitconfig"
CONFIG_DEST["dev-tools,git"]="$HOME/.gitconfig"
CONFIG_DESC["dev-tools,git"]="Git configuration"
CONFIG_REQUIRES["dev-tools,git"]="git"

CONFIGS["dev-tools,gitignore"]="git/gitignore_global"
CONFIG_DEST["dev-tools,gitignore"]="$HOME/.gitignore_global"
CONFIG_DESC["dev-tools,gitignore"]="Global Git ignores"
CONFIG_REQUIRES["dev-tools,gitignore"]="git"

CONFIGS["dev-tools,lazygit"]="dev-tools/lazygit.yml"
CONFIG_DEST["dev-tools,lazygit"]="$HOME/.config/lazygit/config.yml"
CONFIG_DESC["dev-tools,lazygit"]="Terminal UI for Git"
CONFIG_REQUIRES["dev-tools,lazygit"]="lazygit"

# Database configurations
CONFIGS["database,postgresql"]="database/psqlrc"
CONFIG_DEST["database,postgresql"]="$HOME/.psqlrc"
CONFIG_DESC["database,postgresql"]="PostgreSQL client"
CONFIG_REQUIRES["database,postgresql"]="psql"

# Cloud configurations
CONFIGS["cloud,aws"]="cloud/aws-config"
CONFIG_DEST["cloud,aws"]="$HOME/.aws/config"
CONFIG_DESC["cloud,aws"]="AWS CLI configuration"
CONFIG_REQUIRES["cloud,aws"]="aws"

# Security configurations
CONFIGS["security,ssh"]="security/ssh_config"
CONFIG_DEST["security,ssh"]="$HOME/.ssh/config"
CONFIG_DESC["security,ssh"]="SSH client config"
CONFIG_REQUIRES["security,ssh"]="ssh"

# Helper functions
print_header() {
    clear
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Mac Setup Configuration Manager${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

check_installed() {
    local dest="$1"
    if [[ -f "$dest" ]]; then
        return 0
    else
        return 1
    fi
}

check_requirements() {
    local requires="$1"
    if [[ -z "$requires" ]]; then
        return 0
    fi
    
    command -v "$requires" &> /dev/null
}

create_backup() {
    local file="$1"
    local backup_name
    
    if [[ ! -f "$file" ]]; then
        return 0
    fi
    
    mkdir -p "$BACKUP_DIR"
    backup_name="$(basename "$file").$(date +%Y%m%d_%H%M%S).bak"
    
    if cp "$file" "$BACKUP_DIR/$backup_name"; then
        echo -e "${GREEN}✓${NC} Backed up $(basename "$file")"
        return 0
    else
        echo -e "${RED}✗${NC} Failed to backup $(basename "$file")"
        return 1
    fi
}

deploy_config() {
    local source="$1"
    local dest="$2"
    local name="$3"
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"
    
    # Create backup if file exists
    if [[ -f "$dest" ]]; then
        create_backup "$dest"
    fi
    
    # Deploy the configuration
    if cp "$CONFIGS_DIR/$source" "$dest"; then
        echo -e "${GREEN}✓${NC} Deployed $name"
        return 0
    else
        echo -e "${RED}✗${NC} Failed to deploy $name"
        return 1
    fi
}

# Dialog-based UI functions
show_category_menu() {
    local options=()
    local category
    
    for category in "${!CONFIG_CATEGORIES[@]}"; do
        options+=("$category" "${CONFIG_CATEGORIES[$category]}")
    done
    
    if [[ -n "$DIALOG_CMD" ]]; then
        $DIALOG_CMD --clear --title "Configuration Categories" \
            --menu "Select a category:" 20 60 10 \
            "${options[@]}" 2>&1 >/dev/tty
    else
        # Fallback to select menu
        echo "Select a category:"
        select opt in "${CONFIG_CATEGORIES[@]}" "Back"; do
            if [[ "$opt" == "Back" ]]; then
                echo ""
                return
            elif [[ -n "$opt" ]]; then
                for key in "${!CONFIG_CATEGORIES[@]}"; do
                    if [[ "${CONFIG_CATEGORIES[$key]}" == "$opt" ]]; then
                        echo "$key"
                        return
                    fi
                done
            fi
        done
    fi
}

show_config_checklist() {
    local category="$1"
    local options=()
    local key
    local selected=()
    
    # Build options for the category
    for key in "${!CONFIGS[@]}"; do
        if [[ "$key" == "$category,"* ]]; then
            local name="${key#*,}"
            local dest="${CONFIG_DEST[$key]}"
            local desc="${CONFIG_DESC[$key]}"
            local status="NEW"
            
            if check_installed "$dest"; then
                status="INSTALLED"
            fi
            
            options+=("$name" "$desc [$status]" "off")
        fi
    done
    
    if [[ ${#options[@]} -eq 0 ]]; then
        echo "No configurations found for $category"
        read -p "Press Enter to continue..."
        return
    fi
    
    if [[ -n "$DIALOG_CMD" ]]; then
        selected=$($DIALOG_CMD --clear --title "${CONFIG_CATEGORIES[$category]}" \
            --checklist "Select configurations to deploy:" 20 70 10 \
            "${options[@]}" 2>&1 >/dev/tty)
    else
        # Fallback to basic selection
        echo -e "\n${BLUE}${CONFIG_CATEGORIES[$category]}${NC}"
        echo "Select configurations to deploy (space-separated numbers):"
        
        local i=1
        local items=()
        for ((i=0; i<${#options[@]}; i+=3)); do
            local num=$((i/3 + 1))
            local name="${options[$i]}"
            local desc="${options[$i+1]}"
            items+=("$name")
            echo "$num) $name - $desc"
        done
        
        read -p "Selection: " selection
        for num in $selection; do
            if [[ $num -gt 0 && $num -le ${#items[@]} ]]; then
                selected+="${items[$((num-1))]} "
            fi
        done
    fi
    
    # Deploy selected configurations
    if [[ -n "$selected" ]]; then
        echo -e "\n${BLUE}Deploying selected configurations...${NC}\n"
        
        for name in $selected; do
            local key="$category,$name"
            local source="${CONFIGS[$key]}"
            local dest="${CONFIG_DEST[$key]}"
            local requires="${CONFIG_REQUIRES[$key]}"
            
            # Remove quotes if present
            name="${name//\"/}"
            
            # Check requirements
            if ! check_requirements "$requires"; then
                echo -e "${YELLOW}⚠${NC}  $name requires '$requires' (not found)"
                continue
            fi
            
            # Check if source exists
            if [[ ! -f "$CONFIGS_DIR/$source" ]]; then
                echo -e "${RED}✗${NC} Source not found for $name"
                continue
            fi
            
            deploy_config "$source" "$dest" "$name"
        done
        
        echo
        read -p "Press Enter to continue..."
    fi
}

show_all_configs() {
    echo -e "${BLUE}All Available Configurations${NC}\n"
    
    for category in "${!CONFIG_CATEGORIES[@]}"; do
        echo -e "${YELLOW}${CONFIG_CATEGORIES[$category]}:${NC}"
        
        for key in "${!CONFIGS[@]}"; do
            if [[ "$key" == "$category,"* ]]; then
                local name="${key#*,}"
                local dest="${CONFIG_DEST[$key]}"
                local status="${RED}✗${NC}"
                
                if check_installed "$dest"; then
                    status="${GREEN}✓${NC}"
                fi
                
                echo -e "  $status $name"
            fi
        done
        echo
    done
    
    read -p "Press Enter to continue..."
}

check_all_requirements() {
    echo -e "${BLUE}Checking Requirements${NC}\n"
    
    local missing=()
    
    for key in "${!CONFIG_REQUIRES[@]}"; do
        local requires="${CONFIG_REQUIRES[$key]}"
        local name="${key#*,}"
        local category="${key%,*}"
        
        if [[ -n "$requires" ]] && ! check_requirements "$requires"; then
            echo -e "${RED}✗${NC} $name requires '$requires'"
            missing+=("$requires")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        # Remove duplicates
        local unique=($(printf "%s\n" "${missing[@]}" | sort -u))
        echo -e "\n${YELLOW}Install missing tools with:${NC}"
        echo "brew install ${unique[*]}"
    else
        echo -e "${GREEN}All requirements satisfied!${NC}"
    fi
    
    echo
    read -p "Press Enter to continue..."
}

backup_all_installed() {
    echo -e "${BLUE}Backing up installed configurations...${NC}\n"
    
    local count=0
    
    for key in "${!CONFIG_DEST[@]}"; do
        local dest="${CONFIG_DEST[$key]}"
        local name="${key#*,}"
        
        if [[ -f "$dest" ]]; then
            if create_backup "$dest"; then
                ((count++))
            fi
        fi
    done
    
    echo -e "\n${GREEN}Created $count backups in $BACKUP_DIR${NC}"
    read -p "Press Enter to continue..."
}

# Main menu
main_menu() {
    while true; do
        print_header
        
        echo "1) Browse by Category"
        echo "2) Deploy All in Category"
        echo "3) Show All Configurations"
        echo "4) Check Requirements"
        echo "5) Backup Installed Configs"
        echo "6) Quick Deploy Common"
        echo "q) Quit"
        echo
        read -p "Select option: " choice
        
        case $choice in
            1)
                category=$(show_category_menu)
                if [[ -n "$category" ]]; then
                    show_config_checklist "$category"
                fi
                ;;
            2)
                category=$(show_category_menu)
                if [[ -n "$category" ]]; then
                    echo -e "\n${BLUE}Deploying all configurations in ${CONFIG_CATEGORIES[$category]}...${NC}\n"
                    
                    for key in "${!CONFIGS[@]}"; do
                        if [[ "$key" == "$category,"* ]]; then
                            local name="${key#*,}"
                            local source="${CONFIGS[$key]}"
                            local dest="${CONFIG_DEST[$key]}"
                            local requires="${CONFIG_REQUIRES[$key]}"
                            
                            if ! check_requirements "$requires"; then
                                echo -e "${YELLOW}⚠${NC}  $name requires '$requires' (not found)"
                                continue
                            fi
                            
                            if [[ -f "$CONFIGS_DIR/$source" ]]; then
                                deploy_config "$source" "$dest" "$name"
                            fi
                        fi
                    done
                    
                    echo
                    read -p "Press Enter to continue..."
                fi
                ;;
            3)
                show_all_configs
                ;;
            4)
                check_all_requirements
                ;;
            5)
                backup_all_installed
                ;;
            6)
                # Quick deploy common configurations
                echo -e "\n${BLUE}Quick Deploy Common Configurations${NC}\n"
                
                common_configs=(
                    "dev-tools,git"
                    "dev-tools,gitignore"
                    "shell,zsh"
                    "shell,starship"
                    "terminal,tmux"
                )
                
                for key in "${common_configs[@]}"; do
                    if [[ -n "${CONFIGS[$key]}" ]]; then
                        local name="${key#*,}"
                        local source="${CONFIGS[$key]}"
                        local dest="${CONFIG_DEST[$key]}"
                        local requires="${CONFIG_REQUIRES[$key]}"
                        
                        if check_requirements "$requires" && [[ -f "$CONFIGS_DIR/$source" ]]; then
                            deploy_config "$source" "$dest" "$name"
                        fi
                    fi
                done
                
                echo
                read -p "Press Enter to continue..."
                ;;
            q|Q)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option"
                sleep 1
                ;;
        esac
    done
}

# Script entry point
main() {
    # Check if configs directory exists
    if [[ ! -d "$CONFIGS_DIR" ]]; then
        echo -e "${RED}Error: Configs directory not found at $CONFIGS_DIR${NC}"
        exit 1
    fi
    
    # Run main menu
    main_menu
}

# Run main function
main "$@"
