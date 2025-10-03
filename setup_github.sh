#!/bin/bash

# Setup GitHub Repository for Smart Irrigation System
# This script helps you create and push to a GitHub repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Setting up GitHub repository for Smart Irrigation System..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_error "Not in a git repository. Please run 'git init' first."
    exit 1
fi

# Check if we have commits
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
    print_error "No commits found. Please make an initial commit first."
    exit 1
fi

print_status "Current repository status:"
git status --short

echo ""
print_status "To create and push to GitHub repository, follow these steps:"
echo ""
echo "1. Go to https://github.com/new"
echo "2. Create a new repository with these settings:"
echo "   - Repository name: smart-irrigation-system"
echo "   - Description: Smart Irrigation System for LPC1768 with soil moisture and humidity sensing"
echo "   - Visibility: Public (or Private if you prefer)"
echo "   - DO NOT initialize with README, .gitignore, or license (we already have these)"
echo ""
echo "3. After creating the repository, GitHub will show you commands like:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/smart-irrigation-system.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
print_warning "Replace YOUR_USERNAME with your actual GitHub username!"
echo ""

# Check if remote already exists
if git remote get-url origin >/dev/null 2>&1; then
    print_status "Remote 'origin' already exists:"
    git remote get-url origin
    echo ""
    read -p "Do you want to update the remote URL? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter your GitHub username: " github_username
        if [ -n "$github_username" ]; then
            git remote set-url origin "https://github.com/$github_username/smart-irrigation-system.git"
            print_success "Remote URL updated"
        fi
    fi
else
    read -p "Enter your GitHub username: " github_username
    if [ -n "$github_username" ]; then
        git remote add origin "https://github.com/$github_username/smart-irrigation-system.git"
        print_success "Remote 'origin' added"
    else
        print_warning "No username provided. You'll need to add the remote manually."
    fi
fi

echo ""
print_status "Ready to push to GitHub!"
echo ""
print_status "Run these commands to push your code:"
echo "  git branch -M main"
echo "  git push -u origin main"
echo ""

read -p "Do you want to push now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Pushing to GitHub..."
    
    # Ensure we're on main branch
    git branch -M main
    
    # Push to GitHub
    if git push -u origin main; then
        print_success "Successfully pushed to GitHub!"
        print_status "Your repository is now available at:"
        if [ -n "$github_username" ]; then
            echo "https://github.com/$github_username/smart-irrigation-system"
        else
            echo "https://github.com/YOUR_USERNAME/smart-irrigation-system"
        fi
    else
        print_error "Failed to push to GitHub. Please check your credentials and try again."
        print_status "You may need to set up authentication:"
        echo "  - Personal Access Token: https://github.com/settings/tokens"
        echo "  - SSH Key: https://github.com/settings/keys"
    fi
else
    print_status "Skipping push. You can run the commands manually when ready."
fi

echo ""
print_success "Setup complete! Your Smart Irrigation System is ready for GitHub."
