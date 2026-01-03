# Claude Code Professional Engineering Team Setup

A comprehensive, production-ready configuration for Claude Code that replicates the capabilities of a 5+ person professional software engineering team. Based on Boris Cherny's (creator of Claude Code) actual workflow and extensive research into professional engineering practices.

## Overview

This repository provides a complete setup that transforms Claude Code into a multi-role engineering team through specialized slash commands, subagents, hooks, and team-wide configurations. The goal is not to replace human engineers, but to amplify their capabilities by automating repetitive tasks and providing specialized AI assistance for different aspects of the development workflow.

### What You Get

**Automated Team Roles:**
- **Senior Developer** - Main Claude instance with Opus 4.5 for high-level coding
- **Code Reviewer** - Critical review with security and quality checks
- **QA Engineer** - Comprehensive end-to-end testing and verification
- **Code Janitor** - Automatic formatting and code hygiene
- **DevOps Engineer** - Deployment and infrastructure automation
- **Tech Lead** - Architecture decisions and design patterns

**Professional Workflows:**
- Git workflow automation (commit, push, PR creation)
- Automated code formatting and linting
- End-of-turn quality gates with testing
- Multi-session management for parallel work
- Team-wide documentation and knowledge sharing

## Quick Start

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/claude-code.git
   cd claude-code
   ```

2. **Copy the `.claude` directory to your project:**
   ```bash
   cp -r .claude /path/to/your/project/
   cd /path/to/your/project
   ```

3. **Make hooks executable:**
   ```bash
   chmod +x .claude/hooks/*.sh
   ```

4. **Commit to your repository:**
   ```bash
   git add .claude
   git commit -m "feat: add Claude Code professional team setup"
   git push
   ```

5. **Start using Claude Code:**
   ```bash
   claude-code
   ```

### First Steps

1. **Customize team documentation:**
   - Edit `.claude/docs.md` with your project-specific conventions
   - Update allowed commands in `.claude/settings.json`

2. **Try the essential workflows:**
   ```bash
   # Start in Plan mode (shift+tab twice)
   > I need to add user authentication
   
   # After implementation, use subagents
   > @code-simplifier review my changes
   > @verify-app test the authentication
   > @code-reviewer check for issues
   
   # Commit and create PR
   > /commit-push-pr "feat: add user authentication"
   ```

## Repository Structure

```
.
├── .claude/
│   ├── commands/              # Slash commands for workflows
│   │   ├── git/
│   │   │   └── commit-push-pr.md
│   │   ├── test/
│   │   └── deploy/
│   ├── agents/                # Subagents (specialized team members)
│   │   ├── code-simplifier.md
│   │   ├── verify-app.md
│   │   └── code-reviewer.md
│   ├── hooks/                 # Automated quality gates
│   │   ├── post-tool-use.sh
│   │   └── stop.sh
│   ├── settings.json          # Team-wide configurations
│   └── docs.md                # Team knowledge base
├── RESEARCH.md                # Comprehensive research findings
├── IMPLEMENTATION_GUIDE.md    # Step-by-step implementation guide
└── README.md                  # This file
```

## Core Components

### 1. Slash Commands

Slash commands are reusable, parameterized prompts that automate repetitive "inner loop" development workflows. They are stored as Markdown files in `.claude/commands/` and shared across the team via Git.

**Key Features:**
- **Pre-computed Context** - Uses inline bash (`!`command``) to inject real-time data
- **Security Controls** - Frontmatter defines allowed tools to prevent dangerous operations
- **Namespacing** - Organized in subdirectories (git/, test/, deploy/) for clarity
- **Version Control** - Committed to Git for team consistency

**Example: `/commit-push-pr`**

The most-used command by Boris Cherny (dozens of times daily), this automates the complete git workflow:

```markdown
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git push:*), Bash(gh pr create:*)
argument-hint: [commit-message]
description: Commit staged changes, push to the current branch, and create a pull request.
model: claude-opus-4.5
---

## Context for Claude
- **Current git status:** !`git status`
- **Current branch:** !`git branch --show-current`
- **Recent commits:** !`git log --oneline -5`
- **Staged changes:** !`git diff --staged`

## Your Task
1. Review the staged changes
2. Commit with message: "$ARGUMENTS"
3. Push to remote branch
4. Create PR with detailed description
```

**Best Practices:**
- Standardize all commands as Project Commands (`.claude/commands/`)
- Use inline bash to pre-compute context for accuracy
- Explicitly define allowed-tools in frontmatter for security
- Track command usage via hooks for continuous improvement

### 2. Subagents

Subagents are specialized AI assistants with their own system prompts, tools, and separate context windows. They simulate different roles in a professional engineering team, preventing the main agent from being a generalist.

**Key Features:**
- **Specialized Personas** - Each subagent has a focused role and expertise
- **Separate Contexts** - Prevents context pollution in main conversation
- **Granular Tool Access** - Security through limited tool permissions
- **Proactive Delegation** - Automatic invocation when appropriate

**Included Subagents:**

#### `code-simplifier`
- **Role:** Code hygiene and maintainability expert
- **Tools:** Read, Edit, Grep, Glob
- **Purpose:** Improves readability without changing functionality
- **Usage:** Runs proactively after code changes

#### `verify-app`
- **Role:** Quality assurance engineer
- **Tools:** Read, Bash, Grep, Glob
- **Purpose:** Comprehensive end-to-end testing
- **Usage:** Must be used before final commits

#### `code-reviewer`
- **Role:** Senior code reviewer
- **Tools:** Read, Grep, Glob
- **Purpose:** Critical review for quality, security, performance
- **Usage:** Provides structured feedback (critical/important/minor)

**Best Practices:**
- Define specialized personas for distinct roles
- Use "be critical" and "be honest" in prompts to override agreeable LLM behavior
- Include "Use proactively" in descriptions for automatic delegation
- Leverage separate contexts to keep main conversation focused

### 3. Hooks

Hooks are callbacks that inject custom logic at various points in Claude's execution loop. They serve as automated quality gates and ensure professional code hygiene.

**Available Hooks:**

#### `post-tool-use.sh`
Runs immediately after every file edit to enforce deterministic formatting:
- Python: Black formatter + Ruff linter
- JavaScript/TypeScript: Prettier + ESLint
- Go: gofmt
- Rust: rustfmt
- Tracks tool usage metrics

#### `stop.sh`
Runs at the end of each turn as a quality gate:
- Executes test suites (npm test, pytest, cargo test)
- Runs type checking (TypeScript, mypy)
- Performs linting (ESLint, ruff)
- Conducts security scanning (bandit)
- Logs quality metrics

**Best Practices:**
- Use PostToolUse for deterministic, fast operations (formatting)
- Use Stop hooks for comprehensive verification (testing)
- Exit with appropriate codes (0 = success, non-zero = issues found)
- Log metrics for continuous improvement

### 4. Team Documentation

The `.claude/docs.md` file is a living document that serves as the team's shared knowledge base. It's committed to Git and updated weekly as patterns emerge.

**What to Include:**
- Project-specific conventions and patterns
- Common mistakes to avoid
- Things Claude should NOT do
- Things Claude SHOULD always do
- Known issues and workarounds
- Performance and security considerations

**Example Sections:**
```markdown
## Things Claude Should NOT Do
- Don't use `any` type in TypeScript
- Don't commit commented-out code
- Don't hardcode configuration
- Don't skip error handling

## Things Claude SHOULD Do
- Run tests before committing
- Update documentation when changing behavior
- Add logging for important operations
- Use type hints for all functions
```

## Boris Cherny's Workflow Principles

Based on the creator of Claude Code's actual setup:

### 1. Use Opus 4.5 with Thinking
Despite being slower, Opus 4.5 requires less steering and has better tool use, making it faster overall for complex tasks.

### 2. Start in Plan Mode
Press shift+tab twice to enter Plan mode. Get the plan right before switching to auto-accept edits mode. A good plan is critical for success.

### 3. Run Multiple Claudes in Parallel
Boris runs 5 Claudes in terminal tabs and 5-10 on claude.ai/code simultaneously. Use `&` for session handoff and `--teleport` to move between terminal and web.

### 4. Verification is Mandatory
"Give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result." Every workflow should include verification.

### 5. Pre-compute Context
Use inline bash in slash commands to inject real-time context (git status, environment variables) before Claude processes the prompt.

### 6. Shared Team Configuration
Everything in `.claude/` is committed to Git and shared with the team. Update `.claude/docs.md` weekly as you discover new patterns.

## Implementation Roadmap

### Phase 1: Foundation (Week 1)
- [ ] Create `.claude/` directory structure
- [ ] Set up basic slash commands for git workflows
- [ ] Configure permissions in `settings.json`
- [ ] Create team documentation file (`docs.md`)

### Phase 2: Team Members (Week 2)
- [ ] Implement `code-simplifier` subagent
- [ ] Implement `verify-app` subagent
- [ ] Implement `code-reviewer` subagent
- [ ] Test subagent delegation and proactive use

### Phase 3: Automation (Week 3)
- [ ] Set up PostToolUse hook for formatting
- [ ] Set up Stop hook for testing
- [ ] Configure GitHub Actions with `/install-github-action`
- [ ] Set up MCP servers for external tools

### Phase 4: Optimization (Week 4)
- [ ] Practice multi-session management
- [ ] Optimize slash commands with usage tracking
- [ ] Refine subagent prompts based on team feedback
- [ ] Document team-specific patterns in `docs.md`

## Key Metrics for Success

Track these metrics to measure your team's efficiency:

1. **Slash Command Usage** - Which workflows are most used?
2. **Subagent Invocations** - Are specialists being used proactively?
3. **Hook Execution Rate** - How often do quality gates catch issues?
4. **PR Cycle Time** - Time from code to merged PR
5. **Code Review Iterations** - Fewer iterations = better quality
6. **Test Pass Rate** - First-time pass rate for CI/CD

Metrics are automatically logged to `.claude/metrics/`:
- `tool_usage.csv` - Command and tool usage
- `quality_checks.csv` - Quality gate results

## Advanced Features

### Multi-Session Management

Run multiple Claude instances in parallel for maximum throughput:

```bash
# Terminal tabs 1-5
claude-code  # Tab 1: Feature A
claude-code  # Tab 2: Feature B
claude-code  # Tab 3: Bug fixes
claude-code  # Tab 4: Refactoring
claude-code  # Tab 5: Documentation

# Hand off to web
> &

# Teleport between sessions
> --teleport <session-id>
```

### MCP Server Integration

Configure external tool integrations in `.mcp.json`:

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"]
    },
    "sentry": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sentry"]
    }
  }
}
```

### GitHub Actions Integration

Automate PR reviews with Claude:

```bash
# Install GitHub Action
> /install-github-action

# Tag @.claude in PRs to update docs
# Example: "@.claude add this pattern to docs.md"
```

### Background Agents

For long-running tasks:

```bash
# Option 1: Prompt for background verification
> When done, use a background agent to verify

# Option 2: Use Stop hook (already configured)

# Option 3: Skip permissions for sandbox
> --permission-mode=dontAsk
```

## Research Findings

This setup is based on comprehensive research into professional engineering practices and Claude Code capabilities. Key research areas include:

1. **Slash Commands** - Reusable prompts with inline bash for context
2. **Subagents** - Specialized AI team members with distinct roles
3. **Hooks** - Automated quality gates and formatting
4. **Permission Management** - Pre-approved commands for security
5. **MCP Integrations** - External tool connectivity
6. **GitHub Actions** - Automated PR workflows
7. **Verification Strategies** - Testing and quality assurance
8. **Multi-Session Management** - Parallel Claude instances
9. **Plan Mode Workflows** - Planning before implementation
10. **Professional Practices** - Code hygiene and team collaboration

See [RESEARCH.md](RESEARCH.md) for detailed findings with sources and implementation examples.

## Troubleshooting

### Hooks Not Running
```bash
chmod +x .claude/hooks/*.sh
```

### Permission Prompts
Add commands to `settings.json` under `permissions.allowed_commands`

### Subagents Not Being Used
Add "Use proactively" or "MUST BE USED" to the subagent's description

### Tests Failing in Stop Hook
Check `/tmp/claude_test_output.log` for details

### Command Not Found
Ensure `.claude/commands/` is in your project root and files have `.md` extension

## Contributing

This is a living repository. As you discover new patterns, workflows, or improvements:

1. Update `.claude/docs.md` with new knowledge
2. Create new slash commands for repeated workflows
3. Refine subagent prompts based on experience
4. Share metrics and insights with the team
5. Submit PRs with improvements

## Resources

- **[RESEARCH.md](RESEARCH.md)** - Comprehensive research findings with sources
- **[IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md)** - Step-by-step implementation guide
- **[Claude Code Documentation](https://code.claude.com/docs/)** - Official documentation
- **[Boris Cherny's Setup Thread](https://x.com/bcherny/status/2007179847949500714)** - Original workflow description

## License

This configuration is provided as-is for professional engineering teams. Customize and adapt to your specific needs.

## Acknowledgments

This setup is based on Boris Cherny's workflow, the creator of Claude Code, who generously shared his team's practices. The research synthesizes best practices from the Claude Code documentation, professional engineering teams, and real-world usage patterns.

---

**Remember:** The goal is to amplify human capabilities, not replace engineers. This setup automates repetitive tasks and provides specialized AI assistance, allowing engineers to focus on high-level problem solving and creative work.
