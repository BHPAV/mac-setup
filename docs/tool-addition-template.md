# Template: Adding [TOOL_NAME] to Mac Setup

## Step 1: Create Tool Node
```cypher
CREATE (TOOL_KEY:Tool {
  tool_key: 'TOOL_KEY',
  name: 'TOOL_NAME',
  description: 'TOOL_DESCRIPTION',
  category: 'CATEGORY',  -- Choose: terminal/ide/language/database/cloud/system
  command: 'brew install FORMULA_NAME',
  status: 'active',
  created: datetime()
})
```

## Step 2: Connect to Category
```cypher
MATCH (cat:Category {name: 'CATEGORY_NAME'})  -- Choose correct category
MATCH (tool:Tool {tool_key: 'TOOL_KEY'})
CREATE (cat)-[:CONTAINS]->(tool)
```

## Step 3: Add Installation Method
```cypher
MATCH (tool:Tool {tool_key: 'TOOL_KEY'})
MATCH (homebrew:Tool {tool_key: 'homebrew'})
CREATE (tool)-[:INSTALLED_BY]->(homebrew)
```

## Step 4: Add Dependencies (if applicable)
```cypher
-- Example: If tool depends on another
MATCH (tool:Tool {tool_key: 'TOOL_KEY'})
MATCH (dep:Tool {tool_key: 'DEPENDENCY_KEY'})
CREATE (tool)-[:DEPENDS_ON]->(dep)
```

## Step 5: Add Integrations (if applicable)
```cypher
-- Example: If tool works with another
MATCH (tool:Tool {tool_key: 'TOOL_KEY'})
MATCH (other:Tool {tool_key: 'OTHER_TOOL_KEY'})
CREATE (tool)-[:INTEGRATES_WITH]->(other)
```

## Step 6: Update Brewfile
Add to `D:\Dev\tools\mac-setup\Brewfile`:
```ruby
brew "FORMULA_NAME"           # TOOL_DESCRIPTION
```

## Step 7: Update Setup Script
Add to appropriate function in `D:\Dev\tools\mac-setup\scripts\setup.sh`:

For system tools, add to `install_essential_tools()`:
```bash
FORMULA_NAME \
```

For dev tools, add to `install_dev_tools()`:
```bash
brew install --cask FORMULA_NAME
```

## Verification
```cypher
-- Verify tool was created correctly
MATCH (t:Tool {tool_key: 'TOOL_KEY'})
OPTIONAL MATCH (t)-[r]-(connected)
RETURN t, type(r), connected
```

---
**Notes:**
- Replace all UPPERCASE placeholders with actual values
- Choose appropriate category from: Terminal_Environment, Development_IDEs, Programming_Languages, Database_Tools, Cloud_DevOps_Tools, System_Tools
- Ensure tool_key is lowercase with hyphens (no spaces or underscores)
- Check if tool already exists before creating
