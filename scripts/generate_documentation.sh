#!/bin/bash
#MN Generate Documentation
#MD Generate comprehensive documentation from script headers
#MDD Main documentation generator that scans toolbox repositories, extracts metadata, and creates organized documentation files including table of contents, category pages, and individual script documentation.
#MI SystemUtilities
#INFO https://github.com/ToolboxNinja
#MICON 📚
#MCOLOR Z2
#MORDER 5

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_ROOT="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="${1:-toolbox_source}"
DOCS_DIR="$WEB_ROOT/docs"
METADATA_FILE="$DOCS_DIR/scripts_metadata.json"
CONFIG_FILE="$WEB_ROOT/config/exclusions.yml"

echo "📚 Generating Toolbox Documentation"
echo "==================================="
echo "📁 Web Root: $WEB_ROOT"
echo "📂 Source Directory: $SOURCE_DIR"
echo "📄 Docs Directory: $DOCS_DIR"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "❌ Error: Source directory not found: $SOURCE_DIR"
    echo "   Please provide a valid toolbox repository path"
    exit 1
fi

# Create docs directory
mkdir -p "$DOCS_DIR"

# Extract metadata from all scripts
echo "🔍 Step 1: Extracting Script Metadata"
echo "-------------------------------------"
"$SCRIPT_DIR/extract_script_metadata.sh" all "$SOURCE_DIR" "$METADATA_FILE"

if [ ! -f "$METADATA_FILE" ]; then
    echo "❌ Error: Failed to generate metadata file"
    exit 1
fi

echo ""

# Generate documentation files
echo "📝 Step 2: Generating Documentation Files"
echo "-----------------------------------------"

# Function to generate table of contents
generate_table_of_contents() {
    local output_file="$DOCS_DIR/README.md"
    
    echo "📋 Generating table of contents..."
    
    cat > "$output_file" << 'EOF'
# 🛡️ ToolboxNinja Documentation

This documentation is automatically generated from script headers in the ToolboxNinja repository and provides comprehensive information about all available system administration tools.

## 📊 Overview

EOF
    
    # Add statistics with error handling
    local total_scripts=$(jq length "$METADATA_FILE" 2>/dev/null || echo "0")
    local categories=$(jq -r '.[].category' "$METADATA_FILE" 2>/dev/null | sort -u | wc -l || echo "0")
    local scripts_with_params=$(jq '[.[] | select(.has_parameters == "true")] | length' "$METADATA_FILE" 2>/dev/null || echo "0")
    local authors=$(jq -r '.[] | select(.author != "" and .author != null) | .author' "$METADATA_FILE" 2>/dev/null | sort -u | wc -l || echo "0")
    
    cat >> "$output_file" << EOF
- **Total Scripts**: $total_scripts
- **Categories**: $categories
- **Scripts with Parameters**: $scripts_with_params
- **Authors**: $authors
- **Last Updated**: $(date '+%Y-%m-%d %H:%M:%S')

## 📁 Categories

EOF
    
    # Generate category list with counts
    if [ "$total_scripts" -gt 0 ]; then
        jq -r '.[].category' "$METADATA_FILE" 2>/dev/null | sort | uniq -c | sort -nr | while read count category; do
            local category_file=$(echo "$category" | tr '::' '_' | tr '/' '_').md
            echo "- **[$category]($category_file)** ($count scripts)" >> "$output_file"
        done
    fi
    
    cat >> "$output_file" << 'EOF'

## 🔍 Quick Reference

### By Functionality

#### System Administration
EOF
    
    # Add quick reference sections with error handling
    jq -r '.[] | select(.tags[] | test("system|admin|monitoring")) | "- [\(.name)](\(.category | gsub("::"; "_") | gsub("/"; "_")).md#\(.name | gsub(" "; "-") | ascii_downcase)) - \(.description)"' "$METADATA_FILE" 2>/dev/null | sort >> "$output_file" || echo "- No system administration scripts found" >> "$output_file"
    
    echo "" >> "$output_file"
    echo "#### Security Tools" >> "$output_file"
    jq -r '.[] | select(.tags[] | test("security|ssl|firewall")) | "- [\(.name)](\(.category | gsub("::"; "_") | gsub("/"; "_")).md#\(.name | gsub(" "; "-") | ascii_downcase)) - \(.description)"' "$METADATA_FILE" 2>/dev/null | sort >> "$output_file" || echo "- No security tools found" >> "$output_file"
    
    cat >> "$output_file" << EOF

## 🎯 Script Features

### Color Coding
- 🔴 **Red (Z1)** - Dangerous operations requiring caution
- 🟡 **Yellow (Z3)** - Operations requiring attention  
- 🟢 **Green (Z2)** - Safe operations
- 🔵 **Blue (Z4)** - Information and utility scripts

### Icons Guide
- 🛠️ General tools and utilities
- ⚙️ Configuration and setup scripts
- 📦 Installation and package management
- 🚀 Deployment and launch scripts
- 🔒 Security and authentication
- 📊 Monitoring and analysis
- 🔧 Maintenance and repair
- 📝 Documentation and reporting

## 📖 Usage

To use these scripts with the ToolboxNinja Menu System:

\`\`\`bash
# Install the toolbox menu system
curl -sSL https://raw.githubusercontent.com/yourusername/toolboxninja/main/install.sh | bash

# Launch the interactive menu
toolbox

# Or run scripts directly
/opt/toolbox/CategoryName/script_name.sh
\`\`\`

## 🔄 Documentation Updates

This documentation is automatically updated when scripts are modified in the main ToolboxNinja repository.

---

*📅 Generated on $(date '+%Y-%m-%d %H:%M:%S') by the ToolboxNinja Web Documentation System*
EOF
    
    echo "✅ Table of contents generated: $output_file"
}

# Function to generate category documentation  
generate_category_docs() {
    echo "📂 Generating category documentation..."
    
    local categories=$(jq -r '.[].category' "$METADATA_FILE" 2>/dev/null | sort -u || echo "")
    
    while IFS= read -r category; do
        if [ -z "$category" ] || [ "$category" = "null" ]; then
            continue
        fi
        
        local category_file="$DOCS_DIR/$(echo "$category" | tr '::' '_' | tr '/' '_').md"
        local category_display=$(echo "$category" | tr '::' ' > ' | tr '/' ' > ')
        
        echo "  📄 Creating: $(basename "$category_file")"
        
        cat > "$category_file" << EOF
# 📁 $category_display

EOF
        
        local script_count=$(jq "[.[] | select(.category == \"$category\")] | length" "$METADATA_FILE" 2>/dev/null || echo "0")
        local scripts_with_params=$(jq "[.[] | select(.category == \"$category\" and .has_parameters == \"true\")] | length" "$METADATA_FILE" 2>/dev/null || echo "0")
        
        cat >> "$category_file" << EOF
**Category Statistics:**
- Scripts: $script_count
- Interactive Scripts: $scripts_with_params
- Category Path: \`$category\`

## Scripts in this Category

EOF
        
        # Add scripts in this category with error handling
        jq -r ".[] | select(.category == \"$category\") | [.order, .name, .filename, .description, .detailed_description, .info_url, .icon, .author, .tags, .has_parameters] | @tsv" "$METADATA_FILE" 2>/dev/null | \
        sort -n | while IFS=$'\t' read -r order name filename description detailed_description info_url icon author tags has_parameters; do
            
            cat >> "$category_file" << EOF
### $icon $name

**File:** \`$filename\`  
**Description:** $description

EOF
            
            if [ -n "$detailed_description" ] && [ "$detailed_description" != "null" ] && [ "$detailed_description" != "" ]; then
                cat >> "$category_file" << EOF
**Details:** $detailed_description

EOF
            fi
            
            if [ -n "$author" ] && [ "$author" != "null" ] && [ "$author" != "" ]; then
                cat >> "$category_file" << EOF
**Author:** $author  
EOF
            fi
            
            if [ "$has_parameters" = "true" ]; then
                cat >> "$category_file" << EOF
**Interactive:** ✅ This script has interactive parameters  
EOF
            fi
            
            if [ -n "$info_url" ] && [ "$info_url" != "null" ] && [ "$info_url" != "" ]; then
                cat >> "$category_file" << EOF
**More Info:** [$info_url]($info_url)  
EOF
            fi
            
            cat >> "$category_file" << EOF

---

EOF
        done
        
        cat >> "$category_file" << EOF

## Navigation

- [🏠 Back to Main Documentation](README.md)
- [📊 All Categories](README.md#-categories)

---

*📅 Generated on $(date '+%Y-%m-%d %H:%M:%S')*
EOF
        
    done <<< "$categories"
    
    echo "✅ Category documentation generated"
}

# Main execution
echo "🚀 Starting documentation generation..."

generate_table_of_contents
generate_category_docs

# Create .gitkeep for docs directory
touch "$DOCS_DIR/.gitkeep"

echo ""
echo "🎉 Documentation Generation Complete!"
echo "===================================="
echo "📁 Documentation location: $DOCS_DIR"
echo "📄 Files generated:"
echo "  - README.md (Table of Contents)"
echo "  - Category files (*.md)"
echo "  - scripts_metadata.json (Raw metadata)"
echo ""
echo "🔗 View documentation:"
echo "  - Main: $DOCS_DIR/README.md"
echo ""
echo "✅ Ready for web page creation and deployment!"