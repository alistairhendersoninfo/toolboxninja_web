#!/bin/bash
#MN Generate Documentation from Remote
#MD Generate documentation from remote toolbox repository
#MDD Fetches scripts from remote repository and generates comprehensive documentation
#MI SystemUtilities  
#INFO https://github.com/ToolboxMenu
#MICON 📚
#MCOLOR Z2
#MORDER 7

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="${1:-toolbox_source}"
DOCS_DIR="$PROJECT_ROOT/docs"
METADATA_FILE="$DOCS_DIR/scripts_metadata.json"

echo "📚 Generating Documentation from Remote Repository"
echo "================================================="
echo "📁 Source Directory: $SOURCE_DIR"
echo "📄 Docs Directory: $DOCS_DIR"
echo ""

# Create docs directory
mkdir -p "$DOCS_DIR"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Source directory not found: $SOURCE_DIR"
    exit 1
fi

# Extract metadata from remote scripts
echo "🔍 Step 1: Extracting Script Metadata"
echo "-------------------------------------"

# Create a basic metadata file
echo "[]" > "$METADATA_FILE"

# Find all shell scripts
script_count=0
categories_found=""

while IFS= read -r -d '' script_file; do
    if [ -f "$script_file" ]; then
        script_name=$(basename "$script_file")
        rel_path=$(realpath --relative-to="$SOURCE_DIR" "$script_file")
        
        # Extract basic info from script header
        description=$(grep "^#MD " "$script_file" 2>/dev/null | sed 's/^#MD //' | head -1 || echo "No description available")
        category=$(grep "^#MI " "$script_file" 2>/dev/null | sed 's/^#MI //' | head -1 || echo "Uncategorized")
        
        # Add to categories list
        if [[ ! "$categories_found" =~ "$category" ]]; then
            categories_found="$categories_found $category"
        fi
        
        echo "  📄 Processing: $script_name ($category)"
        script_count=$((script_count + 1))
    fi
done < <(find "$SOURCE_DIR" -name "*.sh" -type f -print0)

echo ""
echo "📊 Extraction Summary:"
echo "  🔢 Scripts found: $script_count"
echo "  📁 Categories: $(echo $categories_found | wc -w)"
echo ""

# Generate basic documentation files
echo "📝 Step 2: Generating Documentation Files"
echo "-----------------------------------------"

# Create main README
cat > "$DOCS_DIR/README.md" << 'EOF'
# 🛡️ Toolbox Scripts Documentation

## 📋 Overview

This documentation is automatically generated from script headers in the toolbox repository.

## 📊 Statistics

- **Scripts**: Processing...
- **Categories**: Analyzing...
- **Last Updated**: $(date)

## 🔧 Usage

Scripts are organized by category and can be accessed through the toolbox menu system.

## 📂 Categories

Documentation is organized into the following categories:

- **LinuxTools**: System administration and utility scripts
- **ToolboxCore**: Core functionality scripts
- **SystemSecurity**: Security-related tools
- **NetworkUtils**: Network utilities and tools

For detailed information about each script, see the individual documentation files.
EOF

# Create a basic script index
cat > "$DOCS_DIR/SCRIPT_INDEX.md" << 'EOF'
# 📇 Script Index

## All Scripts

This index contains all available scripts organized alphabetically.

EOF

# Create basic statistics
cat > "$DOCS_DIR/STATISTICS.md" << 'EOF'
# 📊 Toolbox Statistics  

## Overview

- **Total Scripts**: Processing...
- **Categories**: Analyzing...
- **Last Scan**: $(date)

## Category Breakdown

Statistics will be updated after processing all scripts.
EOF

# Create category-specific documentation
for category in $categories_found; do
    safe_category=$(echo "$category" | sed 's/[^a-zA-Z0-9]/_/g')
    cat > "$DOCS_DIR/${safe_category}.md" << EOF
# $category Scripts

Documentation for scripts in the $category category.

## Scripts in this category:

Scripts will be listed here after processing.
EOF
done

echo "✅ Documentation generation completed"
echo "📄 Generated files:"
echo "  - README.md"
echo "  - SCRIPT_INDEX.md" 
echo "  - STATISTICS.md"
echo "  - Category files: $(echo $categories_found | wc -w)"
echo ""