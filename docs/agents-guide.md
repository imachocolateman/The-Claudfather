# Agents Guide

Subagents are specialized AI assistants that Claude Code can delegate tasks to. Each operates with its own context window, custom system prompt, and configurable tool access.

## What Are Subagents?

Subagents provide:
- **Context Isolation**: Separate context from main conversation
- **Specialized Expertise**: Domain-specific instructions
- **Granular Permissions**: Tool restrictions per agent
- **Task Delegation**: Offload specific work to experts
- **Reusability**: Share agents across projects

## File Structure

Agents are stored as Markdown files:

```
.claude/agents/              # Project-level (team-shared)
  code-reviewer.md
  test-specialist.md

~/.claude/agents/            # User-level (personal)
  my-agent.md
```

## Basic Format

```markdown
---
name: agent-name
description: What this agent does and when to use it
tools: Read, Write, Edit, Bash, Grep, Glob
model: inherit
---

# Agent Name

You are [role with specific expertise]...

[Detailed instructions for the agent...]
```

### Frontmatter Fields

#### name (required)
Lowercase identifier with hyphens.

```yaml
name: code-reviewer
name: test-specialist
name: architecture-advisor
```

#### description (required)
Natural language description of the agent's purpose and when to use it.

```yaml
description: Expert code review specialist focusing on security, performance, and best practices. Use proactively after significant code changes or when preparing pull requests.
```

#### tools (optional)
Comma-separated list of allowed tools. Omit to inherit all tools from main conversation.

```yaml
# Read-only agent
tools: Read, Grep, Glob, Bash

# Full access
tools: Read, Write, Edit, Bash, Grep, Glob, WebFetch

# Inherit all tools (default)
# tools: (omit field)
```

#### model (optional)
Which model this agent should use.

```yaml
model: inherit     # Use same model as main conversation (default)
model: sonnet      # Force Claude 3.5 Sonnet
model: haiku       # Use Haiku (faster, cheaper)
model: opus        # Use Opus (most capable)
```

## Agent Invocation

### Automatic Delegation

Claude automatically delegates when it detects a match:

```
User: "Can you review the authentication code?"

Claude: "I'll use the code-reviewer agent to perform a thorough security-focused review..."
[Delegates to code-reviewer agent]
```

### Explicit Invocation

Users can explicitly request an agent:

```
User: "Use the test-specialist agent to write tests for UserService"

Claude: "I'll delegate to the test-specialist agent..."
[Delegates to test-specialist agent]
```

## Creating Effective Agents

### 1. Define Clear Role and Expertise

```markdown
# Code Reviewer Agent

You are an expert code reviewer with deep knowledge of:
- Security vulnerabilities (OWASP Top 10)
- Performance optimization
- Software engineering best practices
- Design patterns and anti-patterns

Your role is to provide thorough, constructive code reviews.
```

### 2. Specify Responsibilities

```markdown
## Your Responsibilities

- Identify security vulnerabilities before production
- Spot performance bottlenecks
- Ensure code follows project conventions
- Improve maintainability and readability
- Provide specific, actionable feedback
```

### 3. Define Workflow

```markdown
## Review Process

### 1. Understand Context

```bash
git diff --staged
git log -5 --oneline
```

Read project conventions from CONTRIBUTING.md or CLAUDE.md.

### 2. Systematic Analysis

Review across these dimensions:
- Security (authentication, input validation, secrets)
- Performance (N+1 queries, algorithms, caching)
- Code Quality (naming, DRY, error handling)
- Testing (coverage, edge cases)

### 3. Output Format

Provide structured feedback:
- Critical Issues (must fix)
- Important Suggestions (should fix)
- Minor Suggestions (nice to have)
- Positive Observations
```

### 4. Tool Restrictions

Enforce specific behaviors with tool restrictions:

```yaml
# Read-only reviewer agent
tools: Read, Grep, Glob, Bash

# Test-writing agent with full access
tools: Read, Write, Edit, Bash, Grep, Glob

# Research agent with web access
tools: Read, Grep, Glob, WebFetch
```

## Agent Patterns

### Read-Only Analyst Agent

```markdown
---
name: code-analyzer
description: Analyze code for issues without making changes
tools: Read, Grep, Glob, Bash
---

# Code Analyzer

You are a READ-ONLY analyst. You CANNOT edit files.

Your role is to:
1. Analyze code structure
2. Identify issues
3. Recommend improvements
4. Report findings

You provide recommendations, developers implement them.
```

### Full-Access Implementation Agent

```markdown
---
name: feature-implementer
description: Implement new features based on specifications
tools: Read, Write, Edit, Bash, Grep, Glob
---

# Feature Implementer

You are a full-stack developer who implements features.

Your workflow:
1. Read specification
2. Plan implementation
3. Write code
4. Write tests
5. Verify functionality

You have full file access but confirm before:
- Deleting files
- Modifying core functionality
- Changing APIs
```

### Specialized Domain Agent

```markdown
---
name: database-expert
description: Database specialist for schema design and optimization
tools: Read, Write, Edit, Bash, Grep, Glob
---

# Database Expert

You are a database specialist with expertise in:
- PostgreSQL, MySQL, MongoDB
- Schema design and normalization
- Query optimization and indexing
- Migration strategies

When working on database tasks:
1. Analyze existing schema
2. Identify optimization opportunities
3. Design improvements
4. Generate migration files
5. Document changes
```

## Context Isolation

Each agent has its own context window:

```
Main Conversation:
├─ [User and Claude discussing architecture]
│
├─ Delegate to code-reviewer agent
│  └─ code-reviewer context:
│     ├─ Agent system prompt
│     ├─ Files it reads
│     └─ Its analysis
│     └─ Returns: Review report
│
└─ [Main conversation continues with review results]
```

**Benefits**:
- Main conversation stays focused
- Agent has dedicated context for deep work
- Long analyses don't clutter main context
- Multiple agents can work in parallel

## Managing Agent Output

### What Gets Returned

Agents return their final message to the main conversation:

```markdown
## Code Review Report

[Agent's complete analysis...]

### Critical Issues
[Security vulnerabilities found...]

### Recommendations
[Suggested improvements...]
```

### Iterating with Agents

You cannot directly message agents. If you need changes:

```
User: "The code-reviewer agent missed the SQL injection issue. Can you re-review?"

Claude: "I'll re-delegate to the code-reviewer agent with specific focus on SQL injection..."
```

## Example Agents

### Minimal Agent

```markdown
---
name: quick-reviewer
description: Fast code review for small changes
tools: Read, Grep, Glob
model: haiku
---

# Quick Reviewer

Perform rapid code review:
1. Read changed files
2. Check for obvious issues
3. Provide concise feedback

Focus on:
- Syntax errors
- Common mistakes
- Style violations
```

### Comprehensive Agent

```markdown
---
name: security-auditor
description: Comprehensive security audit specialist
tools: Read, Grep, Glob, Bash, WebFetch
model: sonnet
---

# Security Auditor

You are a security specialist conducting comprehensive audits.

## Your Expertise

- OWASP Top 10 vulnerabilities
- Secure authentication and authorization
- Data protection and encryption
- Dependency security
- Infrastructure security

## Audit Process

### 1. Reconnaissance

```bash
# Check dependencies
cat package.json
npm audit

# Look for secrets
git grep -i "password\|api_key\|secret"
```

### 2. Code Analysis

Review for:
- SQL injection
- XSS vulnerabilities
- CSRF protection
- Authentication flaws
- Authorization bypasses
- Insecure cryptography

### 3. Report

```markdown
## Security Audit Report

**Date**: [date]
**Scope**: [files reviewed]
**Risk Level**: [Critical/High/Medium/Low]

### Critical Vulnerabilities
[Must fix immediately...]

### Recommendations
[Security improvements...]

### Compliant Areas
[What's done well...]
```
```

## Tool Permission Strategies

### Progressive Permissions

Start restrictive, add tools as needed:

```yaml
# v1: Read-only
tools: Read, Grep, Glob

# v2: Add bash for analysis
tools: Read, Grep, Glob, Bash

# v3: Full access for fixes
tools: Read, Write, Edit, Bash, Grep, Glob
```

### Purpose-Based Permissions

```yaml
# Reviewer: Read-only
tools: Read, Grep, Glob, Bash

# Implementer: Full file access
tools: Read, Write, Edit, Bash, Grep, Glob

# Researcher: Read + web
tools: Read, Grep, Glob, WebFetch

# Tester: Full access
tools: Read, Write, Edit, Bash, Grep, Glob
```

## Creating Agents with /agents Command

Claude Code provides an interactive agent creator:

```bash
claude
> /agents

# Follow prompts:
# - Agent name
# - Description
# - Tool selection (interactive)
# - Model choice
```

This generates the agent file with proper format.

## Testing Agents

### 1. Create Agent

```bash
# Create in user directory for testing
mkdir -p ~/.claude/agents
nano ~/.claude/agents/test-agent.md
```

### 2. Test Delegation

```bash
claude "Use test-agent to analyze src/auth.ts"
```

### 3. Verify Behavior

Check:
- Does agent activate correctly?
- Are tool restrictions enforced?
- Is output format correct?
- Does it have necessary context?

### 4. Share with Team

```bash
cp ~/.claude/agents/test-agent.md /project/.claude/agents/
git add .claude/agents/test-agent.md
git commit -m "feat: add test-agent for [purpose]"
```

## Common Issues

### Agent Has Wrong Context

**Problem**: Agent doesn't have files it needs

**Solution**: Agent must read files explicitly:
```markdown
## Workflow

1. Read the implementation file
2. Read tests if they exist
3. Check project conventions
```

### Tool Restrictions Too Strict

**Problem**: Agent needs a tool not in allowlist

**Solution**: Add tool to `tools` field:
```yaml
tools: Read, Write, Edit, Bash, Grep, Glob
```

### Agent Not Activating

**Problem**: Claude doesn't delegate to agent

**Solutions**:
1. Make description more specific
2. Explicitly request: "Use the [agent-name] agent to..."
3. Check agent file location and syntax

## Composing Agents

Agents can delegate to other agents (with caution):

```markdown
# Project Manager Agent

When user requests feature implementation:

1. Use architecture-advisor to design
2. Use feature-implementer to code
3. Use test-specialist to test
4. Use code-reviewer to review
```

**Note**: Keep delegation chains short (1-2 levels) to avoid complexity.

## Agent Communication Style

Define how the agent should communicate:

```markdown
## Communication Style

**Be Constructive**:
- Explain WHY something is an issue, not just WHAT
- Provide code examples for fixes
- Acknowledge good practices

**Be Specific**:
- Reference exact file:line numbers
- Show before/after code
- Quantify impact when possible

**Prioritize**:
- Critical issues first
- Group similar issues
- Don't nitpick if bigger problems exist
```

## Success Metrics

Define what success looks like for the agent:

```markdown
## Success Metrics

Your work is successful when:
- Security vulnerabilities caught before production
- Code quality improves over time
- Developers learn from feedback
- Reviews are actionable and clear
- No critical issues slip through
```

## Agent vs Skill vs Command

| Feature | Agents | Skills | Commands |
|---------|--------|--------|----------|
| Invocation | Automatic/Manual | Automatic | Manual |
| Context | Separate context | Main context | Main context |
| Tools | Configurable | Configurable | Configurable |
| Use Case | Delegated tasks | Domain knowledge | User workflows |
| Best For | Code reviews, testing | How-to expertise | Specific actions |

## Resources

- [Claude Code Agents Documentation](https://docs.claude.com/en/docs/claude-code/sub-agents)
- [Example Agents in this repo](../agents/)
- [Agent Template](../templates/agent-template.md)
- [Best Practices](./best-practices.md)
