# /project-health

**Purpose:** Comprehensive health check of the entire DevWiki project

## Usage

```
/project-health
```

## What It Does

Performs a complete diagnostic check across:
- **Git Status**: Checks for uncommitted changes, branch status, and recent commits
- **.NET Backend**: Verifies project can build without errors
- **React Frontend**: Checks dependencies and build configuration
- **Database**: Verifies connection string and migration status
- **Docker**: Validates docker-compose configuration
- **Dependencies**: Scans for outdated or vulnerable packages
- **Code Quality**: Checks for linting issues (frontend)

## Example Output

```
✓ Git Status: On main branch, 3 commits ahead of origin
✓ Backend Build: Successful (127 projects compiled)
✓ Frontend Dependencies: All up to date
✓ Docker Compose: Valid configuration
✗ Database: Connection string missing JWT__SECRETKEY
! Frontend: 2 vulnerabilities in dependencies
```

## When to Use

- Before starting development session
- Before submitting changes
- When debugging environment issues
- As part of CI/CD validation
- After cloning the repository

## Related Commands

- `/test-suite` - Run all tests
- `/build-all` - Build entire stack
- `/docker-up` - Start containers
