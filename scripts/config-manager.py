#!/usr/bin/env python3
"""
Mac Setup Configuration Manager
Interactive TUI for selecting and deploying configurations
"""

import os
import sys
import json
import shutil
import subprocess
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Tuple, Optional
import argparse

try:
    from rich.console import Console
    from rich.table import Table
    from rich.panel import Panel
    from rich.prompt import Prompt, Confirm
    from rich.layout import Layout
    from rich.live import Live
    from rich.text import Text
    from rich.progress import Progress, SpinnerColumn, TextColumn
    from rich.tree import Tree
    from rich import box
    from rich.columns import Columns
except ImportError:
    print("Error: This script requires the 'rich' library.")
    print("Please install it with: pip3 install rich")
    sys.exit(1)

console = Console()

class ConfigItem:
    """Represents a configuration item"""
    def __init__(self, name: str, source: str, dest: str, category: str, 
                 description: str = "", requires: List[str] = None):
        self.name = name
        self.source = source
        self.dest = dest
        self.category = category
        self.description = description
        self.requires = requires or []
        self.selected = False
        self.installed = False
        self.backup_path = None
        
    def check_installed(self):
        """Check if configuration is already installed"""
        dest_path = Path(self.dest).expanduser()
        self.installed = dest_path.exists()
        return self.installed

class ConfigManager:
    """Main configuration manager"""
    
    def __init__(self, base_path: str = "."):
        self.base_path = Path(base_path)
        self.configs_dir = self.base_path / "configs"
        self.backup_dir = self.base_path / ".config-backups"
        self.configs: Dict[str, List[ConfigItem]] = {}
        self.load_configurations()
        
    def load_configurations(self):
        """Load all available configurations"""
        # Define all configurations with their mappings
        config_definitions = {
            "shell": [
                ConfigItem("Starship Prompt", "shell/starship.toml", "~/.config/starship.toml", 
                          "shell", "Fast, customizable prompt for any shell", ["starship"]),
                ConfigItem("Bash Configuration", "shell/bashrc", "~/.bashrc", 
                          "shell", "Bash shell configuration with aliases and functions", ["bash"]),
                ConfigItem("Bash Profile", "shell/bash_profile", "~/.bash_profile", 
                          "shell", "Bash login shell configuration", ["bash"]),
                ConfigItem("Fish Shell", "shell/config.fish", "~/.config/fish/config.fish", 
                          "shell", "User-friendly shell with autosuggestions", ["fish"]),
                ConfigItem("Zsh Configuration", "shell/zshrc", "~/.zshrc", 
                          "shell", "Z shell configuration with oh-my-zsh", ["zsh"]),
            ],
            "terminal": [
                ConfigItem("Alacritty", "terminal/alacritty.yml", "~/.config/alacritty/alacritty.yml", 
                          "terminal", "GPU-accelerated terminal emulator", ["alacritty"]),
                ConfigItem("Kitty", "terminal/kitty.conf", "~/.config/kitty/kitty.conf", 
                          "terminal", "Feature-rich GPU terminal", ["kitty"]),
                ConfigItem("WezTerm", "terminal/wezterm.lua", "~/.config/wezterm/wezterm.lua", 
                          "terminal", "GPU-accelerated cross-platform terminal", ["wezterm"]),
                ConfigItem("tmux", "terminal/tmux.conf", "~/.tmux.conf", 
                          "terminal", "Terminal multiplexer configuration", ["tmux"]),
                ConfigItem("Warp", "terminal/warp-preferences.yaml", "~/.warp/preferences.yaml", 
                          "terminal", "Modern terminal with AI features", ["warp"]),
            ],
            "editors": [
                ConfigItem("Neovim", "editors/init.lua", "~/.config/nvim/init.lua", 
                          "editors", "Modern Neovim config with LSP and plugins", ["neovim"]),
                ConfigItem("Vim", "editors/vimrc", "~/.vimrc", 
                          "editors", "Classic Vim configuration", ["vim"]),
                ConfigItem("VS Code Settings", "editors/vscode-settings.json", 
                          "~/Library/Application Support/Code/User/settings.json", 
                          "editors", "Visual Studio Code settings", ["code"]),
                ConfigItem("VS Code Keybindings", "editors/vscode-keybindings.json", 
                          "~/Library/Application Support/Code/User/keybindings.json", 
                          "editors", "VS Code keyboard shortcuts", ["code"]),
                ConfigItem("Helix", "editors/helix-config.toml", "~/.config/helix/config.toml", 
                          "editors", "Post-modern modal text editor", ["helix"]),
            ],
            "dev-tools": [
                ConfigItem("Git", "git/gitconfig", "~/.gitconfig", 
                          "dev-tools", "Git version control configuration", ["git"]),
                ConfigItem("Git Ignore", "git/gitignore_global", "~/.gitignore_global", 
                          "dev-tools", "Global Git ignore patterns", ["git"]),
                ConfigItem("Git Message", "git/gitmessage", "~/.gitmessage", 
                          "dev-tools", "Git commit message template", ["git"]),
                ConfigItem("Lazygit", "dev-tools/lazygit.yml", "~/.config/lazygit/config.yml", 
                          "dev-tools", "Terminal UI for git", ["lazygit"]),
                ConfigItem("GitHub CLI", "dev-tools/gh-config.yml", "~/.config/gh/config.yml", 
                          "dev-tools", "GitHub command line tool config", ["gh"]),
                ConfigItem("Direnv", "dev-tools/direnvrc", "~/.config/direnv/direnvrc", 
                          "dev-tools", "Directory-based environments", ["direnv"]),
            ],
            "languages": [
                ConfigItem("Rust/Cargo", "languages/cargo-config.toml", "~/.cargo/config.toml", 
                          "languages", "Rust package manager configuration", ["rust"]),
                ConfigItem("NPM", "languages/npmrc", "~/.npmrc", 
                          "languages", "Node.js package manager config", ["node"]),
                ConfigItem("Python pip", "languages/pip.conf", "~/.pip/pip.conf", 
                          "languages", "Python package installer config", ["python3"]),
                ConfigItem("Poetry", "languages/poetry-config.toml", "~/.config/pypoetry/config.toml", 
                          "languages", "Python dependency management", ["poetry"]),
            ],
            "database": [
                ConfigItem("PostgreSQL", "database/psqlrc", "~/.psqlrc", 
                          "database", "PostgreSQL client configuration", ["postgresql"]),
                ConfigItem("MySQL", "database/my.cnf", "~/.my.cnf", 
                          "database", "MySQL client configuration", ["mysql"]),
                ConfigItem("pgcli", "database/pgcli-config", "~/.config/pgcli/config", 
                          "database", "PostgreSQL CLI with auto-completion", ["pgcli"]),
            ],
            "cloud": [
                ConfigItem("AWS CLI", "cloud/aws-config", "~/.aws/config", 
                          "cloud", "Amazon Web Services CLI config", ["awscli"]),
                ConfigItem("Kubernetes", "cloud/kube-config", "~/.kube/config", 
                          "cloud", "Kubernetes cluster configuration", ["kubectl"]),
                ConfigItem("Terraform", "cloud/terraformrc", "~/.terraformrc", 
                          "cloud", "Infrastructure as Code tool config", ["terraform"]),
            ],
            "monitoring": [
                ConfigItem("htop", "monitoring/htoprc", "~/.config/htop/htoprc", 
                          "monitoring", "Interactive process viewer", ["htop"]),
                ConfigItem("bat", "monitoring/bat-config", "~/.config/bat/config", 
                          "monitoring", "Cat clone with syntax highlighting", ["bat"]),
                ConfigItem("ripgrep", "monitoring/ripgreprc", "~/.ripgreprc", 
                          "monitoring", "Fast recursive grep", ["ripgrep"]),
                ConfigItem("fd", "monitoring/fdignore", "~/.fdignore", 
                          "monitoring", "Fast find alternative", ["fd"]),
            ],
            "system": [
                ConfigItem("Karabiner", "system/karabiner.json", "~/.config/karabiner/karabiner.json", 
                          "system", "Keyboard customization tool", ["karabiner-elements"]),
                ConfigItem("yabai", "system/yabairc", "~/.config/yabai/yabairc", 
                          "system", "Tiling window manager", ["yabai"]),
                ConfigItem("skhd", "system/skhdrc", "~/.config/skhd/skhdrc", 
                          "system", "Simple hotkey daemon", ["skhd"]),
                ConfigItem("AeroSpace", "system/aerospace.toml", "~/.config/aerospace/aerospace.toml", 
                          "system", "i3-like tiling window manager", ["aerospace"]),
            ],
            "security": [
                ConfigItem("SSH", "security/ssh_config", "~/.ssh/config", 
                          "security", "SSH client configuration", ["openssh"]),
                ConfigItem("GnuPG", "security/gpg.conf", "~/.gnupg/gpg.conf", 
                          "security", "GNU Privacy Guard configuration", ["gnupg"]),
            ]
        }
        
        # Load configurations into the manager
        for category, items in config_definitions.items():
            self.configs[category] = []
            for item in items:
                # Check if source file exists
                source_path = self.configs_dir / item.source
                if source_path.exists():
                    item.check_installed()
                    self.configs[category].append(item)
                    
    def create_backup(self, config: ConfigItem) -> bool:
        """Create backup of existing configuration"""
        dest_path = Path(config.dest).expanduser()
        if not dest_path.exists():
            return True
            
        # Create backup directory
        self.backup_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate backup filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"{dest_path.name}.{timestamp}.bak"
        backup_path = self.backup_dir / backup_name
        
        try:
            shutil.copy2(dest_path, backup_path)
            config.backup_path = backup_path
            return True
        except Exception as e:
            console.print(f"[red]Failed to backup {dest_path}: {e}[/red]")
            return False
            
    def deploy_config(self, config: ConfigItem) -> bool:
        """Deploy a configuration file"""
        source_path = self.configs_dir / config.source
        dest_path = Path(config.dest).expanduser()
        
        # Create parent directory if needed
        dest_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Create backup if file exists
        if dest_path.exists():
            if not self.create_backup(config):
                return False
                
        try:
            shutil.copy2(source_path, dest_path)
            console.print(f"[green]✓[/green] Deployed {config.name}")
            return True
        except Exception as e:
            console.print(f"[red]✗ Failed to deploy {config.name}: {e}[/red]")
            return False
            
    def check_requirements(self, config: ConfigItem) -> Tuple[bool, List[str]]:
        """Check if required tools are installed"""
        missing = []
        for req in config.requires:
            # Check if command exists
            result = subprocess.run(['which', req], capture_output=True, text=True)
            if result.returncode != 0:
                missing.append(req)
        return len(missing) == 0, missing
        
    def restore_backup(self, config: ConfigItem) -> bool:
        """Restore configuration from backup"""
        if not config.backup_path or not config.backup_path.exists():
            console.print(f"[yellow]No backup found for {config.name}[/yellow]")
            return False
            
        dest_path = Path(config.dest).expanduser()
        try:
            shutil.copy2(config.backup_path, dest_path)
            console.print(f"[green]✓ Restored {config.name} from backup[/green]")
            return True
        except Exception as e:
            console.print(f"[red]Failed to restore {config.name}: {e}[/red]")
            return False

class ConfigUI:
    """Terminal UI for configuration management"""
    
    def __init__(self, manager: ConfigManager):
        self.manager = manager
        self.current_category = 0
        self.current_item = 0
        self.categories = list(self.manager.configs.keys())
        
    def display_menu(self):
        """Display the main menu"""
        while True:
            console.clear()
            self.show_header()
            
            # Create menu table
            table = Table(title="Configuration Categories", box=box.ROUNDED)
            table.add_column("", style="cyan", width=3)
            table.add_column("Category", style="bold")
            table.add_column("Configs", justify="center")
            table.add_column("Installed", justify="center", style="green")
            
            for i, category in enumerate(self.categories):
                items = self.manager.configs[category]
                total = len(items)
                installed = sum(1 for item in items if item.installed)
                
                marker = "▶" if i == self.current_category else " "
                table.add_row(
                    marker,
                    category.replace("-", " ").title(),
                    str(total),
                    f"{installed}/{total}"
                )
                
            console.print(table)
            console.print("\n[bold]Navigation:[/bold] ↑/k Up | ↓/j Down | →/Enter Select | q Quit")
            console.print("[bold]Actions:[/bold] a Select All | n Select None | d Deploy Selected | b Backup/Restore")
            
            key = Prompt.ask("\nCommand", default="", show_default=False)
            
            if key.lower() in ['q', 'quit', 'exit']:
                break
            elif key.lower() in ['j', 'down']:
                self.current_category = (self.current_category + 1) % len(self.categories)
            elif key.lower() in ['k', 'up']:
                self.current_category = (self.current_category - 1) % len(self.categories)
            elif key.lower() in ['', 'enter', 'right', 'l']:
                self.show_category_configs()
            elif key.lower() == 'a':
                self.select_all_configs()
            elif key.lower() == 'n':
                self.deselect_all_configs()
            elif key.lower() == 'd':
                self.deploy_selected_configs()
            elif key.lower() == 'b':
                self.show_backup_menu()
                
    def show_header(self):
        """Display header"""
        header = Panel(
            "[bold cyan]Mac Setup Configuration Manager[/bold cyan]\n"
            "[dim]Select and deploy development environment configurations[/dim]",
            box=box.DOUBLE,
            expand=False
        )
        console.print(header)
        console.print()
        
    def show_category_configs(self):
        """Show configurations in selected category"""
        category = self.categories[self.current_category]
        configs = self.manager.configs[category]
        current_item = 0
        
        while True:
            console.clear()
            self.show_header()
            
            # Category header
            console.print(f"[bold]{category.replace('-', ' ').title()} Configurations[/bold]\n")
            
            # Configuration table
            table = Table(box=box.ROUNDED)
            table.add_column("", width=3)
            table.add_column("", width=3)
            table.add_column("Configuration", style="bold")
            table.add_column("Status", justify="center")
            table.add_column("Description")
            
            for i, config in enumerate(configs):
                marker = "▶" if i == current_item else " "
                selected = "☑" if config.selected else "☐"
                status = "[green]Installed[/green]" if config.installed else "[dim]Not installed[/dim]"
                
                table.add_row(
                    marker,
                    selected,
                    config.name,
                    status,
                    config.description
                )
                
            console.print(table)
            
            # Show details for current item
            if configs:
                current_config = configs[current_item]
                details = Panel(
                    f"[bold]Source:[/bold] {current_config.source}\n"
                    f"[bold]Destination:[/bold] {current_config.dest}\n"
                    f"[bold]Requires:[/bold] {', '.join(current_config.requires) if current_config.requires else 'None'}",
                    title=f"[cyan]{current_config.name}[/cyan]",
                    box=box.ROUNDED
                )
                console.print("\n", details)
            
            console.print("\n[bold]Navigation:[/bold] ↑/k Up | ↓/j Down | Space Toggle | ← Back")
            console.print("[bold]Actions:[/bold] a Select All | n None | d Deploy | c Check Requirements")
            
            key = Prompt.ask("\nCommand", default="", show_default=False)
            
            if key.lower() in ['', 'left', 'back', 'h', 'q']:
                break
            elif key.lower() in ['j', 'down'] and configs:
                current_item = (current_item + 1) % len(configs)
            elif key.lower() in ['k', 'up'] and configs:
                current_item = (current_item - 1) % len(configs)
            elif key.lower() == ' ' and configs:
                configs[current_item].selected = not configs[current_item].selected
            elif key.lower() == 'a':
                for config in configs:
                    config.selected = True
            elif key.lower() == 'n':
                for config in configs:
                    config.selected = False
            elif key.lower() == 'd':
                self.deploy_category_configs(category)
            elif key.lower() == 'c' and configs:
                self.check_config_requirements(configs[current_item])
                
    def check_config_requirements(self, config: ConfigItem):
        """Check and display requirements for a configuration"""
        console.print(f"\n[bold]Checking requirements for {config.name}...[/bold]")
        
        ok, missing = self.manager.check_requirements(config)
        
        if ok:
            console.print("[green]✓ All requirements satisfied![/green]")
        else:
            console.print("[red]✗ Missing requirements:[/red]")
            for req in missing:
                console.print(f"  - {req}")
            console.print(f"\n[yellow]Install with: brew install {' '.join(missing)}[/yellow]")
            
        Prompt.ask("\nPress Enter to continue")
        
    def select_all_configs(self):
        """Select all configurations"""
        count = 0
        for configs in self.manager.configs.values():
            for config in configs:
                if not config.selected:
                    config.selected = True
                    count += 1
        console.print(f"[green]Selected {count} configurations[/green]")
        Prompt.ask("Press Enter to continue")
        
    def deselect_all_configs(self):
        """Deselect all configurations"""
        count = 0
        for configs in self.manager.configs.values():
            for config in configs:
                if config.selected:
                    config.selected = False
                    count += 1
        console.print(f"[yellow]Deselected {count} configurations[/yellow]")
        Prompt.ask("Press Enter to continue")
        
    def deploy_selected_configs(self):
        """Deploy all selected configurations"""
        selected = []
        for configs in self.manager.configs.values():
            selected.extend([c for c in configs if c.selected])
            
        if not selected:
            console.print("[yellow]No configurations selected![/yellow]")
            Prompt.ask("Press Enter to continue")
            return
            
        console.print(f"\n[bold]Ready to deploy {len(selected)} configurations:[/bold]")
        for config in selected:
            status = "[yellow]Will overwrite[/yellow]" if config.installed else "[green]New[/green]"
            console.print(f"  • {config.name} ({status})")
            
        if not Confirm.ask("\nProceed with deployment?"):
            return
            
        # Deploy with progress
        console.print("\n[bold]Deploying configurations...[/bold]\n")
        
        success = 0
        failed = 0
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            transient=True
        ) as progress:
            task = progress.add_task("Deploying...", total=len(selected))
            
            for config in selected:
                progress.update(task, description=f"Deploying {config.name}...")
                
                # Check requirements first
                ok, missing = self.manager.check_requirements(config)
                if not ok:
                    console.print(f"[red]✗ {config.name} - missing requirements: {', '.join(missing)}[/red]")
                    failed += 1
                    continue
                    
                if self.manager.deploy_config(config):
                    success += 1
                    config.selected = False
                    config.check_installed()
                else:
                    failed += 1
                    
                progress.advance(task)
                
        console.print(f"\n[bold]Deployment complete![/bold]")
        console.print(f"[green]✓ Success: {success}[/green]")
        if failed > 0:
            console.print(f"[red]✗ Failed: {failed}[/red]")
            
        Prompt.ask("\nPress Enter to continue")
        
    def deploy_category_configs(self, category: str):
        """Deploy selected configs from a category"""
        configs = [c for c in self.manager.configs[category] if c.selected]
        
        if not configs:
            console.print("[yellow]No configurations selected in this category![/yellow]")
            Prompt.ask("Press Enter to continue")
            return
            
        console.print(f"\n[bold]Ready to deploy {len(configs)} configurations from {category}:[/bold]")
        for config in configs:
            status = "[yellow]Will overwrite[/yellow]" if config.installed else "[green]New[/green]"
            console.print(f"  • {config.name} ({status})")
            
        if not Confirm.ask("\nProceed with deployment?"):
            return
            
        console.print("\n[bold]Deploying...[/bold]\n")
        
        for config in configs:
            ok, missing = self.manager.check_requirements(config)
            if not ok:
                console.print(f"[red]✗ {config.name} - missing: {', '.join(missing)}[/red]")
                continue
                
            if self.manager.deploy_config(config):
                config.selected = False
                config.check_installed()
                
        Prompt.ask("\nPress Enter to continue")
        
    def show_backup_menu(self):
        """Show backup and restore menu"""
        console.clear()
        self.show_header()
        
        console.print("[bold]Backup Management[/bold]\n")
        
        # List backups
        if self.manager.backup_dir.exists():
            backups = sorted(self.manager.backup_dir.glob("*.bak"), key=lambda p: p.stat().st_mtime, reverse=True)
            
            if backups:
                table = Table(title="Recent Backups", box=box.ROUNDED)
                table.add_column("#", width=3)
                table.add_column("File", style="cyan")
                table.add_column("Date", style="dim")
                table.add_column("Size", justify="right")
                
                for i, backup in enumerate(backups[:10]):
                    stat = backup.stat()
                    date = datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M")
                    size = f"{stat.st_size / 1024:.1f} KB" if stat.st_size > 1024 else f"{stat.st_size} B"
                    
                    table.add_row(str(i+1), backup.name, date, size)
                    
                console.print(table)
            else:
                console.print("[dim]No backups found[/dim]")
        else:
            console.print("[dim]No backups found[/dim]")
            
        console.print("\n[bold]Options:[/bold]")
        console.print("1. Create backup of all installed configs")
        console.print("2. Restore specific backup")
        console.print("3. Clean old backups")
        console.print("4. Back to main menu")
        
        choice = Prompt.ask("\nChoice", choices=["1", "2", "3", "4"], default="4")
        
        if choice == "1":
            self.backup_all_configs()
        elif choice == "2":
            self.restore_from_backup()
        elif choice == "3":
            self.clean_old_backups()
            
    def backup_all_configs(self):
        """Backup all installed configurations"""
        console.print("\n[bold]Creating backups...[/bold]\n")
        
        backed_up = 0
        for configs in self.manager.configs.values():
            for config in configs:
                if config.installed:
                    if self.manager.create_backup(config):
                        console.print(f"[green]✓[/green] Backed up {config.name}")
                        backed_up += 1
                        
        console.print(f"\n[green]Created {backed_up} backups[/green]")
        Prompt.ask("Press Enter to continue")
        
    def restore_from_backup(self):
        """Restore a specific backup"""
        # This would need more implementation for selecting specific backups
        console.print("[yellow]Restore functionality coming soon![/yellow]")
        Prompt.ask("Press Enter to continue")
        
    def clean_old_backups(self):
        """Clean old backup files"""
        if not self.manager.backup_dir.exists():
            console.print("[yellow]No backups to clean[/yellow]")
            Prompt.ask("Press Enter to continue")
            return
            
        backups = sorted(self.manager.backup_dir.glob("*.bak"), key=lambda p: p.stat().st_mtime)
        
        if len(backups) <= 10:
            console.print("[yellow]Less than 10 backups found, nothing to clean[/yellow]")
            Prompt.ask("Press Enter to continue")
            return
            
        to_delete = backups[:-10]  # Keep last 10
        
        console.print(f"[bold]Will delete {len(to_delete)} old backups[/bold]")
        
        if Confirm.ask("Proceed?"):
            for backup in to_delete:
                backup.unlink()
            console.print(f"[green]Deleted {len(to_delete)} old backups[/green]")
        
        Prompt.ask("Press Enter to continue")

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="Mac Setup Configuration Manager")
    parser.add_argument("--list", action="store_true", help="List all configurations")
    parser.add_argument("--deploy", metavar="CONFIG", help="Deploy specific configuration")
    parser.add_argument("--category", metavar="CAT", help="Deploy all configs in category")
    parser.add_argument("--check", action="store_true", help="Check all requirements")
    
    args = parser.parse_args()
    
    # Find project root
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    
    manager = ConfigManager(project_root)
    
    if args.list:
        # List mode
        for category, configs in manager.configs.items():
            console.print(f"\n[bold]{category.replace('-', ' ').title()}:[/bold]")
            for config in configs:
                status = "✓" if config.installed else "✗"
                console.print(f"  {status} {config.name}")
    elif args.deploy:
        # Deploy specific config
        found = False
        for configs in manager.configs.values():
            for config in configs:
                if config.name.lower() == args.deploy.lower():
                    found = True
                    ok, missing = manager.check_requirements(config)
                    if not ok:
                        console.print(f"[red]Missing requirements: {', '.join(missing)}[/red]")
                    else:
                        manager.deploy_config(config)
                    break
        if not found:
            console.print(f"[red]Configuration '{args.deploy}' not found[/red]")
    elif args.category:
        # Deploy category
        if args.category in manager.configs:
            for config in manager.configs[args.category]:
                ok, missing = manager.check_requirements(config)
                if ok:
                    manager.deploy_config(config)
                else:
                    console.print(f"[red]{config.name} - missing: {', '.join(missing)}[/red]")
        else:
            console.print(f"[red]Category '{args.category}' not found[/red]")
    elif args.check:
        # Check all requirements
        console.print("[bold]Checking all requirements...[/bold]\n")
        all_missing = set()
        for category, configs in manager.configs.items():
            console.print(f"[bold]{category}:[/bold]")
            for config in configs:
                ok, missing = manager.check_requirements(config)
                if ok:
                    console.print(f"  [green]✓[/green] {config.name}")
                else:
                    console.print(f"  [red]✗[/red] {config.name}: {', '.join(missing)}")
                    all_missing.update(missing)
        
        if all_missing:
            console.print(f"\n[yellow]Install missing tools with:[/yellow]")
            console.print(f"brew install {' '.join(sorted(all_missing))}")
    else:
        # Interactive TUI mode
        ui = ConfigUI(manager)
        try:
            ui.display_menu()
        except KeyboardInterrupt:
            console.print("\n[yellow]Interrupted by user[/yellow]")
        except Exception as e:
            console.print(f"\n[red]Error: {e}[/red]")
            sys.exit(1)

if __name__ == "__main__":
    main()
