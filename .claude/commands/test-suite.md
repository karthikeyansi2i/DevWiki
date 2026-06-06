# /test-suite

**Purpose:** Run comprehensive test suite with coverage reporting

## Usage

```
/test-suite [options]
```

## Options

| Option | Description |
|--------|-------------|
| `--unit` | Run only unit tests (default: all) |
| `--integration` | Run only integration tests |
| `--coverage` | Include code coverage report |
| `--watch` | Run in watch mode for development |
| `--verbose` | Detailed output with assertion details |
| `--quick` | Skip slow tests for faster feedback |

## Examples

```bash
# Run all tests with coverage
/test-suite --coverage

# Run tests in watch mode
/test-suite --watch

# Unit tests only with verbose output
/test-suite --unit --verbose

# Quick test run (skip integration)
/test-suite --quick
```

## What It Tests

### Backend Tests (xUnit.net)

- **AuthenticationTests**: JWT generation, token validation, password hashing
- **RepositoryTests**: CRUD operations, querying, filtering
- **ValidationTests**: Input validation, business rule enforcement
- **IntegrationTests**: Database interactions, full API flows

### Frontend Tests (Vitest)

- **ComponentTests**: React component rendering and interactions
- **HookTests**: Custom React hooks behavior
- **UtilityTests**: Helper functions and service logic
- **E2E Tests** (optional): Full user workflows

## Coverage Requirements

- **Minimum Target**: 80% code coverage
- **Critical Paths**: 100% coverage required (auth, data access)
- **Generated Code**: Excluded from coverage (migrations, scaffolds)

## Example Output

```
════════════════════════════════════════════════════════════
DEVWIKI TEST SUITE RESULTS
════════════════════════════════════════════════════════════

Backend Tests (xUnit)
  ✓ Authentication Tests         (24 tests, 2.3s)
  ✓ Repository Tests              (38 tests, 5.1s)
  ✓ Validation Tests              (16 tests, 1.2s)
  ✓ Service Tests                 (12 tests, 3.4s)
  ─────────────────────────────────────────────────────────
  Total: 90 passed, 0 failed, 0 skipped

Code Coverage
  Statements   : 82.4% (1,205/1,463)
  Branches     : 78.9% (342/433)
  Functions    : 85.2% (156/183)
  Lines        : 83.1% (1,198/1,441)
  ─────────────────────────────────────────────────────────
  Status: ✓ PASS (exceeds 80% minimum)

Frontend Tests (Vitest)
  ✓ Component Tests               (34 tests, 1.8s)
  ✓ Hook Tests                    (12 tests, 0.9s)
  ✓ Utility Tests                 (8 tests, 0.4s)
  ─────────────────────────────────────────────────────────
  Total: 54 passed, 0 failed

════════════════════════════════════════════════════════════
Overall Result: ✓ ALL TESTS PASSED (144 tests in 14.2s)
════════════════════════════════════════════════════════════
```

## Continuous Integration

This command is automatically run on:
- Pull requests to `main` branch
- Commits to `develop` branch
- Release builds

## Related Commands

- `/project-health` - Overall system health check
- `/build-all` - Compile entire application
- `/coverage-report` - Generate detailed coverage HTML
