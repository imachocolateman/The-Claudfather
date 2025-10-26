#!/usr/bin/env bash

# sync-claude-components.sh
# Syncs Claude components from The Claudfather repository to local Claude configuration
# Provides intelligent change detection, diff display, and safety features

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
DRY_RUN=false
CREATE_BACKUP=false
VERBOSE=false
SHOW_DIFF=true

# Statistics
NEW_FILES=0
UPDATED_FILES=0
UNCHANGED_FILES=0
SKIPPED_FILES=0

# Display help message
show_help() {
    cat << EOF
${BOLD}Claude Components Sync Script${NC}
Syncs components from The Claudfather repository to your local Claude configuration

${BOLD}Usage:${NC}
  ./sync-claude-components.sh [OPTIONS]

${BOLD}Options:${NC}
  --dry-run    Preview changes without actually syncing
  --backup     Create .bak files before overwriting
  --verbose    Show detailed operations
  --no-diff    Skip showing diffs (faster sync)
  --help       Show this help message

${BOLD}Directories synced:${NC}
  agents/   → ~/.claude/agents/
  commands/ → ~/.claude/commands/

${BOLD}Examples:${NC}
  # Preview changes without syncing
  ./sync-claude-components.sh --dry-run

  # Sync with backups
  ./sync-claude-components.sh --backup

  # Quiet sync without diffs
  ./sync-claude-components.sh --no-diff
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --no-diff)
            SHOW_DIFF=false
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Print verbose messages
verbose_log() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${CYAN}[VERBOSE]${NC} $1"
    fi
}

# Check if file has changed
file_has_changed() {
    local src="$1"
    local dest="$2"

    if [[ ! -f "$dest" ]]; then
        return 0 # File doesn't exist, so it has "changed" (needs to be created)
    fi

    # Compare using checksums
    if command -v md5sum &> /dev/null; then
        local src_sum=$(md5sum "$src" | cut -d' ' -f1)
        local dest_sum=$(md5sum "$dest" | cut -d' ' -f1)
    else
        # macOS fallback
        local src_sum=$(md5 -q "$src")
        local dest_sum=$(md5 -q "$dest")
    fi

    [[ "$src_sum" != "$dest_sum" ]]
}

# Show diff between files
show_file_diff() {
    local src="$1"
    local dest="$2"
    local file_name="$3"

    if [[ "$SHOW_DIFF" != true ]] || [[ ! -f "$dest" ]]; then
        return
    fi

    echo -e "${YELLOW}━━━ Diff for $file_name ━━━${NC}"

    # Use git diff for colored output if available, otherwise use standard diff
    if command -v git &> /dev/null; then
        git diff --no-index --color=always "$dest" "$src" 2>/dev/null || true
    else
        diff -u "$dest" "$src" || true
    fi

    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Sync a single file
sync_file() {
    local src="$1"
    local dest="$2"
    local relative_path="$3"

    verbose_log "Checking $relative_path"

    # Check if file has changed
    if ! file_has_changed "$src" "$dest"; then
        echo -e "  ${GREEN}✓${NC} $relative_path ${CYAN}(unchanged)${NC}"
        UNCHANGED_FILES=$((UNCHANGED_FILES + 1))
        return
    fi

    # Determine if this is a new file or an update
    local action_symbol="↻"
    local action_text="updated"
    if [[ ! -f "$dest" ]]; then
        action_symbol="+"
        action_text="new file"
        NEW_FILES=$((NEW_FILES + 1))
    else
        UPDATED_FILES=$((UPDATED_FILES + 1))
        # Show diff for updated files
        show_file_diff "$src" "$dest" "$relative_path"
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "  ${YELLOW}${action_symbol}${NC} $relative_path ${CYAN}(would be $action_text)${NC}"
    else
        # Create backup if requested
        if [[ "$CREATE_BACKUP" == true ]] && [[ -f "$dest" ]]; then
            cp "$dest" "${dest}.bak"
            verbose_log "Created backup: ${dest}.bak"
        fi

        # Copy the file
        cp "$src" "$dest"
        echo -e "  ${GREEN}${action_symbol}${NC} $relative_path ${CYAN}($action_text)${NC}"
    fi
}

# Sync a directory
sync_directory() {
    local src_dir="$1"
    local dest_dir="$2"
    local dir_name="$3"

    echo -e "\n${BOLD}Syncing $dir_name${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Check if source directory exists
    if [[ ! -d "$src_dir" ]]; then
        echo -e "  ${YELLOW}⚠${NC} Source directory not found: $src_dir"
        return
    fi

    # Create destination directory if it doesn't exist
    if [[ ! -d "$dest_dir" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "  ${YELLOW}📁${NC} Would create directory: $dest_dir"
        else
            mkdir -p "$dest_dir"
            echo -e "  ${GREEN}📁${NC} Created directory: $dest_dir"
        fi
    fi

    # Sync directory (agents/commands)
    for file in "$src_dir"/*.md; do
        if [[ -f "$file" ]]; then
            local file_name=$(basename "$file")
            sync_file "$file" "$dest_dir/$file_name" "$file_name"
        fi
    done
}

# Main execution
main() {
    echo -e "${BOLD}${CYAN}Claude Components Sync${NC}"
    echo -e "${CYAN}══════════════════════════════${NC}"

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}🔍 Running in DRY-RUN mode (no files will be modified)${NC}"
    fi

    if [[ "$CREATE_BACKUP" == true ]]; then
        echo -e "${BLUE}💾 Backup mode enabled${NC}"
    fi

    # Sync each directory
    sync_directory "$SCRIPT_DIR/agents" "$CLAUDE_DIR/agents" "agents"
    sync_directory "$SCRIPT_DIR/commands" "$CLAUDE_DIR/commands" "commands"

    # Display summary
    echo -e "\n${BOLD}${CYAN}Summary${NC}"
    echo -e "${CYAN}══════════════════════════════${NC}"
    echo -e "  ${GREEN}✓${NC} Unchanged: ${UNCHANGED_FILES} files"
    echo -e "  ${GREEN}+${NC} New:       ${NEW_FILES} files"
    echo -e "  ${YELLOW}↻${NC} Updated:   ${UPDATED_FILES} files"

    local total_changes=$((NEW_FILES + UPDATED_FILES))
    if [[ "$DRY_RUN" == true ]]; then
        if [[ $total_changes -gt 0 ]]; then
            echo -e "\n${YELLOW}Run without --dry-run to apply these changes${NC}"
        else
            echo -e "\n${GREEN}Everything is already up to date!${NC}"
        fi
    else
        if [[ $total_changes -gt 0 ]]; then
            echo -e "\n${GREEN}✓ Successfully synced $total_changes file(s)${NC}"
        else
            echo -e "\n${GREEN}✓ Everything is already up to date!${NC}"
        fi
    fi
}

# Run the main function
main