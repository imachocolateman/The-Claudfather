# Skills Guide

Agent Skills are model-invoked capabilities that Claude autonomously uses when relevant. Think of them as specialized knowledge that Claude activates automatically based on context.

## What Are Skills?

Skills are directories containing a `SKILL.md` file that:
- Are **model-invoked** (Claude decides when to use them)
- Provide specialized domain knowledge
- Load progressively (only when needed)
- Can include supporting files for advanced topics

**Key Difference**: Skills are **automatic** (Claude invokes), Commands are **manual** (user invokes).

## File Structure

Skills are directories with a `SKILL.md` file:

```
.claude/skills/               # Project-level (team-shared)
  api-integration/
    SKILL.md                  # Required
    examples.md               # Optional supporting file
    reference.md              # Optional reference docs

~/.claude/skills/             # User-level (personal)
  my-skill/
    SKILL.md
```

## SKILL.md Format

```markdown
---
name: skill-name
description: What this skill does AND when to use it. Include trigger terms.
allowed-tools: Read, Write, Edit  # Optional
---

# Skill Name

[Instructions for Claude...]

For advanced topics, see [reference.md](reference.md).
```

### Frontmatter Fields

#### name (required)
Lowercase identifier with hyphens, max 64 characters.

```yaml
name: api-integration
name: database-schema-design
name: test-writing-expert
```

#### description (required)
Must include BOTH:
1. What the skill does
2. When Claude should use it

Max 1024 characters.

```yaml
# ❌ Bad - only says what
description: Generate API clients with error handling

# ✅ Good - says what AND when
description: Generate production-ready API clients with error handling, type safety, and best practices. Use when the user needs to integrate with external APIs or when API-related tasks are mentioned.
```

#### allowed-tools (optional)
Restrict tools available when this skill is active.

```yaml
# Read-only skill
allowed-tools: Read, Grep, Glob

# Full access
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
```

**Note**: `allowed-tools` only works in Claude Code, not other platforms.

## Progressive Disclosure

Skills support lazy-loading of additional content:

### Basic Structure
```
my-skill/
  SKILL.md          # Main skill instructions
  examples.md       # Detailed code examples
  reference.md      # Comprehensive reference
  advanced.md       # Advanced techniques
```

### In SKILL.md

```markdown
# My Skill

Core instructions here...

## Progressive Disclosure

For additional information:
- [examples.md](examples.md) - Detailed code examples
- [reference.md](reference.md) - API reference
- [advanced.md](advanced.md) - Advanced patterns

Claude will load these files when needed.
```

### Benefits
- Keeps initial context small
- Loads detail only when necessary
- Scales to complex topics
- Improves performance

## Trigger Terms

Skills need clear trigger terms in descriptions so Claude knows when to activate them:

### Good Trigger Terms

```yaml
# API Integration Skill
description: Generate API clients. Use when user mentions APIs, REST, GraphQL, external services, or needs to integrate with third-party services.

# Database Skill
description: Design database schemas. Use when user mentions databases, SQL, PostgreSQL, MySQL, MongoDB, schema design, or data modeling.

# Testing Skill
description: Write comprehensive test suites. Use when user needs tests, mentions TDD, BDD, testing frameworks like Jest or pytest, or test coverage.
```

### Key Phrases to Include
- "Use when user mentions..."
- "Activate for..."
- "When [specific keywords] are mentioned..."
- "For [specific tasks]..."

## Writing Effective Skills

### 1. Start with Role and Purpose

```markdown
# API Integration Skill

This skill helps you create robust, production-ready API integrations following industry best practices.

## When to Use This Skill

Activate when:
- User mentions integrating with an API
- Creating API client libraries
- User provides API documentation
- Need to consume external services
```

### 2. Define Scope Clearly

```markdown
## Core Capabilities

### 1. API Client Generation

Generate complete API clients with:
- Type-safe requests
- Error handling
- Authentication support
- Rate limiting
- Retry logic
- Testing utilities

### 2. Supported API Types

- REST APIs (OpenAPI/Swagger)
- GraphQL APIs
- gRPC APIs
- WebSocket APIs
```

### 3. Provide Step-by-Step Process

```markdown
## Implementation Approach

### Step 1: Discovery

Gather information about the API:
- API type (REST/GraphQL/gRPC)
- Authentication method
- Base URL and endpoints
- Rate limits

### Step 2: Generate Structure

Create organized client structure:
- Main client class
- Type definitions
- Error classes
- Endpoint modules

### Step 3: Implement Core Features

See [examples.md](examples.md) for detailed implementations.
```

### 4. Include Best Practices

```markdown
## Best Practices

- Always use environment variables for secrets
- Implement exponential backoff for retries
- Provide comprehensive error messages
- Include request/response logging
- Type everything with TypeScript
- Generate mock clients for testing
```

### 5. Add Quality Checklist

```markdown
## Quality Checklist

Before completing:

- [ ] All endpoints have type definitions
- [ ] Error handling covers all HTTP status codes
- [ ] Authentication is configurable
- [ ] Rate limiting implemented
- [ ] Tests included
- [ ] No hardcoded secrets
```

## Progressive Disclosure Example

### SKILL.md (Core)

```markdown
---
name: api-integration
description: Generate API clients. Use when integrating with APIs.
---

# API Integration Skill

## Core Approach

1. Analyze API documentation
2. Generate type-safe client
3. Implement error handling
4. Add authentication

## Basic Pattern

```typescript
class ApiClient {
  async request(endpoint, options) {
    // Implementation
  }
}
```

For detailed examples, see [examples.md](examples.md).
For authentication patterns, see [auth.md](auth.md).
```

### examples.md (Detailed)

```markdown
# API Integration Examples

## Complete REST Client

```typescript
import { ApiClient } from './client'

// Full implementation with:
// - Error handling
// - Retry logic
// - Type safety
// - Authentication
// [Complete code here...]
```

## GraphQL Client

```typescript
// GraphQL implementation
```

## Testing

```typescript
// Test examples
```
```

### auth.md (Specialized)

```markdown
# Authentication Patterns

## OAuth 2.0

Complete OAuth flow implementation...

## JWT

JWT token handling...

## API Keys

API key authentication...
```

## Skill Discovery

At startup, Claude loads the **name** and **description** of all skills into context. The full skill content is loaded only when activated.

### How Claude Decides to Use a Skill

1. **User mentions trigger terms** in description
2. **Context suggests need** for that domain knowledge
3. **Similar to previous successful activations**

### Testing Skill Activation

```bash
# Test if skill activates
claude "I need to integrate with the GitHub API"
# Should activate api-integration skill

claude "Design a database for an e-commerce app"
# Should activate database-schema skill

claude "Write tests for the UserService"
# Should activate test-writing skill
```

## Skill vs Command

| Feature | Skills | Commands |
|---------|--------|----------|
| Invocation | Model-invoked (automatic) | User-invoked (manual) |
| Trigger | Based on context | Explicit with `/` |
| Purpose | Domain knowledge | Specific workflows |
| Arguments | No | Yes ($1, $2, etc.) |
| Discovery | Always loaded (metadata) | Shown in `/` menu |
| Use Case | "How to do X" | "Do X now" |

### When to Use Which

**Use a Skill when**:
- Teaching Claude how to handle a class of problems
- Providing domain expertise
- Claude should decide when it's needed
- Knowledge applies across many situations

**Use a Command when**:
- User has a specific workflow to trigger
- Need to accept arguments
- Step-by-step process the user controls
- One-time or on-demand task

## Example Skills

### Simple Skill

```markdown
---
name: code-formatter
description: Format code according to project style. Use when user asks to format code or mentions linting, prettier, or code style.
---

# Code Formatter Skill

Format code following project conventions:

1. Detect project style config (.prettierrc, .eslintrc)
2. Apply formatting rules
3. Maintain consistency

## Supported Languages

- JavaScript/TypeScript (Prettier)
- Python (Black)
- Go (gofmt)
- Rust (rustfmt)
```

### Complex Skill with Progressive Disclosure

```markdown
---
name: react-component-builder
description: Build React components following best practices. Use when user needs to create React components, mentions React, JSX, hooks, or component development.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# React Component Builder

Create production-ready React components.

## Component Types

### Functional Components
Standard stateless or stateful components with hooks.

### Form Components
See [forms.md](forms.md) for form patterns.

### Data Display Components
See [data-display.md](data-display.md) for patterns.

## Best Practices

- Use TypeScript
- Proper prop types
- Accessibility (ARIA)
- Performance (memo, useMemo)
- Testing (React Testing Library)

For detailed examples, see [examples.md](examples.md).
For hooks patterns, see [hooks.md](hooks.md).
For testing strategies, see [testing.md](testing.md).
```

## Tool Restrictions

Restrict tools to enforce specific behavior:

### Read-Only Skill

```yaml
---
name: code-analyzer
description: Analyze code for issues
allowed-tools: Read, Grep, Glob, Bash
---
```

This skill can only read and analyze, not modify code.

### Write-Focused Skill

```yaml
---
name: documentation-generator
description: Generate project documentation
allowed-tools: Read, Write, Grep, Glob
---
```

Can read existing code and write documentation.

## Testing Skills

### 1. Create Skill

```bash
mkdir ~/.claude/skills/test-skill
nano ~/.claude/skills/test-skill/SKILL.md
```

### 2. Test Activation

```bash
claude "Mention trigger terms from description"
```

Check if Claude mentions using the skill.

### 3. Have Colleagues Test

Ask teammates to use it:
- Does it activate when expected?
- Does it stay dormant when not needed?
- Is the output helpful?

### 4. Iterate Description

If activation is wrong:
- Add more specific trigger terms
- Clarify when to use
- Adjust description

## Common Patterns

### Domain Expert Pattern

```markdown
---
name: security-auditor
description: Perform security audits
---

# Security Auditor

You are a security expert specializing in:
- OWASP Top 10 vulnerabilities
- Authentication and authorization
- Data protection and encryption
- Secure coding practices

When analyzing code, check for:
[Detailed security checklist...]
```

### Generator Pattern

```markdown
---
name: crud-generator
description: Generate CRUD operations
---

# CRUD Generator

Generate complete CRUD for an entity:

1. Create data model
2. Generate controller
3. Add service layer
4. Create tests
5. Add API routes

Follow project architecture patterns.
```

### Analyzer Pattern

```markdown
---
name: performance-analyzer
description: Analyze performance issues
---

# Performance Analyzer

Analyze code for performance:

1. Identify bottlenecks
2. Suggest optimizations
3. Recommend caching
4. Database query analysis

Provide specific, actionable recommendations.
```

## Troubleshooting

### Skill Not Activating

**Problem**: Claude doesn't use the skill when expected

**Solutions**:
1. Make description more specific with trigger terms
2. Explicitly mention skill: "Use the api-integration skill to..."
3. Check SKILL.md is in correct location
4. Verify YAML frontmatter is valid

### Skill Always Activating

**Problem**: Skill activates when not relevant

**Solutions**:
1. Make description more specific about when NOT to use
2. Add constraints: "Only use when user explicitly mentions..."
3. Narrow the scope in description

### Supporting Files Not Loading

**Problem**: Claude doesn't reference examples.md, etc.

**Solutions**:
1. Link files from SKILL.md: `[examples](examples.md)`
2. Prompt Claude: "Check examples.md for detailed patterns"
3. Ensure files are in same directory as SKILL.md

## Sharing Skills

### With Your Team

```bash
# Commit skill to project repo
git add .claude/skills/my-skill/
git commit -m "feat: add my-skill for [purpose]"
git push

# Team members get it automatically
git pull
```

### Via Plugin (Advanced)

Package skills as Claude Code plugins for marketplace distribution.

## Versioning Skills

Track changes in a `VERSION.md` or CHANGELOG:

```markdown
# Version History

## v2.0.0 (2025-01-15)
- Added GraphQL support
- Improved error handling
- Added authentication examples

## v1.0.0 (2025-01-01)
- Initial release
- REST API support
```

## Resources

- [Claude Code Skills Documentation](https://docs.claude.com/en/docs/claude-code/skills)
- [Official Skills Repository](https://github.com/anthropics/skills)
- [Example Skills in this repo](../skills/)
- [Skill Template](../templates/skill-template/)
- [Best Practices](./best-practices.md)
