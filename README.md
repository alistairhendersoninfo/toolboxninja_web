# 🌐 ToolboxNinja Web

**Professional documentation and web interface for the ToolboxNinja menu system**

[![Documentation](https://github.com/yourusername/toolboxninja_web/actions/workflows/generate-docs.yml/badge.svg)](https://github.com/yourusername/toolboxninja_web/actions/workflows/generate-docs.yml)
[![Deploy Pages](https://github.com/yourusername/toolboxninja_web/actions/workflows/deploy-pages.yml/badge.svg)](https://github.com/yourusername/toolboxninja_web/actions/workflows/deploy-pages.yml)
[![Live Documentation](https://img.shields.io/badge/docs-live-brightgreen)](https://yourusername.github.io/toolboxninja_web)

📚 **[Live Documentation](https://yourusername.github.io/toolboxninja_web)** | 🛠️ **[Main Toolbox](https://github.com/yourusername/toolboxninja)** | 📊 **[Statistics](https://yourusername.github.io/toolboxninja_web/STATISTICS.html)**

## 🎯 Purpose

This repository contains the **web interface and documentation system** for ToolboxNinja. It automatically generates beautiful, searchable documentation from your toolbox scripts and deploys it as a professional website.

## 🏗️ Repository Structure

```
toolboxninja_web/                    # This repository (web interface)
├── 🔄 .github/workflows/            # GitHub Actions for automation
├── 📚 scripts/                      # Documentation generation scripts
├── 🎨 templates/                    # Web page templates
├── 📖 docs/                         # Generated documentation
├── 🌐 _site/                        # Generated web pages
└── 📋 guides/                       # Setup and usage guides

toolboxninja/                        # Main repository (scripts only)
├── 📁 LinuxTools/                   # Your actual toolbox scripts
├── 📁 SystemSecurity/               # Organized by categories
├── 📁 NetworkUtils/                 # Clean, focused on scripts
└── 📁 YourCustomCategories/         # No web clutter
```

## 🚀 Quick Start

### 1. **Setup Web Documentation**

```bash
# Clone this web repository
git clone https://github.com/yourusername/toolboxninja_web.git
cd toolboxninja_web

# Setup GitHub Pages
./scripts/setup_github_pages.sh

# Configure your main toolbox repository
./scripts/configure_toolbox_repo.sh https://github.com/yourusername/toolboxninja
```

### 2. **Generate Documentation**

```bash
# Scan your toolbox repository and generate docs
./scripts/scan_and_generate.sh /path/to/toolboxninja

# Or scan remote repository
./scripts/scan_remote_repo.sh https://github.com/yourusername/toolboxninja
```

### 3. **Deploy Website**

```bash
# Deploy to GitHub Pages (automatic)
git add . && git commit -m "📚 Update documentation" && git push

# Your documentation site will be live at:
# https://yourusername.github.io/toolboxninja_web
```

## 🔄 Automatic Updates

The web documentation automatically updates when:
- Scripts are modified in the main `toolboxninja` repository
- New scripts are added to any category
- Script headers are updated with new metadata
- Manual regeneration is triggered

## 🌐 Features

### **Professional Web Interface**
- 📱 **Mobile Responsive** - Perfect on all devices
- 🔍 **Advanced Search** - Real-time filtering and search
- 🎨 **Modern UI/UX** - Clean, professional design
- 📊 **Statistics Dashboard** - Comprehensive metrics
- 🏷️ **Category Organization** - Intuitive navigation

### **SEO & Performance**
- 🗺️ **Sitemap Generation** - Search engine optimization
- 📡 **RSS Feeds** - Content syndication
- 📱 **PWA Support** - Install as desktop/mobile app
- ⚡ **Fast Loading** - Optimized static files
- 📈 **Analytics Ready** - Google Analytics integration

### **Developer Features**
- 🔄 **GitFlow Integration** - Automated documentation
- 📝 **Markdown Processing** - Enhanced formatting
- 🎯 **Multi-repo Support** - Scan multiple repositories
- 🛠️ **Customizable Templates** - Brand your documentation
- 📋 **Quality Validation** - Comprehensive checks

## 📚 Documentation

- **[Complete Setup Guide](guides/COMPLETE_SETUP_GUIDE.md)** - Full installation instructions
- **[Web Deployment Guide](guides/WEB_DEPLOYMENT_GUIDE.md)** - Deploy to various platforms
- **[GitFlow Integration](guides/GITFLOW_INTEGRATION.md)** - Automated workflows
- **[Customization Guide](guides/CUSTOMIZATION_GUIDE.md)** - Branding and theming
- **[API Reference](guides/API_REFERENCE.md)** - Script metadata format

## 🔧 Configuration

### **Basic Configuration**

```yaml
# config/toolbox_config.yml
toolbox_repositories:
  - name: "main"
    url: "https://github.com/yourusername/toolboxninja"
    branch: "main"
    scan_paths:
      - "LinuxTools"
      - "SystemSecurity" 
      - "NetworkUtils"
    exclude_paths:
      - "docs"
      - ".github"
      - "target"
      - "node_modules"

web_settings:
  title: "Your Toolbox Documentation"
  description: "Comprehensive system administration tools"
  theme: "professional"
  analytics: "G-XXXXXXXXXX"
```

### **Advanced Features**

```bash
# Multi-repository scanning
./scripts/scan_multiple_repos.sh config/repositories.yml

# Custom branding
./scripts/apply_branding.sh config/branding.yml

# Deploy to multiple platforms
./scripts/deploy_everywhere.sh
```

## 🚀 Deployment Options

### **GitHub Pages (Free)**
- Automatic deployment on every commit
- Custom domain support
- SSL certificate included
- CDN acceleration

### **Netlify**
- Drag & drop deployment
- Branch previews
- Form handling
- Edge functions

### **Vercel**
- Git integration
- Automatic deployments
- Edge network
- Analytics included

### **Custom Server**
- Full control
- Custom domains
- Advanced caching
- Server-side features

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m '✨ Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ for system administrators
- Powered by Jekyll and GitHub Pages
- Inspired by modern documentation practices
- Designed for the ToolboxNinja ecosystem

---

**🌐 Transform your toolbox scripts into professional documentation with ToolboxNinja Web!**

*Part of the ToolboxNinja ecosystem - making system administration tools accessible and professional.*