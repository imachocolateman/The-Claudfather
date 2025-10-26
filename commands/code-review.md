---
description: Comprehensive code review with security, performance, and best practices analysis. Use for pre-commit reviews or pull request preparation.
allowed-tools: Read, Grep, Glob, Bash
argument-hint: [file-or-directory]
model: inherit
---

# Code Review Command

Perform a comprehensive code review with focus on security, performance, maintainability, and best practices.

## Instructions

You are conducting a thorough code review. Follow this systematic approach:

### 1. Scope Identification

If `$ARGUMENTS` is provided:
- Review only the specified file(s) or directory
- Use `git diff $ARGUMENTS` to see recent changes if in git repo

If no arguments provided:
- Run `git diff --staged` to review staged changes
- If no staged changes, run `git diff` to review unstaged changes
- If no changes, ask user what to review

### 2. Review Checklist

Analyze the code systematically across these dimensions:

#### Security
- [ ] No hardcoded credentials, API keys, or secrets
- [ ] Input validation and sanitization present
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (proper escaping)
- [ ] Authentication and authorization checks
- [ ] Secure handling of sensitive data
- [ ] No use of dangerous functions (eval, exec without validation)

#### Performance
- [ ] No obvious performance bottlenecks (N+1 queries, unnecessary loops)
- [ ] Efficient data structures chosen
- [ ] Appropriate caching where beneficial
- [ ] Database queries optimized
- [ ] Large file/data handling done efficiently
- [ ] No memory leaks or resource leaks

#### Code Quality
- [ ] Clear, descriptive variable and function names
- [ ] Functions are focused and single-purpose
- [ ] Appropriate error handling and logging
- [ ] No code duplication (DRY principle)
- [ ] Consistent code style with project conventions
- [ ] Adequate comments for complex logic
- [ ] Magic numbers replaced with named constants

#### Testing
- [ ] Critical paths have test coverage
- [ ] Edge cases considered
- [ ] Error cases tested
- [ ] Tests are clear and maintainable

#### Architecture
- [ ] Follows project's architectural patterns
- [ ] Appropriate separation of concerns
- [ ] Dependencies are minimal and justified
- [ ] No circular dependencies
- [ ] Interfaces used appropriately

### 3. Output Format

Provide your review in this format:

```markdown
## Code Review Summary

**Files Reviewed**: [list files]
**Overall Assessment**: [Approve / Approve with Suggestions / Needs Changes]

### Critical Issues
[Issues that MUST be fixed - security, major bugs]

### Important Suggestions
[Issues that should be addressed - performance, maintainability]

### Minor Suggestions
[Nice-to-haves - style, optimization opportunities]

### Positive Observations
[What was done well - good patterns, clever solutions]
```

### 4. Best Practices

- Be constructive and specific in feedback
- Explain WHY something is an issue, not just WHAT
- Suggest concrete improvements with code examples
- Acknowledge good practices and clever solutions
- Prioritize issues by severity
- Consider the context - different standards for prototype vs production

### 5. Language-Specific Considerations

Adapt your review based on the language:

**JavaScript/TypeScript**: Check for proper async/await usage, type safety, bundle size implications
**Python**: Check for proper exception handling, PEP 8 compliance, generator usage for large data
**Go**: Check for proper error handling, goroutine safety, defer usage
**Rust**: Check for proper ownership, lifetime annotations, unsafe code justification
**Java**: Check for proper resource management, exception hierarchy, immutability

### 6. Context Awareness

Before reviewing, use `Read` tool to check for:
- `.eslintrc`, `prettier.config`, etc. for style rules
- `CONTRIBUTING.md` for project-specific guidelines
- `CLAUDE.md` for project conventions
- Test framework in use (Jest, pytest, etc.)

Apply project's own standards in your review.

## Example Usage

```
/code-review src/auth/login.ts
/code-review
/code-review src/
```

## Notes

- This command focuses on code quality, not functional testing
- Always run tests separately to verify functionality
- Consider using the test-runner command after addressing review feedback
- For architectural reviews, consider using the architecture-advisor agent
