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
