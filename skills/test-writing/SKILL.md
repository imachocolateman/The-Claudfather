---
name: test-writing
description: Generate comprehensive test suites with unit tests, integration tests, edge cases, and proper mocking. Use when the user needs to write tests, improve test coverage, or when testing-related tasks are mentioned.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Test Writing Skill

This skill helps you create thorough, maintainable test suites following testing best practices and patterns.

## When to Use This Skill

Activate this skill when:
- User needs to write tests for existing code
- Creating test suites for new features
- Improving test coverage
- User mentions testing, TDD, BDD, or test frameworks
- Debugging failing tests
- Setting up test infrastructure
- Need to test edge cases and error scenarios

## Core Capabilities

### 1. Test Types

Generate different types of tests:

**Unit Tests**:
- Test individual functions/methods in isolation
- Mock external dependencies
- Fast execution
- High coverage of business logic

**Integration Tests**:
- Test interactions between components
- Test with real dependencies when appropriate
- Database interactions
- API endpoint testing

**End-to-End Tests**:
- Test complete user workflows
- Browser automation (Playwright, Selenium)
- Full stack testing

**Property-Based Tests**:
- Test with generated inputs
- Discover edge cases automatically
- Using frameworks like fast-check, Hypothesis

### 2. Supported Frameworks

**JavaScript/TypeScript**:
- Jest, Vitest, Mocha, Ava
- React Testing Library, Vue Test Utils
- Playwright, Cypress

**Python**:
- pytest, unittest
- Hypothesis (property-based)
- Playwright

**Go**:
- testing package
- testify
- ginkgo/gomega

**Rust**:
- Built-in test framework
- proptest

**Java**:
- JUnit, TestNG
- Mockito
- AssertJ

### 3. Best Practices Applied

#### Test Structure (AAA Pattern)
```
Arrange - Set up test data and preconditions
Act - Execute the code under test
Assert - Verify the results
```

#### Naming Conventions
- Descriptive test names explaining what is tested
- Format: `test_[method]_[scenario]_[expected]`
- Or: `should_[expected]_when_[scenario]`

#### Coverage Goals
- Aim for 80%+ code coverage
- 100% coverage for critical paths
- Edge cases and error scenarios
- Boundary conditions

#### Test Independence
- Tests don't depend on each other
- Can run in any order
- Clean state before/after each test

## Test Writing Process

### Step 1: Analyze Code Under Test

First, understand what you're testing:

```markdown
## Code Analysis

**Function/Class**: [name]
**Purpose**: [what it does]
**Inputs**: [parameters and types]
**Outputs**: [return type]
**Side Effects**: [database, API calls, file I/O]
**Error Cases**: [exceptions, error returns]
**Edge Cases**: [empty inputs, nulls, boundaries]
```

### Step 2: Identify Test Cases

Create comprehensive test case list:

```markdown
## Test Cases

### Happy Path
1. Valid input returns expected output
2. Typical use case works correctly

### Edge Cases
1. Empty input
2. Null/undefined input
3. Boundary values (min, max, 0, -1)
4. Very large inputs
5. Special characters in strings

### Error Cases
1. Invalid input types
2. Out of range values
3. Missing required parameters
4. Network failures
5. Database errors
6. Permission denied
```

### Step 3: Generate Tests

Write tests following the framework's patterns:

#### Jest/Vitest Example

```typescript
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest'
import { UserService } from './user-service'
import { Database } from './database'

describe('UserService', () => {
  let userService: UserService
  let mockDb: jest.Mocked<Database>

  beforeEach(() => {
    // Arrange - set up before each test
    mockDb = {
      query: vi.fn(),
      execute: vi.fn()
    } as any

    userService = new UserService(mockDb)
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = {
        email: 'test@example.com',
        name: 'Test User'
      }
      const expectedUser = { id: 1, ...userData }
      mockDb.execute.mockResolvedValue(expectedUser)

      // Act
      const result = await userService.createUser(userData)

      // Assert
      expect(result).toEqual(expectedUser)
      expect(mockDb.execute).toHaveBeenCalledWith(
        'INSERT INTO users (email, name) VALUES (?, ?)',
        [userData.email, userData.name]
      )
    })

    it('should throw error when email is invalid', async () => {
      // Arrange
      const userData = {
        email: 'invalid-email',
        name: 'Test User'
      }

      // Act & Assert
      await expect(userService.createUser(userData))
        .rejects
        .toThrow('Invalid email format')
    })

    it('should handle database errors', async () => {
      // Arrange
      const userData = {
        email: 'test@example.com',
        name: 'Test User'
      }
      mockDb.execute.mockRejectedValue(new Error('DB connection failed'))

      // Act & Assert
      await expect(userService.createUser(userData))
        .rejects
        .toThrow('Failed to create user')
    })
  })

  describe('getUser', () => {
    it('should return user when found', async () => {
      // Arrange
      const userId = 1
      const expectedUser = {
        id: userId,
        email: 'test@example.com',
        name: 'Test User'
      }
      mockDb.query.mockResolvedValue([expectedUser])

      // Act
      const result = await userService.getUser(userId)

      // Assert
      expect(result).toEqual(expectedUser)
      expect(mockDb.query).toHaveBeenCalledWith(
        'SELECT * FROM users WHERE id = ?',
        [userId]
      )
    })

    it('should return null when user not found', async () => {
      // Arrange
      const userId = 999
      mockDb.query.mockResolvedValue([])

      // Act
      const result = await userService.getUser(userId)

      // Assert
      expect(result).toBeNull()
    })

    it('should handle invalid user id', async () => {
      // Act & Assert
      await expect(userService.getUser(-1))
        .rejects
        .toThrow('Invalid user ID')
    })
  })
})
```

#### pytest Example

```python
import pytest
from unittest.mock import Mock, patch
from user_service import UserService, InvalidEmailError

class TestUserService:
    @pytest.fixture
    def mock_db(self):
        """Create a mock database for testing."""
        return Mock()

    @pytest.fixture
    def user_service(self, mock_db):
        """Create UserService instance with mock database."""
        return UserService(mock_db)

    def test_create_user_with_valid_data(self, user_service, mock_db):
        """Should create user with valid data."""
        # Arrange
        user_data = {
            'email': 'test@example.com',
            'name': 'Test User'
        }
        expected_user = {'id': 1, **user_data}
        mock_db.execute.return_value = expected_user

        # Act
        result = user_service.create_user(user_data)

        # Assert
        assert result == expected_user
        mock_db.execute.assert_called_once_with(
            'INSERT INTO users (email, name) VALUES (?, ?)',
            (user_data['email'], user_data['name'])
        )

    def test_create_user_with_invalid_email(self, user_service):
        """Should raise InvalidEmailError when email is invalid."""
        # Arrange
        user_data = {
            'email': 'invalid-email',
            'name': 'Test User'
        }

        # Act & Assert
        with pytest.raises(InvalidEmailError, match='Invalid email format'):
            user_service.create_user(user_data)

    def test_create_user_handles_database_error(self, user_service, mock_db):
        """Should handle database errors gracefully."""
        # Arrange
        user_data = {
            'email': 'test@example.com',
            'name': 'Test User'
        }
        mock_db.execute.side_effect = Exception('DB connection failed')

        # Act & Assert
        with pytest.raises(Exception, match='Failed to create user'):
            user_service.create_user(user_data)

    @pytest.mark.parametrize('email,is_valid', [
        ('test@example.com', True),
        ('user+tag@domain.co.uk', True),
        ('invalid', False),
        ('', False),
        ('@example.com', False),
        ('test@', False),
    ])
    def test_email_validation(self, user_service, email, is_valid):
        """Test email validation with various inputs."""
        assert user_service.is_valid_email(email) == is_valid
```

### Step 4: Mocking Strategy

#### When to Mock
- External APIs
- Database calls
- File system operations
- Time-dependent code
- Random number generation
- Third-party services

#### When NOT to Mock
- Pure functions
- Simple utilities
- Your own business logic (test with real implementations)

#### Mocking Patterns

```typescript
// Mock entire module
vi.mock('./database', () => ({
  Database: vi.fn().mockImplementation(() => ({
    query: vi.fn(),
    execute: vi.fn()
  }))
}))

// Mock specific function
vi.spyOn(console, 'log').mockImplementation(() => {})

// Mock with different return values
mockDb.query
  .mockResolvedValueOnce([user1])  // First call
  .mockResolvedValueOnce([user2])  // Second call

// Mock implementation
mockFetch.mockImplementation((url) => {
  if (url.includes('/users')) {
    return Promise.resolve({ ok: true, json: () => users })
  }
  return Promise.resolve({ ok: false })
})
```

### Step 5: Integration Tests

For testing with real dependencies:

```typescript
describe('UserService Integration Tests', () => {
  let db: Database
  let userService: UserService

  beforeAll(async () => {
    // Set up test database
    db = await Database.connect(process.env.TEST_DATABASE_URL)
    userService = new UserService(db)
  })

  afterAll(async () => {
    await db.close()
  })

  beforeEach(async () => {
    // Clean database before each test
    await db.execute('DELETE FROM users')
  })

  it('should create and retrieve user', async () => {
    // Create user
    const userData = {
      email: 'test@example.com',
      name: 'Test User'
    }
    const createdUser = await userService.createUser(userData)

    // Retrieve user
    const retrievedUser = await userService.getUser(createdUser.id)

    // Assert
    expect(retrievedUser).toEqual(createdUser)
  })
})
```

## Testing Patterns

### Test Fixtures

```typescript
// fixtures/users.ts
export const testUsers = {
  validUser: {
    email: 'test@example.com',
    name: 'Test User',
    age: 30
  },
  adminUser: {
    email: 'admin@example.com',
    name: 'Admin User',
    role: 'admin'
  }
}

// In tests
import { testUsers } from './fixtures/users'

it('should handle admin user', () => {
  const result = processUser(testUsers.adminUser)
  expect(result.hasAdminAccess).toBe(true)
})
```

### Test Builders/Factories

```typescript
class UserBuilder {
  private user: Partial<User> = {
    email: 'default@example.com',
    name: 'Default User'
  }

  withEmail(email: string): this {
    this.user.email = email
    return this
  }

  withName(name: string): this {
    this.user.name = name
    return this
  }

  asAdmin(): this {
    this.user.role = 'admin'
    return this
  }

  build(): User {
    return this.user as User
  }
}

// Usage
const adminUser = new UserBuilder()
  .withEmail('admin@test.com')
  .asAdmin()
  .build()
```

### Snapshot Testing

```typescript
it('should render user profile correctly', () => {
  const profile = renderUserProfile(testUser)
  expect(profile).toMatchSnapshot()
})

// Update snapshots when intentionally changed
// npm test -- -u
```

### Property-Based Testing

```typescript
import { fc } from 'fast-check'

it('should always return positive result', () => {
  fc.assert(
    fc.property(
      fc.integer({ min: 1, max: 1000 }),
      fc.integer({ min: 1, max: 1000 }),
      (a, b) => {
        const result = add(a, b)
        return result > 0 && result === a + b
      }
    )
  )
})
```

## Testing Anti-Patterns to Avoid

❌ **Testing implementation details**
```typescript
// Bad - testing private methods
expect(service.privateMethod()).toBe(...)

// Good - test public API
expect(service.processData(input)).toEqual(expectedOutput)
```

❌ **Brittle tests**
```typescript
// Bad - tightly coupled to HTML structure
expect(wrapper.find('div').find('span').at(2).text()).toBe('Name')

// Good - use test IDs
expect(screen.getByTestId('user-name')).toHaveTextContent('Name')
```

❌ **Testing the framework**
```typescript
// Bad - testing React's setState
expect(component.state.count).toBe(1)

// Good - test behavior
expect(screen.getByText('Count: 1')).toBeInTheDocument()
```

❌ **Over-mocking**
```typescript
// Bad - mocking everything
vi.mock('./utils')
vi.mock('./helpers')
vi.mock('./formatters')

// Good - mock only external dependencies
vi.mock('./api-client')
// Test with real utils, helpers, formatters
```

## Coverage Analysis

After writing tests, check coverage:

```bash
# Jest/Vitest
npm test -- --coverage

# pytest
pytest --cov=src --cov-report=html

# Go
go test -cover ./...

# Rust
cargo tarpaulin
```

Review coverage report and add tests for uncovered areas:
- Focus on critical paths first
- Cover error handling
- Test edge cases
- Don't chase 100% blindly - some code doesn't need tests

## Quality Checklist

Before completing test suite:

- [ ] All happy paths tested
- [ ] Edge cases covered (empty, null, boundaries)
- [ ] Error cases tested
- [ ] Mocks used appropriately
- [ ] Tests are independent
- [ ] Tests have clear names
- [ ] Tests follow AAA pattern
- [ ] No hardcoded values (use constants/fixtures)
- [ ] Async code tested properly
- [ ] Integration tests for critical flows
- [ ] 80%+ code coverage
- [ ] Tests run fast (< 1s for unit tests)
- [ ] CI/CD integration configured

## Example Usage

This skill works autonomously. When user says:

> "Write tests for the UserService class"

> "I need to improve test coverage"

> "This function needs edge case tests"

Claude will automatically use this skill to generate a comprehensive test suite.

## Notes

- Write tests that document behavior
- Test behavior, not implementation
- Keep tests simple and readable
- Fast tests get run more often
- Integration tests complement unit tests
- Consider TDD: write tests first
- Refactor tests like production code
- Review test failures carefully - they catch bugs!
