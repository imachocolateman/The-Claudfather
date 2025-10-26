---
name: api-integration
description: Generate production-ready API clients with error handling, type safety, and best practices. Use when the user needs to integrate with external APIs, create API wrappers, or when API-related tasks are mentioned.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, WebFetch
---

# API Integration Skill

This skill helps you create robust, production-ready API integrations following industry best practices.

## When to Use This Skill

Activate this skill when:
- User mentions integrating with an API (REST, GraphQL, gRPC)
- Creating API client libraries or wrappers
- User provides API documentation or OpenAPI specs
- Need to consume external services
- Building SDK for an API

## Core Capabilities

### 1. API Client Generation

Generate complete API clients with:
- **Type-safe requests** - Full TypeScript/type definitions
- **Error handling** - Comprehensive error types and retry logic
- **Authentication** - Support for API keys, OAuth, JWT
- **Rate limiting** - Built-in rate limit handling
- **Logging** - Request/response logging for debugging
- **Testing** - Mock responses and test utilities

### 2. Supported API Types

**REST APIs**:
- OpenAPI/Swagger spec support
- Automatic endpoint discovery
- Request/response mapping
- HTTP client abstraction

**GraphQL APIs**:
- Query and mutation generation
- Fragment composition
- Subscription support
- Type generation from schema

**gRPC APIs**:
- Protocol buffer compilation
- Service client generation
- Stream handling

### 3. Best Practices Applied

All generated clients follow these principles:

#### Error Handling
- Custom error classes for different failure modes
- Detailed error messages with context
- Retry logic with exponential backoff
- Circuit breaker pattern for resilience

#### Type Safety
- Request/response type definitions
- Validation at boundaries
- TypeScript strict mode compliance
- Runtime type checking for critical paths

#### Configuration
- Environment-based configuration
- Secrets management (never hardcode)
- Timeout and retry configuration
- Base URL and endpoint customization

#### Testing
- Mock implementations for testing
- Request/response fixtures
- Integration test helpers
- Comprehensive error scenario coverage

## Implementation Approach

### Step 1: Discovery

First, gather information about the API:

```markdown
## API Discovery

- **API Type**: [REST/GraphQL/gRPC]
- **Documentation URL**: [if available]
- **Authentication**: [API Key/OAuth/JWT/Basic]
- **Base URL**: [production/staging endpoints]
- **Rate Limits**: [requests per second/minute]
```

Use WebFetch to retrieve API documentation if URL provided.

### Step 2: Generate Client Structure

Create organized client structure:

```
api-client/
├── src/
│   ├── client.ts          # Main client class
│   ├── types.ts           # Type definitions
│   ├── errors.ts          # Error classes
│   ├── config.ts          # Configuration
│   ├── auth.ts            # Authentication
│   ├── endpoints/         # Endpoint-specific modules
│   │   ├── users.ts
│   │   └── products.ts
│   └── utils/
│       ├── retry.ts       # Retry logic
│       └── logger.ts      # Logging
├── tests/
│   ├── client.test.ts
│   └── mocks/
└── README.md
```

### Step 3: Implement Core Components

See [examples.md](examples.md) for detailed implementation patterns.

## Configuration

The generated client should support flexible configuration:

```typescript
interface ApiClientConfig {
  baseUrl: string
  apiKey?: string
  timeout?: number
  retryAttempts?: number
  retryDelay?: number
  rateLimit?: number
  logger?: Logger
}
```

## Error Handling Strategy

Implement these error types:

1. **NetworkError** - Connection issues, timeouts
2. **AuthenticationError** - Invalid credentials, expired tokens
3. **AuthorizationError** - Insufficient permissions
4. **ValidationError** - Invalid request data
5. **RateLimitError** - Rate limit exceeded
6. **ServerError** - 5xx responses
7. **NotFoundError** - 404 responses

Each should include:
- Original error context
- Retry-ability flag
- User-friendly message
- Debug information

## Authentication Patterns

Support common auth methods:

### API Key
```typescript
client.setApiKey(process.env.API_KEY)
```

### OAuth 2.0
```typescript
client.setOAuthToken(token, refreshToken)
```

### JWT
```typescript
client.setJWT(jwt)
```

## Rate Limiting

Implement rate limiting that:
- Tracks requests per time window
- Queues requests when limit approached
- Returns `Retry-After` header information
- Provides rate limit status

## Testing Support

Generate test utilities:

```typescript
// Mock client for testing
const mockClient = createMockApiClient({
  users: {
    get: (id) => mockUser
  }
})

// Response fixtures
const fixtures = {
  user: { id: 1, name: 'Test User' },
  error: { code: 'AUTH_ERROR', message: 'Invalid token' }
}
```

## Documentation

Always generate comprehensive README covering:
- Installation and setup
- Authentication configuration
- Basic usage examples
- Advanced features
- Error handling
- Testing guide
- API rate limits and quotas

## Progressive Disclosure

For advanced topics, refer to:
- [examples.md](examples.md) - Code examples and patterns
- [authentication.md](authentication.md) - Detailed auth flows (if created)
- [testing.md](testing.md) - Testing strategies (if created)

## Quality Checklist

Before completing API integration:

- [ ] All endpoints have type definitions
- [ ] Error handling covers all HTTP status codes
- [ ] Authentication is configurable (not hardcoded)
- [ ] Rate limiting implemented
- [ ] Retry logic with exponential backoff
- [ ] Request/response logging available
- [ ] Unit tests for client logic
- [ ] Integration tests with mocks
- [ ] README with setup instructions
- [ ] No secrets in code

## Example Usage

This skill works autonomously. When user says:

> "I need to integrate with the GitHub API"

> "Create a client for the Stripe API"

> "Help me call this REST API: https://api.example.com"

Claude will automatically use this skill to generate a complete, production-ready API client.

## Notes

- Always use environment variables for secrets
- Implement proper CORS handling for browser clients
- Consider bundle size for frontend integrations
- Log requests in development, sanitize in production
- Provide both async/await and promise interfaces
- Include TypeScript declaration files for JavaScript projects
