# Knowledge Graph Storage Guide

This guide explains how to store and organize the MacBook setup information in your knowledge graph for future reference and discovery.

## Graph Structure Overview

The MacBook setup information can be organized into a hierarchical knowledge graph with interconnected nodes representing different aspects of the development environment.

## Node Categories

### 1. **Root Node: MacBook Setup**
```
Node: MacBook_M4_Max_Setup
Type: Project
Properties:
  - name: "MacBook M4 Max Development Setup"
  - created_date: "2024-01-15"
  - platform: "macOS"
  - architecture: "Apple Silicon (ARM64)"
  - repository: "https://github.com/yourusername/mac-setup"
```

### 2. **Tool Categories**

#### Terminal Tools
```
Node: Terminal_Environment
Type: Category
Properties:
  - name: "Terminal and Shell Environment"
  - tools: ["Warp", "iTerm2", "Alacritty", "Tmux"]
  
Relationships:
  - PART_OF -> MacBook_M4_Max_Setup
  - CONTAINS -> Warp_Terminal
  - CONTAINS -> Zsh_Shell
  - CONTAINS -> Powerlevel10k_Theme
```

#### Development IDEs
```
Node: Development_IDEs
Type: Category
Properties:
  - name: "Integrated Development Environments"
  - tools: ["Cursor", "VS Code", "Neovim"]
  
Relationships:
  - PART_OF -> MacBook_M4_Max_Setup
  - CONTAINS -> Cursor_IDE
  - CONTAINS -> VS_Code
```

#### Programming Languages
```
Node: Programming_Languages
Type: Category
Properties:
  - name: "Programming Language Environments"
  - languages: ["Python", "Node.js", "Go", "Rust", "Java"]
  
Relationships:
  - PART_OF -> MacBook_M4_Max_Setup
  - CONTAINS -> Python_Environment
  - CONTAINS -> NodeJS_Environment
  - CONTAINS -> Go_Environment
```

### 3. **Individual Tool Nodes**

#### Example: Warp Terminal
```
Node: Warp_Terminal
Type: Tool
Properties:
  - name: "Warp"
  - category: "Terminal"
  - features: ["AI assistance", "GPU acceleration", "Block selection"]
  - install_method: "brew install --cask warp"
  - config_location: "~/Library/Application Support/dev.warp.Warp-Stable/"
  
Relationships:
  - INSTALLED_BY -> Homebrew
  - CONFIGURED_BY -> Warp_Config
  - INTEGRATES_WITH -> Zsh_Shell
  - INTEGRATES_WITH -> Git
```

#### Example: Cursor IDE
```
Node: Cursor_IDE
Type: Tool
Properties:
  - name: "Cursor"
  - category: "IDE"
  - features: ["AI-powered coding", "VS Code based", "Copilot integration"]
  - install_method: "brew install --cask cursor"
  
Relationships:
  - INSTALLED_BY -> Homebrew
  - ALTERNATIVE_TO -> VS_Code
  - USES_CONFIG -> VSCode_Settings
```

### 4. **Configuration Nodes**

```
Node: Zsh_Config
Type: Configuration
Properties:
  - file: "~/.zshrc"
  - purpose: "Shell configuration"
  - key_features: ["aliases", "functions", "environment variables"]
  
Relationships:
  - CONFIGURES -> Zsh_Shell
  - DEPENDS_ON -> Oh_My_Zsh
  - LOADS -> Powerlevel10k_Theme
```

### 5. **Workflow Nodes**

```
Node: Git_Workflow
Type: Workflow
Properties:
  - name: "Git Development Workflow"
  - tools_used: ["Git", "Delta", "GitHub CLI"]
  - key_aliases: ["gs", "ga", "gc", "gp"]
  
Relationships:
  - USES -> Git
  - ENHANCED_BY -> Git_Aliases
  - VISUALIZED_BY -> Delta_Diff_Tool
```

## Relationship Types

### Primary Relationships
- **PART_OF**: Component is part of a larger system
- **CONTAINS**: Parent node contains child nodes
- **DEPENDS_ON**: Node requires another node to function
- **CONFIGURES**: Configuration file configures a tool
- **INTEGRATES_WITH**: Tools work together

### Secondary Relationships
- **ALTERNATIVE_TO**: Alternative tool options
- **ENHANCED_BY**: Tool is enhanced by another
- **INSTALLED_BY**: Installation method
- **PREREQUISITE_FOR**: Required before installation

## Query Examples

### 1. Find all AI-powered tools
```cypher
MATCH (t:Tool)
WHERE 'AI assistance' IN t.features OR 'AI-powered' IN t.features
RETURN t.name, t.category
```

### 2. Show complete Python setup
```cypher
MATCH (p:Programming_Languages)-[:CONTAINS]->(python:Python_Environment)
MATCH (python)-[:USES|DEPENDS_ON*]->(tool)
RETURN python, tool
```

### 3. Find all tools installed via Homebrew
```cypher
MATCH (h:Homebrew)<-[:INSTALLED_BY]-(tool:Tool)
RETURN tool.name, tool.install_method
ORDER BY tool.category
```

### 4. Show Git workflow with all enhancements
```cypher
MATCH (w:Git_Workflow)-[r:USES|ENHANCED_BY|VISUALIZED_BY]->(tool)
RETURN w, type(r) as relationship, tool
```

## Storage Best Practices

### 1. **Node Naming Convention**
- Use PascalCase for node names: `Warp_Terminal`, not `warp-terminal`
- Be descriptive: `Python_Virtual_Environment` not just `Venv`
- Include version where relevant: `Node_v20_11_0`

### 2. **Property Guidelines**
- Keep properties atomic and searchable
- Use arrays for multiple values
- Include installation commands as properties
- Add timestamps for version tracking

### 3. **Relationship Guidelines**
- Use active voice: `CONFIGURES` not `IS_CONFIGURED_BY`
- Be specific: `INTEGRATES_WITH_GIT` if needed
- Avoid circular dependencies
- Document relationship purposes

### 4. **Metadata to Include**
```
Node: Setup_Metadata
Type: Metadata
Properties:
  - setup_date: "2024-01-15"
  - last_updated: "2024-01-15"
  - mac_model: "MacBook Pro M4 Max"
  - macos_version: "Sonoma 14.x"
  - primary_use: "Full-stack development"
  - setup_time: "2-3 hours"
```

## Maintenance and Updates

### Version Tracking
```
Node: Setup_Version_1_0
Type: Version
Properties:
  - version: "1.0"
  - date: "2024-01-15"
  - changes: ["Initial setup", "All tools configured"]
  
Relationships:
  - VERSION_OF -> MacBook_M4_Max_Setup
  - INCLUDES -> [list of all tool nodes]
```

### Update Process
1. Create new version node when making significant changes
2. Link new tools with `ADDED_IN` relationship to version
3. Mark deprecated tools with `DEPRECATED_IN` relationship
4. Keep configuration history for rollback

## Integration with Existing Knowledge

### Link to Related Concepts
- **Development Practices**: Link to best practices nodes
- **Project Templates**: Connect to project initialization workflows
- **Troubleshooting**: Link to common issues and solutions
- **Learning Resources**: Connect to tutorials and documentation

### Cross-Platform Connections
```
Node: Cross_Platform_Tools
Type: Category
Properties:
  - tools: ["Git", "Docker", "VS Code", "Node.js"]
  
Relationships:
  - AVAILABLE_ON -> MacOS
  - AVAILABLE_ON -> Linux
  - AVAILABLE_ON -> Windows
```

## Search and Discovery

### Tags for Better Discovery
Add tags to nodes for easier searching:
- `#automation`
- `#terminal`
- `#ai-tools`
- `#development`
- `#macos`
- `#configuration`

### Common Queries
1. "Show me all terminal enhancements"
2. "What tools support AI features?"
3. "List all configuration files and their locations"
4. "Show the complete Git setup and workflow"
5. "Find all tools that integrate with VS Code"

## Export and Backup

### Export Format
```json
{
  "nodes": [
    {
      "id": "MacBook_M4_Max_Setup",
      "type": "Project",
      "properties": {...}
    }
  ],
  "relationships": [
    {
      "from": "Warp_Terminal",
      "to": "Homebrew",
      "type": "INSTALLED_BY"
    }
  ]
}
```

This structure allows you to:
- Quickly find any tool or configuration
- Understand dependencies and relationships
- Track changes over time
- Share setup knowledge with others
- Build upon existing configurations
