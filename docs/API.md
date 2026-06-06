# DevWiki API Documentation

**Base URL:** `https://api.devwiki.local/api`  
**API Version:** 1.0  
**Last Updated:** 2026-06-06

---

## Table of Contents

1. [Authentication](#authentication)
2. [Response Format](#response-format)
3. [Error Handling](#error-handling)
4. [Authentication Endpoints](#authentication-endpoints)
5. [Article Endpoints](#article-endpoints)
6. [Category Endpoints](#category-endpoints)
7. [Tag Endpoints](#tag-endpoints)
8. [Search Endpoints](#search-endpoints)
9. [Dashboard Endpoints](#dashboard-endpoints)
10. [User Endpoints](#user-endpoints)
11. [Revision Endpoints](#revision-endpoints)
12. [Pagination & Filtering](#pagination--filtering)
13. [Rate Limiting](#rate-limiting)

---

## Authentication

### Authorization Header Format

All authenticated endpoints require the `Authorization` header with JWT token:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Token Details

- **Type:** JWT (JSON Web Token)
- **Algorithm:** HS256 (HMAC-SHA256)
- **Expiration:** 60 minutes
- **Refresh:** Use refresh token endpoint
- **Storage:** HttpOnly secure cookie (production) or localStorage (development)

### Token Claims

```json
{
  "sub": "user-id-uuid",
  "email": "user@example.com",
  "given_name": "John",
  "family_name": "Doe",
  "role": "Editor",
  "iat": 1717590000,
  "exp": 1717593600
}
```

---

## Response Format

### Success Response (2xx)

```json
{
  "success": true,
  "data": {
    "userId": "123e4567-e89b-12d3-a456-426614174000",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Editor"
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

### Error Response (4xx/5xx)

```json
{
  "success": false,
  "errors": [
    {
      "code": "INVALID_CREDENTIALS",
      "message": "Invalid email or password",
      "field": "password"
    },
    {
      "code": "VALIDATION_ERROR",
      "message": "Email must be a valid email address",
      "field": "email"
    }
  ],
  "timestamp": "2026-06-06T10:30:00Z"
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Request success status |
| `data` | object \| array | Response payload (null on error) |
| `errors` | array | Array of error objects |
| `timestamp` | string | ISO 8601 timestamp |

---

## Error Handling

### HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | OK | Successful GET/PUT |
| 201 | Created | Article created successfully |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation failed |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate email/slug |
| 422 | Unprocessable | Invalid data format |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Server Error | Internal error |

### Error Codes

Common error codes returned in API responses:

```
INVALID_CREDENTIALS      - Login failed
EMAIL_EXISTS            - Email already registered
CATEGORY_NOT_FOUND      - Category ID invalid
ARTICLE_NOT_FOUND       - Article ID invalid
REVISION_NOT_FOUND      - Revision doesn't exist
VALIDATION_ERROR        - Input validation failed
UNAUTHORIZED            - User not authenticated
FORBIDDEN               - User lacks permissions
TAG_EXISTS              - Tag already exists
CATEGORY_EXISTS         - Category already exists
```

---

## Authentication Endpoints

### POST /auth/register

Register a new user account.

**Request:**
```bash
curl -X POST https://api.devwiki.local/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePassword123!",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

**Request Schema:**
```json
{
  "email": "string (required, email format)",
  "password": "string (required, min 12 chars)",
  "firstName": "string (required, max 100)",
  "lastName": "string (required, max 100)"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "Viewer"
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

**Error Cases:**
- `400` - Invalid email format or password too short
- `409` - Email already registered

---

### POST /auth/login

Authenticate user and obtain tokens.

**Request:**
```bash
curl -X POST https://api.devwiki.local/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "SecurePassword123!"
  }'
```

**Request Schema:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "550e8400e29b41d4a716446655440000",
    "expiresIn": 3600,
    "user": {
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "email": "john@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "role": "Editor"
    }
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

**Error Cases:**
- `400` - Missing email or password
- `401` - Invalid credentials

---

### POST /auth/refresh

Refresh expired access token.

**Request:**
```bash
curl -X POST https://api.devwiki.local/api/auth/refresh \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <expired-token>" \
  -d '{
    "refreshToken": "550e8400e29b41d4a716446655440000"
  }'
```

**Request Schema:**
```json
{
  "refreshToken": "string (required)"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

**Error Cases:**
- `401` - Invalid refresh token
- `400` - Missing token

---

## Article Endpoints

### GET /articles

List articles with pagination and filtering.

**Request:**
```bash
curl "https://api.devwiki.local/api/articles?page=1&pageSize=20&categoryId=1&sortBy=updatedAt&sortOrder=desc"
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number (1-indexed) |
| `pageSize` | integer | 20 | Items per page (max 100) |
| `categoryId` | integer | - | Filter by category |
| `sortBy` | string | `createdAt` | Sort field: `createdAt`, `updatedAt`, `viewCount` |
| `sortOrder` | string | `desc` | Sort direction: `asc`, `desc` |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "articleId": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Dependency Injection in .NET",
        "slug": "dependency-injection-in-net",
        "summary": "A comprehensive guide to DI patterns...",
        "authorId": "660e8400-e29b-41d4-a716-446655440001",
        "authorName": "John Doe",
        "categoryId": 1,
        "categoryName": ".NET",
        "tags": [
          {
            "tagId": 1,
            "name": "Architecture",
            "slug": "architecture"
          }
        ],
        "viewCount": 152,
        "createdAt": "2026-01-15T10:30:00Z",
        "updatedAt": "2026-06-05T14:22:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "totalItems": 45,
      "totalPages": 3
    }
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

### GET /articles/{id}

Get article details including full content.

**Request:**
```bash
curl "https://api.devwiki.local/api/articles/550e8400-e29b-41d4-a716-446655440000"
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "articleId": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Dependency Injection in .NET",
    "slug": "dependency-injection-in-net",
    "summary": "A comprehensive guide...",
    "content": "# Dependency Injection\n\nDI is a...",
    "authorId": "660e8400-e29b-41d4-a716-446655440001",
    "authorName": "John Doe",
    "categoryId": 1,
    "categoryName": ".NET",
    "tags": [
      {
        "tagId": 1,
        "name": "Architecture",
        "slug": "architecture"
      }
    ],
    "status": "Active",
    "viewCount": 152,
    "createdAt": "2026-01-15T10:30:00Z",
    "updatedAt": "2026-06-05T14:22:00Z"
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

**Error Cases:**
- `404` - Article not found

---

### POST /articles

Create a new article. **Requires authentication (Editor role minimum).**

**Request:**
```bash
curl -X POST https://api.devwiki.local/api/articles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "New Article",
    "summary": "Article summary",
    "content": "# Markdown content",
    "categoryId": 1,
    "tagIds": [1, 2]
  }'
```

**Request Schema:**
```json
{
  "title": "string (required, max 255)",
  "summary": "string (required)",
  "content": "string (required, markdown)",
  "categoryId": "integer (required)",
  "tagIds": "integer[] (optional)"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "articleId": "550e8400-e29b-41d4-a716-446655440000",
    "title": "New Article",
    "slug": "new-article"
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

**Error Cases:**
- `400` - Validation failed
- `401` - Not authenticated
- `403` - Insufficient role
- `404` - Category not found

---

### PUT /articles/{id}

Update article. **Requires authentication (author or admin).**

**Request:**
```bash
curl -X PUT https://api.devwiki.local/api/articles/550e8400-e29b-41d4-a716-446655440000 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "Updated Title",
    "summary": "Updated summary",
    "content": "# Updated content",
    "categoryId": 1,
    "tagIds": [1, 2],
    "changeDescription": "Fixed typos and clarified steps"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "articleId": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Updated Title"
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

### DELETE /articles/{id}

Archive article (soft delete). **Requires authentication (author or admin).**

**Request:**
```bash
curl -X DELETE https://api.devwiki.local/api/articles/550e8400-e29b-41d4-a716-446655440000 \
  -H "Authorization: Bearer <token>"
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "articleId": "550e8400-e29b-41d4-a716-446655440000",
    "status": "Archived"
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

## Category Endpoints

### GET /categories

List all categories.

**Request:**
```bash
curl "https://api.devwiki.local/api/categories"
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "categoryId": 1,
      "name": ".NET",
      "slug": "dotnet",
      "description": "C#, ASP.NET Core, Entity Framework...",
      "articleCount": 12
    },
    {
      "categoryId": 2,
      "name": "React",
      "slug": "react",
      "description": "React, TypeScript, Hooks...",
      "articleCount": 8
    }
  ],
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

### POST /categories

Create category. **Requires authentication (admin role).**

**Request:**
```bash
curl -X POST https://api.devwiki.local/api/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "name": "DevOps",
    "description": "Docker, Kubernetes, CI/CD..."
  }'
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "categoryId": 11,
    "name": "DevOps",
    "slug": "devops",
    "description": "Docker, Kubernetes, CI/CD...",
    "articleCount": 0
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

## Tag Endpoints

### GET /tags

List all tags.

**Request:**
```bash
curl "https://api.devwiki.local/api/tags"
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "tagId": 1,
      "name": "Authentication",
      "slug": "authentication"
    },
    {
      "tagId": 2,
      "name": "Security",
      "slug": "security"
    }
  ],
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

### POST /tags

Create tag. **Requires authentication (editor role).**

**Request:**
```bash
curl -X POST https://api.devwiki.local/api/tags \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "name": "Performance"
  }'
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "tagId": 35,
    "name": "Performance",
    "slug": "performance"
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

## Search Endpoints

### GET /search

Full-text search articles.

**Request:**
```bash
curl "https://api.devwiki.local/api/search?q=dependency%20injection&page=1&pageSize=20"
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | Search query (required, min 2 chars) |
| `page` | integer | Page number (default: 1) |
| `pageSize` | integer | Items per page (default: 20) |

**Response (200):**
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "articleId": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Dependency Injection in .NET",
        "slug": "dependency-injection-in-net",
        "summary": "A comprehensive guide...",
        "authorName": "John Doe",
        "categoryName": ".NET",
        "viewCount": 152
      }
    ],
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "totalItems": 5,
      "totalPages": 1
    }
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

**Error Cases:**
- `400` - Query parameter missing

---

## Dashboard Endpoints

### GET /dashboard/statistics

Get dashboard metrics. **Requires authentication.**

**Request:**
```bash
curl "https://api.devwiki.local/api/dashboard/statistics" \
  -H "Authorization: Bearer <token>"
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalArticles": 145,
    "totalCategories": 10,
    "totalTags": 35,
    "activeEditors": 12,
    "articlesThisMonth": 23,
    "mostViewedCount": 542
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

### GET /dashboard/recent-articles

Get recently updated articles. **Requires authentication.**

**Request:**
```bash
curl "https://api.devwiki.local/api/dashboard/recent-articles?limit=10" \
  -H "Authorization: Bearer <token>"
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `limit` | integer | 10 | Number of articles to return |

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "articleId": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Dependency Injection",
      "slug": "dependency-injection",
      "authorName": "John Doe",
      "updatedAt": "2026-06-06T10:30:00Z"
    }
  ],
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

## Revision Endpoints

### GET /articles/{id}/revisions

Get revision history. **Requires authentication.**

**Request:**
```bash
curl "https://api.devwiki.local/api/articles/550e8400-e29b-41d4-a716-446655440000/revisions" \
  -H "Authorization: Bearer <token>"
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "revisionId": "770e8400-e29b-41d4-a716-446655440000",
      "revisionNumber": 2,
      "updatedByName": "Jane Smith",
      "updatedAt": "2026-06-05T14:22:00Z",
      "changeDescription": "Fixed typos"
    },
    {
      "revisionId": "660e8400-e29b-41d4-a716-446655440001",
      "revisionNumber": 1,
      "updatedByName": "John Doe",
      "updatedAt": "2026-01-15T10:30:00Z",
      "changeDescription": null
    }
  ],
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

### GET /articles/{id}/revisions/{revisionId}

Get specific revision content. **Requires authentication.**

**Request:**
```bash
curl "https://api.devwiki.local/api/articles/550e8400-e29b-41d4-a716-446655440000/revisions/770e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer <token>"
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "revisionId": "770e8400-e29b-41d4-a716-446655440000",
    "articleId": "550e8400-e29b-41d4-a716-446655440000",
    "revisionNumber": 2,
    "content": "# Dependency Injection\n\n...",
    "updatedByName": "Jane Smith",
    "updatedAt": "2026-06-05T14:22:00Z",
    "changeDescription": "Fixed typos"
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

### POST /articles/{id}/revisions/{revisionId}/restore

Restore previous revision. **Requires authentication (author or admin).**

**Request:**
```bash
curl -X POST "https://api.devwiki.local/api/articles/550e8400-e29b-41d4-a716-446655440000/revisions/770e8400-e29b-41d4-a716-446655440000/restore" \
  -H "Authorization: Bearer <token>"
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "articleId": "550e8400-e29b-41d4-a716-446655440000",
    "revisionNumber": 3
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

## User Endpoints

### GET /users

List all users. **Requires authentication (admin role).**

**Request:**
```bash
curl "https://api.devwiki.local/api/users" \
  -H "Authorization: Bearer <token>"
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "userId": "550e8400-e29b-41d4-a716-446655440000",
      "email": "john@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "role": "Editor",
      "isActive": true,
      "createdAt": "2026-01-15T10:30:00Z"
    }
  ],
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

## Markdown Import Endpoint

### POST /articles/import

Import multiple articles from markdown. **Requires authentication (editor role).**

**Request:**
```bash
curl -X POST https://api.devwiki.local/api/articles/import \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "content": "# Article 1\nContent here...\n\n# Article 2\nMore content...",
    "categoryId": 1,
    "tagIds": [1, 2]
  }'
```

**Request Schema:**
```json
{
  "content": "string (required, markdown with h1 headers)",
  "categoryId": "integer (required)",
  "tagIds": "integer[] (optional)"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "createdArticles": 2,
    "errors": []
  },
  "timestamp": "2026-06-06T10:30:00Z"
}
```

---

## Pagination & Filtering

### Pagination

Paginated endpoints return a `pagination` object:

```json
"pagination": {
  "page": 1,
  "pageSize": 20,
  "totalItems": 150,
  "totalPages": 8
}
```

**Limits:**
- Minimum page size: 1
- Maximum page size: 100
- Default page size: 20

### Sorting

Available sort fields and directions:

| Field | Available On | Direction |
|-------|--------------|-----------|
| `createdAt` | Articles | asc, desc (default) |
| `updatedAt` | Articles | asc, desc (default) |
| `viewCount` | Articles | asc, desc |
| `name` | Categories, Tags | asc, desc |

---

## Rate Limiting

### Limits

| Endpoint Type | Limit | Window |
|---|---|---|
| Authentication | 5 requests | 1 minute |
| General API | 100 requests | 1 minute |
| Search | 30 requests | 1 minute |

### Rate Limit Headers

Successful responses include:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1717590000
```

### Exceeding Limits

When rate limited, the API returns:

```
HTTP 429 Too Many Requests

{
  "success": false,
  "errors": [
    {
      "code": "RATE_LIMIT_EXCEEDED",
      "message": "Rate limit exceeded. Try again in 45 seconds."
    }
  ]
}
```

---

## Common Use Cases

### User Registration & Login Flow

```bash
# 1. Register
curl -X POST https://api.devwiki.local/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "firstName": "John",
    "lastName": "Doe"
  }'

# 2. Login
curl -X POST https://api.devwiki.local/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePassword123!"
  }'

# 3. Use token for authenticated requests
curl "https://api.devwiki.local/api/dashboard/statistics" \
  -H "Authorization: Bearer <access_token>"

# 4. Refresh expired token
curl -X POST https://api.devwiki.local/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken": "<refresh_token>"}'
```

### Article Creation & Search Flow

```bash
# 1. Get categories
curl "https://api.devwiki.local/api/categories" \
  -H "Authorization: Bearer <token>"

# 2. Get tags
curl "https://api.devwiki.local/api/tags" \
  -H "Authorization: Bearer <token>"

# 3. Create article
curl -X POST https://api.devwiki.local/api/articles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{
    "title": "Topic",
    "summary": "Summary",
    "content": "# Content",
    "categoryId": 1,
    "tagIds": [1, 2]
  }'

# 4. Search articles
curl "https://api.devwiki.local/api/search?q=dependency%20injection" \
  -H "Authorization: Bearer <token>"
```

---

## API Changelog

### Version 1.0 (Current)

- Authentication endpoints (register, login, refresh)
- Article CRUD operations
- Category management
- Tag management
- Full-text search
- Dashboard statistics
- User management
- Revision history tracking
- Markdown import
- Audit logging

---

## Support

For issues or questions about the API:

1. Check error code in response
2. Review request format against examples
3. Verify JWT token is not expired
4. Check user role permissions
5. Contact: support@devwiki.local

---

**Last Updated:** 2026-06-06  
**Version:** 1.0  
**Status:** Production Ready
