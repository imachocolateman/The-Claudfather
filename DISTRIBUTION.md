# Distribution Guide

This guide explains different strategies for using The Claudfather components across your projects.

## Overview

Claude Code looks for components in two locations:

1. **Project-level**: `.claude/` directory (shared with team via git)
2. **User-level**: `~/.claude/` directory (personal, works across all projects)

Choose the approach that best fits your needs:

| Strategy | Best For | Updates | Pros | Cons |
|----------|----------|---------|------|------|
| Direct Copy | Simple, one-time needs | Manual | No dependencies | No automatic updates |
| Symlinks | Personal workflows | Automatic | Always latest | Not in git, local only |
| Git Submodule | Team sharing | Version-controlled | Team consistency | More complex setup |
| Selective Copy | Project-specific | Manual | Customizable | Divergence from source |

## Strategy 1: Direct Copy (Simplest)

Copy individual components directly to your project or user directory.

### For Personal Use (All Projects)

```bash
# Copy a command
cp ~/The-Claudfather/commands/code-review.md ~/.claude/commands/

# Copy a skill
cp -r ~/The-Claudfather/skills/api-integration ~/.claude/skills/

# Copy an agent
cp ~/The-Claudfather/agents/code-reviewer.md ~/.claude/agents/
```

### For Team Use (Project-Specific)

```bash
cd /path/to/your-project

# Ensure directories exist
mkdir -p .claude/commands .claude/skills .claude/agents

# Copy components
cp ~/The-Claudfather/commands/test-runner.md .claude/commands/
cp -r ~/The-Claudfather/skills/database-schema .claude/skills/
cp ~/The-Claudfather/agents/architecture-advisor.md .claude/agents/

# Commit to git
git add .claude/
git commit -m "feat: add Claude Code components"
```

**Pros**: Simple, no dependencies, easy to customize per-project
**Cons**: No automatic updates, must manually sync changes

## Strategy 2: Symlinks (Personal Workflows)

Create symbolic links for automatic updates. Best for personal use across multiple projects.

### User-Level Symlinks (Recommended for Personal Use)

```bash
# Link entire directories
ln -s ~/The-Claudfather/commands ~/.claude/commands
ln -s ~/The-Claudfather/skills ~/.claude/skills
ln -s ~/The-Claudfather/agents ~/.claude/agents

# Or link individual components
mkdir -p ~/.claude/commands
ln -s ~/The-Claudfather/commands/code-review.md ~/.claude/commands/code-review.md
```

### Project-Level Symlinks

```bash
cd /path/to/your-project
mkdir -p .claude/commands

# Link individual components
ln -s ~/The-Claudfather/commands/code-review.md .claude/commands/code-review.md

# Add to .gitignore (symlinks shouldn't be committed)
echo ".claude/commands/code-review.md" >> .gitignore
```

**Pros**: Automatic updates when you pull The Claudfather repo
**Cons**: Breaks if repo moves, not suitable for team sharing

## Strategy 3: Git Submodule (Team Collaboration)

Use git submodules to version-control The Claudfather within your project.

### Setup Submodule

```bash
cd /path/to/your-project

# Add The Claudfather as submodule
git submodule add https://github.com/yourusername/The-Claudfather.git .claude/claudfather

# Initialize submodule
git submodule update --init --recursive

# Commit the submodule
git add .gitmodules .claude/claudfather
git commit -m "feat: add Claudfather components as submodule"
```

### Using Components from Submodule

Option A: Symlink from submodule to active directories
```bash
# Create symlinks to specific components
ln -s .claude/claudfather/commands/code-review.md .claude/commands/code-review.md
ln -s .claude/claudfather/skills/api-integration .claude/skills/api-integration

# Add symlinks to git
git add .claude/commands/code-review.md .claude/skills/api-integration
git commit -m "feat: link Claudfather components"
```

Option B: Copy from submodule (allows customization)
```bash
cp .claude/claudfather/commands/code-review.md .claude/commands/
# Customize as needed, then commit
git add .claude/commands/code-review.md
git commit -m "feat: add customized code-review command"
```

### Updating Submodule

```bash
# Update to latest version
cd .claude/claudfather
git pull origin main
cd ../..
git add .claude/claudfather
git commit -m "chore: update Claudfather components"

# Team members update with
git submodule update --remote
```

**Pros**: Version-controlled, team collaboration, selective updates
**Cons**: More complex, requires submodule knowledge

## Strategy 4: Selective Copy with Customization

Copy components and customize for your project's specific needs.

```bash
cd /path/to/your-project
mkdir -p .claude/commands

# Copy template
cp ~/The-Claudfather/commands/code-review.md .claude/commands/code-review.md

# Customize for your project
# Edit .claude/commands/code-review.md
# - Adjust allowed-tools
# - Add project-specific checks
# - Modify description

# Commit customized version
git add .claude/commands/code-review.md
git commit -m "feat: add customized code review command"
```

**Pros**: Fully customizable, project-specific optimizations
**Cons**: Diverges from source, no automatic updates, manual maintenance

## Strategy 5: Hybrid Approach (Recommended)

Combine strategies for maximum flexibility:

```bash
# User-level: symlink commonly used components
ln -s ~/The-Claudfather/commands/code-review.md ~/.claude/commands/
ln -s ~/The-Claudfather/agents/code-reviewer.md ~/.claude/agents/

# Project-level: copy and customize project-specific components
cp ~/The-Claudfather/skills/database-schema .claude/skills/ -r
# Then customize .claude/skills/database-schema/SKILL.md for your schema patterns

# Result: Personal tools always updated, project tools customized
```

## MCP Integration Distribution

For MCP configurations, use similar strategies:

### User-Level MCP (Personal)
```bash
# Copy to global config
cp ~/The-Claudfather/mcp/.mcp.json ~/.claude/.mcp.json
# Edit to add your API keys and customize
```

### Project-Level MCP (Team)
```bash
cd /path/to/your-project
cp ~/The-Claudfather/mcp/.mcp.json .mcp.json
# Remove sensitive keys, commit structure only
git add .mcp.json
git commit -m "feat: add MCP configuration"
```

## Choosing the Right Strategy

### Choose Direct Copy if:
- You want simple, one-time setup
- You plan to customize heavily
- You don't need automatic updates

### Choose Symlinks if:
- You want automatic updates
- You use components personally across many projects
- You don't need to share with team

### Choose Git Submodule if:
- You work with a team
- You need version control
- You want controlled updates

### Choose Selective Copy if:
- You need extensive customization
- Each project has unique requirements
- You want full control

### Choose Hybrid if:
- You want best of all worlds
- You have both personal and team projects
- You need flexibility

## Maintenance Tips

### Keeping Components Updated

**With Direct Copy**:
```bash
# Periodically re-copy components you want to update
cp ~/The-Claudfather/commands/code-review.md ~/.claude/commands/
```

**With Symlinks**:
```bash
# Update The Claudfather repo
cd ~/The-Claudfather
git pull origin main
# All symlinked components automatically updated
```

**With Submodules**:
```bash
# In your project
git submodule update --remote .claude/claudfather
git add .claude/claudfather
git commit -m "chore: update Claudfather components"
```

### Tracking Customizations

If you customize copied components, document changes:

```markdown
<!-- In your customized component -->
---
description: Code review command (customized for Project X)
# CUSTOMIZATION: Added project-specific security checks
# BASED ON: The-Claudfather v1.0.0
---
```

## Best Practices

1. **Start Simple**: Begin with direct copy, evolve as needed
2. **Document Choices**: Note which strategy you're using in project README
3. **User vs Project**: Personal preferences in `~/.claude/`, team tools in `.claude/`
4. **Test Before Committing**: Always test components before committing to team repo
5. **Version Awareness**: For critical projects, pin submodule to specific version
6. **Backup Customizations**: If customizing, keep notes on what changed
7. **Review Updates**: When updating, review changes that might affect your workflow

## Troubleshooting

### Symlink Not Working
```bash
# Check if symlink exists
ls -la ~/.claude/commands/

# Re-create if broken
rm ~/.claude/commands/code-review.md
ln -s ~/The-Claudfather/commands/code-review.md ~/.claude/commands/code-review.md
```

### Submodule Issues
```bash
# Reset submodule
git submodule deinit .claude/claudfather
git submodule update --init

# Or remove and re-add
git submodule deinit .claude/claudfather
git rm .claude/claudfather
rm -rf .git/modules/.claude/claudfather
git submodule add <url> .claude/claudfather
```

### Component Not Loading
```bash
# Check Claude Code can find it
claude /help | grep -i command

# Verify file structure
cat ~/.claude/commands/code-review.md | head -10
# Should show valid YAML frontmatter
```

## Further Reading

- [Claude Code Customization Docs](https://docs.claude.com/en/docs/claude-code/customization/overview)
- [Git Submodules Guide](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Symlinks Tutorial](https://www.freecodecamp.org/news/symlink-tutorial-in-linux-how-to-create-and-remove-a-symbolic-link/)
