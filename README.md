# The Claudfather 🎩

A curated collection of Claude Code components (commands, skills, and agents) designed for modular reuse across projects.

**Important** This is currently in development only. Not ready for use

## What's Inside

This repository provides battle-tested Claude Code components that you can drop into any project:

- **Commands** (`commands/`): Custom slash commands for common workflows
- **Skills** (`skills/`): Model-invoked capabilities that Claude uses autonomously
- **Agents** (`agents/`): Specialized subagents for focused tasks
- **Templates** (`templates/`): Scaffolding for creating new components
- **MCP Integration** (`mcp/`): Model Context Protocol configurations and examples

## Quick Start

### Automated Setup (Recommended)

Use the provided setup scripts to install all components to your user-level `~/.claude/` directory:

**Mac/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

The scripts will:
- Auto-detect your Claude user directory
- Show what's NEW or MODIFIED before copying
- Copy commands, agents, skills, and settings
- Provide a summary report

**Windows Note:** If you get an execution policy error, run this once:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Using Individual Components

**Copy a command:**
```bash
# Project-level (shared with team)
cp commands/code-review.md /path/to/your-project/.claude/commands/

# User-level (personal, works across all projects)
cp commands/code-review.md ~/.claude/commands/
```

**Copy a skill:**
```bash
# Project-level
cp -r skills/api-integration /path/to/your-project/.claude/skills/

# User-level
cp -r skills/api-integration ~/.claude/skills/
```

**Copy an agent:**
```bash
# Project-level
cp agents/code-reviewer.md /path/to/your-project/.claude/agents/

# User-level
cp agents/code-reviewer.md ~/.claude/agents/
```

### Using the Entire Collection

See [DISTRIBUTION.md](DISTRIBUTION.md) for strategies on:
- Symlinking for automatic updates
- Git submodules for version control
- Selective copying based on project needs

## Example Components

### Commands (User-Invoked)
- `/code-review` - Comprehensive code review with checklist
- `/test-runner` - Execute tests with intelligent reporting
- `/refactor-guide` - Interactive refactoring workflow

### Skills (Model-Invoked)
- **api-integration** - Generate API clients following best practices
- **database-schema** - Design database schemas with optimization guidance
- **test-writing** - Create comprehensive test suites with edge cases

### Agents (Task-Specialized)
- **code-reviewer** - Deep code review specialist (read-only)
- **test-specialist** - Testing expert with full tool access
- **architecture-advisor** - System design consultant

## Creating New Components

Use the templates in `templates/` directory:

```bash
# Copy template
cp templates/command-template.md commands/my-new-command.md

# Edit and customize
# Then test in a project
cp commands/my-new-command.md ~/.claude/commands/
```

See the documentation guides in `docs/` for detailed instructions.

## Documentation

- **[Commands Guide](docs/commands-guide.md)** - Creating and using custom slash commands
- **[Skills Guide](docs/skills-guide.md)** - Building model-invoked capabilities
- **[Agents Guide](docs/agents-guide.md)** - Developing specialized subagents
- **[Best Practices](docs/best-practices.md)** - Curated patterns and conventions
- **[Distribution Guide](DISTRIBUTION.md)** - Deploying components across projects

## Best Practices

This repository follows official Anthropic Claude Code best practices:

- **Clear naming**: lowercase-with-hyphens for all components
- **Focused scope**: One capability per component
- **Progressive disclosure**: Skills load supporting files on-demand
- **Trigger clarity**: Descriptions include both what and when to use
- **Tool restrictions**: Agents specify allowed tools for safety
- **Team testing**: Components validated across different use cases

## Contributing

This is a personal collection, but you're welcome to:
- Fork and customize for your needs
- Suggest improvements via issues
- Share your own component designs

## License

MIT License - See [LICENSE](LICENSE) file

## Resources

- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code/overview)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Official Skills Repository](https://github.com/anthropics/skills)
