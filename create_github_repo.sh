#!/bin/bash

# Create GitHub Repository for Smart Irrigation System
# This script will guide you through creating and pushing to GitHub

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🌱 Smart Irrigation System - GitHub Setup${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Not in a git repository. Please run 'git init' first.${NC}"
    exit 1
fi

# Check if we have commits
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    echo -e "${RED}❌ No commits found. Please make an initial commit first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Git repository is ready!${NC}"
echo ""

# Show current status
echo -e "${BLUE}📋 Repository Status:${NC}"
git log --oneline -3
echo ""

echo -e "${BLUE}📁 Files to be pushed:${NC}"
git ls-files | head -10
if [ $(git ls-files | wc -l) -gt 10 ]; then
    echo "... and $(( $(git ls-files | wc -l) - 10 )) more files"
fi
echo ""

echo -e "${YELLOW}🚀 Let's create your GitHub repository!${NC}"
echo ""

# Get GitHub username
read -p "Enter your GitHub username: " github_username

if [ -z "$github_username" ]; then
    echo -e "${RED}❌ GitHub username is required. Exiting.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📝 Repository Details:${NC}"
echo "   • Name: smart-irrigation-system"
echo "   • Description: Smart Irrigation System for LPC1768 with soil moisture and humidity sensing"
echo "   • Owner: $github_username"
echo ""

# Create the repository using GitHub API
echo -e "${BLUE}🔧 Creating repository on GitHub...${NC}"

# Check if we have curl
if ! command -v curl >/dev/null 2>&1; then
    echo -e "${RED}❌ curl is required but not installed.${NC}"
    exit 1
fi

# Create repository using GitHub API
echo -e "${YELLOW}⚠️  You'll need a GitHub Personal Access Token for this step.${NC}"
echo -e "${YELLOW}   Get one at: https://github.com/settings/tokens${NC}"
echo -e "${YELLOW}   Required scopes: repo (Full control of private repositories)${NC}"
echo ""

read -p "Enter your GitHub Personal Access Token (or press Enter to skip API creation): " github_token

if [ -n "$github_token" ]; then
    echo -e "${BLUE}🔧 Creating repository via GitHub API...${NC}"
    
    # Create repository
    response=$(curl -s -X POST \
        -H "Authorization: token $github_token" \
        -H "Accept: application/vnd.github.v3+json" \
        https://api.github.com/user/repos \
        -d '{
            "name": "smart-irrigation-system",
            "description": "Smart Irrigation System for LPC1768 with soil moisture and humidity sensing",
            "private": false,
            "auto_init": false
        }')
    
    # Check if repository was created successfully
    if echo "$response" | grep -q '"name": "smart-irrigation-system"'; then
        echo -e "${GREEN}✅ Repository created successfully!${NC}"
    else
        echo -e "${YELLOW}⚠️  Repository might already exist or there was an issue.${NC}"
        echo "Response: $response"
    fi
else
    echo -e "${YELLOW}⚠️  Skipping API creation. You'll need to create the repository manually.${NC}"
    echo ""
    echo -e "${BLUE}📋 Manual Steps:${NC}"
    echo "1. Go to: https://github.com/new"
    echo "2. Repository name: smart-irrigation-system"
    echo "3. Description: Smart Irrigation System for LPC1768 with soil moisture and humidity sensing"
    echo "4. Make it Public"
    echo "5. DO NOT initialize with README, .gitignore, or license"
    echo "6. Click 'Create repository'"
    echo ""
    read -p "Press Enter when you've created the repository..."
fi

# Set up remote and push
repo_url="https://github.com/$github_username/smart-irrigation-system.git"

echo ""
echo -e "${BLUE}🔗 Setting up remote origin...${NC}"
git remote add origin "$repo_url" 2>/dev/null || git remote set-url origin "$repo_url"

echo -e "${BLUE}🚀 Pushing to GitHub...${NC}"
git branch -M main

# Try to push
if git push -u origin main; then
    echo ""
    echo -e "${GREEN}🎉 SUCCESS! Your Smart Irrigation System is now on GitHub!${NC}"
    echo ""
    echo -e "${GREEN}🌐 Repository URL: https://github.com/$github_username/smart-irrigation-system${NC}"
    echo ""
    echo -e "${BLUE}📋 What's included:${NC}"
    echo "   ✅ Complete embedded C++ code for LPC1768"
    echo "   ✅ Comprehensive documentation"
    echo "   ✅ Build system with Makefile"
    echo "   ✅ Test suite for validation"
    echo "   ✅ Configuration management"
    echo "   ✅ GitHub setup scripts"
    echo ""
    echo -e "${YELLOW}🎉 Your smart irrigation project is now ready to share!${NC}"
else
    echo ""
    echo -e "${RED}❌ Push failed. This might be due to:${NC}"
    echo "   • Authentication issues (need GitHub token or SSH key)"
    echo "   • Repository doesn't exist yet"
    echo "   • Network connectivity"
    echo ""
    echo -e "${BLUE}💡 Solutions:${NC}"
    echo "   1. Make sure the repository exists on GitHub"
    echo "   2. Set up authentication: https://github.com/settings/tokens"
    echo "   3. Or use SSH: https://github.com/settings/keys"
    echo ""
    echo -e "${YELLOW}🔄 You can run this script again to retry.${NC}"
fi
