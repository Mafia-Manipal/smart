#!/bin/bash

# Push Smart Irrigation System to GitHub
# This script will guide you through the final steps

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Ready to push Smart Irrigation System to GitHub!${NC}"
echo ""

# Check git status
echo -e "${BLUE}📋 Current repository status:${NC}"
git status --short
echo ""

# Show what will be pushed
echo -e "${BLUE}📁 Files to be pushed:${NC}"
git ls-files
echo ""

echo -e "${YELLOW}📝 Follow these steps to create your GitHub repository:${NC}"
echo ""
echo "1. 🌐 Go to: https://github.com/new"
echo ""
echo "2. 📝 Fill in the repository details:"
echo "   • Repository name: smart-irrigation-system"
echo "   • Description: Smart Irrigation System for LPC1768 with soil moisture and humidity sensing"
echo "   • Visibility: Choose Public or Private"
echo "   • ⚠️  IMPORTANT: Do NOT check 'Add a README file'"
echo "   • ⚠️  IMPORTANT: Do NOT check 'Add .gitignore'"
echo "   • ⚠️  IMPORTANT: Do NOT check 'Choose a license'"
echo ""
echo "3. 🎯 Click 'Create repository'"
echo ""
echo "4. 📋 Copy the repository URL that GitHub shows you"
echo "   (It will look like: https://github.com/YOUR_USERNAME/smart-irrigation-system.git)"
echo ""

read -p "Press Enter when you've created the repository and have the URL ready..."

echo ""
echo -e "${BLUE}🔗 Now let's connect your local repository to GitHub:${NC}"
echo ""

read -p "Enter your GitHub username: " github_username

if [ -n "$github_username" ]; then
    repo_url="https://github.com/$github_username/smart-irrigation-system.git"
    
    echo ""
    echo -e "${BLUE}🔗 Adding remote origin: $repo_url${NC}"
    git remote add origin "$repo_url" 2>/dev/null || git remote set-url origin "$repo_url"
    
    echo ""
    echo -e "${BLUE}🚀 Pushing to GitHub...${NC}"
    git branch -M main
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ SUCCESS! Your Smart Irrigation System is now on GitHub!${NC}"
        echo ""
        echo -e "${GREEN}🌐 Repository URL: https://github.com/$github_username/smart-irrigation-system${NC}"
        echo ""
        echo -e "${BLUE}📋 What's included in your repository:${NC}"
        echo "   • Complete embedded C++ code for LPC1768"
        echo "   • Comprehensive documentation"
        echo "   • Build system with Makefile"
        echo "   • Test suite for validation"
        echo "   • Configuration management"
        echo "   • GitHub setup scripts"
        echo ""
        echo -e "${YELLOW}🎉 Your smart irrigation project is now ready to share!${NC}"
    else
        echo ""
        echo -e "${YELLOW}⚠️  Push failed. This might be due to:${NC}"
        echo "   • Authentication issues (need GitHub token or SSH key)"
        echo "   • Repository doesn't exist yet"
        echo "   • Network connectivity"
        echo ""
        echo -e "${BLUE}💡 Try these solutions:${NC}"
        echo "   1. Make sure the repository exists on GitHub"
        echo "   2. Set up authentication: https://github.com/settings/tokens"
        echo "   3. Or use SSH: https://github.com/settings/keys"
    fi
else
    echo ""
    echo -e "${YELLOW}⚠️  No username provided. You can run this script again when ready.${NC}"
fi
