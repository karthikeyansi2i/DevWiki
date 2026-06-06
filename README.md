# DevWiki - Developer Knowledge Hub

A production-quality full-stack application for managing internal engineering documentation.

## Architecture Overview

DevWiki follows Clean Architecture principles with a clear separation of concerns:

- **Frontend**: React + TypeScript + Vite
- **Backend**: ASP.NET Core 9 Web API
- **Database**: PostgreSQL
- **Authentication**: JWT tokens
- **Patterns**: CQRS with MediatR, Repository Pattern, Unit of Work

## Project Structure

```
DevWiki/
├── backend/                 # ASP.NET Core solution
│   ├── DevWiki.Domain/     # Domain entities and business logic
│   ├── DevWiki.Application/ # CQRS commands/queries, validators, DTOs
│   ├── DevWiki.Infrastructure/ # Database, repositories, external services
│   ├── DevWiki.API/        # Web API controllers and configuration
│   └── DevWiki.Tests/      # Unit and integration tests
├── frontend/               # React + TypeScript + Vite
│   ├── src/
│   │   ├── components/    # Reusable React components
│   │   ├── pages/         # Page components
│   │   ├── services/      # API client services
│   │   ├── context/       # React Context for state
│   │   ├── types/         # TypeScript type definitions
│   │   └── App.tsx        # Main app component with routing
│   └── package.json       # Frontend dependencies
├── docker-compose.yml     # Local PostgreSQL setup
├── .mcp.json              # Model Context Protocol configuration
├── .claude/commands/      # Custom Claude Code commands
└── docs/
    ├── SPEC.md            # Complete specification document
    ├── API.md             # Comprehensive API documentation
    └── SECURITY-AUDIT.md  # Security assessment report
```

## Phase 1 - Authentication & Foundation (Complete)

### Features Implemented
- ✅ User registration and login
- ✅ JWT token-based authentication
- ✅ Role-based authorization (Admin, Editor, Viewer)
- ✅ Refresh token mechanism
- ✅ Secure password hashing (PBKDF2-SHA256)
- ✅ Database schema and migrations
- ✅ Frontend authentication pages (Login, Register)
- ✅ Protected routes

## Phase 2 - Article & Category Management (Complete)

### Features Implemented
- ✅ Article CRUD operations
- ✅ Category management
- ✅ Article list and detail views
- ✅ Markdown editor support
- ✅ Pagination and filtering
- ✅ Tag management and assignment

## Phase 3 - Tags & Full-Text Search (Complete)

### Features Implemented
- ✅ Tag management endpoints
- ✅ PostgreSQL full-text search
- ✅ Search results page with pagination
- ✅ Dashboard with statistics
- ✅ Recent activity tracking
- ✅ View count analytics

## Phase 4 - Revision History & Advanced Features (Complete)

### Features Implemented
- ✅ Article revision tracking
- ✅ Revision history UI
- ✅ Revision restoration
- ✅ Markdown file import
- ✅ Bulk article creation
- ✅ User management and listing
- ✅ Audit logging

## Phase 5 - Deployment & Documentation (Complete)

### Features Implemented
- ✅ Docker containerization (multi-stage builds)
- ✅ GitHub Actions CI/CD pipeline
- ✅ Comprehensive API documentation
- ✅ Security audit report
- ✅ MCP integration
- ✅ Custom Claude Code commands
- ✅ Unit tests (80%+ coverage)
- ✅ Performance optimization
- ✅ Security hardening

### Technology Stack

**Backend**
- ASP.NET Core 9
- Entity Framework Core 9
- PostgreSQL
- MediatR (CQRS)
- FluentValidation
- Serilog
- JWT Authentication

**Frontend**
- React 18
- TypeScript
- Vite
- React Router
- TanStack Query (React Query)
- Tailwind CSS
- Axios

## Getting Started

### Prerequisites
- .NET 9 SDK
- Node.js 18+
- Docker & Docker Compose
- PostgreSQL 15 (via Docker)

### Backend Setup

1. **Start PostgreSQL**
```bash
docker-compose up -d postgres
```

2. **Update Database Configuration**
Edit `backend/DevWiki.API/appsettings.json` if needed:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=devwiki;Username=devwiki;Password=devwiki123"
  }
}
```

3. **Run Migrations**
```bash
cd backend
dotnet ef database update --project DevWiki.Infrastructure --startup-project DevWiki.API
```

4. **Start API Server**
```bash
cd backend
dotnet run --project DevWiki.API
```

API will be available at: `https://localhost:7000/api`

### Frontend Setup

1. **Install Dependencies**
```bash
cd frontend
npm install
```

2. **Configure API URL** (optional)
Create `.env.local`:
```
VITE_API_URL=https://localhost:7000/api
```

3. **Start Development Server**
```bash
npm run dev
```

Frontend will be available at: `http://localhost:5173`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Create new user
- `POST /api/auth/login` - Authenticate and get tokens
- `POST /api/auth/refresh` - Refresh access token

### Response Format
All responses follow this format:
```json
{
  "success": true,
  "data": { /* endpoint-specific data */ },
  "timestamp": "2026-06-05T10:30:00Z"
}
```

Errors:
```json
{
  "success": false,
  "errors": [
    {
      "code": "ERROR_CODE",
      "message": "Human-readable message",
      "field": "fieldName"
    }
  ],
  "timestamp": "2026-06-05T10:30:00Z"
}
```

## Testing the Phase 1

### Register a New User
```bash
curl -X POST https://localhost:7000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePassword123!",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

### Login
```bash
curl -X POST https://localhost:7000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePassword123!"
  }'
```

### Refresh Token
```bash
curl -X POST https://localhost:7000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{
    "refreshToken": "<refresh_token>"
  }'
```

## Documentation

- **[SPEC.md](./docs/SPEC.md)** - Complete technical specification (5 phases)
- **[API.md](./docs/API.md)** - Comprehensive API endpoint documentation
- **[SECURITY-AUDIT.md](./docs/SECURITY-AUDIT.md)** - Security assessment and compliance report

## Custom Commands

Access these commands with `/` in Claude Code:

- `/project-health` - Comprehensive health check of the entire project
- `/test-suite` - Run all tests with coverage reporting
- `/deploy-stack` - Build and deploy the complete application stack

## MCP Integration

The project includes Model Context Protocol configuration (`.mcp.json`) with 6 integrated servers:
- **bash** - Shell command execution
- **codebase** - Code structure analysis
- **git** - Version control operations
- **dotnet** - .NET build and testing
- **npm** - Node package management
- **docker** - Container management

## Development Guidelines

### Backend
- Use MediatR for all business operations (Commands/Queries)
- Validate input with FluentValidation
- Implement proper error handling
- Log operations with Serilog
- Write unit tests for services
- Use async/await throughout

### Frontend
- Use TypeScript for type safety
- Create reusable components
- Use TanStack Query for server state
- Implement proper error boundaries
- Follow accessibility standards
- Test components with React Testing Library

## Security

- Passwords are hashed with PBKDF2-SHA256
- JWT tokens expire in 1 hour
- Refresh tokens allow extended sessions
- CORS is configured for development
- SQL injection prevented via parameterized queries
- HTTPS enforced in production

## Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL is running
docker ps

# View logs
docker logs devwiki-postgres

# Recreate database
docker-compose down
docker-compose up -d postgres
```

### Frontend Connection Issues
- Ensure backend is running on correct port
- Check CORS configuration in Program.cs
- Verify API URL in .env or appsettings

## License

Internal use only.

## Project Deliverables

✅ **Complete**: 
- Working full-stack application with 14+ API endpoints
- 3+ related database tables (Users, Articles, Categories, Tags, ArticleRevisions, AuditLogs)
- 5+ React components across multiple pages
- 21+ unit tests with 80%+ code coverage
- CI/CD pipeline with security scanning
- Comprehensive documentation
- MCP integration
- Custom Claude Code commands
- Clean git history with layer-by-layer development

## References

- [docs/SPEC.md](./docs/SPEC.md) - Complete technical specification
- [docs/API.md](./docs/API.md) - API endpoint documentation
- [docs/SECURITY-AUDIT.md](./docs/SECURITY-AUDIT.md) - Security report
- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core)
- [React Documentation](https://react.dev)
- [Entity Framework Core](https://docs.microsoft.com/ef/core)
- [MediatR](https://github.com/jbogard/MediatR)
