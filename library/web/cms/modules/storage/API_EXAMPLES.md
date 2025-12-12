# Storage Module API Examples

This document provides examples of how to use the Storage module API endpoints.

## Base URL

All endpoints are prefixed with `/api/{version}/storage` where `{version}` is typically `v1`.

## Authentication

All endpoints require authentication. You need to include authentication credentials in your requests.

## Endpoints Overview

1. **List All Tables** - Get all table names
2. **Get Table Schema** - Get column information for a table
3. **List Table Items** - Get all rows from a table (with pagination)
4. **Execute SQL Query** - Execute custom SELECT queries

---

### 1. List All Tables

**GET** `/api/v1/storage/tables`

Returns a list of all table names in the database.

**Example Request:**
```bash
curl -X GET "http://localhost/api/v1/storage/tables" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Example Response:**
```json
{
  "rows": [
    "users",
    "r_users",
    "r_contents",
    "r_usage_reports",
    "r_author_contents"
  ],
  "count": 5
}
```

---

### 2. Get Table Schema

**GET** `/api/v1/storage/tables/{table_name}/schema`

Returns the schema information (columns, types, nullable status) for a specific table.

**Example Request:**
```bash
curl -X GET "http://localhost/api/v1/storage/tables/r_users/schema" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Example Response:**
```json
{
  "table_name": "r_users",
  "columns": [
    {
      "name": "id",
      "type": "TEXT",
      "nullable": false
    },
    {
      "name": "uid",
      "type": "INTEGER",
      "nullable": false
    },
    {
      "name": "kind",
      "type": "TEXT",
      "nullable": false
    },
    {
      "name": "data",
      "type": "TEXT",
      "nullable": true
    }
  ],
  "column_count": 4
}
```

---

### 3. List Table Items (Rows)

**GET** `/api/v1/storage/tables/{table_name}/items`

Returns all rows from a specific table with pagination support.

**Query Parameters:**
- `offset` (optional): Number of rows to skip (default: 0)
- `count` (optional): Number of rows to return (default: 100)

**Example Request:**
```bash
curl -X GET "http://localhost/api/v1/storage/tables/r_users/items?offset=0&count=10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Example Response:**
```json
{
  "table_name": "r_users",
  "rows": [
    {
      "id": "pub",
      "uid": 1,
      "kind": "publisher",
      "data": "{\"profile\":{\"name\":\"Publisher\"}}"
    },
    {
      "id": "author1",
      "uid": 2,
      "kind": "author",
      "data": "{\"profile\":{\"name\":\"Author\"}}"
    }
  ],
  "count": 2,
  "offset": 0,
  "limit": 10,
  "has_more": false
}
```

**Get Next Page:**
```bash
curl -X GET "http://localhost/api/v1/storage/tables/r_users/items?offset=10&count=10" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Get All Items (Default Limit):**
```bash
curl -X GET "http://localhost/api/v1/storage/tables/r_contents/items" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 4. Execute SQL Query

**POST** `/api/v1/storage/query`

Execute a SELECT query on the database. Only SELECT and PRAGMA queries are allowed for security.

#### Basic Query Example

**Request Body (JSON):**
```json
{
  "query": "SELECT id, uid, kind FROM r_users LIMIT 10",
  "limit": 10
}
```

**Example Request:**
```bash
curl -X POST "http://localhost/api/v1/storage/query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "query": "SELECT id, uid, kind FROM r_users LIMIT 10",
    "limit": 10
  }'
```

**Example Response:**
```json
{
  "rows": [
    {
      "id": "pub",
      "uid": 1,
      "kind": "publisher"
    },
    {
      "id": "author1",
      "uid": 2,
      "kind": "author"
    }
  ],
  "count": 2,
  "truncated": false
}
```

#### Query with WHERE Clause

**Example:**
```bash
curl -X POST "http://localhost/api/v1/storage/query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "query": "SELECT id, uid, kind FROM r_users WHERE kind = '\''publisher'\'' ORDER BY uid DESC",
    "limit": 20
  }'
```

#### Query with JOIN

**Example:**
```bash
curl -X POST "http://localhost/api/v1/storage/query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "query": "SELECT ru.id, ru.uid, u.name, u.email FROM r_users ru JOIN users u ON ru.uid = u.uid WHERE ru.kind = '\''publisher'\''",
    "limit": 50
  }'
```

#### Count Records

**Example:**
```bash
curl -X POST "http://localhost/api/v1/storage/query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "query": "SELECT COUNT(*) as total FROM r_users WHERE kind = '\''author'\''",
    "limit": 1
  }'
```

**Response:**
```json
{
  "rows": [
    {
      "total": 42
    }
  ],
  "count": 1
}
```

#### Query with Aggregation

**Example:**
```bash
curl -X POST "http://localhost/api/v1/storage/query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "query": "SELECT kind, COUNT(*) as count FROM r_users GROUP BY kind ORDER BY count DESC",
    "limit": 10
  }'
```

#### Query with Date Filtering

**Example:**
```bash
curl -X POST "http://localhost/api/v1/storage/query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "query": "SELECT id, signed, name FROM r_contents WHERE signed >= '\''2024-01-01'\'' ORDER BY signed DESC",
    "limit": 100
  }'
```

#### Query JSON Data (SQLite3)

For SQLite3, you can query JSON data stored in columns:

**Example:**
```bash
curl -X POST "http://localhost/api/v1/storage/query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "query": "SELECT id, JSON_EXTRACT(data, '\''$.profile.name'\'') as name FROM r_users WHERE JSON_EXTRACT(data, '\''$.profile.email'\'') LIKE '\''%@example.com'\''",
    "limit": 50
  }'
```

#### Query with LIKE Pattern

**Example:**
```bash
curl -X POST "http://localhost/api/v1/storage/query" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "query": "SELECT id, kind FROM r_users WHERE id LIKE '\''pub%'\''",
    "limit": 20
  }'
```

#### Query Using Query Parameters (Alternative Method)

You can also pass the query as a URL parameter:

**Example:**
```bash
curl -X POST "http://localhost/api/v1/storage/query?query=SELECT%20id%2C%20uid%20FROM%20r_users%20LIMIT%205&limit=5" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Note: The query must be URL-encoded when using query parameters.

---

## Common Query Patterns

### 1. Get Recent Records

```json
{
  "query": "SELECT * FROM r_contents ORDER BY signed DESC LIMIT 10",
  "limit": 10
}
```

### 2. Search by Pattern

```json
{
  "query": "SELECT * FROM r_users WHERE id LIKE '%author%'",
  "limit": 50
}
```

### 3. Get Statistics

```json
{
  "query": "SELECT kind, COUNT(*) as count, MIN(uid) as min_uid, MAX(uid) as max_uid FROM r_users GROUP BY kind",
  "limit": 10
}
```

### 4. Complex Filtering

```json
{
  "query": "SELECT id, owner, signed, name FROM r_contents WHERE owner IS NOT NULL AND signed >= '2024-01-01' ORDER BY signed DESC",
  "limit": 100
}
```

### 5. Get Table Row Count

```json
{
  "query": "SELECT COUNT(*) as row_count FROM r_users",
  "limit": 1
}
```

---

## Error Responses

If something goes wrong, you'll receive an error response:

```json
{
  "error": true,
  "message": "Query execution failed or returned no results"
}
```

Common error messages:
- `"Missing or empty query parameter"` - No query provided
- `"Permission denied: query storage permission required"` - User lacks required permission
- `"Query execution failed or returned no results"` - Query syntax error or no results
- `"Unable to access SQL storage"` - Database connection issue

---

## Security Notes

1. **Read-Only Access**: Only SELECT and PRAGMA queries are allowed. INSERT, UPDATE, DELETE, DROP, etc. are blocked.

2. **Query Limits**: Always specify a reasonable limit (default is 100). Large result sets may be truncated.

3. **Permissions**: 
   - `browse storage tables` - Required for listing tables and viewing schemas
   - `query storage` - Required for executing queries

4. **SQL Injection**: While the API uses parameterized queries internally, be careful when constructing queries from user input. Always validate and sanitize input.

---

## Example Workflow

1. **List available tables:**
   ```bash
   GET /api/v1/storage/tables
   ```

2. **Inspect a table's structure:**
   ```bash
   GET /api/v1/storage/tables/r_users/schema
   ```

3. **List all items from the table (simple pagination):**
   ```bash
   GET /api/v1/storage/tables/r_users/items?offset=0&count=20
   ```

4. **Get next page of items:**
   ```bash
   GET /api/v1/storage/tables/r_users/items?offset=20&count=20
   ```

5. **Or use custom query for more complex filtering:**
   ```bash
   POST /api/v1/storage/query
   {
     "query": "SELECT * FROM r_users WHERE kind = 'publisher'",
     "limit": 10
   }
   ```

6. **Refine the query based on results:**
   ```bash
   POST /api/v1/storage/query
   {
     "query": "SELECT id, uid FROM r_users WHERE kind = 'publisher' AND uid > 5 ORDER BY uid",
     "limit": 20
   }
   ```

