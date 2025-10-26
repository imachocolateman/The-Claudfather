# Commands Guide

Custom slash commands are user-invoked prompt templates that make Claude Code workflows more efficient and repeatable.

## What Are Commands?

Commands are Markdown files with YAML frontmatter that:
- Are invoked explicitly by users (e.g., `/code-review`)
- Accept arguments for customization
- Can execute bash commands and reference files
- Provide reusable workflows

**Key Difference**: Commands are **user-invoked** while Skills are **model-invoked** (Claude decides when to use them).

## File Structure

Commands are stored as `.md` files:

```
.claude/commands/          # Project-level (team-shared)
  code-review.md
  test-runner.md

~/.claude/commands/        # User-level (personal)
  my-workflow.md
```

## Basic Format

```markdown
---
description: Brief description (max 1024 chars)
allowed-tools: Bash, Read, Edit, Write
argument-hint: [file] [options]
model: inherit
---

# Command Name

Detailed instructions for Claude to follow...
```

### Frontmatter Fields

#### description (required)
Brief explanation of what the command does and when to use it.

```yaml
description: Run comprehensive code review with security and performance checks
```

#### allowed-tools (optional)
Restrict which tools Claude can use during this command.

```yaml
allowed-tools: Read, Grep, Glob, Bash
```

Available tools: `Bash`, `Read`, `Edit`, `Write`, `Grep`, `Glob`, `WebFetch`, `TodoWrite`, and MCP tools.

#### argument-hint (optional)
Shown in command palette to guide users on arguments.

```yaml
argument-hint: [file-or-directory]
```

#### model (optional)
Specify which model to use.

```yaml
model: inherit        # Use current model (default)
model: sonnet         # Force Sonnet
model: haiku          # Force Haiku (faster, cheaper)
model: opus           # Force Opus (most capable)
```

## Using Arguments

Commands can accept arguments using special variables:

### $ARGUMENTS
All arguments as a single string.

```markdown
---
description: Review specified files
argument-hint: [files...]
---

# Code Review

Review these files: $ARGUMENTS

If `$ARGUMENTS` is provided, review those files.
If empty, review staged changes.
```

Usage:
```bash
/code-review src/auth.ts src/user.ts
# $ARGUMENTS = "src/auth.ts src/user.ts"
```

### $1, $2, $3, etc.
Individual positional arguments.

```markdown
---
description: Compare two branches
argument-hint: [branch1] [branch2]
---

# Branch Comparison

Compare branch $1 with branch $2

```bash
git diff $1..$2
```
```

Usage:
```bash
/compare main feature/new-ui
# $1 = "main"
# $2 = "feature/new-ui"
```

## Executing Bash Commands

Prefix lines with `!` to execute bash commands inline:

```markdown
# Deploy Command

! git pull origin main
! npm install
! npm run build
! pm2 restart app
```

Output is included in Claude's context automatically.

## Referencing Files

Use `@` prefix to include file contents:

```markdown
# Compare Files

Compare the implementation:
@src/old-implementation.ts

With the new version:
@src/new-implementation.ts

Highlight differences and improvements.
```

## Organizing Commands

### Flat Structure (Recommended)
```
.claude/commands/
  code-review.md
  test-runner.md
  deploy.md
```

Simple, easy to copy, minimal organization.

### Namespaced (Subdirectories)
```
.claude/commands/
  frontend/
    component-review.md
    style-check.md
  backend/
    api-review.md
    db-migration.md
```

In command palette shows as:
- `/component-review (project:frontend)`
- `/api-review (project:backend)`

## Example Commands

### Simple Command

```markdown
---
description: Check git status and show recent commits
---

# Git Status

Show current git status:

```bash
git status
git log --oneline -10
```

Summarize the current state of the repository.
```

### Command with Arguments

```markdown
---
description: Create a new React component with tests
argument-hint: [component-name]
---

# Create Component

Create a new React component named: $1

1. Create component file: `src/components/$1.tsx`
2. Create test file: `src/components/$1.test.tsx`
3. Create story file: `src/components/$1.stories.tsx`

Follow project patterns for:
- TypeScript interfaces
- Props documentation
- Accessibility attributes
- Test coverage
```

### Command with Tool Restrictions

```markdown
---
description: Security audit (read-only)
allowed-tools: Read, Grep, Glob, Bash
---

# Security Audit

Perform read-only security audit.

You CANNOT make changes. Only analyze and report.

Check for:
- Hardcoded secrets
- SQL injection vulnerabilities
- XSS risks
- Insecure dependencies
```

### Advanced Command with Bash Execution

```markdown
---
description: Run tests and generate coverage report
allowed-tools: Bash, Read, WebFetch
---

# Test Coverage

Execute tests and analyze coverage:

```bash
npm test -- --coverage --json --outputFile=coverage.json
```

Analyze the results and:
1. Identify untested code
2. Recommend additional tests
3. Highlight critical paths without coverage
```

## Best Practices

### 1. Clear Descriptions
```yaml
# ❌ Bad
description: Review code

# ✅ Good
description: Comprehensive code review checking security, performance, and best practices. Use before committing or creating PRs.
```

### 2. Validate Arguments
```markdown
# Validate Arguments

If `$ARGUMENTS` is empty, ask the user what to review.

If `$1` is not a valid file:
```bash
if [ ! -f "$1" ]; then
  echo "Error: File $1 not found"
  exit 1
fi
```
```

### 3. Provide Examples
Include usage examples in the command:

```markdown
## Example Usage

```
/test-runner                    # Run all tests
/test-runner src/auth           # Run auth tests
/test-runner --watch            # Run in watch mode
```
```

### 4. Use Clear Instructions
Be specific about what Claude should do:

```markdown
# ❌ Vague
Review the code and provide feedback.

# ✅ Specific
Review the code for:
1. Security vulnerabilities (SQL injection, XSS, hardcoded secrets)
2. Performance issues (N+1 queries, inefficient algorithms)
3. Code quality (naming, duplication, complexity)

Provide specific examples and suggested fixes for each issue.
```

### 5. Handle Edge Cases
```markdown
# Test Runner

If `$ARGUMENTS` is provided:
- Run specific test file or pattern

If no arguments:
- Run full test suite

If tests fail:
- Analyze failures
- Suggest fixes
- Offer to re-run after fixes
```

## Testing Commands

### 1. Create Command
```bash
# Create in user directory for testing
nano ~/.claude/commands/my-test-command.md
```

### 2. Test in Claude Code
```bash
claude
> /my-test-command
```

### 3. Iterate
Edit the command file and test again. Changes take effect immediately.

### 4. Share with Team
Once tested, copy to project:
```bash
cp ~/.claude/commands/my-test-command.md /path/to/project/.claude/commands/
git add .claude/commands/my-test-command.md
git commit -m "feat: add my-test-command"
```

## Common Patterns

### Checklist Pattern
```markdown
# Pre-Commit Checklist

Run through pre-commit checklist:

- [ ] All tests passing
- [ ] No linting errors
- [ ] Dependencies updated
- [ ] CHANGELOG updated
- [ ] No console.logs or debuggers
- [ ] TypeScript types correct

Report status of each item.
```

### Workflow Pattern
```markdown
# Release Workflow

Follow the release process:

1. **Version Bump**
   ```bash
   npm version patch
   ```

2. **Update Changelog**
   Add entry to CHANGELOG.md

3. **Build**
   ```bash
   npm run build
   ```

4. **Publish**
   ```bash
   npm publish
   ```

5. **Tag and Push**
   ```bash
   git push && git push --tags
   ```
```

### Analysis Pattern
```markdown
# Bundle Size Analysis

Analyze bundle size:

```bash
npm run build -- --analyze
```

Review the analysis and recommend:
1. Libraries that could be lazy-loaded
2. Dependencies that could be replaced
3. Code that could be split
```

## Troubleshooting

### Command Not Showing in Palette

**Problem**: Command doesn't appear in `/` menu

**Solutions**:
1. Check file is in correct location (`.claude/commands/` or `~/.claude/commands/`)
2. Verify file has `.md` extension
3. Check YAML frontmatter is valid
4. Restart Claude Code

### Arguments Not Working

**Problem**: `$ARGUMENTS` or `$1` not being replaced

**Solutions**:
1. Use arguments in command body, not just frontmatter
2. Ensure no quotes around variable: `$1` not `"$1"`
3. Test with simple echo: `echo "Arg1: $1, Arg2: $2"`

### Bash Commands Not Executing

**Problem**: Bash commands in code blocks not running

**Solutions**:
1. Use inline execution with `!` prefix (outside code blocks)
2. Or explicitly tell Claude to run: "Execute these commands:"
3. Check `allowed-tools` includes `Bash`

### Tool Access Denied

**Problem**: "Tool X not allowed for this command"

**Solutions**:
1. Add tool to `allowed-tools` in frontmatter
2. Or remove `allowed-tools` to allow all tools

## Advanced Usage

### Dynamic Arguments
```markdown
# Create Migration

Create database migration: $1

```bash
# Generate timestamp
timestamp=$(date +%Y%m%d%H%M%S)
filename="migrations/${timestamp}_$1.sql"
```

Create file: $filename
```

### Conditional Logic
```markdown
# Deploy

Deploy to environment: $1

If $1 is "production":
- Require confirmation
- Run full test suite
- Create backup

If $1 is "staging":
- Skip confirmation
- Run smoke tests
- No backup needed
```

### Multiple Files
```markdown
# Generate CRUD

Generate CRUD for entity: $1

Create these files:
1. `src/models/$1.ts` - Data model
2. `src/controllers/$1.controller.ts` - HTTP handlers
3. `src/services/$1.service.ts` - Business logic
4. `src/routes/$1.routes.ts` - Route definitions
5. `tests/$1.test.ts` - Test suite
```

## Converting Existing Workflows

If you have manual workflows, convert them to commands:

**Before** (manual steps):
```
1. Run git status
2. Check for uncommitted changes
3. Review recent commits
4. Check tests pass
5. Review CHANGELOG
```

**After** (command):
```markdown
---
description: Pre-push checklist
---

# Pre-Push Check

Run pre-push checklist:

```bash
git status
git log --oneline -5
npm test
```

Review:
- Uncommitted changes?
- CHANGELOG updated?
- All tests passing?

Ready to push?
```

## Resources

- [Claude Code Commands Documentation](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Example Commands in this repo](../commands/)
- [Command Template](../templates/command-template.md)
