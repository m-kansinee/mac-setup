#!/usr/bin/env bash

set -e

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

printf "${BLUE}🚀 Starting MacBook Bootstrap Process...${NC}\n"

# 1. Check for Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
    printf "${BLUE}📦 Installing Xcode Command Line Tools...${NC}\n"
    xcode-select --install
    printf "${RED}⚠️  Please wait for the installation to finish before continuing.${NC}\n"
    read -p "Press [Enter] when installation is complete..."
else
    printf "${GREEN}✅ Xcode Command Line Tools already installed.${NC}\n"
fi

# 2. Check for Homebrew
if ! command -v brew &>/dev/null; then
    printf "${BLUE}🍺 Installing Homebrew...${NC}\n"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Set Homebrew PATH for Apple Silicon immediately for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
    
    # Persist Homebrew PATH for future sessions
    if [ ! -f "$HOME/.zprofile" ] || ! grep -q "brew shellenv" "$HOME/.zprofile"; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    fi
else
    printf "${GREEN}✅ Homebrew already installed.${NC}\n"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 3. Check for Ansible
if ! command -v ansible &>/dev/null; then
    printf "${BLUE}⚙️  Installing Ansible...${NC}\n"
    brew install ansible
else
    printf "${GREEN}✅ Ansible already installed.${NC}\n"
fi

# 4. Install required Ansible collections
printf "${BLUE}📚 Installing Ansible collections from requirements.yml...${NC}\n"
ansible-galaxy collection install -r requirements.yml

# 5. Run the Playbook
printf "${BLUE}🎬 Starting Ansible Playbook...${NC}\n"
printf "${BLUE}Note: You will be prompted for your macOS user password for sudo tasks.${NC}\n"

ansible-playbook main.yml --ask-become-pass

printf "${GREEN}✨ Bootstrap Complete! Please restart your terminal to enter Fish shell.${NC}\n"
