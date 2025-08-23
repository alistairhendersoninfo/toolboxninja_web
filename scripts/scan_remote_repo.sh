#!/bin/bash
#MN Scan Remote Repository
#MD Scan a remote toolbox repository and generate documentation
#MDD Downloads and scans a remote toolbox repository (like toolboxninja), extracts script metadata, and generates comprehensive documentation for web deployment.
#MI SystemUtilities
#INFO https://github.com/ToolboxNinja
#MICON 🔍
#MCOLOR Z2
#MORDER 1

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_ROOT="$(dirname "$SCRIPT_DIR")"
TEMP_DIR=$(mktemp -d)
REPO_URL="$1"
BRANCH="${2:-main}"

echo "🔍 Scanning Remote Toolbox Repository"
echo "====================================="
echo "📡 Repository: $REPO_URL"
echo "🌿 Branch: $BRANCH"
echo "📁 Temp Directory: $TEMP_DIR"
echo ""

# Validate input
if [ -z "$REPO_URL" ]; then
    echo "❌ Error: Repository URL is required"
    echo ""
    echo "Usage: $0 <repository_url> [branch]"
    echo ""
    echo "Examples:"
    echo "  $0 https://github.com/username/toolboxninja"
    echo "  $0 https://github.com/username/toolboxninja develop"
    echo "  $0 git@github.com:username/toolboxninja.git"
    exit 1
fi

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "📥 Step 1: Cloning Repository"
echo "----------------------------"

# Clone the repository
if git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TEMP_DIR/toolbox_source"; then
    echo "✅ Repository cloned successfully"
else
    echo "❌ Error: Failed to clone repository"
    echo "   Please check the URL and branch name"
    exit 1
fi

# Get repository information
cd "$TEMP_DIR/toolbox_source"
REPO_NAME=$(basename "$REPO_URL" .git)
LATEST_COMMIT=$(git log -1 --format="%H")
LATEST_COMMIT_SHORT=$(git log -1 --format="%h")
LATEST_COMMIT_MSG=$(git log -1 --format="%s")
COMMIT_DATE=$(git log -1 --format="%ci")
SCRIPT_COUNT=$(find . -name "*.sh" -type f | wc -l)

echo ""
echo "📊 Repository Information:"
echo "  Name: $REPO_NAME"
echo "  Latest Commit: $LATEST_COMMIT_SHORT"
echo "  Commit Message: $LATEST_COMMIT_MSG"
echo "  Commit Date: $COMMIT_DATE"
echo "  Scripts Found: $SCRIPT_COUNT"

cd "$WEB_ROOT"

echo ""
echo "📚 Step 2: Generating Documentation"
echo "----------------------------------"

# Generate documentation from the cloned repository
if [ -x "$SCRIPT_DIR/generate_documentation.sh" ]; then
    "$SCRIPT_DIR/generate_documentation.sh" "$TEMP_DIR/toolbox_source"
else
    echo "❌ Error: Documentation generator not found"
    exit 1
fi

echo ""
echo "🌐 Step 3: Creating Web Pages"
echo "----------------------------"

# Create web pages
if [ -x "$SCRIPT_DIR/create_web_pages.sh" ]; then
    "$SCRIPT_DIR/create_web_pages.sh"
else
    echo "❌ Error: Web page creator not found"
    exit 1
fi

echo ""
echo "💾 Step 4: Saving Scan Information"
echo "---------------------------------"

# Save scan information
cat > "$WEB_ROOT/.last_scan_info" << EOF
{
  "repository_url": "$REPO_URL",
  "branch": "$BRANCH", 
  "latest_commit": "$LATEST_COMMIT",
  "latest_commit_short": "$LATEST_COMMIT_SHORT",
  "commit_message": "$LATEST_COMMIT_MSG",
  "commit_date": "$COMMIT_DATE",
  "script_count": $SCRIPT_COUNT,
  "scan_date": "$(date -Iseconds)",
  "repository_name": "$REPO_NAME"
}
EOF

echo "$LATEST_COMMIT" > "$WEB_ROOT/.last_scan_commit"

echo "✅ Scan information saved"

echo ""
echo "✅ Step 5: Validation"
echo "--------------------"

# Validate the generated documentation
if [ -x "$SCRIPT_DIR/validate_documentation.sh" ]; then
    "$SCRIPT_DIR/validate_documentation.sh" || echo "⚠️ Validation completed with warnings"
else
    echo "⚠️ Validation script not found, skipping validation"
fi

echo ""
echo "🎉 Remote Repository Scan Complete!"
echo "==================================="
echo "📊 Summary:"
echo "  Repository: $REPO_NAME"
echo "  Scripts Processed: $SCRIPT_COUNT"
echo "  Documentation: $(find docs -name "*.md" | wc -l) files generated"
echo "  Web Pages: $(find _site -name "*.md" | wc -l) pages created"
echo "  Last Commit: $LATEST_COMMIT_SHORT - $LATEST_COMMIT_MSG"
echo ""
echo "🚀 Next Steps:"
echo "1. Review generated documentation in docs/"
echo "2. Check web pages in _site/"
echo "3. Commit and push to deploy:"
echo "   git add . && git commit -m '📚 Update docs from $REPO_NAME' && git push"
echo ""
echo "🌐 Your documentation will be live after GitHub Pages deployment!"

# Show some statistics
if [ -f "docs/scripts_metadata.json" ]; then
    echo ""
    echo "📈 Quick Statistics:"
    echo "  Categories: $(jq -r '.[].category' docs/scripts_metadata.json | sort -u | wc -l)"
    echo "  Authors: $(jq -r '.[] | select(.author != "" and .author != null) | .author' docs/scripts_metadata.json | sort -u | wc -l)"
    echo "  Interactive Scripts: $(jq '[.[] | select(.has_parameters == "true")] | length' docs/scripts_metadata.json)"
fi