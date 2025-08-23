#!/bin/bash
#MN Validate Documentation
#MD Validate generated documentation files for consistency and completeness
#MDD Checks documentation files, validates metadata, and ensures all required files exist.
#MI SystemUtilities
#INFO https://github.com/ToolboxMenu
#MICON ✅
#MCOLOR Z2
#MORDER 9

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$PROJECT_ROOT/docs"

echo "✅ Validating Documentation"
echo "========================="
echo "📁 Docs Directory: $DOCS_DIR"
echo ""

# Check if docs directory exists
if [ ! -d "$DOCS_DIR" ]; then
    echo "❌ Error: Documentation directory not found: $DOCS_DIR"
    exit 1
fi

# Check for required files
REQUIRED_FILES=(
    "README.md"
    "scripts_metadata.json"
)

echo "🔍 Checking required files..."
missing_files=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$DOCS_DIR/$file" ]; then
        echo "❌ Missing: $file"
        missing_files=$((missing_files + 1))
    else
        echo "✅ Found: $file"
    fi
done

# Check metadata file validity
if [ -f "$DOCS_DIR/scripts_metadata.json" ]; then
    echo ""
    echo "🔍 Validating metadata file..."
    if jq empty "$DOCS_DIR/scripts_metadata.json" 2>/dev/null; then
        echo "✅ Metadata JSON is valid"
        
        # Count scripts in metadata
        script_count=$(jq length "$DOCS_DIR/scripts_metadata.json" 2>/dev/null || echo "0")
        echo "📊 Scripts in metadata: $script_count"
    else
        echo "❌ Metadata JSON is invalid"
        missing_files=$((missing_files + 1))
    fi
fi

# Check markdown files
echo ""
echo "🔍 Checking documentation files..."
md_files=$(find "$DOCS_DIR" -name "*.md" -type f | wc -l)
echo "📄 Markdown files found: $md_files"

if [ $md_files -eq 0 ]; then
    echo "⚠️ Warning: No markdown files found"
fi

# Summary
echo ""
echo "📋 Validation Summary"
echo "==================="
if [ $missing_files -eq 0 ]; then
    echo "✅ All required files present"
    echo "✅ Documentation validation passed"
    exit 0
else
    echo "❌ $missing_files required files missing"
    echo "❌ Documentation validation failed"
    exit 1
fi