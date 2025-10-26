# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Claudfather is a curated collection of modular, reusable Claude Code components (commands, skills, and agents). This is NOT a traditional software project with build/test workflows. Instead, it's a component library designed for distribution across other projects.

## Repository Structure

```
commands/        - Custom slash commands (user-invoked)
skills/          - Agent skills (model-invoked, self-contained directories)
agents/          - Specialized subagents (task-focused)
templates/       - Templates for creating new components
mcp/            - MCP server configurations
docs/           - Comprehensive documentation guides
```

## Key Principles

### Component Design Philosophy

1. **Modularity First**: Each component must be independently usable
2. **Self-Documenting**: Clear descriptions that explain both WHAT and WHEN
3. **Production-Ready**: All examples should demonstrate real-world patterns
4. **Best Practices**: Follow official Anthropic guidelines strictly

### Naming Conventions

- **Commands**: lowercase-with-hyphens.md (e.g., `code-review.md`)
- **Skills**: lowercase-with-hyphens/ with SKILL.md inside (e.g., `api-integration/SKILL.md`)
- **Agents**: lowercase-with-hyphens.md (e.g., `code-reviewer.md`)
- **Max length**: 64 characters for names
- **No special characters**: Only letters, numbers, hyphens

### Component Formats

**Commands** require YAML frontmatter:
```yaml
---
description: Brief description (max 1024 chars)
allowed-tools: Bash, Read, Edit  # optional
argument-hint: [file] [options]  # optional
model: inherit  # optional
---
```

**Skills** require SKILL.md with frontmatter:
```yaml
---
name: skill-name
description: What it does AND when to use it (max 1024 chars)
allowed-tools: Read, Grep, Glob  # optional
---
```

**Agents** require YAML frontmatter:
```yaml
---
name: agent-name
description: Natural language purpose statement
tools: Read, Grep, Glob, Bash  # comma-separated, optional
model: inherit  # or sonnet, opus, haiku
---
```

## Development Workflow

### When Adding New Components

1. **Use templates**: Start from `templates/` directory
2. **Test first**: Copy to `~/.claude/` and test in a real project
3. **Document trigger terms**: For skills, be explicit about when Claude should use them
4. **Keep focused**: One capability per component
5. **Progressive disclosure**: For skills, use linked supporting files instead of stuffing everything in SKILL.md

### Quality Checklist

Before committing a new component:
- [ ] Naming follows conventions (lowercase-with-hyphens)
- [ ] Description is clear and includes "when to use" guidance
- [ ] Frontmatter is properly formatted (YAML syntax)
- [ ] Component tested in at least one real project
- [ ] Supporting documentation is updated
- [ ] No hardcoded paths or project-specific assumptions

### Documentation Updates

When modifying components, also update:
- README.md (if adding new example)
- Relevant guide in `docs/` directory
- DISTRIBUTION.md (if deployment approach changes)

## Testing Components

Since these are Claude Code components, manual testing involves:

1. Copy component to `~/.claude/` directory
2. Open a test project with Claude Code
3. For commands: Test with `/command-name`
4. For skills: Verify Claude invokes them appropriately
5. For agents: Test delegation with explicit requests

## Git Workflow

- Main branch: `main` (stable, production-ready components)
- No automated tests (manual validation required)
- Commit message format: "type: brief description"
  - feat: New component
  - fix: Bug fix in component
  - docs: Documentation update
  - refactor: Component improvement
  - chore: Maintenance tasks

## Important Notes

- **No build system**: This is a component library, not executable code
- **No dependencies**: Components should work standalone
- **Markdown-focused**: All components are Markdown with YAML frontmatter
- **Distribution-oriented**: Components designed to be copied/symlinked to other projects

## Resources

- [Claude Code Docs](https://docs.claude.com/en/docs/claude-code/overview)
- [Best Practices Blog](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Official Skills Repo](https://github.com/anthropics/skills)

## License

MIT License (see LICENSE file)
