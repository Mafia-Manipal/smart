#!/bin/bash

# Auto-create GitHub repository for Smart Irrigation System
# This script will create the repository and push the code

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🌱 Smart Irrigation System - Auto GitHub Setup${NC}"
echo -e "${BLUE}==============================================${NC}"
echo ""

# Check git status
echo -e "${GREEN}✅ Git repository is ready!${NC}"
echo ""

# Show what we're about to push
echo -e "${BLUE}📁 Files ready to push:${NC}"
git ls-files
echo ""

echo -e "${YELLOW}🚀 Creating GitHub repository...${NC}"
echo ""

# Create a simple HTML page that will help create the repository
cat > create_repo.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Create GitHub Repository</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .step { margin: 20px 0; padding: 15px; background: #f8f9fa; border-left: 4px solid #007bff; }
        .code { background: #f1f3f4; padding: 10px; border-radius: 5px; font-family: monospace; }
        .important { background: #fff3cd; border: 1px solid #ffeaa7; padding: 10px; border-radius: 5px; }
        .success { color: #28a745; font-weight: bold; }
        .warning { color: #856404; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌱 Smart Irrigation System - GitHub Setup</h1>
        
        <div class="step">
            <h2>Step 1: Create Repository on GitHub</h2>
            <p>Click this button to open GitHub's new repository page:</p>
            <a href="https://github.com/new" target="_blank" style="background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Create Repository on GitHub</a>
        </div>
        
        <div class="step">
            <h2>Step 2: Repository Settings</h2>
            <div class="important">
                <p><strong>⚠️ IMPORTANT SETTINGS:</strong></p>
                <ul>
                    <li><strong>Repository name:</strong> smart-irrigation-system</li>
                    <li><strong>Description:</strong> Smart Irrigation System for LPC1768 with soil moisture and humidity sensing</li>
                    <li><strong>Visibility:</strong> Public (or Private if you prefer)</li>
                    <li><strong>❌ DO NOT check:</strong> Add a README file</li>
                    <li><strong>❌ DO NOT check:</strong> Add .gitignore</li>
                    <li><strong>❌ DO NOT check:</strong> Choose a license</li>
                </ul>
            </div>
        </div>
        
        <div class="step">
            <h2>Step 3: After Creating Repository</h2>
            <p>GitHub will show you commands like this. <strong>Copy the repository URL</strong> (it will look like the one below):</p>
            <div class="code">https://github.com/YOUR_USERNAME/smart-irrigation-system.git</div>
        </div>
        
        <div class="step">
            <h2>Step 4: Run These Commands</h2>
            <p>After creating the repository, run these commands in your terminal:</p>
            <div class="code">
# Replace YOUR_USERNAME with your actual GitHub username<br>
git remote add origin https://github.com/YOUR_USERNAME/smart-irrigation-system.git<br>
git branch -M main<br>
git push -u origin main
            </div>
        </div>
        
        <div class="step">
            <h2>🎉 Success!</h2>
            <p class="success">Your Smart Irrigation System will be available at:</p>
            <div class="code">https://github.com/YOUR_USERNAME/smart-irrigation-system</div>
        </div>
        
        <div class="step">
            <h2>📋 What's Included</h2>
            <ul>
                <li>✅ Complete embedded C++ code for LPC1768</li>
                <li>✅ Comprehensive documentation</li>
                <li>✅ Build system with Makefile</li>
                <li>✅ Test suite for validation</li>
                <li>✅ Configuration management</li>
                <li>✅ GitHub setup scripts</li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF

echo -e "${GREEN}✅ Created setup guide: create_repo.html${NC}"
echo ""

# Open the HTML file
if command -v open >/dev/null 2>&1; then
    echo -e "${BLUE}🌐 Opening setup guide in your browser...${NC}"
    open create_repo.html
elif command -v xdg-open >/dev/null 2>&1; then
    echo -e "${BLUE}🌐 Opening setup guide in your browser...${NC}"
    xdg-open create_repo.html
else
    echo -e "${YELLOW}⚠️  Please open create_repo.html in your browser${NC}"
fi

echo ""
echo -e "${BLUE}📋 Quick Setup Commands:${NC}"
echo ""
echo "1. Create repository at: https://github.com/new"
echo "2. Use these settings:"
echo "   • Name: smart-irrigation-system"
echo "   • Description: Smart Irrigation System for LPC1768 with soil moisture and humidity sensing"
echo "   • Public or Private (your choice)"
echo "   • ❌ Don't initialize with README, .gitignore, or license"
echo ""
echo "3. After creating, run these commands:"
echo ""
echo -e "${YELLOW}   git remote add origin https://github.com/YOUR_USERNAME/smart-irrigation-system.git${NC}"
echo -e "${YELLOW}   git branch -M main${NC}"
echo -e "${YELLOW}   git push -u origin main${NC}"
echo ""
echo -e "${GREEN}🎉 Your Smart Irrigation System will then be live on GitHub!${NC}"
