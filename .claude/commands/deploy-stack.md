# /deploy-stack

**Purpose:** Build and deploy the complete DevWiki application stack

## Usage

```
/deploy-stack [environment] [options]
```

## Environments

| Environment | Purpose | Database | API Port | Frontend Port |
|---|---|---|---|---|
| `development` | Local development | SQLite/Local PostgreSQL | 7000 | 3000 |
| `staging` | Pre-production testing | Staging PostgreSQL | 7001 | 3001 |
| `production` | Live deployment | Production PostgreSQL | 443 | 443 |

## Options

| Option | Description |
|--------|-------------|
| `--rebuild` | Force rebuild all images (don't use cache) |
| `--clean` | Remove existing containers before deploy |
| `--no-test` | Skip test execution before deploy |
| `--migrate` | Run database migrations |
| `--seed` | Seed database with sample data |
| `--logs` | Follow container logs after deployment |
| `--health-check` | Perform health checks before marking success |

## Examples

```bash
# Deploy to development with fresh build
/deploy-stack development --rebuild --migrate

# Deploy to staging with health checks
/deploy-stack staging --health-check --logs

# Production deploy (requires approval)
/deploy-stack production --migrate --health-check

# Quick local development setup
/deploy-stack development
```

## Deployment Process

### Pre-Deployment (1-2 minutes)

```
1. Code Validation
   ├─ Git status check (clean working directory required)
   ├─ Branch verification (must be on approved branch)
   └─ Commit message validation

2. Tests & Quality Gates
   ├─ Run full test suite (must pass)
   ├─ Check code coverage (must be ≥80%)
   ├─ Lint checks (no errors allowed)
   └─ Security scan (SAST analysis)
```

### Build Phase (3-5 minutes)

```
3. Build Backend
   ├─ Restore NuGet packages
   ├─ Compile C# code
   ├─ Run integration tests
   └─ Generate Docker image (devwiki-api:latest)

4. Build Frontend
   ├─ Install npm dependencies
   ├─ Compile TypeScript/React
   ├─ Run frontend tests
   ├─ Generate optimized build
   └─ Generate Docker image (devwiki-web:latest)

5. Build Infrastructure
   ├─ Create PostgreSQL image
   ├─ Configure Nginx reverse proxy
   └─ Prepare volume mounts
```

### Deployment Phase (1-2 minutes)

```
6. Stop Previous Services (if running)
   ├─ Graceful shutdown of containers
   ├─ Preserve data volumes
   └─ Wait for connections to close

7. Start New Stack
   ├─ PostgreSQL database service
   ├─ .NET API backend service
   ├─ React frontend service (Nginx)
   └─ Health checks enabled

8. Database Migration
   ├─ Run pending migrations
   ├─ Seed initial data (if applicable)
   └─ Verify schema integrity
```

### Post-Deployment (1 minute)

```
9. Health Verification
   ├─ Backend health endpoint (GET /health)
   ├─ Frontend home page (HTTP 200)
   ├─ Database connectivity
   ├─ Authentication service
   └─ API endpoints responding

10. Smoke Tests
    ├─ User registration flow
    ├─ Article listing
    ├─ Search functionality
    └─ Dashboard access
```

## Example Output

```
════════════════════════════════════════════════════════════
DEVWIKI DEPLOYMENT STACK
════════════════════════════════════════════════════════════

Environment: development
Branch: develop
Deployment ID: deploy-20260606-143022

[1/10] Code Validation
  ✓ Working directory clean
  ✓ Branch verification passed
  ✓ 3 commits ready to deploy

[2/10] Running Tests & Quality Gates
  ✓ Backend tests: 90 passed (14.2s)
  ✓ Frontend tests: 54 passed (4.1s)
  ✓ Code coverage: 82.4% (exceeds 80%)
  ✓ Lint checks: 0 errors

[3/10] Building Backend
  ⟳ Restoring packages...
  ✓ NuGet packages restored (2.3s)
  ⟳ Compiling...
  ✓ Build successful (18.4s)
  ✓ Docker image: devwiki-api:latest

[4/10] Building Frontend
  ⟳ Installing dependencies...
  ✓ npm packages installed (5.2s)
  ⟳ Building...
  ✓ React build successful (12.1s)
  ✓ Docker image: devwiki-web:latest

[5/10] Infrastructure Ready
  ✓ Docker images created
  ✓ Volumes prepared
  ✓ Network configured

[6/10] Stopping Previous Services
  ✓ Previous containers stopped (graceful)
  ✓ Waiting for cleanup...

[7/10] Starting New Stack
  ⟳ Starting PostgreSQL...
  ✓ PostgreSQL running (5432)
  ⟳ Starting Backend API...
  ✓ Backend API running (7000)
  ⟳ Starting Frontend...
  ✓ Frontend running (3000)

[8/10] Database Migration
  ✓ 5 pending migrations applied
  ✓ Schema verified
  ✓ Seed data loaded

[9/10] Health Verification
  ✓ Backend /health: 200 OK (12ms)
  ✓ Frontend /: 200 OK (8ms)
  ✓ Database connectivity: OK
  ✓ Auth service: OK
  ✓ All endpoints responding

[10/10] Smoke Tests
  ✓ User registration: PASS
  ✓ Article listing: PASS
  ✓ Search: PASS
  ✓ Dashboard: PASS

════════════════════════════════════════════════════════════
✓ DEPLOYMENT SUCCESSFUL
════════════════════════════════════════════════════════════

Application URLs:
  Frontend:  http://localhost:3000
  API:       http://localhost:7000
  Database:  localhost:5432

Deployment completed in 4m 23s
```

## Rollback

If deployment fails or issues occur:

```bash
# Rollback to previous version
/deploy-stack <environment> --rollback

# View deployment history
/deploy-stack --history

# Check current status
/deploy-stack --status
```

## Monitoring

After successful deployment:

```bash
# View logs
docker-compose logs -f

# Check container status
docker-compose ps

# View application metrics
/monitor-stack
```

## Related Commands

- `/project-health` - Pre-deployment health check
- `/test-suite` - Run tests before deployment
- `/docker-up` - Start containers manually
- `/docker-down` - Stop containers
- `/monitor-stack` - View application metrics

## Deployment Checklist

- [ ] Code reviewed and approved
- [ ] All tests passing (80%+ coverage)
- [ ] Branch protection rules satisfied
- [ ] No sensitive data in commits
- [ ] Environment variables configured
- [ ] Database backups created (production only)
- [ ] Deployment approved by maintainer
- [ ] Rollback plan reviewed
