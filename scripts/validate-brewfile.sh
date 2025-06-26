#!/bin/bash

# validate-brewfile.sh - Simple Brewfile validation script
# This script extracts and lists all tools from the Brewfile

set -e

BREWFILE="${1:-Brewfile}"

echo "================================================"
echo "BREWFILE TOOL INVENTORY"
echo "================================================"

if [ ! -f "$BREWFILE" ]; then
    echo "Error: Brewfile not found at $BREWFILE"
    exit 1
fi

echo -e "\nParsing: $BREWFILE\n"

# Count tools
FORMULA_COUNT=$(grep -E '^brew\s+"[^"]+"' "$BREWFILE" | wc -l)
CASK_COUNT=$(grep -E '^cask\s+"[^"]+"' "$BREWFILE" | wc -l)
TAP_COUNT=$(grep -E '^tap\s+"[^"]+"' "$BREWFILE" | wc -l)

echo "Summary:"
echo "  Taps: $TAP_COUNT"
echo "  Formulas: $FORMULA_COUNT"
echo "  Casks: $CASK_COUNT"
echo "  Total tools: $((FORMULA_COUNT + CASK_COUNT))"

# List formulas
echo -e "\n--- BREW FORMULAS ---"
grep -E '^brew\s+"[^"]+"' "$BREWFILE" | sed 's/brew "\([^"]*\)".*/\1/' | sort

# List casks
echo -e "\n--- BREW CASKS ---"
grep -E '^cask\s+"[^"]+"' "$BREWFILE" | sed 's/cask "\([^"]*\)".*/\1/' | sort

# List taps
echo -e "\n--- TAPS ---"
grep -E '^tap\s+"[^"]+"' "$BREWFILE" | sed 's/tap "\([^"]*\)".*/\1/' | sort

echo -e "\n================================================"

# Optional: Check for duplicates
echo -e "\nChecking for duplicates..."
DUPLICATES=$(grep -E '^(brew|cask)\s+"[^"]+"' "$BREWFILE" | sed 's/\(brew\|cask\) "\([^"]*\)".*/\2/' | sort | uniq -d)

if [ -n "$DUPLICATES" ]; then
    echo "WARNING: Found duplicate entries:"
    echo "$DUPLICATES"
else
    echo "✓ No duplicates found"
fi

echo -e "\nValidation complete!"
