-- ============================================
-- 05_articles_dotnet.sql
-- 8 articles in the .NET category (CategoryId = 1)
-- ============================================

INSERT INTO "Articles" ("ArticleId", "Title", "Slug", "Summary", "Content", "AuthorId", "CategoryId", "Status", "ViewCount", "CreatedAt", "UpdatedAt")
VALUES
(
  'a0000001-0000-0000-0000-000000000001',
  'Understanding .NET Garbage Collection',
  'understanding-dotnet-garbage-collection',
  'A deep dive into how the .NET garbage collector manages memory, including generational collection, GC modes, and best practices for minimizing GC pressure in high-performance applications.',
  $$
## Introduction

The .NET garbage collector (GC) is a core component of the .NET runtime that automatically manages memory allocation and deallocation. Understanding how the GC works is essential for writing efficient and performant .NET applications.

## Generational Collection

The .NET GC uses a generational approach to optimize memory management. It divides objects into three generations:

| Generation | Description | Collection Frequency |
|---|---|---|
| Gen 0 | Short-lived objects (e.g., local variables) | Most frequent |
| Gen 1 | Objects that survived a Gen 0 collection | Less frequent |
| Gen 2 | Long-lived objects (e.g., static data, caches) | Rare |

Short-lived objects are collected frequently, while long-lived objects are promoted to higher generations. This strategy minimizes the work done during each collection cycle.

## GC Modes

The GC supports two primary modes:

- **Workstation GC**: Optimized for client applications with low latency requirements
- **Server GC**: Optimized for server applications requiring throughput and high concurrency

Server GC creates a separate heap and thread for each logical CPU, enabling parallel garbage collection.

```csharp
// Example of forcing a garbage collection (use sparingly!)
long memoryBefore = GC.GetTotalMemory(false);
// Perform memory-intensive work
byte[] largeBuffer = new byte[1024 * 1024 * 100]; // 100 MB
GC.KeepAlive(largeBuffer);
long memoryAfter = GC.GetTotalMemory(true);

Console.WriteLine($"Memory delta: {memoryAfter - memoryBefore} bytes");
```

## Best Practices

To minimize GC performance impact:

- Avoid large object heap (LOH) fragmentation by reusing large buffers
- Use object pooling with `ArrayPool<T>` for reusable arrays
- Minimize allocations in hot paths by using structs instead of classes where appropriate

```csharp
using System.Buffers;

public class BufferManager
{
    private readonly ArrayPool<byte> _pool = ArrayPool<byte>.Shared;

    public byte[] RentBuffer(int minimumLength)
    {
        return _pool.Rent(minimumLength);
    }

    public void ReturnBuffer(byte[] buffer, bool clearArray = false)
    {
        _pool.Return(buffer, clearArray);
    }
}
```

## Finalization and IDisposable

Objects with unmanaged resources should implement `IDisposable`:

- Implement the dispose pattern with a finalizer
- Use `using` statements or `await using` for deterministic cleanup
- Avoid creating finalizable objects in hot paths if possible

## References

- [Microsoft Docs: Garbage Collection](https://docs.microsoft.com/en-us/dotnet/standard/garbage-collection/)
- [Garbage Collection Performance Guidelines](https://docs.microsoft.com/en-us/dotnet/standard/garbage-collection/performance)
- [.NET Memory Management Blog](https://devblogs.microsoft.com/dotnet/tag/garbage-collection/)
  $$,
  '11111111-1111-1111-1111-111111111111',
  1,
  1,
  8723,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000002',
  'Async Programming Patterns in .NET',
  'async-programming-patterns-in-dotnet',
  'Explore the most effective async programming patterns in .NET, from basic Task-based operations to advanced techniques like channels and dataflow pipelines.',
  $$
## Introduction

Asynchronous programming is a cornerstone of modern .NET development. It enables applications to remain responsive by performing non-blocking operations. This article covers fundamental and advanced patterns for effective async programming.

## Task-Based Async Pattern

The `Task-based Asynchronous Pattern (TAP)` is the standard approach using `async` and `await` keywords:

```csharp
public async Task<Order> FetchOrderAsync(int orderId)
{
    using var httpClient = new HttpClient();
    var response = await httpClient.GetStringAsync($"https://api.example.com/orders/{orderId}");
    return JsonSerializer.Deserialize<Order>(response);
}
```

Always follow these rules:

- Async methods should return `Task`, `Task<T>`, or `ValueTask<T>`
- Avoid `async void` except for event handlers
- Use `ConfigureAwait(false)` in library code to avoid capturing the synchronization context

## Concurrency Patterns

| Pattern | Use Case | Example API |
|---|---|---|
| Sequential | Operations must run one after another | `await op1; await op2` |
| Parallel | Independent operations | `Task.WhenAll(t1, t2)` |
| Race | First result wins | `Task.WhenAny(t1, t2)` |
| Streaming | Process as available | `Channel<T>`, `IAsyncEnumerable<T>` |

## Channels

The `System.Threading.Channels` namespace provides producer/consumer patterns:

```csharp
var channel = Channel.CreateUnbounded<LogEntry>();

var producer = Task.Run(async () =>
{
    for (int i = 0; i < 100; i++)
    {
        await channel.Writer.WriteAsync(new LogEntry { Id = i, Message = $"Entry {i}" });
    }
    channel.Writer.Complete();
});

var consumer = Task.Run(async () =>
{
    await foreach (var entry in channel.Reader.ReadAllAsync())
    {
        Console.WriteLine($"Processing: {entry.Message}");
    }
});

await Task.WhenAll(producer, consumer);
```

## Cancellation

Always support cooperative cancellation by accepting a `CancellationToken` parameter in async methods.

## Error Handling

Use `try/catch` blocks around awaited calls. Avoid `Task.Wait()` or `Task.Result` as they can cause deadlocks.

## References

- [Microsoft Docs: Async Programming](https://docs.microsoft.com/en-us/dotnet/csharp/async)
- [Task-based Async Pattern Overview](https://docs.microsoft.com/en-us/dotnet/standard/async-in-depth)
- [Channels in .NET](https://devblogs.microsoft.com/dotnet/an-introduction-to-system-threading-channels/)
  $$,
  '11111111-1111-1111-1111-111111111111',
  1,
  1,
  6541,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000003',
  'Dependency Injection in .NET',
  'dependency-injection-in-dotnet',
  'A comprehensive guide to the built-in dependency injection container in .NET, covering service lifetimes, registration patterns, and advanced scenarios like factory-based resolution and decorators.',
  $$
## Introduction

Dependency injection (DI) is a first-class citizen in .NET. The built-in `Microsoft.Extensions.DependencyInjection` container provides a lightweight, performant DI system suitable for most applications.

## Service Lifetimes

.NET defines three service lifetimes:

| Lifetime | Instance Created | Best For |
|---|---|---|
| `Transient` | Every time requested | Lightweight, stateless services |
| `Scoped` | Once per scope/request | EF Core DbContext, request-scoped services |
| `Singleton` | Once for the application lifetime | Caches, configuration, logging |

```csharp
builder.Services.AddTransient<IOrderProcessor, OrderProcessor>();
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddSingleton<ICacheProvider, MemoryCacheProvider>();
```

## Registration Patterns

### Factory Registration

Sometimes you need to control instance creation:

```csharp
builder.Services.AddScoped<IConnectionFactory>(sp =>
{
    var config = sp.GetRequiredService<IConfiguration>();
    var connectionString = config.GetConnectionString("Default");
    return new ConnectionFactory(connectionString);
});
```

### Multiple Implementations

Register multiple implementations of the same interface and use `IEnumerable<T>` to resolve them:

```csharp
builder.Services.AddScoped<IValidationHandler, OrderValidationHandler>();
builder.Services.AddScoped<IValidationHandler, PaymentValidationHandler>();

public class ValidationPipeline
{
    private readonly IEnumerable<IValidationHandler> _handlers;

    public ValidationPipeline(IEnumerable<IValidationHandler> handlers)
    {
        _handlers = handlers;
    }

    public async Task<ValidationResult> ExecuteAsync(Order order)
    {
        foreach (var handler in _handlers)
        {
            var result = await handler.ValidateAsync(order);
            if (!result.IsValid) return result;
        }
        return ValidationResult.Success();
    }
}
```

## Avoiding Common Pitfalls

- Avoid captive dependencies — registering a `Scoped` service into a `Singleton` creates a captive dependency
- Avoid service locator anti-pattern — resolve dependencies through constructor injection
- Dispose properly — the container automatically disposes `IDisposable` services

## References

- [Microsoft Docs: Dependency Injection](https://docs.microsoft.com/en-us/dotnet/core/extensions/dependency-injection)
- [DI Container Guidelines](https://docs.microsoft.com/en-us/dotnet/core/extensions/dependency-injection-guidelines)
- [Mark Seemann's DI in .NET Book](https://www.manning.com/books/dependency-injection-in-dot-net)
  $$,
  '11111111-1111-1111-1111-111111111111',
  1,
  1,
  5432,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000004',
  'Configuration Management in .NET',
  'configuration-management-in-dotnet',
  'Learn how to manage application configuration in .NET using JSON files, environment variables, user secrets, and the options pattern with strong-typed settings classes.',
  $$
## Introduction

The .NET configuration system is hierarchical, extensible, and built around the `IConfiguration` interface. It supports multiple sources that are layered together to form a unified key-value store.

## Configuration Sources

Configuration providers are layered in order of precedence (last wins):

| Source | Example | Priority |
|---|---|---|
| appsettings.json | `{ "Logging": { "Level": "Debug" } }` | Lowest |
| appsettings.Development.json | Environment-specific overrides | Low |
| User Secrets | Development secrets stored on dev machine | Medium |
| Environment Variables | `Logging__Level=Warning` | High |
| Command-line args | `--Logging:Level=Error` | Highest |

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Configuration
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true)
    .AddEnvironmentVariables()
    .AddUserSecrets<Program>();
```

## Options Pattern

The Options pattern provides strong-typed access to configuration sections:

```csharp
public class SmtpSettings
{
    public const string SectionName = "Smtp";

    public string Host { get; set; } = string.Empty;
    public int Port { get; set; } = 587;
    public bool UseSsl { get; set; } = true;
    public string Username { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

// Registration
builder.Services.Configure<SmtpSettings>(
    builder.Configuration.GetSection(SmtpSettings.SectionName));

// Usage
public class EmailService
{
    private readonly SmtpSettings _settings;

    public EmailService(IOptions<SmtpSettings> options)
    {
        _settings = options.Value;
    }
}
```

## Options Interfaces

Use the right options interface for your needs:

- `IOptions<T>` — Singleton, reads configuration at app startup
- `IOptionsSnapshot<T>` — Scoped, reloads on each request when `reloadOnChange` is enabled
- `IOptionsMonitor<T>` — Singleton, provides change notifications via `.OnChange()`

## References

- [Microsoft Docs: Configuration in .NET](https://docs.microsoft.com/en-us/dotnet/core/extensions/configuration)
- [Options Pattern in .NET](https://docs.microsoft.com/en-us/dotnet/core/extensions/options)
- [Configuration Provider Samples](https://github.com/dotnet/Extensions/tree/main/samples)
  $$,
  '11111111-1111-1111-1111-111111111111',
  1,
  1,
  3127,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000005',
  'Logging Best Practices with Serilog',
  'logging-best-practices-with-serilog',
  'Master structured logging with Serilog in .NET applications, covering configuration, sinks, enrichers, and best practices for production-grade observability.',
  $$
## Introduction

Serilog is the most popular structured logging library for .NET. Unlike traditional text-based logging, Serilog captures events as structured data that can be queried and analyzed.

## Setting Up Serilog

Install the required packages:

```bash
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Serilog.Sinks.File
dotnet add package Serilog.Sinks.Seq
```

Configure Serilog in `Program.cs`:

```csharp
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.Hosting.Lifetime", LogEventLevel.Information)
    .WriteTo.Console(
        outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj}{NewLine}{Exception}")
    .WriteTo.File(
        path: "logs/devwiki-.log",
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 30)
    .WriteTo.Seq("http://localhost:5341")
    .Enrich.WithMachineName()
    .Enrich.WithEnvironmentName()
    .CreateLogger();

builder.Host.UseSerilog();
```

## Structured Logging

Always use named placeholders instead of string concatenation:

```csharp
// Bad
_logger.LogInformation("User {0} logged in at {1}", user.Id, DateTime.UtcNow);

// Good
_logger.LogInformation("User {UserId} logged in at {LoginTime}", user.Id, DateTime.UtcNow);
```

| Approach | Searchable | Indexable | Recommendation |
|---|---|---|---|
| String concatenation | No | No | Avoid |
| Anonymous placeholders | Partial | No | Avoid |
| Named placeholders | Yes | Yes | Always use |

## Context and Enrichers

Use `LogContext` to add properties across multiple log calls:

```csharp
using (LogContext.PushProperty("CorrelationId", correlationId))
using (LogContext.PushProperty("UserId", currentUser.Id))
{
    _logger.LogInformation("Processing order {OrderId}", order.Id);
    _logger.LogInformation("Payment completed for order {OrderId}", order.Id);
}
```

## Smart Event Leveling

- `Verbose` — Deep debugging traces, disabled in production
- `Debug` — Development-only information
- `Information` — Normal application flow events
- `Warning` — Degraded operation that still succeeds
- `Error` — Recoverable failures
- `Fatal` — Unrecoverable application crashes

## References

- [Serilog Documentation](https://serilog.net/)
- [Structured Logging with Serilog](https://docs.serilog.net/articles/structured-data.html)
- [Serilog Best Practices](https://nblumhardt.com/tags/serilog/)
  $$,
  '11111111-1111-1111-1111-111111111111',
  1,
  1,
  4982,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000006',
  'Working with HttpClient in .NET',
  'working-with-httpclient-in-dotnet',
  'A practical guide to using HttpClient correctly in .NET, covering IHttpClientFactory, retry policies with Polly, connection pool management, and common pitfalls.',
  $$
## Introduction

`HttpClient` is the primary class for sending HTTP requests in .NET. However, improper usage — particularly socket exhaustion from improper disposal — is a common source of production issues. This guide covers the recommended patterns.

## The Problem with HttpClient

Creating a new `HttpClient` for every request creates new socket connections that linger in `TIME_WAIT` state:

```csharp
// BAD: Creates a new connection for every request
public class BadOrderService
{
    public async Task<Order> GetOrderAsync(int id)
    {
        using var client = new HttpClient();
        var response = await client.GetStringAsync($"https://api.example.com/orders/{id}");
        return JsonSerializer.Deserialize<Order>(response);
    }
}
```

## IHttpClientFactory

Use `IHttpClientFactory` to manage connection pooling:

```csharp
// Register in DI
builder.Services.AddHttpClient<IOrderApiClient, OrderApiClient>(client =>
{
    client.BaseAddress = new Uri("https://api.example.com");
    client.Timeout = TimeSpan.FromSeconds(10);
    client.DefaultRequestHeaders.Add("Accept", "application/json");
})
.AddTransientHttpErrorPolicy(policy =>
    policy.WaitAndRetryAsync(3, retryAttempt =>
        TimeSpan.FromMilliseconds(Math.Pow(2, retryAttempt) * 100)));

// Usage
public class OrderApiClient : IOrderApiClient
{
    private readonly HttpClient _httpClient;

    public OrderApiClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<Order> GetOrderAsync(int id)
    {
        var response = await _httpClient.GetAsync($"/orders/{id}");
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<Order>();
    }
}
```

## Common HttpClient Patterns

| Pattern | Description | Use When |
|---|---|---|
| Typed Client | Dedicated client class per API | Multiple endpoints per API |
| Named Client | Named configuration via `AddHttpClient("name")` | Simple configuration needed |
| Untyped Client | Direct `IHttpClientFactory` injection | One-off requests |

## Handling Transient Faults with Polly

```csharp
builder.Services.AddHttpClient<IImportService, ImportService>()
    .AddTransientHttpErrorPolicy(p => p.CircuitBreakerAsync(
        handledEventsAllowedBeforeBreaking: 5,
        durationOfBreak: TimeSpan.FromSeconds(30)));
```

## References

- [Microsoft Docs: HttpClient in .NET](https://docs.microsoft.com/en-us/dotnet/fundamentals/networking/httpclient)
- [IHttpClientFactory Guide](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/implement-resilient-applications/use-httpclientfactory-to-implement-resilient-http-requests)
- [Polly Documentation](https://github.com/App-vNext/Polly)
  $$,
  '11111111-1111-1111-1111-111111111111',
  1,
  1,
  7216,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000007',
  'NET Middleware Pipeline Deep Dive',
  'dotnet-middleware-pipeline-deep-dive',
  'Understanding the ASP.NET Core middleware pipeline — how to build, order, and write custom middleware for request/response processing in modern web applications.',
  $$
## Introduction

The ASP.NET Core middleware pipeline is a series of components that process HTTP requests and responses. Each middleware component decides whether to pass the request to the next component or short-circuit the pipeline.

## Pipeline Architecture

Middleware components execute in the order they are registered and return in reverse order:

```
Request  →  Middleware A  →  Middleware B  →  Endpoint
            ↓                ↓
Response ←  Middleware A  ←  Middleware B
```

## Built-in Middleware Order

The recommended ordering for common middleware:

```csharp
var app = builder.Build();

app.UseExceptionHandler();       // 1. Error handling
app.UseHttpsRedirection();      // 2. Redirect to HTTPS
app.UseStaticFiles();            // 3. Serve static files
app.UseRouting();                // 4. Route matching
app.UseAuthentication();         // 5. Authentication
app.UseAuthorization();          // 6. Authorization
app.MapControllers();              // 7. Endpoints
```

## Custom Middleware

Create custom middleware by convention or factory pattern:

```csharp
// Convention-based middleware
public class RequestTimingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestTimingMiddleware> _logger;

    public RequestTimingMiddleware(RequestDelegate next, ILogger<RequestTimingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        await _next(context);
        stopwatch.Stop();

        _logger.LogInformation(
            "{Method} {Path} responded {StatusCode} in {Duration}ms",
            context.Request.Method,
            context.Request.Path,
            context.Response.StatusCode,
            stopwatch.ElapsedMilliseconds);
    }
}

// Registration
app.UseMiddleware<RequestTimingMiddleware>();
```

## Short-Circuiting

Middleware can short-circuit the pipeline to prevent further processing:

| Condition | Action | Example |
|---|---|---|
| Maintenance mode | Return 503 immediately | `app.UseWhen(ctx => IsMaintenance, ...)` |
| IP whitelisting | Return 403 for blocked IPs | Custom security middleware |
| Request validation | Return 400 for invalid requests | Validation middleware |

## References

- [ASP.NET Core Middleware](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware/)
- [Custom Middleware Examples](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware/write)
- [Middleware Ordering Guide](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/middleware/#middleware-order)
  $$,
  '11111111-1111-1111-1111-111111111111',
  1,
  1,
  3854,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000008',
  'Performance Optimization in .NET Applications',
  'performance-optimization-in-dotnet-applications',
  'Practical strategies for optimizing .NET application performance including benchmarking, memory profiling, string pooling, Span<T> usage, and async I/O best practices.',
  $$
## Introduction

Performance optimization in .NET applications requires systematic measurement and targeted improvements. This article covers proven techniques for improving throughput, reducing memory allocations, and minimizing latency.

## Measure First

Never optimize without data. Use `BenchmarkDotNet` for microbenchmarks:

```csharp
[MemoryDiagnoser]
[Orderer(SummaryOrderPolicy.FastestToSlowest)]
public class StringConcatenationBenchmark
{
    private readonly string[] _parts = Enumerable.Range(0, 100)
        .Select(i => $"item-{i}")
        .ToArray();

    [Benchmark]
    public string StringBuilder()
    {
        var sb = new StringBuilder();
        foreach (var part in _parts)
            sb.Append(part).Append(',');
        return sb.ToString();
    }

    [Benchmark]
    public string StringJoin()
    {
        return string.Join(",", _parts);
    }
}
```

| Method | Mean | Allocated | Result |
|---|---|---|---|
| StringBuilder | 2.456 us | 5.2 KB | Slower |
| StringJoin | 0.321 us | 1.1 KB | Faster |

## Span<T> and Memory<T>

Use `Span<T>` and `Memory<T>` for zero-allocation slicing:

```csharp
public static int ParseHeaderValue(ReadOnlySpan<char> line)
{
    // Slice the span without allocation
    var colonIndex = line.IndexOf(':');
    var valueSpan = line.Slice(colonIndex + 1).Trim();
    return int.Parse(valueSpan);
}
```

## Key Optimization Areas

- **String allocations**: Use `StringBuilder`, `string.Create`, or pooled strings
- **Array allocations**: Use `ArrayPool<T>` for temporary buffers
- **LINQ allocations**: Prefer simple `for` or `foreach` loops in hot paths
- **Async overhead**: Avoid `async`/`await` for trivial synchronous operations

## Profiling Tools

| Tool | Purpose | Platform |
|---|---|---|
| BenchmarkDotNet | Microbenchmarks | All |
| Visual Studio Profiler | CPU/Memory profiling | Windows |
| dotnet-counters | Real-time monitoring | Cross-platform |
| dotnet-trace | Event-level tracing | Cross-platform |
| PerfView | Advanced analysis | Windows |

## References

- [BenchmarkDotNet Documentation](https://benchmarkdotnet.org/)
- [.NET Performance Tips](https://docs.microsoft.com/en-us/dotnet/fundamentals/code-analysis/performance-rules)
- [High-Performance .NET Book](https://www.manning.com/books/high-performance-dot-net)
  $$,
  '11111111-1111-1111-1111-111111111111',
  1,
  1,
  9154,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
);

-- Refresh the sequence for generating future article IDs




