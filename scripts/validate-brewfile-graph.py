#!/usr/bin/env python3
"""
Validate Brewfile against Knowledge Graph

This script compares tools in the Brewfile with tools in the Neo4j knowledge graph
to ensure they are synchronized.

Usage:
    python validate-brewfile-graph.py [--neo4j-uri URI] [--neo4j-user USER] [--neo4j-password PASSWORD]
"""

import os
import re
import sys
from typing import Set, Dict, List, Tuple

# Check if neo4j driver is available
try:
    from neo4j import GraphDatabase
    NEO4J_AVAILABLE = True
except ImportError:
    NEO4J_AVAILABLE = False
    print("Warning: neo4j-driver not installed. Install with: pip install neo4j")

class BrewfileParser:
    """Parse Brewfile to extract tools"""
    
    def __init__(self, brewfile_path: str):
        self.brewfile_path = brewfile_path
        self.formulas: Set[str] = set()
        self.casks: Set[str] = set()
        
    def parse(self) -> Dict[str, Set[str]]:
        """Parse Brewfile and return formulas and casks"""
        if not os.path.exists(self.brewfile_path):
            raise FileNotFoundError(f"Brewfile not found at {self.brewfile_path}")
            
        with open(self.brewfile_path, 'r') as f:
            for line in f:
                line = line.strip()
                
                # Skip comments and empty lines
                if not line or line.startswith('#'):
                    continue
                    
                # Match brew formulas
                brew_match = re.match(r'brew\s+"([^"]+)"', line)
                if brew_match:
                    self.formulas.add(brew_match.group(1))
                    
                # Match cask applications
                cask_match = re.match(r'cask\s+"([^"]+)"', line)
                if cask_match:
                    self.casks.add(cask_match.group(1))
                    
        return {
            'formulas': self.formulas,
            'casks': self.casks
        }

class KnowledgeGraphValidator:
    """Validate tools in Neo4j knowledge graph"""
    
    def __init__(self, uri: str, user: str, password: str):
        if not NEO4J_AVAILABLE:
            raise ImportError("neo4j-driver is required for knowledge graph validation")
        self.driver = GraphDatabase.driver(uri, auth=(user, password))
        
    def close(self):
        self.driver.close()
        
    def get_tools_from_graph(self) -> Dict[str, str]:
        """Get all tools from the knowledge graph"""
        tools = {}
        
        query = """
        MATCH (p:Project {id: 'macbook-m4-max-setup'})-[:HAS_CATEGORY]->(cat:Category)-[:CONTAINS]->(tool:Tool)
        RETURN tool.tool_key as key, tool.name as name, tool.command as command
        """
        
        with self.driver.session() as session:
            result = session.run(query)
            for record in result:
                key = record['key']
                command = record['command'] or ''
                
                # Extract brew formula/cask name from command
                brew_match = re.search(r'brew\s+install\s+(?:--cask\s+)?([^\s]+)', command)
                if brew_match:
                    tools[key] = brew_match.group(1)
                    
        return tools

class ValidationReport:
    """Generate validation report"""
    
    def __init__(self):
        self.brewfile_only: Set[str] = set()
        self.graph_only: Set[str] = set()
        self.matched: Set[str] = set()
        self.command_mismatches: List[Tuple[str, str, str]] = []
        
    def compare(self, brewfile_tools: Set[str], graph_tools: Dict[str, str]):
        """Compare Brewfile tools with graph tools"""
        graph_formulas = set(graph_tools.values())
        
        # Find tools only in Brewfile
        self.brewfile_only = brewfile_tools - graph_formulas
        
        # Find tools only in graph (that should be in Brewfile)
        for key, formula in graph_tools.items():
            if formula and formula not in brewfile_tools:
                self.graph_only.add(formula)
            elif formula in brewfile_tools:
                self.matched.add(formula)
                
    def print_report(self):
        """Print validation report"""
        print("\n" + "="*60)
        print("BREWFILE vs KNOWLEDGE GRAPH VALIDATION REPORT")
        print("="*60)
        
        # Summary
        total_brewfile = len(self.brewfile_only) + len(self.matched)
        total_graph = len(self.graph_only) + len(self.matched)
        
        print(f"\nSUMMARY:")
        print(f"  Tools in Brewfile: {total_brewfile}")
        print(f"  Tools in Knowledge Graph: {total_graph}")
        print(f"  Matched tools: {len(self.matched)}")
        print(f"  Tools only in Brewfile: {len(self.brewfile_only)}")
        print(f"  Tools only in Graph: {len(self.graph_only)}")
        
        # Details
        if self.brewfile_only:
            print(f"\n{len(self.brewfile_only)} TOOLS IN BREWFILE BUT NOT IN KNOWLEDGE GRAPH:")
            for tool in sorted(self.brewfile_only):
                print(f"  - {tool}")
                
        if self.graph_only:
            print(f"\n{len(self.graph_only)} TOOLS IN KNOWLEDGE GRAPH BUT NOT IN BREWFILE:")
            for tool in sorted(self.graph_only):
                print(f"  - {tool}")
                
        if self.matched:
            print(f"\n{len(self.matched)} MATCHED TOOLS (sample):")
            for tool in sorted(list(self.matched)[:10]):
                print(f"  ✓ {tool}")
            if len(self.matched) > 10:
                print(f"  ... and {len(self.matched) - 10} more")
                
        # Recommendations
        if self.brewfile_only or self.graph_only:
            print("\nRECOMMENDATIONS:")
            if self.brewfile_only:
                print("  1. Add missing tools to knowledge graph using the AI LLM Guide")
                print("     See: docs/ai-llm-guide.md for instructions")
            if self.graph_only:
                print("  2. Add missing tools to Brewfile or remove from knowledge graph")
                
        print("\n" + "="*60)

def main():
    """Main validation function"""
    # Parse command line arguments
    import argparse
    parser = argparse.ArgumentParser(description='Validate Brewfile against Knowledge Graph')
    parser.add_argument('--brewfile', default='Brewfile', help='Path to Brewfile')
    parser.add_argument('--neo4j-uri', default='bolt://localhost:7687', help='Neo4j URI')
    parser.add_argument('--neo4j-user', default='neo4j', help='Neo4j username')
    parser.add_argument('--neo4j-password', help='Neo4j password (or set NEO4J_PASSWORD env var)')
    parser.add_argument('--skip-graph', action='store_true', help='Skip knowledge graph validation')
    
    args = parser.parse_args()
    
    # Get Neo4j password from env or args
    neo4j_password = args.neo4j_password or os.environ.get('NEO4J_PASSWORD')
    
    # Parse Brewfile
    print(f"Parsing Brewfile at: {args.brewfile}")
    parser = BrewfileParser(args.brewfile)
    brewfile_data = parser.parse()
    
    all_brewfile_tools = brewfile_data['formulas'] | brewfile_data['casks']
    print(f"Found {len(all_brewfile_tools)} tools in Brewfile")
    
    # Validate against knowledge graph if available
    if not args.skip_graph and NEO4J_AVAILABLE and neo4j_password:
        print("\nConnecting to Neo4j knowledge graph...")
        try:
            validator = KnowledgeGraphValidator(args.neo4j_uri, args.neo4j_user, neo4j_password)
            graph_tools = validator.get_tools_from_graph()
            print(f"Found {len(graph_tools)} tools in knowledge graph")
            
            # Generate report
            report = ValidationReport()
            report.compare(all_brewfile_tools, graph_tools)
            report.print_report()
            
            validator.close()
            
            # Exit with error if discrepancies found
            if report.brewfile_only or report.graph_only:
                sys.exit(1)
                
        except Exception as e:
            print(f"Error validating knowledge graph: {e}")
            sys.exit(1)
    else:
        if args.skip_graph:
            print("\nSkipping knowledge graph validation (--skip-graph specified)")
        elif not NEO4J_AVAILABLE:
            print("\nSkipping knowledge graph validation (neo4j-driver not installed)")
        elif not neo4j_password:
            print("\nSkipping knowledge graph validation (no password provided)")
            print("Set NEO4J_PASSWORD environment variable or use --neo4j-password")
            
        print("\nBrewfile Summary:")
        print(f"  Formulas: {len(brewfile_data['formulas'])}")
        print(f"  Casks: {len(brewfile_data['casks'])}")
        print(f"  Total: {len(all_brewfile_tools)}")

if __name__ == "__main__":
    main()
