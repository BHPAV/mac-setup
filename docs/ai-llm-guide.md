# AI LLM Guide: Mac Setup Knowledge Graph

This guide provides instructions for AI assistants to query, understand, and extend the Mac setup knowledge graph.

## 🔍 Accessing the Mac Setup Knowledge Graph

### Finding the Root Project
```cypher
MATCH (p:Project {id: 'macbook-m4-max-setup'})
RETURN p
```

### Exploring Categories
```cypher
// List all tool categories
MATCH (p:Project {id: 'macbook-m4-max-setup'})-[:HAS_CATEGORY]->(cat:Category)
RETURN cat.name, cat.description
ORDER BY cat.name

// Categories available:
// - Terminal_Environment
// - Development_IDEs  
// - Programming_Languages
// - Database_Tools
// - Cloud_DevOps_Tools
// - System_Tools
// - Security_Tools
```

### Finding Tools by Category
```cypher
// Example: Find all terminal tools
MATCH (cat:Category {name: 'Terminal_Environment'})-[:CONTAINS]->(tool:Tool)
RETURN tool.name, tool.tool_key, tool.command, tool.description
ORDER BY tool.name
```

### Understanding Tool Relationships
```cypher
// Find tool dependencies
MATCH (tool:Tool {tool_key: 'poetry'})-[:DEPENDS_ON]->(dep:Tool)
RETURN tool.name + " depends on " + dep.name

// Find tool integrations
MATCH (tool:Tool)-[:INTEGRATES_WITH]-(other:Tool)
RETURN DISTINCT tool.name, other.name

// Find installation method
MATCH (tool:Tool)-[:INSTALLED_BY]->(installer:Tool)
RETURN tool.name, installer.name, tool.command
```

### Finding Configurations
```cypher
// List all configurations
MATCH (conf:Configuration)
RETURN conf.name, conf.file_path, conf.purpose

// Find what a configuration configures
MATCH (conf:Configuration)-[:CONFIGURES]->(tool:Tool)
RETURN conf.name + " configures " + tool.name
```

### Exploring Workflows
```cypher
// List workflows and their tools
MATCH (w:Workflow)-[:USES]->(tool:Tool)
RETURN w.name, COLLECT(tool.name) as tools_used
```

## 📝 Instructions for Adding New Tools

### STEP 1: Determine Tool Category
First, identify which category the tool belongs to:
- **Terminal_Environment**: Terminal emulators, shells, terminal enhancements
- **Development_IDEs**: Code editors, IDEs
- **Programming_Languages**: Language runtimes, compilers, language-specific tools
- **Database_Tools**: Database servers, clients, GUI tools
- **Cloud_DevOps_Tools**: Cloud CLIs, container tools, CI/CD, IaC
- **System_Tools**: OS utilities, package managers, system enhancement
- **Security_Tools**: Authentication, encryption, security utilities

### STEP 2: Create the Tool Node
```cypher
// Template for creating a new tool
CREATE (tool:Tool {
  tool_key: 'unique-tool-key',  // lowercase, hyphenated
  name: 'Tool Display Name',
  description: 'What this tool does and why it's useful',
  category: 'category-name',  // terminal, ide, language, database, cloud, system
  command: 'brew install tool-name',  // installation command
  status: 'active',
  created: datetime(),
  version: 'latest',  // optional: specific version
  spec: 'Key features and capabilities',  // optional: detailed spec
  language: 'shell'  // optional: implementation language
})
```

### STEP 3: Connect to Category
```cypher
MATCH (cat:Category {name: 'Category_Name'})
MATCH (tool:Tool {tool_key: 'unique-tool-key'})
CREATE (cat)-[:CONTAINS]->(tool)
```

### STEP 4: Add Installation Relationship
```cypher
// If installed via Homebrew
MATCH (tool:Tool {tool_key: 'unique-tool-key'})
MATCH (homebrew:Tool {tool_key: 'homebrew'})
CREATE (tool)-[:INSTALLED_BY]->(homebrew)
```

### STEP 5: Add Dependencies (if any)
```cypher
// If tool depends on another
MATCH (tool:Tool {tool_key: 'unique-tool-key'})
MATCH (dependency:Tool {tool_key: 'dependency-key'})
CREATE (tool)-[:DEPENDS_ON]->(dependency)
```

### STEP 6: Add Integrations (if any)
```cypher
// If tool integrates with others
MATCH (tool:Tool {tool_key: 'unique-tool-key'})
MATCH (other:Tool {tool_key: 'other-tool-key'})
CREATE (tool)-[:INTEGRATES_WITH]->(other)
```

### STEP 7: Update Brewfile
Add the tool to `D:\Dev\tools\mac-setup\Brewfile`:
```ruby
brew "tool-name"           # For CLI tools
# or
cask "tool-name"          # For GUI applications
```

### STEP 8: Update Setup Script
Add to appropriate function in `scripts/setup.sh`:
```bash
brew install tool-name
# or
brew install --cask tool-name
```

## 📄 Instructions for Adding New Configurations

### STEP 1: Create Configuration Node
```cypher
CREATE (conf:Configuration {
  name: 'Configuration Name',
  file_path: '~/.configfile',  // destination path
  source_path: 'configs/category/filename',  // repo path
  purpose: 'What this configuration does',
  key_features: ['feature1', 'feature2', 'feature3'],
  created: datetime()
})
```

### STEP 2: Connect to Tool
```cypher
MATCH (conf:Configuration {name: 'Configuration Name'})
MATCH (tool:Tool {tool_key: 'tool-key'})
CREATE (conf)-[:CONFIGURES]->(tool)
```

### STEP 3: Add Dependencies (if needed)
```cypher
MATCH (conf:Configuration {name: 'Configuration Name'})
MATCH (dep:Tool {tool_key: 'dependency-key'})
CREATE (conf)-[:DEPENDS_ON]->(dep)
```

### STEP 4: Create Config File
Create the actual configuration file in the repository:
```bash
# Create in appropriate subdirectory
configs/
├── shell/       # Shell configurations
├── git/         # Git configurations
├── editors/     # Editor configurations
├── terminal/    # Terminal app configurations
└── [category]/  # Other categories as needed
```

### STEP 5: Update Additional Configs Script
Add to `scripts/additional-configs.sh` if needed.

## 🔄 Complete Example: Adding lazygit

### 1. Create Tool
```cypher
CREATE (lazygit:Tool {
  tool_key: 'lazygit',
  name: 'lazygit',
  description: 'Simple terminal UI for git commands',
  category: 'terminal',
  command: 'brew install lazygit',
  status: 'active',
  created: datetime()
})
```

### 2. Connect to Category
```cypher
MATCH (cat:Category {name: 'Terminal_Environment'})
MATCH (lazygit:Tool {tool_key: 'lazygit'})
CREATE (cat)-[:CONTAINS]->(lazygit)
```

### 3. Add Relationships
```cypher
MATCH (lazygit:Tool {tool_key: 'lazygit'})
MATCH (homebrew:Tool {tool_key: 'homebrew'})
MATCH (git:Tool {tool_key: 'git'})
CREATE (lazygit)-[:INSTALLED_BY]->(homebrew)
CREATE (lazygit)-[:DEPENDS_ON]->(git)
CREATE (lazygit)-[:INTEGRATES_WITH]->(git)
```

### 4. Update Files
Add to Brewfile:
```ruby
brew "lazygit"             # Terminal UI for git
```

Add to setup.sh (in install_essential_tools function):
```bash
lazygit \
```

## 🎯 Best Practices for AI LLMs

1. **Always Check Existing Tools First**
   ```cypher
   MATCH (t:Tool) WHERE t.name =~ '(?i).*toolname.*' RETURN t
   ```

2. **Use Consistent Naming**
   - tool_key: lowercase-hyphenated
   - name: Proper Case Display Name
   - category: lowercase singular

3. **Include Installation Commands**
   - Always specify the exact installation command
   - Prefer Homebrew when available

4. **Document Relationships**
   - INSTALLED_BY: How is it installed?
   - DEPENDS_ON: What must be installed first?
   - INTEGRATES_WITH: What does it work well with?
   - ALTERNATIVE_TO: What could it replace?

5. **Update Repository Files**
   - Don't just update the graph - update the actual files
   - Maintain consistency between graph and filesystem

6. **Add to Appropriate Workflow**
   ```cypher
   MATCH (w:Workflow {name: 'Workflow Name'})
   MATCH (tool:Tool {tool_key: 'tool-key'})
   CREATE (w)-[:USES]->(tool)
   ```

## 🔍 Verification Queries

After adding a tool or configuration:

```cypher
// Verify tool was created and connected
MATCH (t:Tool {tool_key: 'new-tool-key'})
OPTIONAL MATCH (t)-[r]-(connected)
RETURN t, type(r), connected

// Check category membership
MATCH (cat:Category)-[:CONTAINS]->(t:Tool {tool_key: 'new-tool-key'})
RETURN cat.name, t.name

// Verify installation method
MATCH (t:Tool {tool_key: 'new-tool-key'})-[:INSTALLED_BY]->(installer)
RETURN t.name + " installed by " + installer.name
```

## 📚 Quick Reference

### Common Patterns
- **Homebrew Formula**: `brew "package-name"`
- **Homebrew Cask**: `cask "app-name"`
- **Direct Download**: Custom command in tool.command
- **Language Tool**: Often installed via pipx, cargo, npm, etc.

### Relationship Types
- **CONTAINS**: Category → Tool
- **INSTALLED_BY**: Tool → Installer
- **DEPENDS_ON**: Tool/Config → Dependency
- **INTEGRATES_WITH**: Tool ↔ Tool (bidirectional)
- **CONFIGURES**: Configuration → Tool
- **USES**: Workflow → Tool
- **ALTERNATIVE_TO**: Tool → Tool

### File Locations
- Tools List: `Brewfile`
- Main Script: `scripts/setup.sh`
- Configs: `configs/[category]/[filename]`
- Documentation: `docs/`

Remember: The knowledge graph should always reflect the actual state of the repository files!
