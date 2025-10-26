---
name: database-schema
description: Design optimized database schemas with proper normalization, indexing, and migration strategies. Use when the user needs to design databases, create schema migrations, optimize queries, or when database-related tasks are mentioned.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Database Schema Design Skill

This skill helps you design robust, scalable database schemas following best practices for performance, maintainability, and data integrity.

## When to Use This Skill

Activate this skill when:
- User needs to design a new database schema
- Creating or modifying database tables
- Optimizing existing schema for performance
- Generating database migrations
- User mentions SQL, PostgreSQL, MySQL, MongoDB, or other databases
- Need to establish relationships between entities
- Working with ORMs (Prisma, TypeORM, Sequelize, SQLAlchemy, etc.)

## Core Capabilities

### 1. Schema Design

Design comprehensive database schemas with:
- **Proper normalization** (1NF, 2NF, 3NF, BCNF)
- **Appropriate indexes** for query performance
- **Foreign key constraints** for referential integrity
- **Check constraints** for data validation
- **Default values** and nullability rules
- **Composite keys** where appropriate
- **Soft deletes** for audit trails

### 2. Supported Database Systems

**Relational Databases**:
- PostgreSQL (with JSON, arrays, full-text search)
- MySQL/MariaDB
- SQLite
- SQL Server
- Oracle

**NoSQL Databases**:
- MongoDB (document design)
- Redis (data structures)
- Cassandra (wide-column)

**ORM Support**:
- Generate schemas compatible with popular ORMs
- Prisma schema files
- TypeORM entities
- SQLAlchemy models
- Django models

### 3. Best Practices Applied

#### Naming Conventions
- Tables: plural, snake_case (e.g., `user_accounts`, `order_items`)
- Columns: snake_case (e.g., `created_at`, `user_id`)
- Indexes: descriptive (e.g., `idx_users_email`, `idx_orders_user_id_created_at`)
- Foreign keys: `fk_[table]_[referenced_table]`
- Primary keys: `id` or `[table_name]_id`

#### Data Types
- Use appropriate sizes (SMALLINT vs INT vs BIGINT)
- VARCHAR with reasonable limits, not MAX
- DECIMAL for money (never FLOAT)
- TIMESTAMP WITH TIME ZONE for dates
- ENUM for fixed sets, consider lookup tables for flexibility
- JSON/JSONB for flexible data (PostgreSQL)

#### Indexing Strategy
- Primary key on every table
- Foreign keys indexed for joins
- Columns frequently in WHERE clauses
- Columns used in ORDER BY
- Composite indexes for multi-column queries
- Avoid over-indexing (slower writes, more storage)

#### Performance Optimization
- Denormalization where read-heavy and justified
- Partitioning for large tables
- Archiving strategies for historical data
- Appropriate use of triggers and stored procedures
- Query-first design (design for your queries)

## Schema Design Process

### Step 1: Entity Identification

Identify core entities and their attributes:

```markdown
## Entities

### User
- id (PK)
- email (unique, indexed)
- password_hash
- name
- created_at
- updated_at
- deleted_at (soft delete)

### Order
- id (PK)
- user_id (FK → users.id, indexed)
- status (enum: pending, processing, completed, cancelled)
- total_amount (decimal)
- created_at
- updated_at

### OrderItem
- id (PK)
- order_id (FK → orders.id, indexed)
- product_id (FK → products.id, indexed)
- quantity
- price (snapshot at purchase time)
```

### Step 2: Relationship Mapping

Define relationships:
- **One-to-Many**: User → Orders (user_id in orders)
- **Many-to-Many**: Orders ↔ Products (via order_items junction table)
- **One-to-One**: User → UserProfile (user_id unique FK in profiles)

### Step 3: Schema Generation

Generate SQL DDL statements:

```sql
-- PostgreSQL Example
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NOT NULL;

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### Step 4: Migration Strategy

Create migrations for schema changes:

```sql
-- Migration: 001_create_users_table.sql
-- Up
CREATE TABLE users ( ... );

-- Down
DROP TABLE users;
```

### Step 5: ORM Schema (if applicable)

Generate ORM-compatible schemas:

```typescript
// Prisma schema
model User {
  id           BigInt     @id @default(autoincrement())
  email        String     @unique @db.VarChar(255)
  passwordHash String     @map("password_hash") @db.VarChar(255)
  name         String     @db.VarChar(255)
  createdAt    DateTime   @default(now()) @map("created_at") @db.Timestamptz
  updatedAt    DateTime   @updatedAt @map("updated_at") @db.Timestamptz
  deletedAt    DateTime?  @map("deleted_at") @db.Timestamptz
  orders       Order[]

  @@index([email], map: "idx_users_email", where: deleted_at == null)
  @@map("users")
}
```

## Common Patterns

### Soft Deletes

```sql
ALTER TABLE users ADD COLUMN deleted_at TIMESTAMP WITH TIME ZONE;
CREATE INDEX idx_users_deleted_at ON users(deleted_at) WHERE deleted_at IS NOT NULL;

-- Queries always filter:
SELECT * FROM users WHERE deleted_at IS NULL;
```

### Audit Trail

```sql
CREATE TABLE audit_log (
  id BIGSERIAL PRIMARY KEY,
  table_name VARCHAR(100) NOT NULL,
  record_id BIGINT NOT NULL,
  action VARCHAR(20) NOT NULL,  -- INSERT, UPDATE, DELETE
  old_values JSONB,
  new_values JSONB,
  user_id BIGINT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_log_table_record ON audit_log(table_name, record_id);
CREATE INDEX idx_audit_log_user_id ON audit_log(user_id);
```

### Polymorphic Associations

```sql
-- Comments that can belong to Posts or Products
CREATE TABLE comments (
  id BIGSERIAL PRIMARY KEY,
  commentable_type VARCHAR(50) NOT NULL,  -- 'Post' or 'Product'
  commentable_id BIGINT NOT NULL,
  content TEXT NOT NULL,
  user_id BIGINT NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_comments_commentable ON comments(commentable_type, commentable_id);
```

### Hierarchical Data (Self-Referencing)

```sql
-- Categories with parent-child relationships
CREATE TABLE categories (
  id BIGSERIAL PRIMARY KEY,
  parent_id BIGINT REFERENCES categories(id),
  name VARCHAR(255) NOT NULL,
  path VARCHAR(500),  -- materialized path: /electronics/computers/laptops
  level INT NOT NULL DEFAULT 0
);

CREATE INDEX idx_categories_parent_id ON categories(parent_id);
CREATE INDEX idx_categories_path ON categories(path);
```

### Versioning/History

```sql
-- Product versions
CREATE TABLE products (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  version INT NOT NULL DEFAULT 1,
  is_current BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_products_current ON products(id) WHERE is_current = true;
```

## Optimization Guidelines

### When to Denormalize

Consider denormalization when:
- Read:write ratio is very high (100:1 or more)
- Joins are causing performance issues
- Aggregations are frequently needed
- Real-time analytics required

Example:
```sql
-- Instead of counting orders every time
ALTER TABLE users ADD COLUMN order_count INT NOT NULL DEFAULT 0;

-- Update via trigger on orders table
CREATE TRIGGER update_user_order_count
  AFTER INSERT OR DELETE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_order_count();
```

### Partitioning

For large tables (millions of rows):

```sql
-- Partition orders by date
CREATE TABLE orders (
  id BIGSERIAL,
  user_id BIGINT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL,
  ...
) PARTITION BY RANGE (created_at);

CREATE TABLE orders_2024_q1 PARTITION OF orders
  FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
  FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
```

### Full-Text Search

```sql
-- PostgreSQL
ALTER TABLE articles ADD COLUMN search_vector tsvector;

CREATE INDEX idx_articles_search ON articles USING GIN(search_vector);

UPDATE articles SET search_vector =
  to_tsvector('english', coalesce(title, '') || ' ' || coalesce(content, ''));

-- Trigger to keep it updated
CREATE TRIGGER articles_search_update
  BEFORE INSERT OR UPDATE ON articles
  FOR EACH ROW
  EXECUTE FUNCTION tsvector_update_trigger(search_vector, 'pg_catalog.english', title, content);
```

## Validation and Constraints

### Check Constraints

```sql
ALTER TABLE products
  ADD CONSTRAINT check_price_positive CHECK (price > 0);

ALTER TABLE orders
  ADD CONSTRAINT check_valid_status
  CHECK (status IN ('pending', 'processing', 'completed', 'cancelled'));

ALTER TABLE users
  ADD CONSTRAINT check_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
```

### Unique Constraints

```sql
-- Simple unique
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

-- Composite unique
ALTER TABLE user_roles
  ADD CONSTRAINT unique_user_role UNIQUE (user_id, role_id);

-- Partial unique (PostgreSQL)
CREATE UNIQUE INDEX unique_active_subscription
  ON subscriptions(user_id)
  WHERE status = 'active';
```

## Migration Best Practices

### Safe Migrations

```sql
-- ✅ SAFE: Add nullable column
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- ✅ SAFE: Add column with default
ALTER TABLE users ADD COLUMN is_verified BOOLEAN NOT NULL DEFAULT false;

-- ⚠️  RISKY: Add NOT NULL without default (requires data)
-- Step 1: Add nullable
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
-- Step 2: Populate data
UPDATE users SET phone = 'unknown' WHERE phone IS NULL;
-- Step 3: Add constraint
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;

-- ❌ DANGEROUS: Drop column (data loss)
-- Use only if sure and backed up
ALTER TABLE users DROP COLUMN temp_field;
```

### Zero-Downtime Migrations

```sql
-- Adding an index on large table
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Renaming column (requires application changes)
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN user_name VARCHAR(255);
-- Step 2: Copy data
UPDATE users SET user_name = name;
-- Step 3: Deploy app using new column
-- Step 4: Drop old column
ALTER TABLE users DROP COLUMN name;
```

## Quality Checklist

Before finalizing schema:

- [ ] All tables have primary keys
- [ ] Foreign keys defined with proper ON DELETE behavior
- [ ] Indexes on all foreign keys
- [ ] Indexes on frequently queried columns
- [ ] Appropriate data types (not all VARCHAR(255))
- [ ] DECIMAL for money fields
- [ ] Timestamps for created_at/updated_at
- [ ] Unique constraints where needed
- [ ] Check constraints for data validation
- [ ] NOT NULL constraints where appropriate
- [ ] Default values for boolean and enum fields
- [ ] Proper naming conventions
- [ ] Migration files created (up/down)
- [ ] Performance tested with realistic data volumes

## Example Usage

This skill works autonomously. When user says:

> "I need to design a database for an e-commerce app"

> "Create a schema for a blog with users, posts, and comments"

> "Help me optimize this slow query"

Claude will automatically use this skill to design a complete, production-ready database schema.

## Notes

- Always consider query patterns when designing schema
- Don't over-normalize if it hurts performance
- Index wisely - each index has a write cost
- Use appropriate data types to save space
- Plan for growth - use BIGINT for IDs if expecting scale
- Document complex business rules in schema comments
- Version all schema changes through migrations
- Test migrations on production-like data volumes
