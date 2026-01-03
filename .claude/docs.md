# Team Documentation for Claude Code

This file contains team-specific knowledge, patterns, and conventions that Claude should follow when working on this codebase. Update this file weekly as you discover new patterns or encounter issues.

## Project Overview

**Description:** [Brief description of what this project does]

**Architecture:** [High-level architecture overview]

**Tech Stack:**
- Language: [e.g., Python 3.11, TypeScript 5.0]
- Framework: [e.g., FastAPI, React, Next.js]
- Database: [e.g., PostgreSQL, MongoDB]
- Infrastructure: [e.g., AWS, Docker, Kubernetes]

## Code Conventions

### Naming Conventions
- **Files:** Use kebab-case for filenames (e.g., `user-service.ts`)
- **Classes:** Use PascalCase (e.g., `UserService`)
- **Functions:** Use camelCase (e.g., `getUserById`)
- **Constants:** Use UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)

### File Organization
```
src/
├── components/     # Reusable UI components
├── services/       # Business logic and API calls
├── utils/          # Helper functions
├── types/          # Type definitions
└── tests/          # Test files (co-located with source)
```

### Import Order
1. External libraries (e.g., `react`, `lodash`)
2. Internal modules (e.g., `@/components`)
3. Relative imports (e.g., `./utils`)
4. Type imports (e.g., `import type { User }`)

## Common Patterns

### Error Handling
Always use try-catch blocks with specific error types:
```typescript
try {
  await riskyOperation();
} catch (error) {
  if (error instanceof ValidationError) {
    // Handle validation error
  } else if (error instanceof NetworkError) {
    // Handle network error
  } else {
    // Handle unexpected error
    logger.error('Unexpected error', { error });
    throw error;
  }
}
```

### API Response Format
All API responses should follow this structure:
```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "metadata": {
    "timestamp": "2025-01-03T10:00:00Z",
    "version": "1.0"
  }
}
```

### Testing Patterns
- Use descriptive test names: `test_user_creation_with_valid_email`
- Follow AAA pattern: Arrange, Act, Assert
- Mock external dependencies
- Test edge cases and error conditions

## Things Claude Should NOT Do

### ❌ Avoid These Patterns
1. **Don't use `any` type in TypeScript** - Always provide specific types
2. **Don't commit commented-out code** - Delete it or use feature flags
3. **Don't hardcode configuration** - Use environment variables
4. **Don't skip error handling** - Every external call needs try-catch
5. **Don't write tests that depend on external services** - Use mocks

### ❌ Common Mistakes to Avoid
- **Database queries without pagination** - Always paginate large datasets
- **Missing input validation** - Validate all user inputs
- **Synchronous operations in async functions** - Use await properly
- **Circular dependencies** - Refactor to remove circular imports
- **Missing null checks** - Always check for null/undefined

## Things Claude SHOULD Do

### ✅ Always Do These
1. **Run tests before committing** - Use `/commit-push-pr` which includes verification
2. **Update documentation** - If you change behavior, update docs
3. **Add logging** - Log important operations and errors
4. **Use type hints** - Provide type annotations for all functions
5. **Write meaningful commit messages** - Follow conventional commits

### ✅ Best Practices
- **Use the code-simplifier subagent** after complex changes
- **Use the verify-app subagent** before final commits
- **Use the code-reviewer subagent** for self-review
- **Pre-compute context** in slash commands with inline bash
- **Document complex logic** with inline comments

## Team-Specific Knowledge

### Known Issues
- [Issue 1]: [Description and workaround]
- [Issue 2]: [Description and workaround]

### Performance Considerations
- [Optimization 1]: [When and how to apply]
- [Optimization 2]: [When and how to apply]

### Security Notes
- [Security concern 1]: [How to handle]
- [Security concern 2]: [How to handle]

## Workflow

### Standard Development Flow
1. Start in Plan mode (shift+tab twice)
2. Create a detailed plan
3. Switch to auto-accept edits mode
4. Implement the plan
5. Use code-simplifier subagent
6. Use verify-app subagent
7. Use code-reviewer subagent
8. Use `/commit-push-pr` to finalize

### Code Review Checklist
- [ ] Tests pass
- [ ] Code is formatted
- [ ] No linting errors
- [ ] Documentation updated
- [ ] No security vulnerabilities
- [ ] Performance is acceptable

## Update Log

Track when this document is updated and why:

- **2025-01-03**: Initial documentation created
- [Add updates here as the team learns new patterns]

---

**Note:** This is a living document. Update it whenever you discover something Claude should know about this codebase.
