#!/bin/bash

# DevOps Note Creator Script
# Usage: devops

# Configuration - UPDATE THIS PATH TO YOUR ACTUAL DEVOPS DIRECTORY
DEVOPS_REPO="$HOME/DevOps"  # ⚠️ CHANGE THIS TO YOUR ACTUAL PATH ⚠️
KASTEN_DIR="$DEVOPS_REPO/kasten"
TEMPLATE_FILE="$DEVOPS_REPO/template/Main Note.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo -e "${BLUE}DevOps Note Creator${NC}"
    echo "Usage: devops"
    echo ""
    echo "This script creates a new DevOps note in your kasten directory"
    echo "using the Main Note template and opens it in Neovim."
    echo ""
    echo -e "${YELLOW}IMPORTANT: Update DEVOPS_REPO path in the script to point to your DevOps repository${NC}"
    echo -e "Current path: ${RED}$DEVOPS_REPO${NC}"
}

# Function to list existing notes
list_notes() {
    if [ -d "$KASTEN_DIR" ]; then
        echo -e "${BLUE}Existing notes in kasten:${NC}"
        find "$KASTEN_DIR" -name "*.md" -type f | xargs -n 1 basename | sed 's/\.md$//' | sed 's/-/ /g' | sort
    else
        echo -e "${RED}Kasten directory not found${NC}"
    fi
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
    -l|--list)
        list_notes
        exit 0
        ;;
    "")
        # Continue with normal operation
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo "Use 'devops --help' for usage information"
        exit 1
        ;;
esac

# Check if DevOps repo exists
if [ ! -d "$DEVOPS_REPO" ]; then
    echo -e "${RED}Error: DevOps repository not found at:${NC}"
    echo -e "${RED}  $DEVOPS_REPO${NC}"
    echo ""
    show_usage
    exit 1
fi

# Check if kasten directory exists
if [ ! -d "$KASTEN_DIR" ]; then
    echo -e "${RED}Error: kasten directory not found at:${NC}"
    echo -e "${RED}  $KASTEN_DIR${NC}"
    echo -e "${YELLOW}Please create the kasten directory in your DevOps repository${NC}"
    exit 1
fi

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}Error: Template file not found at:${NC}"
    echo -e "${RED}  $TEMPLATE_FILE${NC}"
    echo -e "${YELLOW}Please make sure your template exists${NC}"
    exit 1
fi

# Display current kasten directory info
echo -e "${BLUE}Kasten directory: $KASTEN_DIR${NC}"
echo -e "${BLUE}Number of existing notes: $(find "$KASTEN_DIR" -name "*.md" | wc -l)${NC}"
echo ""

# Prompt for note title
echo -e "${YELLOW}Enter the title for your new DevOps note:${NC}"
read -r note_title

# Check if title was provided
if [ -z "$note_title" ]; then
    echo -e "${RED}Error: No title provided. Exiting.${NC}"
    exit 1
fi

# Generate filename (replace spaces with hyphens, remove special chars, lowercase)
clean_title=$(echo "$note_title" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
filename="$clean_title.md"
filepath="$KASTEN_DIR/$filename"

# Check if file already exists
if [ -f "$filepath" ]; then
    echo -e "${RED}Error: Note '$filename' already exists in kasten directory.${NC}"
    echo -e "${YELLOW}Use 'devops --list' to see existing notes${NC}"
    exit 1
fi

# Get current date and time
current_date=$(date '+%Y-%m-%d')
current_time=$(date '+%H:%M')

# Create new note from template
if sed "s/{{date}}/$current_date/g; s/{{time}}/$current_time/g; s/{{Title}}/$note_title/g" "$TEMPLATE_FILE" > "$filepath"; then
    echo -e "${GREEN}✅ Successfully created: $filepath${NC}"
    echo -e "${BLUE}📝 Template applied with:${NC}"
    echo -e "   Date: $current_date"
    echo -e "   Time: $current_time" 
    echo -e "   Title: $note_title"
    echo ""
    
    # Open the file in neovim
    echo -e "${YELLOW}Opening in Neovim...${NC}"
    nvim "$filepath"
else
    echo -e "${RED}❌ Error: Failed to create note at $filepath${NC}"
    exit 1
fi
