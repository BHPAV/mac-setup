# 🚀 Mac Setup Quick Reference for AI LLMs

## 🎯 Adding a New Tool - Quick Steps

```cypher
-- 1. CREATE TOOL
CREATE (tool:Tool {
  tool_key: 'tool-name',      -- lowercase-hyphenated
  name: 'Tool Name',          -- Proper Case
  description: 'What it does',
  category: 'category',       -- terminal/ide/language/database/cloud/system/security
  command: 'brew install tool-name',
  status: 'active',
  created: datetime()
})

-- 2. CONNECT TO CATEGORY
MATCH (cat:Category {name: 'Category_Name'})
MATCH (tool:Tool {tool_key: 'tool-name'})
CREATE (cat)-[:CONTAINS]->(tool)

-- 3. ADD INSTALLER
MATCH (tool:Tool {tool_key: 'tool-name'})
MATCH (homebrew:Tool {tool_key: 'homebrew'})
CREATE (tool)-[:INSTALLED_BY]->(homebrew)
```

Then update files:
- Add to `Brewfile`: `brew "tool-name"`
- Add to `scripts/setup.sh` in appropriate function

## 📁 Category Reference

| Category | Name in Graph | Description | Example Tools |
|----------|--------------|-------------|---------------|
| Terminal | Terminal_Environment | Shells, terminal apps | Warp, iTerm2, Zsh |
| IDEs | Development_IDEs | Code editors | Cursor, VS Code |
| Languages | Programming_Languages | Runtimes, compilers | Python, Node.js, Go |
| Databases | Database_Tools | DB servers & clients | Neo4j, PostgreSQL |
| Cloud | Cloud_DevOps_Tools | Cloud & DevOps | AWS CLI, Docker |
| System | System_Tools | OS utilities | Homebrew, Git |
| Security | Security_Tools | Security & authentication | GnuPG, 1Password CLI |

## 🔗 Relationship Types

```
Category -[:CONTAINS]-> Tool
Tool -[:INSTALLED_BY]-> Installer
Tool -[:DEPENDS_ON]-> Dependency
Tool <-[:INTEGRATES_WITH]-> Tool
Configuration -[:CONFIGURES]-> Tool
Workflow -[:USES]-> Tool
```

## 📝 Adding a Configuration

```cypher
-- 1. CREATE CONFIG
CREATE (conf:Configuration {
  name: 'Config Name',
  file_path: '~/.configfile',
  source_path: 'configs/category/file',
  purpose: 'What it configures',
  created: datetime()
})

-- 2. CONNECT TO TOOL
MATCH (conf:Configuration {name: 'Config Name'})
MATCH (tool:Tool {tool_key: 'tool-key'})
CREATE (conf)-[:CONFIGURES]->(tool)
```

Then create actual file in `configs/` directory.

## ⚡ Essential Queries

```cypher
-- Check if tool exists
MATCH (t:Tool) WHERE t.name =~ '(?i).*toolname.*' RETURN t

-- Find category for a tool type
MATCH (c:Category) RETURN c.name, c.description

-- See what installs a tool
MATCH (t:Tool {tool_key: 'tool-key'})-[:INSTALLED_BY]->(i) RETURN i

-- Find tool dependencies
MATCH (t:Tool {tool_key: 'tool-key'})-[:DEPENDS_ON]->(d) RETURN d
```

## 📂 File Structure
```
mac-setup/
├── Brewfile              # Add brew formulas here
├── scripts/
│   └── setup.sh         # Add to install functions
├── configs/
│   ├── shell/           # Shell configs
│   ├── git/             # Git configs  
│   ├── editors/         # Editor configs
│   └── terminal/        # Terminal app configs
└── docs/                # Documentation
```

## ✅ Checklist for New Tool

- [ ] Tool node created with unique tool_key
- [ ] Connected to correct Category
- [ ] INSTALLED_BY relationship added
- [ ] Dependencies added (if any)
- [ ] Added to Brewfile
- [ ] Added to setup.sh
- [ ] Tested installation command
- [ ] Documentation updated (if needed)

## 🚫 Common Mistakes to Avoid

1. ❌ Forgetting to connect to Category
2. ❌ Using spaces in tool_key (use hyphens)
3. ❌ Not adding to Brewfile
4. ❌ Creating duplicate tools
5. ❌ Wrong category assignment

## 💡 Pro Tips

- Always check existing tools first
- Use exact Homebrew formula names
- Keep descriptions concise but clear
- Add relationships to enhance discoverability
- Update both graph AND files
