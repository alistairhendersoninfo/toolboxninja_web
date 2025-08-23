#!/bin/bash
#MN Create Web Pages
#MD Create enhanced web pages from Markdown documentation
#MDD Converts generated Markdown documentation into enhanced web pages with navigation, search, and interactive features for deployment to GitHub Pages or other web platforms.
#MI SystemUtilities
#INFO https://pages.github.com/
#MICON 🌐
#MCOLOR Z2
#MORDER 8

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCS_DIR="$PROJECT_ROOT/docs"
WEB_DIR="$PROJECT_ROOT/_site"

echo "🌐 Creating Enhanced Web Pages"
echo "=============================="
echo "📁 Docs Directory: $DOCS_DIR"
echo "🌍 Web Directory: $WEB_DIR"
echo ""

# Ensure docs exist
if [ ! -d "$DOCS_DIR" ]; then
    echo "❌ Error: Documentation directory not found: $DOCS_DIR"
    echo "   Please run ./scripts/generate_documentation.sh first"
    exit 1
fi

# Create web directory
mkdir -p "$WEB_DIR"

echo "🔄 Step 1: Processing Markdown Files"
echo "-----------------------------------"

# Function to enhance markdown files
enhance_markdown() {
    local input_file="$1"
    local output_file="$2"
    local title="$3"
    
    echo "  📄 Processing: $(basename "$input_file")"
    
    # Add YAML front matter for Jekyll
    cat > "$output_file" << EOF
---
layout: default
title: "$title"
description: "Auto-generated documentation from script headers"
---

EOF
    
    # Process the markdown content
    sed 's/\.md)/\.html)/g' "$input_file" >> "$output_file"
    
    # Add navigation footer if not already present
    if ! grep -q "## Navigation" "$output_file"; then
        cat >> "$output_file" << 'EOF'

---

## 🧭 Navigation

- [🏠 Home](index.html)
- [📇 Script Index](SCRIPT_INDEX.html)
- [📊 Statistics](STATISTICS.html)
- [📚 All Categories](#categories)

EOF
    fi
}

# Process main documentation files
enhance_markdown "$DOCS_DIR/README.md" "$WEB_DIR/index.md" "Toolbox Documentation"
enhance_markdown "$DOCS_DIR/SCRIPT_INDEX.md" "$WEB_DIR/SCRIPT_INDEX.md" "Script Index"
enhance_markdown "$DOCS_DIR/STATISTICS.md" "$WEB_DIR/STATISTICS.md" "Statistics"

# Process category files
for category_file in "$DOCS_DIR"/*.md; do
    filename=$(basename "$category_file")
    
    # Skip files we've already processed
    if [[ "$filename" == "README.md" || "$filename" == "SCRIPT_INDEX.md" || "$filename" == "STATISTICS.md" ]]; then
        continue
    fi
    
    # Extract category name from filename
    category_name=$(echo "$filename" | sed 's/\.md$//' | sed 's/__/ > /g' | sed 's/_/ /g')
    
    enhance_markdown "$category_file" "$WEB_DIR/$filename" "$category_name"
done

echo ""
echo "🎨 Step 2: Creating Enhanced Features"
echo "-----------------------------------"

# Create sitemap
echo "🗺️  Creating sitemap..."
cat > "$WEB_DIR/sitemap.xml" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
EOF

# Add URLs to sitemap
for html_file in "$WEB_DIR"/*.md; do
    if [ -f "$html_file" ]; then
        filename=$(basename "$html_file" .md)
        if [ "$filename" = "index" ]; then
            url="/"
        else
            url="/$filename.html"
        fi
        
        cat >> "$WEB_DIR/sitemap.xml" << EOF
    <url>
        <loc>https://$(git config --get remote.origin.url | sed 's/.*github\.com[:/]\([^/]*\)\/\([^.]*\).*/\1.github.io\/\2/')$url</loc>
        <lastmod>$(date -Iseconds)</lastmod>
        <changefreq>weekly</changefreq>
        <priority>0.8</priority>
    </url>
EOF
    fi
done

cat >> "$WEB_DIR/sitemap.xml" << 'EOF'
</urlset>
EOF

# Create robots.txt
echo "🤖 Creating robots.txt..."
cat > "$WEB_DIR/robots.txt" << 'EOF'
User-agent: *
Allow: /

Sitemap: https://$(git config --get remote.origin.url | sed 's/.*github\.com[:/]\([^/]*\)\/\([^.]*\).*/\1.github.io\/\2/')/sitemap.xml
EOF

# Create RSS feed
echo "📡 Creating RSS feed..."
cat > "$WEB_DIR/feed.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
        <title>Toolbox Documentation</title>
        <description>Auto-generated documentation from script headers</description>
        <link>https://$(git config --get remote.origin.url | sed 's/.*github\.com[:/]\([^/]*\)\/\([^.]*\).*/\1.github.io\/\2/')</link>
        <atom:link href="https://$(git config --get remote.origin.url | sed 's/.*github\.com[:/]\([^/]*\)\/\([^.]*\).*/\1.github.io\/\2/')/feed.xml" rel="self" type="application/rss+xml"/>
        <pubDate>$(date -R)</pubDate>
        <lastBuildDate>$(date -R)</lastBuildDate>
        <generator>Toolbox Documentation System</generator>
        
        <item>
            <title>Documentation Updated</title>
            <description>Toolbox documentation has been updated with the latest script information</description>
            <link>https://$(git config --get remote.origin.url | sed 's/.*github\.com[:/]\([^/]*\)\/\([^.]*\).*/\1.github.io\/\2/')</link>
            <guid>https://$(git config --get remote.origin.url | sed 's/.*github\.com[:/]\([^/]*\)\/\([^.]*\).*/\1.github.io\/\2/')?$(date +%s)</guid>
            <pubDate>$(date -R)</pubDate>
        </item>
    </channel>
</rss>
EOF

# Create search index JSON for client-side search
echo "🔍 Creating search index..."
if [ -f "$DOCS_DIR/scripts_metadata.json" ]; then
    jq '[.[] | {
        title: .name,
        description: .description,
        category: .category,
        path: (.category | gsub("::"; "_") | gsub("/"; "_")) + ".html#" + (.name | gsub(" "; "-") | ascii_downcase),
        tags: .tags,
        author: .author
    }]' "$DOCS_DIR/scripts_metadata.json" > "$WEB_DIR/search_index.json" 2>/dev/null || echo "[]" > "$WEB_DIR/search_index.json"
else
    echo "[]" > "$WEB_DIR/search_index.json"
fi

# Create manifest.json for PWA support
echo "📱 Creating web app manifest..."
cat > "$WEB_DIR/manifest.json" << 'EOF'
{
    "name": "Toolbox Documentation",
    "short_name": "Toolbox Docs",
    "description": "Comprehensive documentation for system administration scripts",
    "start_url": "/",
    "display": "standalone",
    "background_color": "#ffffff",
    "theme_color": "#667eea",
    "icons": [
        {
            "src": "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Ctext y='.9em' font-size='90'%3E🛡️%3C/text%3E%3C/svg%3E",
            "sizes": "any",
            "type": "image/svg+xml"
        }
    ]
}
EOF

echo ""
echo "📊 Step 3: Creating Interactive Features"
echo "---------------------------------------"

# Create advanced search page
echo "🔍 Creating advanced search page..."
cat > "$WEB_DIR/search.md" << 'EOF'
---
layout: default
title: "Advanced Search"
description: "Search through all toolbox scripts and documentation"
---

# 🔍 Advanced Search

<div class="search-container">
    <input type="text" id="advanced-search" placeholder="Search scripts, descriptions, tags, authors..." class="search-input">
    <div class="search-filters">
        <label><input type="checkbox" id="filter-scripts" checked> Scripts</label>
        <label><input type="checkbox" id="filter-categories" checked> Categories</label>
        <label><input type="checkbox" id="filter-authors" checked> Authors</label>
        <label><input type="checkbox" id="filter-tags" checked> Tags</label>
    </div>
</div>

<div id="search-results" class="search-results-container">
    <p>Start typing to search through all documentation...</p>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('advanced-search');
    const resultsContainer = document.getElementById('search-results');
    let searchIndex = [];
    
    // Load search index
    fetch('/search_index.json')
        .then(response => response.json())
        .then(data => {
            searchIndex = data;
        })
        .catch(error => {
            console.error('Error loading search index:', error);
        });
    
    searchInput.addEventListener('input', function() {
        const query = this.value.toLowerCase();
        if (query.length < 2) {
            resultsContainer.innerHTML = '<p>Start typing to search through all documentation...</p>';
            return;
        }
        
        const results = searchIndex.filter(item => {
            return item.title.toLowerCase().includes(query) ||
                   item.description.toLowerCase().includes(query) ||
                   item.category.toLowerCase().includes(query) ||
                   (item.author && item.author.toLowerCase().includes(query)) ||
                   (item.tags && item.tags.some(tag => tag.toLowerCase().includes(query)));
        });
        
        if (results.length === 0) {
            resultsContainer.innerHTML = '<p>No results found for "' + query + '"</p>';
            return;
        }
        
        const resultsHtml = results.map(result => `
            <div class="search-result-item">
                <h3><a href="${result.path}">${result.title}</a></h3>
                <p class="result-description">${result.description}</p>
                <div class="result-meta">
                    <span class="category">📁 ${result.category}</span>
                    ${result.author ? `<span class="author">👤 ${result.author}</span>` : ''}
                    ${result.tags && result.tags.length > 0 ? `<span class="tags">🏷️ ${result.tags.join(', ')}</span>` : ''}
                </div>
            </div>
        `).join('');
        
        resultsContainer.innerHTML = `
            <h2>Search Results (${results.length} found)</h2>
            ${resultsHtml}
        `;
    });
});
</script>

<style>
.search-container {
    margin: 2rem 0;
    padding: 2rem;
    background: #f8f9fa;
    border-radius: 8px;
}

.search-input {
    width: 100%;
    padding: 1rem;
    font-size: 1.2rem;
    border: 2px solid #e2e8f0;
    border-radius: 8px;
    margin-bottom: 1rem;
}

.search-filters {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
}

.search-filters label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    cursor: pointer;
}

.search-results-container {
    margin-top: 2rem;
}

.search-result-item {
    background: white;
    padding: 1.5rem;
    margin: 1rem 0;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    border-left: 4px solid #3498db;
}

.search-result-item h3 {
    margin-top: 0;
    margin-bottom: 0.5rem;
}

.search-result-item h3 a {
    color: #2c3e50;
    text-decoration: none;
}

.search-result-item h3 a:hover {
    color: #3498db;
}

.result-description {
    color: #666;
    margin-bottom: 1rem;
}

.result-meta {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
    font-size: 0.9rem;
}

.result-meta span {
    background: #e2e8f0;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
}

.category { background: #dbeafe; color: #1e40af; }
.author { background: #fef3c7; color: #92400e; }
.tags { background: #dcfce7; color: #166534; }
</style>
EOF

echo ""
echo "🎉 Web Pages Creation Complete!"
echo "==============================="
echo "📁 Web files location: $WEB_DIR"
echo "🌐 Files created:"
echo "  - Enhanced Markdown files with Jekyll front matter"
echo "  - sitemap.xml for SEO"
echo "  - robots.txt for search engines"
echo "  - feed.xml for RSS subscriptions"
echo "  - search_index.json for client-side search"
echo "  - manifest.json for PWA support"
echo "  - search.md for advanced search functionality"
echo ""
echo "🚀 Ready for deployment to:"
echo "  - GitHub Pages (automatic with workflow)"
echo "  - Netlify (drag & drop _site folder)"
echo "  - Vercel (connect repository)"
echo "  - Any static hosting service"
echo ""
echo "✅ Web pages ready for deployment!"