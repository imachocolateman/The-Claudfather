# Best Practices

This guide compiles best practices for creating and using Claude Code components, drawn from official Anthropic documentation and real-world usage.

## General Principles

### 1. Modularity First

**Design for Reuse**:
- Each component does one thing well
- No project-specific hardcoded values
- Components work standalone

```markdown
# ❌ Bad - hardcoded paths
Read the config at /Users/me/project/config.json

# ✅ Good - flexible
Read the config file in the project root
```

### 2. Self-Documenting Components

**Clear Descriptions**:
- Explain what AND when to use
- Include trigger terms
- Provide usage examples

```yaml
# ❌ Bad
description: Review code

# ✅ Good
description: Comprehensive code review checking security, performance, and best practices. Use before committing or creating PRs. Includes SQL injection checks, N+1 query detection, and style validation.
```

### 3. Progressive Disclosure

**Start Simple, Add Detail on Demand**:

```
skill/
  SKILL.md          # Core instructions (always loaded)
  examples.md       # Detailed examples (load when needed)
  reference.md      # Comprehensive docs (load when needed)
```

Benefits:
- Efficient context usage
- Faster initial loading
- Scales to complex topics

### 4. Test Before Sharing

**Validation Process**:
1. Test in personal directory (~/.claude/)
2. Use in real projects
3. Have colleagues test
4. Iterate based on feedback
5. Then commit to team repo

## Component-Specific Best Practices

### Commands

#### Use Meaningful Arguments

```markdown
# ❌ Bad
---
argument-hint: [arg1] [arg2]
---

# ✅ Good
---
argument-hint: [file-or-directory] [--with-coverage]
---
```

#### Validate Inputs

```markdown
# Validate Arguments

If `$ARGUMENTS` is empty:
- Ask user what to process
- Don't assume defaults

If file doesn't exist:
```bash
if [ ! -f "$1" ]; then
  echo "Error: File not found: $1"
  exit 1
fi
```
```

#### Provide Usage Examples

```markdown
## Example Usage

```
/command                      # Default behavior
/command src/auth.ts          # Specific file
/command src/ --verbose       # With options
```
```

#### Restrict Tools When Appropriate

```yaml
# Read-only command
allowed-tools: Read, Grep, Glob, Bash(git *)

# Full access command
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
```

### Skills

#### Write Trigger-Rich Descriptions

```yaml
# ❌ Vague
description: Handle API calls

# ✅ Specific with triggers
description: Generate production-ready API clients with error handling, type safety, and rate limiting. Use when user mentions APIs, REST, GraphQL, external services, HTTP requests, or needs to integrate with third-party services.
```

#### Include "When to Use"

Every skill description should answer:
- What does it do?
- When should it activate?
- What keywords trigger it?

```yaml
description: |
  WHAT: Design optimized database schemas with indexes and migrations.
  WHEN: Use when user mentions databases, SQL, PostgreSQL, schema design, or data modeling.
  KEYWORDS: database, schema, migration, SQL, table, index, query
```

#### Structure Content Hierarchically

```markdown
# Skill Name

## Core Capabilities
[Essential information - always loaded]

## Implementation Approach
[Step-by-step process]

## Best Practices
[Guidelines to follow]

## Progressive Disclosure
For advanced topics, see:
- [examples.md](examples.md)
- [reference.md](reference.md)
```

#### Keep SKILL.md Focused

Main SKILL.md should be:
- < 500 lines ideally
- Core instructions only
- Links to supporting docs

Supporting files can be longer with detailed examples.

### Agents

#### Define Clear Role and Boundaries

```markdown
# Agent Name

You are [specific role] with expertise in [domain].

You CAN:
- [Capability 1]
- [Capability 2]

You CANNOT:
- [Limitation 1]
- [Limitation 2]
```

#### Match Tools to Responsibility

```yaml
# Reviewer: Read-only
tools: Read, Grep, Glob, Bash

# Implementer: Full access
tools: Read, Write, Edit, Bash, Grep, Glob

# Researcher: Read + web
tools: Read, Grep, Glob, WebFetch
```

#### Structure Output Consistently

```markdown
## Output Format

Always provide results in this structure:

```markdown
## [Report Title]

**Summary**: [brief overview]

### [Section 1]
[detailed findings]

### [Section 2]
[recommendations]

### Next Steps
[actionable items]
```
```

#### Emphasize Communication Style

```markdown
## Communication Style

**Be Constructive**:
- Explain WHY, not just WHAT
- Provide examples
- Acknowledge good work

**Be Specific**:
- Use file:line references
- Show code examples
- Quantify impact

**Prioritize**:
- Critical issues first
- Group similar items
- Focus on high-impact
```

## Naming Conventions

### All Components

- **Lowercase with hyphens**: `code-review`, `api-integration`, `test-specialist`
- **Max 64 characters**: Keep names concise
- **Descriptive**: Name should indicate purpose
- **No special chars**: Only letters, numbers, hyphens

```
# ✅ Good names
code-review.md
api-integration/
test-specialist.md

# ❌ Bad names
CodeReview.md
api_integration/
testSpecialist.md
```

### Files and Directories

```
.claude/
  commands/
    kebab-case-name.md
  skills/
    kebab-case-name/
      SKILL.md
      examples.md
  agents/
    kebab-case-name.md
```

## YAML Frontmatter

### Always Valid YAML

```yaml
# ❌ Bad - missing quotes with special chars
description: Review code & suggest improvements

# ✅ Good - quoted
description: "Review code & suggest improvements"

# ❌ Bad - multi-line without pipe
description: This is a very long description that
spans multiple lines

# ✅ Good - pipe or quoted
description: |
  This is a very long description that
  spans multiple lines
```

### Required vs Optional Fields

```yaml
# Commands
description: [required]
allowed-tools: [optional]
argument-hint: [optional]
model: [optional]

# Skills
name: [required]
description: [required]
allowed-tools: [optional]

# Agents
name: [required]
description: [required]
tools: [optional]
model: [optional]
```

## Tool Management

### Start Restrictive

Begin with minimal tools, add as needed:

```yaml
# v1: Read-only
allowed-tools: Read, Grep, Glob

# v2: Add bash for analysis
allowed-tools: Read, Grep, Glob, Bash

# v3: Full access if needed
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
```

### Purpose-Based Tool Selection

**Analyzers**: `Read, Grep, Glob, Bash`
**Writers**: `Read, Write, Bash, Grep, Glob`
**Editors**: `Read, Edit, Bash, Grep, Glob`
**Researchers**: `Read, Grep, Glob, WebFetch`
**Full-Featured**: All tools

### Never Restrict Without Reason

Only restrict tools if you need to:
- Enforce read-only behavior
- Prevent accidental changes
- Limit scope for safety

Otherwise, allow all tools (omit field).

## Context Management

### Keep Components Focused

- Commands: One workflow
- Skills: One domain
- Agents: One role

```markdown
# ❌ Too broad
name: developer-helper
description: Helps with coding, testing, deployment, and documentation

# ✅ Focused
name: test-writer
description: Generate comprehensive test suites with edge cases
```

### Use Progressive Disclosure

Don't pack everything into main file:

```markdown
# SKILL.md - Core only

[Essential information]

For details:
- [examples.md](examples.md) - 20+ code examples
- [patterns.md](patterns.md) - Advanced patterns
- [troubleshooting.md](troubleshooting.md) - Common issues
```

## Security Best Practices

### Never Hardcode Secrets

```markdown
# ❌ Bad
const API_KEY = "sk_live_abc123xyz"

# ✅ Good
const API_KEY = process.env.API_KEY
```

### Validate All Inputs

```markdown
# ❌ Bad - no validation
Run command: `git clone $1`

# ✅ Good - validate first
Validate that $1 is a safe URL before running:
```bash
if [[ ! "$1" =~ ^https?:// ]]; then
  echo "Error: Invalid URL"
  exit 1
fi
git clone "$1"
```
```

### Check for Sensitive Data

Before committing, scan for:
- API keys
- Passwords
- Database credentials
- Private URLs
- Personal information

```bash
# Quick check
git diff | grep -iE "password|api_key|secret|token|credential"
```

## Documentation

### Component Documentation

Every component should have:

**In the file itself**:
- Clear description
- Usage examples
- Expected behavior

**In project README**:
- What components are available
- When to use each
- How to deploy them

### CLAUDE.md Integration

Document your components in CLAUDE.md:

```markdown
# CLAUDE.md

## Available Custom Components

### Commands
- `/code-review` - Pre-commit code review
- `/test-runner` - Execute tests with analysis

### Skills
- **api-integration** - Generate API clients
- **database-schema** - Design database schemas

### Agents
- **code-reviewer** - Security-focused reviews
- **test-specialist** - Comprehensive testing
```

## Version Control

### What to Commit

✅ **Do commit**:
- Component files (.md)
- Templates
- Documentation
- Example configurations

❌ **Don't commit**:
- API keys or secrets
- Personal configurations
- Project-specific customizations
- .mcp.json with credentials

### Git Workflow

```bash
# Good commit messages
git commit -m "feat: add code-review command"
git commit -m "fix: improve api-integration trigger terms"
git commit -m "docs: add examples to test-specialist"
git commit -m "refactor: split large skill into modules"

# Use .gitignore
echo ".mcp.json" >> .gitignore
echo "*.env" >> .gitignore
```

## Testing and Validation

### Manual Testing Checklist

Before sharing a component:

- [ ] Test in personal directory first
- [ ] Try in 2-3 different projects
- [ ] Test edge cases and errors
- [ ] Verify tool restrictions work
- [ ] Check with different arguments
- [ ] Have colleague try it
- [ ] Iterate based on feedback

### Continuous Improvement

```markdown
# Component: test-runner

## Feedback Log

### 2025-01-15 - Added coverage analysis
User feedback: "Would be helpful to see coverage"
Change: Added --coverage flag handling

### 2025-01-10 - Fixed Python support
Issue: Wasn't detecting pytest
Change: Added pytest.ini check

### 2025-01-05 - Initial release
```

## Performance Optimization

### Keep Components Lightweight

- Skills: Core SKILL.md < 500 lines
- Commands: Focus on workflow, not encyclopedia
- Agents: Clear instructions, not exhaustive lists

### Load on Demand

```markdown
# Instead of including all examples inline

## Examples

See [examples.md](examples.md) for:
- 20+ code examples
- Common patterns
- Edge cases
```

### Efficient Tool Usage

```markdown
# ❌ Wasteful
Read file1
Read file2
Read file3
[Process each separately]

# ✅ Efficient
Read file1, file2, file3 in parallel
[Process together]
```

## Common Pitfalls to Avoid

### Over-Engineering

```markdown
# ❌ Too complex
Create a full CI/CD pipeline with:
- Docker
- Kubernetes
- Monitoring
- Logging
- Alerting
[50 more steps...]

# ✅ Start simple
Run tests and deploy to staging:
1. Run tests
2. Build
3. Deploy
```

### Vague Instructions

```markdown
# ❌ Vague
Review the code and provide feedback.

# ✅ Specific
Review code for:
1. Security: SQL injection, XSS, secrets
2. Performance: N+1 queries, O(n²) algorithms
3. Quality: Naming, DRY, error handling

Provide file:line references and code examples.
```

### Tool Restriction Overuse

```yaml
# ❌ Over-restricted without reason
allowed-tools: Read

# ✅ Appropriate restriction
# Only restrict if component should be read-only
allowed-tools: Read, Grep, Glob, Bash
```

### Missing Error Handling

```markdown
# ❌ No error handling
Run tests and report results.

# ✅ With error handling
Run tests:
- If tests pass: Report success and coverage
- If tests fail: Analyze failures and suggest fixes
- If tests can't run: Check setup and guide user
```

## Maintenance

### Regular Review

Quarterly review of components:
- Are they still relevant?
- Do they follow current best practices?
- Can they be simplified?
- Are there new features to add?

### Update Documentation

When updating components:
- Update description if behavior changes
- Add examples for new features
- Document breaking changes
- Update version/changelog

### Deprecation Strategy

When retiring a component:

```markdown
# component.md

> **DEPRECATED**: This component is deprecated in favor of [new-component].
> See [migration guide](migration.md) for upgrading.

[Original content...]
```

## Resources

### Official Documentation
- [Claude Code Overview](https://docs.claude.com/en/docs/claude-code/overview)
- [Best Practices Blog](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Skills Documentation](https://docs.claude.com/en/docs/claude-code/skills)
- [Agents Documentation](https://docs.claude.com/en/docs/claude-code/sub-agents)

### Community Resources
- [Official Skills Repository](https://github.com/anthropics/skills)
- [The Claudfather Repository](https://github.com/yourusername/The-Claudfather)

### Related Guides
- [Commands Guide](./commands-guide.md)
- [Skills Guide](./skills-guide.md)
- [Agents Guide](./agents-guide.md)
- [Distribution Guide](../DISTRIBUTION.md)
