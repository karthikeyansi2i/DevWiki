-- ============================================
-- 07_articles_efcore.sql
-- 7 articles in the Entity Framework Core category (CategoryId = 3)
-- ============================================

INSERT INTO "Articles" ("ArticleId", "Title", "Slug", "Summary", "Content", "AuthorId", "CategoryId", "Status", "ViewCount", "CreatedAt", "UpdatedAt")
VALUES
(
  'a0000001-0000-0000-0000-000000000011',
  'Entity Framework Core Getting Started',
  'entity-framework-core-getting-started',
  'A comprehensive introduction to Entity Framework Core covering setup, DbContext, migrations, and basic CRUD operations for developers new to the ORM.',
  $content$
## Introduction

Entity Framework Core (EF Core) is a lightweight, extensible, open-source object-relational mapper (ORM) for .NET applications. It bridges the gap between relational databases and object-oriented code by allowing developers to work with database data using strongly typed .NET objects, eliminating the need to write raw SQL for most operations.

## Setting Up EF Core

To get started, install the required NuGet packages:

```bash
dotnet add package Microsoft.EntityFrameworkCore
dotnet add package Microsoft.EntityFrameworkCore.SqlServer
dotnet add package Microsoft.EntityFrameworkCore.Tools
```

For PostgreSQL, substitute the provider package accordingly:

```bash
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
```

## Defining the DbContext

The `DbContext` class is the primary gateway for database interactions. It manages entity sets, tracks changes, and coordinates queries:

```csharp
public class BlogDbContext : DbContext
{
    public BlogDbContext(DbContextOptions<BlogDbContext> options)
        : base(options)
    {
    }

    public DbSet<Blog> Blogs => Set<Blog>();
    public DbSet<Post> Posts => Set<Post>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Blog>(entity =>
        {
            entity.ToTable("Blogs");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Name).HasMaxLength(200).IsRequired();
        });
    }
}
```

## Creating Entities

Entities are simple Plain Old CLR Objects (POCOs) that map to database tables:

```csharp
public class Blog
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime CreatedAt { get; set; }
    public ICollection<Post> Posts { get; set; } = new List<Post>();
}

public class Post
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public int BlogId { get; set; }
    public Blog Blog { get; set; } = null!;
}
```

## Configuration in Program.cs

Register the DbContext in the dependency injection container:

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<BlogDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();
```

## Basic CRUD Operations

### Create

```csharp
public async Task<int> CreateBlogAsync(Blog blog)
{
    _context.Blogs.Add(blog);
    return await _context.SaveChangesAsync();
}
```

### Read

```csharp
public async Task<List<Blog>> GetAllBlogsAsync()
{
    return await _context.Blogs
        .Include(b => b.Posts)
        .ToListAsync();
}

public async Task<Blog?> GetBlogByIdAsync(int id)
{
    return await _context.Blogs.FindAsync(id);
}
```

### Update

```csharp
public async Task UpdateBlogAsync(Blog blog)
{
    _context.Blogs.Update(blog);
    await _context.SaveChangesAsync();
}
```

### Delete

```csharp
public async Task DeleteBlogAsync(int id)
{
    var blog = await _context.Blogs.FindAsync(id);
    if (blog is not null)
    {
        _context.Blogs.Remove(blog);
        await _context.SaveChangesAsync();
    }
}
```

## Entity States

EF Core tracks entities through five states:

| State | Description |
|---|---|
| `Detached` | Entity is not being tracked |
| `Unchanged` | Entity is tracked and unchanged from the database |
| `Added` | Entity will be inserted on `SaveChanges` |
| `Modified` | Entity will be updated on `SaveChanges` |
| `Deleted` | Entity will be deleted on `SaveChanges` |

## Running Migrations

Create and apply your initial migration:

```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

This generates a `Migrations` folder with timestamped migration files containing both `Up` and `Down` methods for version-controlled schema changes.

## References

- [EF Core Documentation](https://docs.microsoft.com/en-us/ef/core/)
- [Getting Started with EF Core](https://docs.microsoft.com/en-us/ef/core/get-started/overview/first-app)
- [Entity Framework Core in Action Book](https://www.manning.com/books/entity-framework-core-in-action)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  3,
  1,
  9842,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000012',
  'Advanced Querying with EF Core',
  'advanced-querying-with-ef-core',
  'Master advanced querying techniques in Entity Framework Core including LINQ expressions, raw SQL, compiled queries, and projection strategies for complex scenarios.',
  $content$
## Introduction

Entity Framework Core provides a rich set of querying capabilities that go far beyond simple CRUD operations. This article explores advanced techniques for building efficient, maintainable queries that handle complex scenarios without sacrificing performance.

## LINQ Query Basics

EF Core translates LINQ expressions into optimized SQL. Understanding how LINQ methods map to SQL is essential:

```csharp
var recentPosts = await _context.Posts
    .Where(p => p.PublishedAt > DateTime.UtcNow.AddDays(-7))
    .OrderByDescending(p => p.PublishedAt)
    .Take(10)
    .Select(p => new { p.Title, p.Blog.Name, p.PublishedAt })
    .ToListAsync();
```

This generates a parameterized SQL query that only fetches the required columns.

## Projections and Select

Use `Select` to shape query results and avoid over-fetching:

```csharp
var blogSummaries = await _context.Blogs
    .Where(b => b.IsActive)
    .Select(b => new BlogSummaryDto
    {
        Id = b.Id,
        Name = b.Name,
        PostCount = b.Posts.Count,
        LatestPostTitle = b.Posts
            .OrderByDescending(p => p.PublishedAt)
            .Select(p => p.Title)
            .FirstOrDefault()
    })
    .ToListAsync();
```

This translates to a single SQL query with a subquery for the latest post.

## Raw SQL Queries

When LINQ cannot express the required operation, use raw SQL:

```csharp
var blogs = await _context.Blogs
    .FromSqlRaw("SELECT * FROM \"Blogs\" WHERE \"Rating\" > {0}", minRating)
    .Include(b => b.Posts)
    .ToListAsync();
```

For non-entity queries, use `SqlQuery`:

```csharp
var results = await _context.Database
    .SqlQuery<int>($"SELECT COUNT(*) FROM \"Posts\" WHERE \"BlogId\" = {blogId}")
    .FirstOrDefaultAsync();
```

## Compiled Queries

Compiled queries cache the query plan for repeated execution:

```csharp
private static readonly Func<BlogDbContext, string, IAsyncEnumerable<Blog>> GetBlogsByName =
    EF.CompileAsyncQuery((BlogDbContext context, string name) =>
        context.Blogs.Where(b => b.Name.Contains(name)).OrderBy(b => b.Name));
```

Usage:

```csharp
await foreach (var blog in GetBlogsByName(_context, "NET"))
{
    Console.WriteLine(blog.Name);
}
```

Compiled queries are ideal for hot paths where the same query structure executes frequently with different parameters.

## Explicit Loading

When you need to load related data after the initial query:

```csharp
var blog = await _context.Blogs.FindAsync(blogId);

await _context.Entry(blog)
    .Collection(b => b.Posts)
    .Query()
    .Where(p => p.IsPublished)
    .OrderByDescending(p => p.PublishedAt)
    .LoadAsync();
```

## Query Filters at Query Time

Apply conditional filters dynamically:

```csharp
public IQueryable<Post> GetFilteredPosts(bool includeDrafts)
{
    var query = _context.Posts.AsQueryable();

    if (!includeDrafts)
    {
        query = query.Where(p => p.Status == PostStatus.Published);
    }

    return query.OrderByDescending(p => p.PublishedAt);
}
```

## Query Splitting

For queries with multiple related collections, use split queries to avoid Cartesian explosion:

```csharp
var blogs = await _context.Blogs
    .Include(b => b.Posts)
    .Include(b => b.Tags)
    .AsSplitQuery()
    .ToListAsync();
```

## Performance Comparison

| Technique | Use Case | Performance |
|---|---|---|
| Eager Loading (Include) | Small to medium related data | Good for simple graphs |
| Explicit Loading | Conditional related data | Moderate, extra round trips |
| Lazy Loading | On-demand navigation | Poor for collections |
| Split Queries | Multiple collections | Avoids Cartesian explosion |
| Projection (Select) | Specific columns only | Best for read-only scenarios |

## References

- [EF Core Querying Documentation](https://docs.microsoft.com/en-us/ef/core/querying/)
- [Performance Considerations for EF Core](https://docs.microsoft.com/en-us/ef/core/performance/)
- [Compiled Queries in EF Core](https://docs.microsoft.com/en-us/ef/core/performance/compiled-queries)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  3,
  1,
  7341,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000013',
  'EF Core Migrations Deep Dive',
  'ef-core-migrations-deep-dive',
  'An in-depth exploration of Entity Framework Core migrations covering creation, customization, rollbacks, and production deployment strategies for evolving database schemas.',
  $content$
## Introduction

Migrations are the mechanism by which EF Core applies incremental schema changes to a database as your model evolves. They enable version-controlled, repeatable database deployments that align with application code changes.

## Creating Migrations

The migration workflow begins with model changes:

```bash
dotnet ef migrations add AddBlogRatingColumn
```

This generates three files in the `Migrations` directory:

| File | Purpose |
|---|---|
| `YYYYMMDDHHMMSS_AddBlogRatingColumn.cs` | Contains `Up` and `Down` methods |
| `YYYYMMDDHHMMSS_AddBlogRatingColumn.Designer.cs` | Metadata for the model snapshot |
| `BlogDbContextModelSnapshot.cs` | Snapshot of the current model state |

## Inside a Migration File

Each migration contains the instructions for applying and reverting changes:

```csharp
public partial class AddBlogRatingColumn : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<int>(
            name: "Rating",
            table: "Blogs",
            type: "integer",
            nullable: false,
            defaultValue: 0);

        migrationBuilder.CreateIndex(
            name: "IX_Blogs_Rating",
            table: "Blogs",
            column: "Rating");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "IX_Blogs_Rating",
            table: "Blogs");

        migrationBuilder.DropColumn(
            name: "Rating",
            table: "Blogs");
    }
}
```

## Applying Migrations

Use the database update command to apply pending migrations:

```bash
dotnet ef database update
```

You can also target a specific migration:

```bash
dotnet ef database update AddBlogRatingColumn
```

## Generating SQL Scripts

For production deployments, generate SQL scripts rather than applying migrations directly:

```bash
dotnet ef migrations script -o script.sql
```

To generate a script between two specific migrations:

```bash
dotnet ef migrations script InitialCreate AddBlogRatingColumn -o upgrade.sql
```

This produces a single SQL file that can be reviewed and executed by a DBA.

## Rolling Back Migrations

Remove the last migration from the project:

```bash
dotnet ef migrations remove
```

To revert the database to a previous migration:

```bash
dotnet ef database update PreviousMigrationName
```

## Custom Migration Operations

Add custom SQL within migrations for operations EF Core does not support natively:

```csharp
protected override void Up(MigrationBuilder migrationBuilder)
{
    migrationBuilder.Sql("""
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW."UpdatedAt" = NOW();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
        """);

    migrationBuilder.Sql("""
        CREATE TRIGGER trigger_blogs_updated_at
            BEFORE UPDATE ON "Blogs"
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
        """);
}
```

## Migration Bundles

For production environments without the .NET SDK, create a self-contained migration bundle:

```bash
dotnet ef migrations bundle --self-contained -r win-x64
```

This produces a single executable that applies migrations when run.

## Best Practices

- **Never edit migration files after they have been applied to a shared database**
- Use `migrations list` to check pending migrations before deployment
- Always review generated migrations before applying
- Keep migrations small and focused on a single logical change
- Use meaningful migration names that describe the change
- Test migrations against a staging database before production
- Consider using `EnsureCreated` for prototyping, but never in production

## References

- [EF Core Migrations Documentation](https://docs.microsoft.com/en-us/ef/core/managing-schemas/migrations/)
- [Custom Migrations Operations](https://docs.microsoft.com/en-us/ef/core/managing-schemas/migrations/operations)
- [Migration Bundles](https://docs.microsoft.com/en-us/ef/core/managing-schemas/migrations/bundles)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  3,
  1,
  5621,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000014',
  'Performance Tuning EF Core Queries',
  'performance-tuning-ef-core-queries',
  'Learn how to diagnose and resolve performance bottlenecks in Entity Framework Core applications using query analysis, batching, indexing strategies, and best practices.',
  $content$
## Introduction

Performance is a critical concern for any data-driven application. EF Core is often blamed for slow queries, but in most cases the issue is incorrect usage rather than the framework itself. This article covers proven techniques for identifying and resolving performance bottlenecks.

## Identifying Slow Queries

Before optimizing, you must measure. Enable EF Core logging to capture query execution times:

```csharp
optionsBuilder.LogTo(Console.WriteLine, LogLevel.Information)
    .EnableSensitiveDataLogging()
    .EnableDetailedErrors();
```

Better yet, use the `SimplifyLogger` extension to capture only slow queries:

```csharp
protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
{
    optionsBuilder.LogTo(
        logMessage => AddToSlowQueryLog(logMessage),
        events: new[] { CoreEventId.QueryExecutionPlanned },
        minimumLevel: LogLevel.Warning);
}
```

## The N+1 Query Problem

The most common performance pitfall is the N+1 query problem, where lazy loading causes separate queries for each related entity:

```csharp
// BAD: N+1 queries
var blogs = await _context.Blogs.ToListAsync();
foreach (var blog in blogs)
{
    Console.WriteLine($"{blog.Name}: {blog.Posts.Count} posts");
}
```

Fix this with eager loading:

```csharp
// GOOD: Single query with JOIN
var blogs = await _context.Blogs
    .Include(b => b.Posts)
    .ToListAsync();
```

## AsNoTracking for Read-Only Queries

For queries that do not require entity tracking, disable the change tracker:

```csharp
var posts = await _context.Posts
    .AsNoTracking()
    .Where(p => p.IsPublished)
    .OrderByDescending(p => p.PublishedAt)
    .ToListAsync();
```

This eliminates the overhead of snapshot creation and change detection.

## Batching SaveChanges

When performing bulk operations, batch multiple changes in a single call:

```csharp
public async Task BulkInsertPostsAsync(List<Post> posts)
{
    foreach (var batch in posts.Chunk(100))
    {
        _context.Posts.AddRange(batch);
        await _context.SaveChangesAsync();
    }
}
```

EF Core automatically batches INSERT, UPDATE, and DELETE statements within a single `SaveChanges` call.

## Indexing Strategy

Ensure your database indexes align with your query patterns:

```sql
CREATE INDEX IX_Posts_PublishedAt ON "Posts" ("PublishedAt" DESC);
CREATE INDEX IX_Posts_AuthorId_Status ON "Posts" ("AuthorId", "Status");
```

Use EF Core migration tools to manage indexes declaratively:

```csharp
entity.HasIndex(p => p.PublishedAt)
    .HasDatabaseName("IX_Posts_PublishedAt")
    .IsDescending();

entity.HasIndex(p => new { p.AuthorId, p.Status })
    .HasDatabaseName("IX_Posts_AuthorId_Status");
```

## Query Plan Analysis

Examine the generated SQL to identify missing indexes or inefficient joins:

```sql
EXPLAIN ANALYZE
SELECT p."Title", p."PublishedAt", b."Name"
FROM "Posts" p
INNER JOIN "Blogs" b ON p."BlogId" = b."Id"
WHERE p."IsPublished" = TRUE
ORDER BY p."PublishedAt" DESC
LIMIT 20;
```

Look for sequential scans on large tables and add indexes accordingly.

## Performance Pitfalls Comparison

| Pitfall | Impact | Solution |
|---|---|---|
| N+1 queries | Exponential queries | Use `Include` or `Select` |
| Tracking overhead | Memory + CPU | Use `AsNoTracking` |
| Unbounded result sets | Memory pressure | Use pagination (`Skip`/`Take`) |
| Cartesian explosion | Massive result sets | Use `AsSplitQuery` |
| Client-side evaluation | Unoptimized queries | Check for client-side evaluation warnings |

## References

- [EF Core Performance Overview](https://docs.microsoft.com/en-us/ef/core/performance/)
- [Advanced Performance Topics](https://docs.microsoft.com/en-us/ef/core/performance/advanced-performance-topics)
- [Efficient Querying in EF Core](https://docs.microsoft.com/en-us/ef/core/performance/efficient-querying)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  3,
  1,
  8912,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000015',
  'Entity Framework Core Relationships',
  'entity-framework-core-relationships',
  'A comprehensive guide to configuring and working with entity relationships in EF Core, covering one-to-one, one-to-many, and many-to-many mappings.',
  $content$
## Introduction

Entity relationships are the backbone of any relational database. EF Core provides a flexible convention-based and fluent API system for configuring relationships between entities. Understanding how to model these relationships correctly is essential for building maintainable and performant data access layers.

## Relationship Types

There are three primary relationship types in EF Core:

| Relationship | Example | Database Mapping |
|---|---|---|
| One-to-One | User ↔ Profile | Foreign key with unique constraint |
| One-to-Many | Blog ↔ Posts | Foreign key column on child table |
| Many-to-Many | Post ↔ Tags | Junction table |

## One-to-Many Relationships

The most common relationship type. Configured by convention when a navigation property contains a collection:

```csharp
public class Blog
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ICollection<Post> Posts { get; set; } = new List<Post>();
}

public class Post
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int BlogId { get; set; }
    public Blog Blog { get; set; } = null!;
}
```

Fluent API configuration:

```csharp
modelBuilder.Entity<Post>()
    .HasOne(p => p.Blog)
    .WithMany(b => b.Posts)
    .HasForeignKey(p => p.BlogId)
    .OnDelete(DeleteBehavior.Cascade);
```

## One-to-One Relationships

Useful for splitting large entities or modeling optional data:

```csharp
public class User
{
    public int Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public UserProfile Profile { get; set; } = null!;
}

public class UserProfile
{
    public int Id { get; set; }
    public string? AvatarUrl { get; set; }
    public string? Bio { get; set; }
    public int UserId { get; set; }
    public User User { get; set; } = null!;
}
```

```csharp
modelBuilder.Entity<User>()
    .HasOne(u => u.Profile)
    .WithOne(p => p.User)
    .HasForeignKey<UserProfile>(p => p.UserId);
```

## Many-to-Many Relationships

EF Core 5 introduced implicit many-to-many joins without requiring a join entity class:

```csharp
public class Post
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public ICollection<Tag> Tags { get; set; } = new List<Tag>();
}

public class Tag
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ICollection<Post> Posts { get; set; } = new List<Post>();
}
```

Configure the join table name and keys:

```csharp
modelBuilder.Entity<Post>()
    .HasMany(p => p.Tags)
    .WithMany(t => t.Posts)
    .UsingEntity(j => j.ToTable("PostTags"));
```

For scenarios requiring additional payload on the join, create an explicit join entity:

```csharp
public class PostTag
{
    public int PostId { get; set; }
    public Post Post { get; set; } = null!;
    public int TagId { get; set; }
    public Tag Tag { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
}

modelBuilder.Entity<PostTag>()
    .HasKey(pt => new { pt.PostId, pt.TagId });

modelBuilder.Entity<PostTag>()
    .HasOne(pt => pt.Post)
    .WithMany(p => p.PostTags)
    .HasForeignKey(pt => pt.PostId);

modelBuilder.Entity<PostTag>()
    .HasOne(pt => pt.Tag)
    .WithMany(t => t.PostTags)
    .HasForeignKey(pt => pt.TagId);
```

## Delete Behaviors

| Behavior | Description | Use Case |
|---|---|---|
| `Cascade` | Deletes related entities | Owner-child relationships |
| `Restrict` | Prevents deletion if related exists | Critical reference data |
| `SetNull` | Sets FK to null | Optional relationships |
| `ClientCascade` | Cascade only on tracked entities | In-memory delete operations |
| `ClientSetNull` | Sets FK to null in memory | Client-side optional data |
| `NoAction` | Takes no action | Manual management |

## Self-Referencing Relationships

Model hierarchical structures like categories or organizational charts:

```csharp
public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int? ParentCategoryId { get; set; }
    public Category? ParentCategory { get; set; }
    public ICollection<Category> SubCategories { get; set; } = new List<Category>();
}
```

## References

- [EF Core Relationships Documentation](https://docs.microsoft.com/en-us/ef/core/modeling/relationships)
- [Many-to-Many Relationships](https://docs.microsoft.com/en-us/ef/core/modeling/relationships/many-to-many)
- [Delete Behaviors](https://docs.microsoft.com/en-us/ef/core/saving/cascade-delete)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  3,
  1,
  6789,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000016',
  'Using EF Core with PostgreSQL',
  'using-ef-core-with-postgresql',
  'A practical guide to configuring and optimizing Entity Framework Core with the Npgsql provider for PostgreSQL, covering setup, data types, full-text search, and provider-specific features.',
  $content$
## Introduction

PostgreSQL is a powerful open-source relational database with extensive features. When combined with EF Core and the Npgsql provider, developers get a robust ORM experience with access to PostgreSQL-specific capabilities such as JSONB, full-text search, and advanced indexing.

## Setting Up Npgsql

Install the Npgsql EF Core provider:

```bash
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
```

Register the provider in `Program.cs`:

```csharp
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("PostgresConnection")));
```

Configure the connection string in `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "PostgresConnection": "Host=localhost;Port=5432;Database=devwiki;Username=devwiki;Password=devwiki"
  }
}
```

## PostgreSQL-Specific Data Types

Npgsql maps PostgreSQL types to .NET types:

| PostgreSQL Type | .NET Type | Notes |
|---|---|---|
| `UUID` | `Guid` | Auto-generated with `HasDefaultValueSql("gen_random_uuid()")` |
| `JSONB` | `JsonDocument` or custom | Enables document-style queries |
| `TSVECTOR` | `NpgsqlTsVector` | Full-text search support |
| `TSQUERY` | `NpgsqlTsQuery` | Search query construction |
| `NUMERIC` | `decimal` | Arbitrary precision numeric |
| `ARRAY` | `T[]` | Native array types |
| `HSTORE` | `Dictionary<string,string>` | Key-value store |

Configure JSONB columns:

```csharp
modelBuilder.Entity<Article>()
    .Property(a => a.Metadata)
    .HasColumnType("jsonb");

modelBuilder.Entity<Article>()
    .HasIndex(a => a.Metadata)
    .HasMethod("GIN");
```

## Full-Text Search with Npgsql

EF Core with Npgsql supports PostgreSQL full-text search natively:

```csharp
public class Article
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public NpgsqlTsVector SearchVector { get; set; } = null!;
}
```

Configure the computed column with a generated tsvector:

```csharp
modelBuilder.Entity<Article>()
    .HasGeneratedTsVectorColumn(
        a => a.SearchVector,
        "english",
        a => new { a.Title, a.Content })
    .HasIndex(a => a.SearchVector)
    .HasMethod("GIN");
```

Query using full-text search:

```csharp
var articles = await _context.Articles
    .Where(a => a.SearchVector.Matches("EF Core performance"))
    .OrderByDescending(a => a.SearchVector.Rank(EF.Functions.ToTsQuery("english", "EF Core performance")))
    .Select(a => new { a.Title, a.Slug })
    .ToListAsync();
```

## Connection Resiliency

PostgreSQL connections can fail due to transient faults. Implement retry logic:

```csharp
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(dbContextOptionsBuilder =>
    {
        dbContextOptionsBuilder
            .ConnectionString(connectionString)
            .EnableRetryOnFailure(
                maxRetryCount: 3,
                maxRetryDelay: TimeSpan.FromSeconds(10),
                errorCodesToAdd: null);
    }));
```

## Indexing Strategies for PostgreSQL

PostgreSQL offers several index types beyond B-tree:

```csharp
// GIN index for JSONB or full-text search
entity.HasIndex(a => a.Metadata).HasMethod("GIN");

// GiST index for full-text search ranking
entity.HasIndex(a => a.SearchVector).HasMethod("GIST");
```

## Migrations for PostgreSQL

EF Core with Npgsql generates PostgreSQL-compatible migrations. Create and apply as usual:

```bash
dotnet ef migrations add InitialPostgresSchema
dotnet ef database update
```

The generated SQL uses PostgreSQL syntax, including `CREATE INDEX CONCURRENTLY` when specified via migration builder.

## References

- [Npgsql EF Core Provider Documentation](https://www.npgsql.org/efcore/)
- [PostgreSQL Full-Text Search with EF Core](https://www.npgsql.org/efcore/mapping/full-text-search.html)
- [Npgsql Connection Resiliency](https://www.npgsql.org/efcore/connection-resiliency.html)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  3,
  1,
  4123,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000017',
  'Global Query Filters in EF Core',
  'global-query-filters-in-ef-core',
  'Explore how global query filters in EF Core enable automatic soft-delete, multi-tenancy, and row-level security by applying predicates automatically to all queries.',
  $content$
## Introduction

Global query filters are LINQ predicates applied automatically to all queries for a given entity type. Introduced in EF Core 2.0, they are indispensable for implementing cross-cutting concerns like soft deletes, multi-tenancy, and row-level security without littering individual queries with boilerplate conditions.

## Defining Global Query Filters

Configure filters in `OnModelCreating` using the `HasQueryFilter` method:

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Post>().HasQueryFilter(p => !p.IsDeleted);
    modelBuilder.Entity<Blog>().HasQueryFilter(b => b.IsActive);
}
```

Every query against `Post` will now automatically include `WHERE "IsDeleted" = FALSE`, and every query against `Blog` will include `WHERE "IsActive" = TRUE`.

## Implementing Soft Delete

Global query filters make soft-delete implementations trivial:

```csharp
public interface ISoftDeletable
{
    bool IsDeleted { get; set; }
    DateTime? DeletedAt { get; set; }
}

public class Post : ISoftDeletable
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
}

protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    foreach (var entityType in modelBuilder.Model.GetEntityTypes()
        .Where(t => typeof(ISoftDeletable).IsAssignableFrom(t.ClrType)))
    {
        modelBuilder.Entity(entityType.ClrType)
            .HasQueryFilter(e => !((ISoftDeletable)e).IsDeleted);
    }
}
```

The soft-delete operation simply marks the entity:

```csharp
public async Task SoftDeletePostAsync(int postId)
{
    var post = await _context.Posts.FindAsync(postId);
    if (post is not null)
    {
        post.IsDeleted = true;
        post.DeletedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
    }
}
```

## Multi-Tenancy Support

Global query filters elegantly handle multi-tenant architectures where each tenant's data must be isolated:

```csharp
public class TenantDbContext : DbContext
{
    private readonly int _tenantId;

    public TenantDbContext(DbContextOptions<TenantDbContext> options, ITenantService tenantService)
        : base(options)
    {
        _tenantId = tenantService.GetCurrentTenantId();
    }

    public DbSet<Article> Articles => Set<Article>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Article>().HasQueryFilter(a =>
            a.TenantId == _tenantId);
    }
}
```

This ensures every query automatically scopes to the current tenant without explicit `Where` clauses.

## Combining Multiple Filters

Multiple conditions within a single `HasQueryFilter` call are combined with AND logic:

```csharp
modelBuilder.Entity<Document>().HasQueryFilter(d =>
    !d.IsDeleted &&
    d.TenantId == _tenantId &&
    d.Status != DocumentStatus.Archived);
```

## Disabling Filters

Use `IgnoreQueryFilters` to bypass filters when needed:

```csharp
var deletedPosts = await _context.Posts
    .IgnoreQueryFilters()
    .Where(p => p.IsDeleted)
    .ToListAsync();
```

This is essential for administrative operations that need to access soft-deleted records or cross-tenant data.

## Limitations and Considerations

| Consideration | Description |
|---|---|
| Navigation property filters | Filters are not applied to navigations loaded via `Include` |
| Performance | Complex filter expressions can impact query plan generation |
| Debugging | Filters are invisible in LINQ queries, making debugging harder |
| Testing | Unit tests must account for filter context |
| Inheritance | Filters apply differently with TPH, TPT, and TPC mappings |

## Testing with Global Filters

When writing integration tests, seed data must respect the filter context:

```csharp
[Fact]
public async Task GetPosts_ExcludesSoftDeleted()
{
    using var context = CreateContext(tenantId: 1);

    context.Posts.Add(new Post
    {
        Title = "Active Post",
        IsDeleted = false,
        TenantId = 1
    });
    context.Posts.Add(new Post
    {
        Title = "Deleted Post",
        IsDeleted = true,
        TenantId = 1
    });
    await context.SaveChangesAsync();

    var posts = await context.Posts.ToListAsync();

    Assert.Single(posts);
    Assert.Equal("Active Post", posts[0].Title);
}
```

## References

- [Global Query Filters Documentation](https://docs.microsoft.com/en-us/ef/core/querying/filters)
- [Multi-Tenancy with EF Core](https://docs.microsoft.com/en-us/ef/core/miscellaneous/multi-tenancy)
- [Soft Delete Pattern with Global Filters](https://docs.microsoft.com/en-us/ef/core/saving/cascade-delete)
  $content$,
  '11111111-1111-1111-1111-111111111111',
  3,
  1,
  3456,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
);

-- Refresh the sequence for generating future article IDs




