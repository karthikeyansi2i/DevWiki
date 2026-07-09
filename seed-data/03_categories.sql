-- ============================================
-- 03_categories.sql
-- 10 categories
-- ============================================

INSERT INTO "Categories" ("CategoryId", "Name", "Slug", "Description", "CreatedAt", "UpdatedAt")
VALUES
(1, '.NET', 'dotnet', 'Articles about the .NET platform, runtime fundamentals, and base class libraries.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
(2, 'ASP.NET Core', 'aspnet-core', 'Web development with ASP.NET Core including MVC, APIs, middleware, and SignalR.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
(3, 'Entity Framework Core', 'entity-framework-core', 'ORM patterns, migrations, querying, and performance with EF Core.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
(4, 'React', 'react', 'Frontend development with React including hooks, state management, and testing.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
(5, 'TypeScript', 'typescript', 'TypeScript language features, generics, types, and integration patterns.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
(6, 'PostgreSQL', 'postgresql', 'PostgreSQL features including indexing, full-text search, window functions, and JSON.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
(7, 'SQL Performance', 'sql-performance', 'Query optimization, indexing strategies, execution plans, and database tuning.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
(8, 'System Design', 'system-design', 'Software architecture patterns including Clean Architecture, CQRS, and microservices.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
(9, 'Git', 'git', 'Version control workflows, branching strategies, and advanced Git commands.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z'),
(10, 'DevOps', 'devops', 'CI/CD pipelines, containerization, infrastructure as code, and deployment automation.', '2026-01-01T00:00:00Z', '2026-01-01T00:00:00Z');
