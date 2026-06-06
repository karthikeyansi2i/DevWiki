# DevWiki - Specification Document

**Project:** Developer Knowledge Hub (DevWiki)  
**Version:** 1.0  
**Date:** 2026-06-05  
**Status:** Production Ready

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Database Design](#database-design)
4. [API Design](#api-design)
5. [Folder Structure](#folder-structure)
6. [Technology Stack](#technology-stack)
7. [Implementation Phases](#implementation-phases)
8. [Security & Authorization](#security--authorization)
9. [Performance Considerations](#performance-considerations)
10. [Deployment Strategy](#deployment-strategy)

---

## Project Overview

### Vision
DevWiki is an internal engineering knowledge base for software teams to store, organize, and search technical documentation, architecture notes, coding standards, troubleshooting guides, and best practices.

### Key Features
- **User Management:** Registration, login, role-based access control (Admin, Editor, Viewer)
- **Article Management:** Create, edit, delete, archive, restore articles with rich markdown support
- **Categorization:** Organize content by predefined categories and flexible tagging
- **Revision History:** Track all changes with ability to view and restore previous versions
- **Full-Text Search:** PostgreSQL-powered search with ranking and pagination
- **Dashboard:** Analytics and activity tracking
- **Markdown Import:** Bulk import documentation from files
- **Audit Logs:** Track administrative actions and content changes

---

## System Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     CLIENT LAYER                             │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  React SPA (Vite)                                      │  │
│  │  - TypeScript                                          │  │
│  │  - React Router for navigation                         │  │
│  │  - TanStack Query for server state management          │  │
│  │  - Tailwind CSS for styling                            │  │
│  │  - React Markdown for content display                  │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┐
                           │                                      │
                    JWT Token Exchange                            │
                           │                                      │
┌────────────────────────────────────────────────────────────────┐
│                     API GATEWAY                                │
│  ASP.NET Core 9 Web API                                        │
│  ┌────────────────────────────────────────────────────────┐  │
│  │ Authentication Middleware                              │  │
│  │ - JWT Validation                                       │  │
│  │ - Refresh Token Rotation                               │  │
│  │ - CORS Configuration                                   │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┐
                           │                                      │
┌────────────────────────────────────────────────────────────────┐
│                 APPLICATION LAYER                              │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐│
│  │ Controllers (API Endpoints)                             ││
│  └──────────────────────────────────────────────────────────┘│
│                           │                                   │
│  ┌──────────────────────────────────────────────────────────┐│
│  │ MediatR Pipeline (CQRS)                                 ││
│  │ - Commands (Write Operations)                           ││
│  │ - Queries (Read Operations)                             ││
│  │ - Behaviors (Cross-cutting Concerns)                    ││
│  └──────────────────────────────────────────────────────────┘│
│                           │                                   │
│  ┌──────────────────────────────────────────────────────────┐│
│  │ Application Services                                    ││
│  │ - Business Logic                                        ││
│  │ - Orchestration                                         ││
│  └──────────────────────────────────────────────────────────┘│
│                           │                                   │
│  ┌──────────────────────────────────────────────────────────┐│
│  │ Domain Services                                         ││
│  │ - Domain Logic                                          ││
│  │ - Validation Rules                                      ││
│  └──────────────────────────────────────────────────────────┘│
└────────────────────────────────────────────────────────────────┐
                           │                                      │
┌────────────────────────────────────────────────────────────────┐
│                  DATA ACCESS LAYER                             │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐│
│  │ Entity Framework Core                                   ││
│  │ - DbContext                                             ││
│  │ - DbSets                                                ││
│  │ - Change Tracking                                       ││
│  └──────────────────────────────────────────────────────────┘│
│                           │                                   │
│  ┌──────────────────────────────────────────────────────────┐│
│  │ Repository Pattern                                      ││
│  │ - Generic Repository<T>                                 ││
│  │ - Unit of Work                                          ││
│  └──────────────────────────────────────────────────────────┘│
└────────────────────────────────────────────────────────────────┐
                           │                                      │
┌────────────────────────────────────────────────────────────────┐
│               DATABASE & EXTERNAL SERVICES                     │
│                                                                │
│  ┌──────────────────┐  ┌──────────────────┐                  │
│  │   PostgreSQL     │  │  File Storage    │                  │
│  │  (Primary DB)    │  │  (Markdown/Docs) │                  │
│  └──────────────────┘  └──────────────────┘                  │
└────────────────────────────────────────────────────────────────┘
```

### Architectural Principles

**Clean Architecture:**
- Separation of concerns across layers
- Domain-centric design
- Framework-agnostic business logic
- Testable without infrastructure dependencies

**CQRS Pattern:**
- Commands for write operations (Create, Update, Delete)
- Queries for read operations
- MediatR as the mediator
- Scalable separation of read/write models (future)

**Dependency Injection:**
- Inversion of Control container
- Constructor injection
- Interface-based dependencies
- Loose coupling between layers

---

## Database Design

### Entity Relationship Diagram

```
┌─────────────────────┐
│      Users          │
├─────────────────────┤
│ UserId (PK)         │
│ Email               │
│ NormalizedEmail     │
│ PasswordHash        │
│ FirstName           │
│ LastName            │
│ Role                │◄──┐
│ IsActive            │   │
│ CreatedAt           │   │
│ UpdatedAt           │   │
└─────────────────────┘   │
         │                │
         │ (Author)       │
         │                │
┌────────┴────────────────┴──────────┐
│         Articles        │           │
├────────────────────────────────────┤
│ ArticleId (PK)                     │
│ Title                              │
│ Slug (Unique)                      │
│ Summary                            │
│ Content (Markdown)                 │
│ AuthorId (FK) ─────────────────────┘
│ CategoryId (FK) ────────────┐
│ Status (Active/Archived)    │
│ ViewCount                   │
│ CreatedAt                   │
│ UpdatedAt                   │
└───────────────┬──────────────┬─────┐
                │              │     │
                │              │     │
         ┌──────▼──────┐      │     │
         │ ArticleTags │      │     │
         ├─────────────┤      │     │
         │ArticleId(FK)│      │     │
         │ TagId (FK) ─┼──────┤     │
         └─────────────┘      │     │
                              │     │
                    ┌─────────▼──────┐
                    │   Categories   │
                    ├────────────────┤
                    │CategoryId(PK)  │
                    │Name            │
                    │Slug            │
                    │Description     │
                    │CreatedAt       │
                    │UpdatedAt       │
                    └─────────────────┘
                              │
                              │
                    ┌─────────▼──────┐
                    │      Tags      │
                    ├────────────────┤
                    │ TagId (PK)     │
                    │ Name           │
                    │ Slug           │
                    │ CreatedAt      │
                    │ UpdatedAt      │
                    └────────────────┘

┌──────────────────────────┐
│    ArticleRevisions      │
├──────────────────────────┤
│ RevisionId (PK)          │
│ ArticleId (FK)   ────────┼──────► Articles
│ Content (Snapshot)       │
│ RevisionNumber           │
│ UpdatedBy (FK)   ────────┼──────► Users
│ UpdatedAt                │
│ ChangeDescription        │
└──────────────────────────┘

┌──────────────────────────┐
│      AuditLogs           │
├──────────────────────────┤
│ AuditLogId (PK)          │
│ UserId (FK)      ────────┼──────► Users
│ Action                   │
│ EntityType               │
│ EntityId                 │
│ Changes (JSON)           │
│ CreatedAt                │
└──────────────────────────┘
```

### Tables & Columns

#### Users
```sql
CREATE TABLE Users (
    UserId UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Email VARCHAR(255) NOT NULL UNIQUE,
    NormalizedEmail VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL CHECK (Role IN ('Admin', 'Editor', 'Viewer')),
    IsActive BOOLEAN NOT NULL DEFAULT TRUE,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### Categories
```sql
CREATE TABLE Categories (
    CategoryId SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Slug VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### Tags
```sql
CREATE TABLE Tags (
    TagId SERIAL PRIMARY KEY,
    Name VARCHAR(100) NOT NULL UNIQUE,
    Slug VARCHAR(100) NOT NULL UNIQUE,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

#### Articles
```sql
CREATE TABLE Articles (
    ArticleId UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Title VARCHAR(255) NOT NULL,
    Slug VARCHAR(255) NOT NULL UNIQUE,
    Summary TEXT NOT NULL,
    Content TEXT NOT NULL,
    AuthorId UUID NOT NULL REFERENCES Users(UserId),
    CategoryId INT NOT NULL REFERENCES Categories(CategoryId),
    Status VARCHAR(50) NOT NULL CHECK (Status IN ('Active', 'Archived')) DEFAULT 'Active',
    ViewCount INT NOT NULL DEFAULT 0,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_author (AuthorId),
    INDEX idx_category (CategoryId),
    INDEX idx_status (Status),
    INDEX idx_created_at (CreatedAt),
    FULL TEXT SEARCH ts_vector (Title, Summary, Content)
);
```

#### ArticleTags
```sql
CREATE TABLE ArticleTags (
    ArticleId UUID NOT NULL REFERENCES Articles(ArticleId) ON DELETE CASCADE,
    TagId INT NOT NULL REFERENCES Tags(TagId) ON DELETE CASCADE,
    PRIMARY KEY (ArticleId, TagId)
);
```

#### ArticleRevisions
```sql
CREATE TABLE ArticleRevisions (
    RevisionId UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ArticleId UUID NOT NULL REFERENCES Articles(ArticleId) ON DELETE CASCADE,
    Content TEXT NOT NULL,
    RevisionNumber INT NOT NULL,
    UpdatedBy UUID NOT NULL REFERENCES Users(UserId),
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ChangeDescription VARCHAR(255),
    
    UNIQUE (ArticleId, RevisionNumber),
    INDEX idx_article (ArticleId),
    INDEX idx_updated_at (UpdatedAt)
);
```

#### AuditLogs
```sql
CREATE TABLE AuditLogs (
    AuditLogId UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    UserId UUID NOT NULL REFERENCES Users(UserId),
    Action VARCHAR(100) NOT NULL,
    EntityType VARCHAR(100) NOT NULL,
    EntityId VARCHAR(255) NOT NULL,
    Changes JSONB,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user (UserId),
    INDEX idx_created_at (CreatedAt),
    INDEX idx_entity (EntityType, EntityId)
);
```

---

## API Design

### Base URL
```
https://api.devwiki.local/api
```

### Authentication
All endpoints (except `/auth/register` and `/auth/login`) require:
```
Authorization: Bearer <access_token>
```

### Response Format

**Success (2xx):**
```json
{
    "success": true,
    "data": { /* endpoint-specific data */ },
    "timestamp": "2026-06-05T10:30:00Z"
}
```

**Error (4xx/5xx):**
```json
{
    "success": false,
    "errors": [
        {
            "code": "ERROR_CODE",
            "message": "Human-readable message",
            "field": "fieldName" /* optional */
        }
    ],
    "timestamp": "2026-06-05T10:30:00Z"
}
```

### Authentication Endpoints

#### POST /auth/register
Register a new user

**Request:**
```json
{
    "email": "user@example.com",
    "password": "SecurePassword123!",
    "firstName": "John",
    "lastName": "Doe"
}
```

**Response (201):**
```json
{
    "success": true,
    "data": {
        "userId": "uuid",
        "email": "user@example.com",
        "firstName": "John",
        "lastName": "Doe"
    }
}
```

#### POST /auth/login
Authenticate and obtain tokens

**Request:**
```json
{
    "email": "user@example.com",
    "password": "SecurePassword123!"
}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "accessToken": "jwt_token",
        "refreshToken": "refresh_token",
        "expiresIn": 3600,
        "user": {
            "userId": "uuid",
            "email": "user@example.com",
            "role": "Editor"
        }
    }
}
```

#### POST /auth/refresh
Refresh access token

**Request:**
```json
{
    "refreshToken": "refresh_token"
}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "accessToken": "new_jwt_token",
        "expiresIn": 3600
    }
}
```

### Article Endpoints

#### GET /articles
List articles with pagination and filtering

**Query Parameters:**
- `page` (int, default=1): Page number
- `pageSize` (int, default=20): Items per page
- `categoryId` (int): Filter by category
- `tagId` (int): Filter by tag
- `sortBy` (string): `createdAt`, `updatedAt`, `viewCount` (default=`createdAt`)
- `sortOrder` (string): `asc`, `desc` (default=`desc`)

**Response (200):**
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "articleId": "uuid",
                "title": "String",
                "slug": "string",
                "summary": "String",
                "categoryId": 1,
                "categoryName": "String",
                "tags": [{"tagId": 1, "name": "String"}],
                "authorId": "uuid",
                "authorName": "String",
                "viewCount": 42,
                "createdAt": "2026-06-05T10:30:00Z",
                "updatedAt": "2026-06-05T10:30:00Z"
            }
        ],
        "pagination": {
            "page": 1,
            "pageSize": 20,
            "totalItems": 150,
            "totalPages": 8
        }
    }
}
```

#### GET /articles/{id}
Get article details

**Response (200):**
```json
{
    "success": true,
    "data": {
        "articleId": "uuid",
        "title": "String",
        "slug": "string",
        "summary": "String",
        "content": "# Markdown content",
        "categoryId": 1,
        "categoryName": "String",
        "tags": [{"tagId": 1, "name": "String"}],
        "authorId": "uuid",
        "authorName": "String",
        "viewCount": 42,
        "status": "Active",
        "createdAt": "2026-06-05T10:30:00Z",
        "updatedAt": "2026-06-05T10:30:00Z"
    }
}
```

#### POST /articles
Create a new article (requires Editor role)

**Request:**
```json
{
    "title": "String",
    "summary": "String",
    "content": "# Markdown content",
    "categoryId": 1,
    "tagIds": [1, 2, 3]
}
```

**Response (201):**
```json
{
    "success": true,
    "data": {
        "articleId": "uuid",
        "title": "String",
        "slug": "auto-generated-slug"
    }
}
```

#### PUT /articles/{id}
Update article (requires Author or Admin role)

**Request:**
```json
{
    "title": "String",
    "summary": "String",
    "content": "# Updated markdown",
    "categoryId": 1,
    "tagIds": [1, 2, 3],
    "changeDescription": "Fixed typos and clarified steps"
}
```

**Response (200):**
```json
{
    "success": true,
    "data": {
        "articleId": "uuid",
        "title": "String"
    }
}
```

#### DELETE /articles/{id}
Archive article (requires Author or Admin role)

**Response (200):**
```json
{
    "success": true,
    "data": {
        "articleId": "uuid",
        "status": "Archived"
    }
}
```

#### POST /articles/{id}/restore
Restore archived article (requires Author or Admin role)

**Response (200):**
```json
{
    "success": true,
    "data": {
        "articleId": "uuid",
        "status": "Active"
    }
}
```

### Search Endpoints

#### GET /search
Full-text search articles

**Query Parameters:**
- `q` (string, required): Search query
- `page` (int, default=1): Page number
- `pageSize` (int, default=20): Items per page

**Response (200):**
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "articleId": "uuid",
                "title": "String",
                "slug": "string",
                "summary": "String",
                "relevance": 0.95,
                "highlights": ["excerpt with <mark>query</mark> highlighted"]
            }
        ],
        "pagination": {
            "page": 1,
            "pageSize": 20,
            "totalItems": 45,
            "totalPages": 3
        }
    }
}
```

### Category Endpoints

#### GET /categories
List all categories

**Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "categoryId": 1,
            "name": "String",
            "slug": "string",
            "description": "String",
            "articleCount": 12
        }
    ]
}
```

#### POST /categories
Create category (requires Admin role)

**Request:**
```json
{
    "name": "String",
    "description": "String"
}
```

#### PUT /categories/{id}
Update category (requires Admin role)

#### DELETE /categories/{id}
Delete category (requires Admin role)

### Tag Endpoints

#### GET /tags
List all tags

#### POST /tags
Create tag (requires Editor role)

#### PUT /tags/{id}
Update tag (requires Editor role)

#### DELETE /tags/{id}
Delete tag (requires Admin role)

### Revision Endpoints

#### GET /articles/{id}/revisions
Get revision history

**Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "revisionId": "uuid",
            "revisionNumber": 1,
            "updatedBy": "String",
            "updatedAt": "2026-06-05T10:30:00Z",
            "changeDescription": "String"
        }
    ]
}
```

#### GET /articles/{id}/revisions/{revisionId}
Get specific revision content

**Response (200):**
```json
{
    "success": true,
    "data": {
        "revisionId": "uuid",
        "articleId": "uuid",
        "revisionNumber": 1,
        "content": "# Markdown content",
        "updatedBy": "String",
        "updatedAt": "2026-06-05T10:30:00Z"
    }
}
```

#### POST /articles/{id}/revisions/{revisionId}/restore
Restore previous revision (requires Author or Admin role)

**Response (200):**
```json
{
    "success": true,
    "data": {
        "articleId": "uuid",
        "revisionNumber": 2
    }
}
```

### Dashboard Endpoints

#### GET /dashboard/statistics
Get dashboard metrics

**Response (200):**
```json
{
    "success": true,
    "data": {
        "totalArticles": 145,
        "totalCategories": 10,
        "totalTags": 35,
        "totalUsers": 28,
        "activeEditors": 12,
        "articlesThisMonth": 23
    }
}
```

#### GET /dashboard/recent-articles
Get recently updated articles

**Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "articleId": "uuid",
            "title": "String",
            "slug": "string",
            "updatedAt": "2026-06-05T10:30:00Z",
            "updatedBy": "String"
        }
    ]
}
```

### User Management Endpoints

#### GET /users
List users (requires Admin role)

#### POST /users
Create user (requires Admin role)

#### PUT /users/{id}
Update user (requires Admin role)

#### DELETE /users/{id}
Deactivate user (requires Admin role)

#### GET /users/{id}/activity
Get user activity (requires Admin role)

---

## Folder Structure

### Backend (ASP.NET Core)

```
DevWiki.Backend/
├── src/
│   ├── DevWiki.API/
│   │   ├── Controllers/
│   │   │   ├── AuthController.cs
│   │   │   ├── ArticlesController.cs
│   │   │   ├── CategoriesController.cs
│   │   │   ├── TagsController.cs
│   │   │   ├── SearchController.cs
│   │   │   ├── UsersController.cs
│   │   │   ├── DashboardController.cs
│   │   │   └── RevisionsController.cs
│   │   ├── Middleware/
│   │   │   ├── ExceptionHandlingMiddleware.cs
│   │   │   └── RequestLoggingMiddleware.cs
│   │   ├── Program.cs
│   │   ├── appsettings.json
│   │   ├── appsettings.Development.json
│   │   └── DevWiki.API.csproj
│   │
│   ├── DevWiki.Application/
│   │   ├── Commands/
│   │   │   ├── Articles/
│   │   │   │   ├── CreateArticleCommand.cs
│   │   │   │   ├── UpdateArticleCommand.cs
│   │   │   │   ├── DeleteArticleCommand.cs
│   │   │   │   └── RestoreArticleCommand.cs
│   │   │   ├── Auth/
│   │   │   │   ├── RegisterCommand.cs
│   │   │   │   ├── LoginCommand.cs
│   │   │   │   └── RefreshTokenCommand.cs
│   │   │   ├── Categories/
│   │   │   ├── Tags/
│   │   │   └── Users/
│   │   ├── Queries/
│   │   │   ├── Articles/
│   │   │   │   ├── GetArticlesQuery.cs
│   │   │   │   ├── GetArticleByIdQuery.cs
│   │   │   │   └── GetArticleRevisionsQuery.cs
│   │   │   ├── Categories/
│   │   │   ├── Tags/
│   │   │   ├── Search/
│   │   │   │   └── SearchArticlesQuery.cs
│   │   │   └── Dashboard/
│   │   ├── Handlers/
│   │   │   └── /* Handlers for Commands & Queries */
│   │   ├── DTOs/
│   │   │   ├── Requests/
│   │   │   ├── Responses/
│   │   │   └── Common/
│   │   ├── Validators/
│   │   │   ├── Commands/
│   │   │   └── DTOs/
│   │   ├── Mappings/
│   │   │   └── MappingProfile.cs
│   │   ├── Services/
│   │   │   ├── IAuthService.cs
│   │   │   ├── IArticleService.cs
│   │   │   ├── ISearchService.cs
│   │   │   └── /* Other services */
│   │   ├── Behaviors/
│   │   │   ├── ValidationBehavior.cs
│   │   │   ├── LoggingBehavior.cs
│   │   │   └── PerformanceBehavior.cs
│   │   └── DevWiki.Application.csproj
│   │
│   ├── DevWiki.Domain/
│   │   ├── Entities/
│   │   │   ├── User.cs
│   │   │   ├── Article.cs
│   │   │   ├── Category.cs
│   │   │   ├── Tag.cs
│   │   │   ├── ArticleRevision.cs
│   │   │   ├── ArticleTag.cs
│   │   │   └── AuditLog.cs
│   │   ├── ValueObjects/
│   │   │   ├── Email.cs
│   │   │   ├── Password.cs
│   │   │   └── Slug.cs
│   │   ├── Enums/
│   │   │   ├── UserRole.cs
│   │   │   └── ArticleStatus.cs
│   │   ├── Exceptions/
│   │   │   ├── DomainException.cs
│   │   │   ├── ArticleNotFoundException.cs
│   │   │   └── /* Other exceptions */
│   │   ├── Interfaces/
│   │   │   ├── IRepository.cs
│   │   │   ├── IUnitOfWork.cs
│   │   │   ├── IAuditLog.cs
│   │   │   └── /* Other interfaces */
│   │   └── DevWiki.Domain.csproj
│   │
│   ├── DevWiki.Infrastructure/
│   │   ├── Persistence/
│   │   │   ├── DevWikiDbContext.cs
│   │   │   ├── EntityConfigurations/
│   │   │   │   ├── UserConfiguration.cs
│   │   │   │   ├── ArticleConfiguration.cs
│   │   │   │   ├── CategoryConfiguration.cs
│   │   │   │   ├── TagConfiguration.cs
│   │   │   │   ├── ArticleRevisionConfiguration.cs
│   │   │   │   └── AuditLogConfiguration.cs
│   │   │   └── Migrations/
│   │   ├── Repositories/
│   │   │   ├── GenericRepository.cs
│   │   │   ├── ArticleRepository.cs
│   │   │   ├── UserRepository.cs
│   │   │   └── /* Other repositories */
│   │   ├── UnitOfWork/
│   │   │   └── UnitOfWork.cs
│   │   ├── Authentication/
│   │   │   ├── JwtTokenService.cs
│   │   │   └── PasswordHasher.cs
│   │   ├── Services/
│   │   │   ├── SearchService.cs
│   │   │   └── SlugGenerator.cs
│   │   ├── DependencyInjection.cs
│   │   └── DevWiki.Infrastructure.csproj
│   │
│   └── DevWiki.Tests/
│       ├── Unit/
│       │   ├── ApplicationTests/
│       │   │   ├── Commands/
│       │   │   └── Queries/
│       │   ├── DomainTests/
│       │   └── InfrastructureTests/
│       ├── Integration/
│       │   ├── ApiTests/
│       │   └── RepositoryTests/
│       └── DevWiki.Tests.csproj
│
├── docker-compose.yml
└── DevWiki.Backend.sln

```

### Frontend (React + Vite)

```
DevWiki.Frontend/
├── src/
│   ├── components/
│   │   ├── Auth/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── RegisterForm.tsx
│   │   │   └── ProtectedRoute.tsx
│   │   ├── Layout/
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   ├── MainLayout.tsx
│   │   │   └── Footer.tsx
│   │   ├── Articles/
│   │   │   ├── ArticleList.tsx
│   │   │   ├── ArticleCard.tsx
│   │   │   ├── ArticleDetail.tsx
│   │   │   ├── ArticleEditor.tsx
│   │   │   ├── MarkdownPreview.tsx
│   │   │   └── ArticleSearch.tsx
│   │   ├── Dashboard/
│   │   │   ├── Dashboard.tsx
│   │   │   ├── StatisticsCard.tsx
│   │   │   ├── RecentActivity.tsx
│   │   │   └── TopArticles.tsx
│   │   ├── Categories/
│   │   │   ├── CategoryList.tsx
│   │   │   ├── CategoryForm.tsx
│   │   │   └── CategorySelect.tsx
│   │   ├── Tags/
│   │   │   ├── TagList.tsx
│   │   │   ├── TagForm.tsx
│   │   │   └── TagSelect.tsx
│   │   ├── Users/
│   │   │   ├── UserManagement.tsx
│   │   │   ├── UserForm.tsx
│   │   │   └── UserTable.tsx
│   │   ├── Revisions/
│   │   │   ├── RevisionHistory.tsx
│   │   │   ├── RevisionComparison.tsx
│   │   │   └── RevisionRestore.tsx
│   │   ├── Common/
│   │   │   ├── Button.tsx
│   │   │   ├── Modal.tsx
│   │   │   ├── Pagination.tsx
│   │   │   ├── Spinner.tsx
│   │   │   ├── Toast.tsx
│   │   │   ├── ErrorBoundary.tsx
│   │   │   └── Breadcrumb.tsx
│   │   └── __tests__/
│   │
│   ├── pages/
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   ├── DashboardPage.tsx
│   │   ├── ArticlesPage.tsx
│   │   ├── ArticleDetailPage.tsx
│   │   ├── ArticleEditPage.tsx
│   │   ├── SearchPage.tsx
│   │   ├── CategoriesPage.tsx
│   │   ├── TagsPage.tsx
│   │   ├── UserManagementPage.tsx
│   │   ├── NotFoundPage.tsx
│   │   └── UnauthorizedPage.tsx
│   │
│   ├── services/
│   │   ├── api/
│   │   │   ├── client.ts
│   │   │   ├── articleApi.ts
│   │   │   ├── authApi.ts
│   │   │   ├── categoryApi.ts
│   │   │   ├── tagApi.ts
│   │   │   ├── searchApi.ts
│   │   │   ├── userApi.ts
│   │   │   ├── dashboardApi.ts
│   │   │   └── revisionApi.ts
│   │   ├── hooks/
│   │   │   ├── useAuth.ts
│   │   │   ├── useArticles.ts
│   │   │   ├── useSearch.ts
│   │   │   ├── useToast.ts
│   │   │   └── usePagination.ts
│   │   └── utils/
│   │       ├── formatters.ts
│   │       ├── validators.ts
│   │       ├── storage.ts
│   │       └── constants.ts
│   │
│   ├── store/
│   │   ├── authStore.ts
│   │   ├── uiStore.ts
│   │   └── /* React Context or Zustand state */
│   │
│   ├── styles/
│   │   ├── globals.css
│   │   ├── variables.css
│   │   └── /* Tailwind config via tailwind.config.js */
│   │
│   ├── types/
│   │   ├── index.ts
│   │   ├── api.ts
│   │   ├── entities.ts
│   │   └── forms.ts
│   │
│   ├── App.tsx
│   ├── main.tsx
│   └── __tests__/
│
├── public/
│   ├── favicon.ico
│   └── manifest.json
│
├── vite.config.ts
├── tailwind.config.js
├── tsconfig.json
├── package.json
└── .env.example
```

---

## Technology Stack

### Backend

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Runtime | .NET 9 | Application runtime |
| Web Framework | ASP.NET Core 9 | Web API framework |
| ORM | Entity Framework Core 9 | Database abstraction |
| Mediator | MediatR | CQRS pattern implementation |
| Validation | FluentValidation | Business rule validation |
| Mapping | AutoMapper | DTO mapping |
| Logging | Serilog | Structured logging |
| JWT | System.IdentityModel.Tokens.Jwt | Token-based auth |
| Testing | xUnit, Moq, Testcontainers | Unit & integration tests |
| CLI | Entity Framework CLI | Database migrations |

### Frontend

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Language | TypeScript | Type-safe JavaScript |
| Framework | React 18 | UI library |
| Build Tool | Vite | Fast bundler |
| Routing | React Router v6 | Client-side navigation |
| State | TanStack Query (React Query) | Server state management |
| Styling | Tailwind CSS | Utility-first CSS |
| Markdown | React Markdown | Render markdown content |
| Editor | EasyMDE | Markdown editor |
| HTTP | Axios | HTTP client |
| Forms | React Hook Form | Form management |
| Validation | Zod | Schema validation |
| Testing | Vitest, React Testing Library | Unit & component tests |

### Infrastructure

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Database | PostgreSQL 15 | Primary data store |
| Containerization | Docker | Application packaging |
| Orchestration | Docker Compose | Local development |
| CI/CD | GitHub Actions | Automated testing & deployment |
| Version Control | Git | Source control |

---

## Implementation Phases

### Phase 1: Foundation & Authentication (Completed)

**Objectives:**
- Set up project structure and dependencies
- Implement PostgreSQL database and migrations
- Create user authentication system
- Build basic API endpoints
- Frontend authentication pages

**Deliverables:**
1. Backend project setup with Clean Architecture
2. Database schema and migrations
3. User registration & login endpoints
4. JWT token generation and validation
5. Role-based authorization middleware
6. Login & Register pages
7. Protected route implementation
8. Local storage for JWT tokens

---

### Phase 2: Article & Category Management (Completed)

**Objectives:**
- Implement article CRUD operations
- Create category management
- Build article list and detail views
- Add basic article editor

**Deliverables:**
1. Article entity and repository
2. Category entity and repository
3. Commands for article operations
4. Queries for article retrieval
5. REST endpoints for articles
6. Article list page with pagination
7. Article detail page
8. Article editor
9. Category management

---

### Phase 3: Tags & Full-Text Search (Completed)

**Objectives:**
- Complete tag management
- Implement PostgreSQL full-text search
- Build search results page
- Add dashboard with metrics

**Deliverables:**
1. Tag management endpoints
2. Full-text search implementation
3. Search API endpoint
4. Search results page
5. Dashboard with statistics
6. Recent activity widget
7. Most viewed articles widget

---

### Phase 4: Revision History & Advanced Features (Completed)

**Objectives:**
- Implement revision tracking
- Add revision comparison
- Restore previous versions
- Implement markdown import feature

**Deliverables:**
1. Article revision system
2. Revision history endpoint
3. Revision restoration logic
4. Revision comparison page
5. Markdown file import
6. Bulk article creation
7. Audit logging
8. User management

---

### Phase 5: Deployment & Documentation (Completed)

**Objectives:**
- Docker containerization
- GitHub Actions CI/CD
- Security hardening
- Comprehensive documentation
- MCP integration
- Custom commands

**Deliverables:**
1. Dockerfile for backend
2. Dockerfile for frontend
3. docker-compose.yml
4. GitHub Actions workflows
5. Security audit report
6. Comprehensive API documentation
7. MCP configuration
8. Custom Claude commands

---

## Security & Authorization

### Authentication

- **JWT (JSON Web Tokens):**
  - Access token lifetime: 1 hour
  - Refresh token lifetime: 7 days
  - Stored in httpOnly cookies (frontend uses localStorage for demo)
  - Token validation on every request

- **Password Security:**
  - Minimum 12 characters
  - PBKDF2-SHA256 with salt
  - No password in logs
  - Password reset flow (future)

### Authorization

**Role-Based Access Control (RBAC):**

| Action | Admin | Editor | Viewer |
|--------|-------|--------|--------|
| View articles | ✓ | ✓ | ✓ |
| Create articles | ✓ | ✓ | ✗ |
| Edit own articles | ✓ | ✓ | ✗ |
| Edit any article | ✓ | ✗ | ✗ |
| Delete articles | ✓ | ✓ | ✗ |
| Manage categories | ✓ | ✗ | ✗ |
| Manage tags | ✓ | ✓ | ✗ |
| Manage users | ✓ | ✗ | ✗ |
| View audit logs | ✓ | ✗ | ✗ |

### Data Protection

- HTTPS only (enforce in production)
- CORS configuration
- SQL injection prevention via parameterized queries
- XSS protection via output encoding
- CSRF tokens for state-changing operations
- Rate limiting on auth endpoints
- Input validation and sanitization

### Audit Logging

- All user actions logged
- Changes tracked with before/after values
- Audit trail stored in AuditLogs table
- Admin access to audit logs
- No audit log deletion

---

## Performance Considerations

### Database

- **Indexing:**
  - Foreign keys (ArticleId, UserId, CategoryId)
  - Status filtering (Active/Archived)
  - Created/Updated timestamps
  - Full-text search indexes
  - Composite indexes for common queries

- **Query Optimization:**
  - Use projection to select only needed columns
  - Eager loading for related entities
  - Query result caching
  - Connection pooling (EF Core)

- **Pagination:**
  - Always paginate list results
  - Default page size: 20
  - Maximum page size: 100

### API

- **Caching:**
  - Response caching for GET endpoints
  - Cache-Control headers
  - ETag support for conditional requests
  - Invalidate cache on mutations

- **Compression:**
  - GZIP compression for responses
  - Minified JSON responses

- **Rate Limiting:**
  - 100 requests per minute per IP (auth endpoints: 5 per minute)
  - Sliding window algorithm

### Frontend

- **Bundle Optimization:**
  - Code splitting by route
  - Lazy loading of components
  - Minification and tree-shaking
  - Asset optimization (images, fonts)

- **Caching:**
  - Service worker for offline support
  - Local caching of user preferences
  - HTTP caching headers

- **Rendering:**
  - React.memo for expensive components
  - useMemo for computed values
  - Virtualization for large lists

---

## Deployment Strategy

### Local Development

```bash
# Backend
docker-compose up -d postgres
dotnet ef database update
dotnet run --project src/DevWiki.API

# Frontend
cd frontend
npm run dev
```

### Docker Production

**Backend Dockerfile:**
- Multi-stage build
- Minimal runtime image
- Non-root user
- Health checks

**Frontend Dockerfile:**
- Multi-stage build
- Nginx serving
- Static asset optimization
- CORS proxy (optional)

**docker-compose.yml:**
- PostgreSQL service
- Backend API service
- Frontend web service
- Volume management
- Network configuration

### CI/CD Pipeline (GitHub Actions)

**On Pull Request:**
- Run backend tests
- Run frontend tests
- Lint code
- Build Docker images

**On Merge to Main:**
- Build and tag Docker images
- Push to registry
- Deploy to staging
- Run smoke tests

**On Release Tag:**
- Build production images
- Push to registry
- Deploy to production

---

## Summary

This specification provides a comprehensive blueprint for DevWiki:

1. **Clear Architecture:** Clean Architecture with CQRS pattern ensures maintainability
2. **Secure by Design:** Authentication, authorization, and audit logging built-in
3. **Scalable Database:** PostgreSQL with proper indexing and relationships
4. **Well-Structured API:** RESTful endpoints with consistent response format
5. **Modern Frontend:** React with TypeScript for type safety and developer experience
6. **Phased Implementation:** Incremental delivery with clear milestones
7. **Production Ready:** Docker, CI/CD, and deployment strategy included

---

**Document Version:** 1.0  
**Last Updated:** 2026-06-05  
**Status:** Complete and Production-Ready
