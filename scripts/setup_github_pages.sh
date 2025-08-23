#!/bin/bash
#MN Setup GitHub Pages
#MD Setup GitHub Pages for automatic documentation deployment
#MDD Configures GitHub repository settings and creates necessary files for automatic deployment of documentation to GitHub Pages with custom domain support and advanced features.
#MI SystemUtilities
#INFO https://pages.github.com/
#MICON 🌐
#MCOLOR Z2
#MORDER 9

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🌐 Setting up GitHub Pages"
echo "=========================="
echo "📁 Project Root: $PROJECT_ROOT"
echo ""

# Check if we're in a git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "❌ Error: Not in a Git repository"
    echo "   Please run this script from the project root"
    exit 1
fi

# Get repository information
REPO_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
if [ -z "$REPO_URL" ]; then
    echo "❌ Error: No remote origin found"
    echo "   Please add a GitHub remote first: git remote add origin <url>"
    exit 1
fi

# Extract owner and repo name
if [[ "$REPO_URL" =~ github\.com[:/]([^/]+)/([^.]+) ]]; then
    REPO_OWNER="${BASH_REMATCH[1]}"
    REPO_NAME="${BASH_REMATCH[2]}"
    PAGES_URL="https://${REPO_OWNER}.github.io/${REPO_NAME}"
else
    echo "❌ Error: Could not parse GitHub repository URL: $REPO_URL"
    exit 1
fi

echo "📊 Repository Information:"
echo "  Owner: $REPO_OWNER"
echo "  Repository: $REPO_NAME"
echo "  Pages URL: $PAGES_URL"
echo ""

# Create GitHub Pages configuration
echo "⚙️  Step 1: Creating GitHub Pages Configuration"
echo "----------------------------------------------"

# Create CNAME file if custom domain is desired
read -p "🌍 Do you want to use a custom domain? (y/N): " use_custom_domain
if [[ "$use_custom_domain" =~ ^[Yy]$ ]]; then
    read -p "🔗 Enter your custom domain (e.g., docs.example.com): " custom_domain
    if [ -n "$custom_domain" ]; then
        echo "$custom_domain" > "$PROJECT_ROOT/CNAME"
        echo "✅ Created CNAME file with domain: $custom_domain"
        PAGES_URL="https://$custom_domain"
    fi
fi

# Create .nojekyll file to allow files starting with underscore
touch "$PROJECT_ROOT/.nojekyll"
echo "✅ Created .nojekyll file"

# Create GitHub Pages specific README
cat > "$PROJECT_ROOT/README_PAGES.md" << EOF
# 🛡️ Toolbox Documentation

Welcome to the Toolbox Documentation site! This documentation is automatically generated from script headers and deployed via GitHub Pages.

## 🌐 Live Documentation

Visit the live documentation at: [$PAGES_URL]($PAGES_URL)

## 🔄 Automatic Updates

This documentation is automatically updated whenever scripts are modified and committed to the repository. The process:

1. **Script Changes** → Commit to repository
2. **GitHub Actions** → Generate documentation
3. **GitHub Pages** → Deploy updated site
4. **Live Site** → Reflects latest changes

## 📚 Features

- **📋 Complete Documentation** - All scripts documented with metadata
- **🔍 Advanced Search** - Client-side search functionality
- **📱 Mobile Friendly** - Responsive design for all devices
- **🎨 Modern UI** - Clean, professional appearance
- **📊 Statistics** - Comprehensive metrics and analytics
- **🔗 Cross-References** - Easy navigation between sections

## 🛠️ Local Development

To work with the documentation locally:

\`\`\`bash
# Generate documentation
./scripts/generate_documentation.sh

# Create web pages
./scripts/create_web_pages.sh

# Serve locally (requires Jekyll)
bundle exec jekyll serve --source _site
\`\`\`

## 📞 Support

- **Repository**: [GitHub Repository]($REPO_URL)
- **Issues**: [Report Issues]($REPO_URL/issues)
- **Documentation**: [Setup Guide](GITFLOW_DOCUMENTATION_GUIDE.md)

---

*📅 Last updated: $(date '+%Y-%m-%d %H:%M:%S')*
EOF

echo "✅ Created GitHub Pages README"

# Update main Jekyll configuration
echo ""
echo "⚙️  Step 2: Updating Jekyll Configuration"
echo "----------------------------------------"

cat > "$PROJECT_ROOT/_config.yml" << EOF
# Site settings
title: "🛡️ Toolbox Documentation"
description: "Comprehensive documentation for system administration scripts"
baseurl: ""
url: "$PAGES_URL"

# Repository information
repository: "$REPO_OWNER/$REPO_NAME"
github:
  owner_name: "$REPO_OWNER"
  repository_name: "$REPO_NAME"

# Build settings
markdown: kramdown
highlighter: rouge
theme: minima

# Plugins
plugins:
  - jekyll-feed
  - jekyll-sitemap
  - jekyll-seo-tag
  - jekyll-github-metadata

# Kramdown settings
kramdown:
  input: GFM
  syntax_highlighter: rouge
  syntax_highlighter_opts:
    block:
      line_numbers: true

# Collections
collections:
  categories:
    output: true
    permalink: /:collection/:name/

# Defaults
defaults:
  - scope:
      path: ""
      type: "pages"
    values:
      layout: "default"
  - scope:
      path: ""
      type: "categories"
    values:
      layout: "category"

# Exclude files from processing
exclude:
  - scripts/
  - src/
  - target/
  - Cargo.toml
  - build.sh
  - "*.sh"
  - vendor/
  - .bundle/
  - .sass-cache/
  - .jekyll-cache/
  - gemfiles/
  - Gemfile
  - Gemfile.lock
  - node_modules/
  - "*.gemspec"

# Include files that start with underscore
include:
  - _site

# SEO settings
author: "$REPO_OWNER"
twitter:
  username: "$REPO_OWNER"
social:
  name: "Toolbox Documentation"
  links:
    - "$REPO_URL"

# Google Analytics (optional)
# google_analytics: UA-XXXXXXXX-X

# GitHub Pages specific settings
github_pages:
  source: "/"
  destination: "_site"
EOF

echo "✅ Updated Jekyll configuration"

# Create Gemfile for GitHub Pages
echo ""
echo "💎 Step 3: Creating Gemfile for Dependencies"
echo "-------------------------------------------"

cat > "$PROJECT_ROOT/Gemfile" << 'EOF'
source "https://rubygems.org"

# GitHub Pages gem
gem "github-pages", group: :jekyll_plugins

# Additional plugins
group :jekyll_plugins do
  gem "jekyll-feed"
  gem "jekyll-sitemap"
  gem "jekyll-seo-tag"
  gem "jekyll-github-metadata"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]
EOF

echo "✅ Created Gemfile"

# Create GitHub issue templates
echo ""
echo "📝 Step 4: Creating GitHub Issue Templates"
echo "-----------------------------------------"

mkdir -p "$PROJECT_ROOT/.github/ISSUE_TEMPLATE"

cat > "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/documentation_issue.md" << 'EOF'
---
name: Documentation Issue
about: Report an issue with the documentation
title: '[DOCS] '
labels: 'documentation'
assignees: ''
---

## 📚 Documentation Issue

### 🐛 Problem Description
A clear and concise description of what the documentation issue is.

### 📍 Location
- **Page/Section**: 
- **URL**: 
- **Script**: (if applicable)

### 🔍 Expected Behavior
What you expected to see in the documentation.

### 📸 Screenshots
If applicable, add screenshots to help explain your problem.

### 💡 Suggested Fix
If you have suggestions for how to fix the issue, please describe them here.

### 🌍 Environment
- **Browser**: 
- **Device**: 
- **OS**: 

### 📋 Additional Context
Add any other context about the problem here.
EOF

cat > "$PROJECT_ROOT/.github/ISSUE_TEMPLATE/script_request.md" << 'EOF'
---
name: Script Request
about: Request a new script or modification to existing script
title: '[SCRIPT] '
labels: 'enhancement'
assignees: ''
---

## 🛠️ Script Request

### 📋 Description
A clear and concise description of what script you need or what modification you want.

### 🎯 Use Case
Describe the use case or problem this script would solve.

### 📝 Proposed Implementation
If you have ideas about how this should be implemented, please describe them.

### 🏷️ Metadata
Please provide the following information for the script:

- **Category**: 
- **Name**: 
- **Description**: 
- **Icon**: (emoji)
- **Tags**: (comma-separated)
- **Author**: 

### 📚 Documentation
Any relevant documentation or references that might help.

### 📋 Additional Context
Add any other context or screenshots about the feature request here.
EOF

echo "✅ Created GitHub issue templates"

# Create pull request template
cat > "$PROJECT_ROOT/.github/pull_request_template.md" << 'EOF'
## 📋 Pull Request Description

### 🎯 Purpose
Brief description of what this PR accomplishes.

### 🛠️ Changes Made
- [ ] Added new script(s)
- [ ] Modified existing script(s)
- [ ] Updated documentation
- [ ] Fixed bug(s)
- [ ] Other: ___________

### 📝 Script Information (if applicable)
- **Script Name**: 
- **Category**: 
- **Description**: 
- **Tags**: 

### ✅ Checklist
- [ ] Script has proper metadata headers (#MN, #MD, etc.)
- [ ] Script is executable
- [ ] Documentation will be auto-generated
- [ ] Tested the script locally
- [ ] Follows project conventions

### 📸 Screenshots (if applicable)
Add screenshots of the script in action or documentation changes.

### 📋 Additional Notes
Any additional information or context for reviewers.
EOF

echo "✅ Created pull request template"

# Create GitHub Actions status badge
echo ""
echo "🏷️  Step 5: Creating Status Badges"
echo "--------------------------------"

# Add badges to main README if it exists
if [ -f "$PROJECT_ROOT/README.md" ]; then
    # Check if badges already exist
    if ! grep -q "github.com/$REPO_OWNER/$REPO_NAME/actions" "$PROJECT_ROOT/README.md"; then
        # Add badges at the top of README
        temp_readme=$(mktemp)
        cat > "$temp_readme" << EOF
# 🛡️ Toolbox Menu System

[![Documentation](https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/generate-docs.yml/badge.svg)](https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/generate-docs.yml)
[![Pages](https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/$REPO_OWNER/$REPO_NAME/actions/workflows/deploy-pages.yml)
[![Live Documentation]($PAGES_URL/badge.svg)]($PAGES_URL)

📚 **[Live Documentation]($PAGES_URL)** | 🔧 **[Setup Guide](COMPLETE_SETUP_GUIDE.md)** | 📊 **[Statistics]($PAGES_URL/STATISTICS.html)**

EOF
        tail -n +2 "$PROJECT_ROOT/README.md" >> "$temp_readme"
        mv "$temp_readme" "$PROJECT_ROOT/README.md"
        echo "✅ Added status badges to README.md"
    else
        echo "ℹ️  Status badges already exist in README.md"
    fi
fi

echo ""
echo "📋 Step 6: Final Instructions"
echo "----------------------------"

cat << EOF
🎉 GitHub Pages Setup Complete!

📊 Summary of changes:
✅ Created GitHub Pages configuration files
✅ Updated Jekyll configuration
✅ Created Gemfile for dependencies
✅ Added GitHub issue templates
✅ Created pull request template
✅ Added status badges (if README.md exists)

🚀 Next steps:

1. **Commit and push changes:**
   git add .
   git commit -m "🌐 Setup GitHub Pages deployment"
   git push origin main

2. **Enable GitHub Pages:**
   - Go to: https://github.com/$REPO_OWNER/$REPO_NAME/settings/pages
   - Source: "GitHub Actions"
   - Click "Save"

3. **Wait for deployment:**
   - Check: https://github.com/$REPO_OWNER/$REPO_NAME/actions
   - First deployment may take 5-10 minutes

4. **Visit your documentation:**
   - URL: $PAGES_URL
   - Updates automatically on every commit!

📚 Features enabled:
✅ Automatic documentation generation
✅ Professional web interface
✅ Mobile-responsive design
✅ Advanced search functionality
✅ SEO optimization
✅ RSS feeds
✅ PWA support

🔧 Local development:
   bundle install
   bundle exec jekyll serve --source _site

💡 Tips:
- Documentation updates automatically on script commits
- Custom domain supported (edit CNAME file)
- Analytics can be added (edit _config.yml)
- Themes can be customized (edit CSS in workflows)

🎯 Your documentation site will be live at:
   $PAGES_URL

Happy documenting! 🚀
EOF