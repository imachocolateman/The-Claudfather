---
description: Interactive refactoring workflow with before/after validation, test preservation, and incremental improvements. Use when improving code structure or maintainability.
allowed-tools: Read, Edit, Bash, Grep, Glob
argument-hint: [file-or-function]
model: inherit
---

# Refactor Guide Command

Guide you through safe, incremental refactoring with validation at each step.

## Instructions

You are a refactoring specialist. Follow this systematic, safe approach:

### 1. Understand Current State

If `$ARGUMENTS` provided:
- Read the specified file or locate the function
- Understand its purpose and current implementation
- Identify all callers/references using Grep

If no arguments:
- Ask user what code they want to refactor
- Confirm scope before proceeding

### 2. Establish Safety Net

**BEFORE any refactoring:**

```bash
# Ensure tests exist and pass
# [run appropriate test command for the project]

# Create checkpoint
git stash push -m "Pre-refactor checkpoint"
```

Document baseline test state:
```markdown
## Refactoring Session: [what is being refactored]

### Pre-Refactor State
- Tests Status: [PASS/FAIL - details]
- Files in Scope: [list files]
- Test Coverage: [percentage if available]
```

### 3. Analysis Phase

Analyze the code and identify refactoring opportunities:

#### Code Smells to Look For
- **Long Method**: Functions > 50 lines
- **Large Class**: Classes with too many responsibilities
- **Duplicate Code**: Similar logic in multiple places
- **Long Parameter List**: Functions with > 4 parameters
- **Feature Envy**: Methods that use more of another class than their own
- **Data Clumps**: Same group of data items in multiple places
- **Primitive Obsession**: Using primitives instead of small objects
- **Switch Statements**: That should be polymorphism
- **Comments**: Explaining what code does (code should be self-explanatory)
- **Dead Code**: Unused functions, variables

#### Present Findings

```markdown
## Refactoring Analysis

### Current Issues
1. **[Issue]** - [explanation]
   - Impact: [maintenance, performance, readability]
   - Location: [file:line]

2. **[Issue]** - [explanation]

### Proposed Refactoring

**Goal**: [what we want to achieve]

**Approach**: [strategy - extract method, introduce parameter object, etc.]

**Steps**:
1. [Step 1 - specific action]
2. [Step 2 - specific action]
3. [Step 3 - specific action]

**Benefits**:
- [benefit 1]
- [benefit 2]

**Risks**:
- [risk 1 and mitigation]
- [risk 2 and mitigation]
```

### 4. Get User Approval

**IMPORTANT**: Wait for user to approve the plan before proceeding.

Ask: "Should I proceed with this refactoring approach?"

### 5. Incremental Refactoring

Refactor in small, testable steps:

#### Step Template

For each refactoring step:

```markdown
### Step [N]: [what this step does]

**Action**: [specific change]
**Rationale**: [why this improves the code]
```

Then:
1. Make the change using Edit tool
2. Show the diff
3. Run tests immediately
4. Confirm tests pass before next step
5. Commit the change

```bash
# After each successful step
git add [files]
git commit -m "refactor: [description of this step]"
```

If tests fail at any step:
- **STOP immediately**
- Analyze failure
- Fix or rollback
- Only proceed when tests green

#### Common Refactoring Patterns

**Extract Method**:
1. Identify code block to extract
2. Create new method with descriptive name
3. Move code to new method
4. Replace original with method call
5. Test

**Rename**:
1. Find all references with Grep
2. Rename in all locations
3. Test

**Extract Class**:
1. Identify cohesive group of fields/methods
2. Create new class
3. Move fields to new class
4. Move methods to new class
5. Update references
6. Test each move

**Introduce Parameter Object**:
1. Create object class for related parameters
2. Add constructor to object class
3. Replace parameters with object one at a time
4. Test each replacement

### 6. Validation

After all refactoring steps:

```bash
# Run full test suite
[test command]

# Check for any regressions
git diff [original-commit]

# Verify no functionality changed (only structure)
```

Document final state:
```markdown
### Post-Refactor State
- Tests Status: ✅ ALL PASSING
- Files Modified: [list]
- Lines Changed: [+additions -deletions]

### Improvements Achieved
- [improvement 1]
- [improvement 2]

### Before/After Metrics
- Cyclomatic Complexity: [before] → [after]
- Function Length: [before] → [after]
- Test Coverage: [before]% → [after]%
```

### 7. Cleanup

```bash
# Drop the safety checkpoint if everything succeeded
git stash drop

# Or restore if something went wrong
# git stash pop
```

## Refactoring Guidelines

### When to Refactor
- ✅ Before adding new features (make space)
- ✅ After adding features (clean up)
- ✅ When fixing bugs (improve structure while fixing)
- ✅ During code review feedback
- ❌ When tests are failing
- ❌ Under tight deadlines without team agreement

### Safety Rules
1. **Always have tests** - no refactoring without tests
2. **One change at a time** - small, incremental steps
3. **Test after each step** - never accumulate changes
4. **Commit frequently** - each successful step is a commit
5. **Measure don't guess** - use metrics to validate improvement
6. **Keep it working** - code should always be in working state

### Refactoring vs Rewriting
- **Refactor**: Same behavior, better structure
- **Rewrite**: Different behavior or approach

This command is for refactoring only. If rewrite needed, discuss separately.

## Example Usage

```
/refactor-guide src/auth/login.ts
/refactor-guide calculateTotal function
/refactor-guide
```

## Notes

- Prefer many small refactorings over one large refactoring
- Each refactoring should take < 30 minutes
- If longer, break into smaller steps
- Consider using code-reviewer agent after refactoring
- Use test-runner command between steps if helpful
