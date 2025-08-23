#!/bin/bash
#MN Configure Toolbox Repository
#MD Configure the main toolbox repository for documentation scanning
#MDD Sets up configuration to automatically scan and generate documentation from the main toolboxninja repository, including repository URL, branch settings, and scan preferences.
#MI SystemUtilities
#INFO https://github.com/ToolboxNinja
#MICON ⚙️
#MCOLOR Z2
#MORDER 2

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$WEB_ROOT/config"
CONFIG_FILE="$CONFIG_DIR/toolbox_config.yml"

REPO_URL="$1"
BRANCH="${2:-main}"

echo "⚙️ Configuring Toolbox Repository"
echo "================================="
echo ""

# Create config directory
mkdir -p "$CONFIG_DIR"

if [ -z "$REPO_URL" ]; then
    echo "🔧 Interactive Configuration Setup"
    echo "---------------------------------"
    
    # Interactive setup
    read -p "📡 Enter toolbox repository URL: " REPO_URL
    read -p "🌿 Enter branch name (default: main): " BRANCH_INPUT
    BRANCH="${BRANCH_INPUT:-main}"
    
    echo ""
    echo "📁 Scan Path Configuration"
    echo "-------------------------"
    echo "Which directories should be scanned for scripts?"
    echo "(Enter paths separated by spaces, or press Enter for all)"
    read -p "📂 Scan paths (e.g., LinuxTools SystemSecurity): " SCAN_PATHS_INPUT
    
    if [ -n "$SCAN_PATHS_INPUT" ]; then
        IFS=' ' read -ra SCAN_PATHS <<< "$SCAN_PATHS_INPUT"
    else
        SCAN_PATHS=(".")
    fi
    
    echo ""
    echo "🚫 Exclusion Configuration"
    echo "-------------------------"
    echo "Which directories should be excluded from scanning?"
    echo "(Common exclusions: docs .github target node_modules)"
    read -p "🚫 Exclude paths: " EXCLUDE_PATHS_INPUT
    
    if [ -n "$EXCLUDE_PATHS_INPUT" ]; then
        IFS=' ' read -ra EXCLUDE_PATHS <<< "$EXCLUDE_PATHS_INPUT"
    else
        EXCLUDE_PATHS=("docs" ".github" "target" "node_modules" ".git" "build" "dist")
    fi
    
    echo ""
    echo "🎨 Website Configuration"
    echo "-----------------------"
    read -p "📝 Website title: " SITE_TITLE
    read -p "📄 Website description: " SITE_DESCRIPTION
    read -p "🎨 Theme (professional/modern/minimal): " THEME
    
    SITE_TITLE="${SITE_TITLE:-Toolbox Documentation}"
    SITE_DESCRIPTION="${SITE_DESCRIPTION:-Comprehensive system administration tools}"
    THEME="${THEME:-professional}"
    
else
    echo "📋 Command Line Configuration"
    echo "----------------------------"
    echo "📡 Repository: $REPO_URL"
    echo "🌿 Branch: $BRANCH"
    
    # Default configuration for command line usage
    SCAN_PATHS=(".")
    EXCLUDE_PATHS=("docs" ".github" "target" "node_modules" ".git" "build" "dist" "src" "Cargo.toml" "*.md")
    SITE_TITLE="Toolbox Documentation"
    SITE_DESCRIPTION="Comprehensive system administration tools"
    THEME="professional"
fi

echo ""
echo "💾 Creating Configuration File"
echo "-----------------------------"

# Create the configuration file
cat > "$CONFIG_FILE" << EOF
# ToolboxNinja Web Configuration
# Generated on $(date)

# Main toolbox repository settings
toolbox_repositories:
  - name: "main"
    url: "$REPO_URL"
    branch: "$BRANCH"
    scan_paths:
EOF

# Add scan paths
for path in "${SCAN_PATHS[@]}"; do
    echo "      - \"$path\"" >> "$CONFIG_FILE"
done

cat >> "$CONFIG_FILE" << EOF
    exclude_paths:
EOF

# Add exclude paths
for path in "${EXCLUDE_PATHS[@]}"; do
    echo "      - \"$path\"" >> "$CONFIG_FILE"
done

cat >> "$CONFIG_FILE" << EOF

# Website settings
web_settings:
  title: "$SITE_TITLE"
  description: "$SITE_DESCRIPTION"
  theme: "$THEME"
  base_url: ""
  
  # SEO settings
  author: "$(git config user.name 2>/dev/null || echo 'Toolbox Team')"
  keywords: "toolbox, system administration, scripts, documentation"
  
  # Social media
  twitter_username: ""
  github_username: "$(echo "$REPO_URL" | sed -n 's/.*github\.com[:/]\([^/]*\)\/.*/\1/p')"
  
  # Analytics (optional)
  google_analytics: ""
  
  # Custom domain (optional)
  custom_domain: ""

# Documentation generation settings
generation_settings:
  # Include scripts without headers
  include_headerless: true
  
  # Default values for missing metadata
  default_icon: "📝"
  default_category: "Uncategorized"
  default_order: 999
  
  # File patterns to scan
  script_patterns:
    - "*.sh"
    - "*.bash"
  
  # Metadata extraction settings
  max_header_lines: 50
  require_executable: false

# Deployment settings
deployment:
  # GitHub Pages settings
  github_pages:
    enabled: true
    branch: "gh-pages"
    cname: ""
  
  # Netlify settings (optional)
  netlify:
    enabled: false
    build_command: "./scripts/create_web_pages.sh"
    publish_directory: "_site"
  
  # Custom deployment (optional)
  custom:
    enabled: false
    deploy_command: ""
    deploy_path: ""

# Automation settings
automation:
  # Automatic scanning schedule
  schedule:
    enabled: true
    cron: "0 2 * * *"  # Daily at 2 AM UTC
  
  # Webhook settings (for immediate updates)
  webhooks:
    enabled: false
    secret: ""
  
  # Update behavior
  auto_commit: true
  commit_message_template: "📚 Auto-update documentation from {repository}"
EOF

echo "✅ Configuration file created: $CONFIG_FILE"

# Create a repository info file for quick reference
cat > "$CONFIG_DIR/repository_info.json" << EOF
{
  "repository_url": "$REPO_URL",
  "branch": "$BRANCH",
  "configured_date": "$(date -Iseconds)",
  "scan_paths": [$(printf '"%s",' "${SCAN_PATHS[@]}" | sed 's/,$//')]
  "exclude_paths": [$(printf '"%s",' "${EXCLUDE_PATHS[@]}" | sed 's/,$//')]
}
EOF

echo "✅ Repository info saved: $CONFIG_DIR/repository_info.json"

echo ""
echo "🧪 Testing Configuration"
echo "-----------------------"

# Test the configuration by doing a quick scan
echo "🔍 Testing repository access..."
if git ls-remote "$REPO_URL" "$BRANCH" >/dev/null 2>&1; then
    echo "✅ Repository is accessible"
    
    # Do a quick scan test
    echo "📊 Running test scan..."
    if "$SCRIPT_DIR/scan_remote_repo.sh" "$REPO_URL" "$BRANCH" >/dev/null 2>&1; then
        echo "✅ Test scan completed successfully"
    else
        echo "⚠️ Test scan had issues (check repository contents)"
    fi
else
    echo "❌ Error: Cannot access repository"
    echo "   Please check the URL and your access permissions"
fi

echo ""
echo "🎉 Configuration Complete!"
echo "========================="
echo ""
echo "📋 Summary:"
echo "  Repository: $REPO_URL"
echo "  Branch: $BRANCH"
echo "  Scan Paths: ${SCAN_PATHS[*]}"
echo "  Exclude Paths: ${EXCLUDE_PATHS[*]}"
echo "  Website Title: $SITE_TITLE"
echo ""
echo "🚀 Next Steps:"
echo ""
echo "1. **Generate Initial Documentation:**"
echo "   ./scripts/scan_remote_repo.sh '$REPO_URL' '$BRANCH'"
echo ""
echo "2. **Setup GitHub Pages:**"
echo "   ./scripts/setup_github_pages.sh"
echo ""
echo "3. **Deploy Documentation:**"
echo "   git add . && git commit -m '⚙️ Configure toolbox repository' && git push"
echo ""
echo "4. **Automatic Updates:**"
echo "   - Documentation will update daily at 2 AM UTC"
echo "   - Manual updates: GitHub Actions > Run workflow"
echo "   - Webhook updates: Configure in repository settings"
echo ""
echo "📚 Your documentation will be automatically generated from:"
echo "   $REPO_URL"
echo ""
echo "🌐 And deployed to your GitHub Pages site!"

# Create a quick reference script
cat > "$WEB_ROOT/quick_update.sh" << EOF
#!/bin/bash
# Quick update script - generated by configure_toolbox_repo.sh

echo "🔄 Quick Documentation Update"
echo "============================"

# Scan the configured repository
./scripts/scan_remote_repo.sh '$REPO_URL' '$BRANCH'

# Commit and push if there are changes
if [ -n "\$(git status --porcelain)" ]; then
    git add .
    git commit -m "📚 Quick update from $REPO_URL"
    git push
    echo "✅ Documentation updated and deployed!"
else
    echo "ℹ️ No changes detected"
fi
EOF

chmod +x "$WEB_ROOT/quick_update.sh"
echo ""
echo "💡 Tip: Use ./quick_update.sh for manual updates anytime!"