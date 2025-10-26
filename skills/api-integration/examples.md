# API Integration Examples

This document provides detailed code examples and patterns for the API Integration skill.

## Complete REST API Client Example

### Basic Client Structure

```typescript
// src/client.ts
import { ApiClientConfig, ApiClientOptions } from './types'
import { NetworkError, AuthenticationError, RateLimitError } from './errors'
import { RetryHandler } from './utils/retry'
import { Logger } from './utils/logger'

export class ApiClient {
  private config: Required<ApiClientConfig>
  private retryHandler: RetryHandler
  private logger: Logger

  constructor(config: ApiClientConfig) {
    this.config = {
      timeout: 30000,
      retryAttempts: 3,
      retryDelay: 1000,
      rateLimit: 100,
      ...config
    }

    this.retryHandler = new RetryHandler(this.config)
    this.logger = config.logger || new Logger()
  }

  async request<T>(
    method: string,
    endpoint: string,
    options?: ApiClientOptions
  ): Promise<T> {
    const url = `${this.config.baseUrl}${endpoint}`

    return this.retryHandler.execute(async () => {
      try {
        this.logger.debug(`${method} ${url}`, options?.body)

        const response = await fetch(url, {
          method,
          headers: this.buildHeaders(options?.headers),
          body: options?.body ? JSON.stringify(options.body) : undefined,
          signal: AbortSignal.timeout(this.config.timeout)
        })

        if (!response.ok) {
          throw await this.handleErrorResponse(response)
        }

        const data = await response.json()
        this.logger.debug(`Response: ${response.status}`, data)

        return data as T
      } catch (error) {
        if (error instanceof DOMException && error.name === 'TimeoutError') {
          throw new NetworkError('Request timeout', { url, timeout: this.config.timeout })
        }
        throw error
      }
    })
  }

  private buildHeaders(customHeaders?: Record<string, string>): HeadersInit {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...customHeaders
    }

    if (this.config.apiKey) {
      headers['Authorization'] = `Bearer ${this.config.apiKey}`
    }

    return headers
  }

  private async handleErrorResponse(response: Response): Promise<Error> {
    const body = await response.json().catch(() => ({}))

    switch (response.status) {
      case 401:
        return new AuthenticationError(body.message || 'Authentication failed')
      case 429:
        const retryAfter = response.headers.get('Retry-After')
        return new RateLimitError(
          'Rate limit exceeded',
          retryAfter ? parseInt(retryAfter) : undefined
        )
      case 500:
      case 502:
      case 503:
        return new NetworkError(`Server error: ${response.status}`, {
          status: response.status,
          body
        })
      default:
        return new Error(`HTTP ${response.status}: ${body.message || response.statusText}`)
    }
  }

  get<T>(endpoint: string, options?: ApiClientOptions): Promise<T> {
    return this.request<T>('GET', endpoint, options)
  }

  post<T>(endpoint: string, body: unknown, options?: ApiClientOptions): Promise<T> {
    return this.request<T>('POST', endpoint, { ...options, body })
  }

  put<T>(endpoint: string, body: unknown, options?: ApiClientOptions): Promise<T> {
    return this.request<T>('PUT', endpoint, { ...options, body })
  }

  delete<T>(endpoint: string, options?: ApiClientOptions): Promise<T> {
    return this.request<T>('DELETE', endpoint, options)
  }
}
```

### Error Classes

```typescript
// src/errors.ts
export class ApiError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly context?: Record<string, unknown>
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

export class NetworkError extends ApiError {
  public readonly retryable = true

  constructor(message: string, context?: Record<string, unknown>) {
    super(message, 'NETWORK_ERROR', context)
    this.name = 'NetworkError'
  }
}

export class AuthenticationError extends ApiError {
  public readonly retryable = false

  constructor(message: string) {
    super(message, 'AUTH_ERROR')
    this.name = 'AuthenticationError'
  }
}

export class RateLimitError extends ApiError {
  public readonly retryable = true

  constructor(message: string, public readonly retryAfter?: number) {
    super(message, 'RATE_LIMIT_ERROR', { retryAfter })
    this.name = 'RateLimitError'
  }
}
```

### Retry Handler

```typescript
// src/utils/retry.ts
import { ApiClientConfig } from '../types'

export class RetryHandler {
  constructor(private config: Required<ApiClientConfig>) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    let lastError: Error

    for (let attempt = 0; attempt <= this.config.retryAttempts; attempt++) {
      try {
        return await fn()
      } catch (error) {
        lastError = error as Error

        // Don't retry if error is not retryable
        if (!this.shouldRetry(error, attempt)) {
          throw error
        }

        // Calculate delay with exponential backoff
        const delay = this.calculateDelay(attempt, error)
        await this.sleep(delay)
      }
    }

    throw lastError!
  }

  private shouldRetry(error: unknown, attempt: number): boolean {
    if (attempt >= this.config.retryAttempts) {
      return false
    }

    // Check if error has retryable property
    if (typeof error === 'object' && error !== null && 'retryable' in error) {
      return (error as { retryable: boolean }).retryable
    }

    // Retry on network errors by default
    return error instanceof NetworkError
  }

  private calculateDelay(attempt: number, error: unknown): number {
    // If rate limit error with Retry-After, use that
    if (error instanceof RateLimitError && error.retryAfter) {
      return error.retryAfter * 1000
    }

    // Exponential backoff: delay * (2 ^ attempt)
    return this.config.retryDelay * Math.pow(2, attempt)
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}
```

### Type Definitions

```typescript
// src/types.ts
export interface ApiClientConfig {
  baseUrl: string
  apiKey?: string
  timeout?: number
  retryAttempts?: number
  retryDelay?: number
  rateLimit?: number
  logger?: Logger
}

export interface ApiClientOptions {
  headers?: Record<string, string>
  body?: unknown
  signal?: AbortSignal
}

export interface Logger {
  debug(message: string, ...args: unknown[]): void
  info(message: string, ...args: unknown[]): void
  warn(message: string, ...args: unknown[]): void
  error(message: string, ...args: unknown[]): void
}

// API Response Types
export interface User {
  id: number
  email: string
  name: string
  createdAt: string
}

export interface PaginatedResponse<T> {
  data: T[]
  page: number
  perPage: number
  total: number
}
```

### Endpoint Module Example

```typescript
// src/endpoints/users.ts
import { ApiClient } from '../client'
import { User, PaginatedResponse } from '../types'

export class UsersEndpoint {
  constructor(private client: ApiClient) {}

  async getUser(userId: number): Promise<User> {
    return this.client.get<User>(`/users/${userId}`)
  }

  async listUsers(page = 1, perPage = 20): Promise<PaginatedResponse<User>> {
    return this.client.get<PaginatedResponse<User>>(
      `/users?page=${page}&per_page=${perPage}`
    )
  }

  async createUser(userData: Omit<User, 'id' | 'createdAt'>): Promise<User> {
    return this.client.post<User>('/users', userData)
  }

  async updateUser(userId: number, userData: Partial<User>): Promise<User> {
    return this.client.put<User>(`/users/${userId}`, userData)
  }

  async deleteUser(userId: number): Promise<void> {
    return this.client.delete<void>(`/users/${userId}`)
  }
}
```

## GraphQL Client Example

```typescript
// src/graphql-client.ts
interface GraphQLResponse<T> {
  data?: T
  errors?: Array<{ message: string; path?: string[] }>
}

export class GraphQLClient {
  constructor(
    private endpoint: string,
    private token?: string
  ) {}

  async query<T>(query: string, variables?: Record<string, unknown>): Promise<T> {
    const response = await fetch(this.endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(this.token && { Authorization: `Bearer ${this.token}` })
      },
      body: JSON.stringify({ query, variables })
    })

    const result: GraphQLResponse<T> = await response.json()

    if (result.errors) {
      throw new Error(`GraphQL Error: ${result.errors.map(e => e.message).join(', ')}`)
    }

    return result.data!
  }

  async mutate<T>(mutation: string, variables?: Record<string, unknown>): Promise<T> {
    return this.query<T>(mutation, variables)
  }
}
```

## Usage Examples

### Basic Usage

```typescript
import { ApiClient } from './client'
import { UsersEndpoint } from './endpoints/users'

// Initialize client
const client = new ApiClient({
  baseUrl: 'https://api.example.com/v1',
  apiKey: process.env.API_KEY,
  timeout: 10000,
  retryAttempts: 3
})

// Create endpoint instances
const users = new UsersEndpoint(client)

// Use the API
async function example() {
  try {
    // Get a user
    const user = await users.getUser(123)
    console.log(user)

    // List users with pagination
    const userList = await users.listUsers(1, 50)
    console.log(`Total users: ${userList.total}`)

    // Create a user
    const newUser = await users.createUser({
      email: 'test@example.com',
      name: 'Test User'
    })
    console.log('Created:', newUser)

  } catch (error) {
    if (error instanceof AuthenticationError) {
      console.error('Auth failed:', error.message)
    } else if (error instanceof RateLimitError) {
      console.error('Rate limited, retry after:', error.retryAfter)
    } else {
      console.error('Request failed:', error)
    }
  }
}
```

### With Custom Headers

```typescript
const data = await client.get('/protected', {
  headers: {
    'X-Custom-Header': 'value'
  }
})
```

### Testing

```typescript
// tests/client.test.ts
import { ApiClient } from '../src/client'
import { NetworkError } from '../src/errors'

describe('ApiClient', () => {
  let client: ApiClient

  beforeEach(() => {
    client = new ApiClient({
      baseUrl: 'https://api.test.com',
      apiKey: 'test-key'
    })
  })

  it('should make successful GET request', async () => {
    // Mock fetch
    global.fetch = jest.fn().mockResolvedValue({
      ok: true,
      json: async () => ({ id: 1, name: 'Test' })
    })

    const result = await client.get('/test')

    expect(result).toEqual({ id: 1, name: 'Test' })
    expect(fetch).toHaveBeenCalledWith(
      'https://api.test.com/test',
      expect.objectContaining({
        method: 'GET',
        headers: expect.objectContaining({
          'Authorization': 'Bearer test-key'
        })
      })
    )
  })

  it('should retry on network error', async () => {
    let attempts = 0
    global.fetch = jest.fn().mockImplementation(() => {
      attempts++
      if (attempts < 3) {
        throw new NetworkError('Connection failed')
      }
      return Promise.resolve({
        ok: true,
        json: async () => ({ success: true })
      })
    })

    const result = await client.get('/test')

    expect(attempts).toBe(3)
    expect(result).toEqual({ success: true })
  })
})
```

## Best Practices Summary

1. **Always use environment variables** for API keys and secrets
2. **Implement exponential backoff** for retries
3. **Type everything** - full TypeScript support
4. **Log requests** in development, sanitize in production
5. **Handle rate limits** gracefully with queuing
6. **Provide mock clients** for testing
7. **Document all endpoints** with examples
8. **Version your client** alongside API versions
