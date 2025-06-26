# Validation Scripts

This directory contains scripts to validate the consistency between the Brewfile and the Neo4j knowledge graph.

## Scripts

### validate-brewfile.sh
A simple bash script that parses the Brewfile and provides an inventory of all tools.

**Usage:**
```bash
./validate-brewfile.sh [path/to/Brewfile]
```

**Features:**
- Counts taps, formulas, and casks
- Lists all tools sorted by type
- Checks for duplicate entries
- No external dependencies

### validate-brewfile-graph.py
A Python script that compares tools in the Brewfile with tools in the Neo4j knowledge graph.

**Requirements:**
```bash
pip install neo4j
```

**Usage:**
```bash
# With environment variable
export NEO4J_PASSWORD=your_password
python validate-brewfile-graph.py

# With command line argument
python validate-brewfile-graph.py --neo4j-password your_password

# Skip graph validation (just parse Brewfile)
python validate-brewfile-graph.py --skip-graph
```

**Options:**
- `--brewfile PATH`: Path to Brewfile (default: ./Brewfile)
- `--neo4j-uri URI`: Neo4j connection URI (default: bolt://localhost:7687)
- `--neo4j-user USER`: Neo4j username (default: neo4j)
- `--neo4j-password PASS`: Neo4j password (or use NEO4J_PASSWORD env var)
- `--skip-graph`: Skip knowledge graph validation

**Output:**
- Summary of tools in Brewfile vs Knowledge Graph
- List of tools only in Brewfile (need to be added to graph)
- List of tools only in Graph (need to be added to Brewfile)
- Recommendations for synchronization

## Running Validations

### Quick Brewfile Check
```bash
cd /path/to/mac-setup
./scripts/validate-brewfile.sh
```

### Full Validation with Knowledge Graph
```bash
cd /path/to/mac-setup
export NEO4J_PASSWORD=your_password
python scripts/validate-brewfile-graph.py
```

### CI/CD Integration
The validation scripts can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Validate Brewfile
  run: |
    ./scripts/validate-brewfile.sh
    
- name: Validate Knowledge Graph Sync
  env:
    NEO4J_PASSWORD: ${{ secrets.NEO4J_PASSWORD }}
  run: |
    pip install neo4j
    python scripts/validate-brewfile-graph.py
```

## Maintaining Synchronization

When validation finds discrepancies:

1. **Tools in Brewfile but not in Graph**: 
   - Use the AI LLM Guide to add them to the knowledge graph
   - Follow the template in `docs/tool-addition-template.md`

2. **Tools in Graph but not in Brewfile**:
   - Either add them to the Brewfile if they should be installed
   - Or remove them from the graph if they're no longer needed

3. **Regular Validation**:
   - Run validation after adding new tools
   - Include in PR checks to ensure consistency
   - Schedule periodic validation to catch drift

## Exit Codes

- `0`: Success - Brewfile and Knowledge Graph are in sync
- `1`: Failure - Discrepancies found between Brewfile and Graph
