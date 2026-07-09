-- ============================================
-- 06_articles_aspnet.sql
-- 8 articles in the ASP.NET Core category (CategoryId = 2)
-- ============================================

INSERT INTO "Articles" ("ArticleId", "Title", "Slug", "Summary", "Content", "AuthorId", "CategoryId", "Status", "ViewCount", "CreatedAt", "UpdatedAt")
VALUES
(
  'a0000001-0000-0000-0000-000000000009',
  'Building RESTful APIs with ASP.NET Core',
  'building-restful-apis-with-aspnet-core',
  'A comprehensive guide to building RESTful APIs using ASP.NET Core, covering controller-based and Minimal API approaches, routing, versioning, and response formatting.',
  $$
## Introduction

ASP.NET Core is a cross-platform, high-performance framework for building modern RESTful APIs. It provides a unified programming model with support for both traditional controller-based APIs and the newer Minimal API approach introced in .NET 6. Understanding both paradigms allows developers to choose the right approach for each service they build.

## Controllers vs Minimal APIs

The framework offers two distinct approaches, each with its own strengths:

| Feature | Controller APIs | Minimal APIs |
|---|---|---|
| Organization | Grouped by controller class | Top-level program or grouped files |
| DI mechanism | Constructor injection | Lambda parameter injection |
| Route setup | Attribute routing on actions | Route handlers with MapGet, MapPost |
| Built-in model binding | Automatic via [ApiController] | Explicit via [FromQuery], [FromBody] |
| Testability | Easy with unit tests | Requires integration test helpers |
| Best suited for | Large applications, teams | Microservices, small endpoints |

```csharp
// Controller-based API approach
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly IProductService _productService;
    private readonly ILogger<ProductsController> _logger;

    public ProductsController(IProductService productService, ILogger<ProductsController> logger)
    {
        _productService = productService;
        _logger = logger;
    }

    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(ProductDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<ProductDto>> GetById(Guid id)
    {
        var product = await _productService.GetByIdAsync(id);
        if (product is null)
        {
            _logger.LogWarning("Product {ProductId} not found", id);
            return NotFound(new ProblemDetails
            {
                Title = "Product not found",
                Status = 404,
                Detail = $"No product exists with ID {id}"
            });
        }
        return Ok(product);
    }
}
```

## Designing RESTful Endpoints

RESTful API design follows a set of conventions that make your API intuitive and predictable. Resources are represented as nouns and actions are expressed through HTTP methods. Consistent naming, proper status codes, and predictable URL structures reduce the learning curve for API consumers.

```csharp
// Minimal API with groups and structured organization
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();

var app = builder.Build();

var api = app.MapGroup("/api");
var products = api.MapGroup("/products").WithTags("Products");
var categories = api.MapGroup("/categories").WithTags("Categories");

products.MapGet("/", async (IProductService service, int page = 1, int size = 10) =>
{
    var items = await service.GetPagedAsync(page, size);
    var total = await service.GetCountAsync();
    return Results.Ok(new { items, total, page, size });
});

products.MapGet("/{id}", async (Guid id, IProductService service) =>
{
    var product = await service.GetByIdAsync(id);
    return product is null ? Results.NotFound() : Results.Ok(product);
});

products.MapPost("/", async (CreateProductRequest req, IProductService service) =>
{
    var product = await service.CreateAsync(req);
    return Results.Created($"/api/products/{product.Id}", product);
});

products.MapPut("/{id}", async (Guid id, UpdateProductRequest req, IProductService service) =>
{
    var updated = await service.UpdateAsync(id, req);
    return updated ? Results.NoContent() : Results.NotFound();
});

products.MapDelete("/{id}", async (Guid id, IProductService service) =>
{
    var deleted = await service.DeleteAsync(id);
    return deleted ? Results.NoContent() : Results.NotFound();
});

app.Run();
```

## Response Standardization

Consistent response envelopes simplify client consumption. Use a standardized wrapper for all API responses that includes success status, data, and error details. This pattern eliminates ambiguity and provides a uniform contract for every endpoint.

## API Versioning

Version your API from day one to support future evolution without breaking existing clients. URL path versioning is the most common approach, making the version explicit and cache-friendly.

- Use URL path versioning for public APIs
- Consider header-based versioning for internal services
- Maintain backward compatibility within a major version
- Deprecate old versions with clear sunset timelines

## References

- [ASP.NET Core Web API Documentation](https://learn.microsoft.com/en-us/aspnet/core/web-api/)
- [RESTful API Design Best Practices](https://learn.microsoft.com/en-us/azure/architecture/best-practices/api-design)
- [Minimal APIs Overview](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/minimal-apis)
  $$,
  '11111111-1111-1111-1111-111111111111',
  2,
  1,
  7841,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000000a',
  'JWT Authentication in ASP.NET Core',
  'jwt-authentication-in-aspnet-core',
  'Learn how to implement JWT-based authentication in ASP.NET Core, including token generation, validation, refresh token rotation, and role-based authorization policies.',
  $$
## Introduction

JSON Web Token (JWT) authentication is the standard mechanism for securing modern web APIs. ASP.NET Core provides built-in middleware and configuration options for JWT validation, making it straightforward to implement token-based authentication. This article walks through the complete setup from token generation to endpoint authorization.

## Configuring JWT Authentication

The first step is registering JWT authentication services in Program.cs. You must configure token validation parameters that control how the framework verifies incoming tokens, including issuer, audience, signing key, and lifetime constraints.

```csharp
var builder = WebApplication.CreateBuilder(args);

var jwtSettings = builder.Configuration.GetSection("Jwt");
var secretKey = jwtSettings["SecretKey"]!;
var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidateAudience = true,
        ValidAudience = jwtSettings["Audience"],
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = key,
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();
```

## Token Generation Service

Tokens should be generated by a dedicated service that encapsulates claims creation, expiration logic, and signing. Never embed sensitive data in claims and always use short expiration times for access tokens combined with longer-lived refresh tokens.

```csharp
public interface ITokenService
{
    TokenResponse GenerateToken(ApplicationUser user, IList<string> roles);
    ClaimsPrincipal? ValidateToken(string token);
}

public class TokenService : ITokenService
{
    private readonly JwtSettings _settings;

    public TokenService(IOptions<JwtSettings> settings) => _settings = settings.Value;

    public TokenResponse GenerateToken(ApplicationUser user, IList<string> roles)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.SecretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(JwtRegisteredClaimNames.Email, user.Email!),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new("username", user.UserName!)
        };
        claims.AddRange(roles.Select(r => new Claim(ClaimTypes.Role, r)));

        var accessToken = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_settings.ExpirationMinutes),
            signingCredentials: credentials);

        return new TokenResponse(
            new JwtSecurityTokenHandler().WriteToken(accessToken),
            DateTime.UtcNow.AddMinutes(_settings.ExpirationMinutes),
            GenerateRefreshToken());
    }
}
```

## Authorization Policies

Role-based and policy-based authorization protect your endpoints. Define policies that map to your application's security requirements and apply them consistently.

| Policy | Requirement | Endpoints Protected |
|---|---|---|
| AdminOnly | User must be in Admin role | User management, settings |
| EditorOrAdmin | User in Editor or Admin role | Content creation, editing |
| ViewerOnly | User in Viewer role | Read-only access |

```csharp
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy =>
        policy.RequireRole("Admin"));

    options.AddPolicy("EditorOrAdmin", policy =>
        policy.RequireRole("Editor", "Admin"));

    options.AddPolicy("ViewerOnly", policy =>
        policy.RequireRole("Viewer"));
});

// Applying policies
[Authorize(Policy = "AdminOnly")]
[HttpGet("admin/users")]
public async Task<IActionResult> GetUsers() { }

[Authorize(Policy = "EditorOrAdmin")]
[HttpPost("articles")]
public async Task<IActionResult> CreateArticle() { }
```

## Refresh Token Rotation

Access tokens have short lifetimes to limit exposure if leaked. Refresh tokens allow clients to obtain new access tokens without requiring the user to re-authenticate. Store refresh tokens securely server-side and rotate them with each use to prevent replay attacks.

## References

- [JWT Authentication in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/security/authentication/jwt-auth)
- [RFC 7519 - JSON Web Token Standard](https://datatracker.ietf.org/doc/html/rfc7519)
- [Authorization Policies in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/security/authorization/policies)
  $$,
  '11111111-1111-1111-1111-111111111111',
  2,
  1,
  9213,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000000b',
  'Model Validation in ASP.NET Core',
  'model-validation-in-aspnet-core',
  'Master input validation in ASP.NET Core using Data Annotations, FluentValidation, and custom validation attributes to ensure robust and secure API endpoints.',
  $$
## Introduction

Input validation is a critical security and data integrity layer in any web application. ASP.NET Core provides multiple validation approaches, from the built-in Data Annotations system to the more powerful FluentValidation library. Choosing the right validation strategy improves code maintainability, user experience, and application security.

## Data Annotations

The simplest validation approach uses attributes on model properties. ASP.NET Core automatically validates decorated models when the [ApiController] attribute is present, returning a 400 response with validation errors when the model state is invalid.

```csharp
public class CreateArticleRequest
{
    [Required(ErrorMessage = "Title is required")]
    [StringLength(200, MinimumLength = 3, ErrorMessage = "Title must be 3-200 characters")]
    public string Title { get; set; } = string.Empty;

    [Required(ErrorMessage = "Content is required")]
    [MinLength(50, ErrorMessage = "Content must be at least 50 characters")]
    public string Content { get; set; } = string.Empty;

    [Required]
    public Guid CategoryId { get; set; }

    [Url(ErrorMessage = "Cover image must be a valid URL")]
    public string? CoverImageUrl { get; set; }

    [Range(1, 100, ErrorMessage = "Reading time must be between 1 and 100 minutes")]
    public int ReadingTime { get; set; }

    [DataType(DataType.DateTime)]
    public DateTime? PublishedAt { get; set; }
}
```

## FluentValidation

For complex validation logic, FluentValidation provides a cleaner separation of concerns by defining validator classes. It supports conditional rules, cross-property validation, and custom error messages with greater flexibility than Data Annotations.

| Feature | Data Annotations | FluentValidation |
|---|---|---|
| Rule location | On model properties | Separate validator classes |
| Conditional rules | Limited | Full support |
| Complex cross-field validation | Difficult | Built-in |
| Custom error messages | String constants | Lambda expressions |
| Testability | Hard to unit test | Easy to unit test |

```csharp
using FluentValidation;

public class CreateArticleRequestValidator : AbstractValidator<CreateArticleRequest>
{
    public CreateArticleRequestValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Title is required")
            .Length(3, 200).WithMessage("Title must be 3-200 characters")
            .Must(title => !title.Contains("<script>"))
            .WithMessage("Title contains prohibited content");

        RuleFor(x => x.Content)
            .NotEmpty().WithMessage("Content is required")
            .MinimumLength(50).WithMessage("Content must be at least 50 characters");

        RuleFor(x => x.CategoryId)
            .NotEmpty().WithMessage("Category is required");

        RuleFor(x => x.ReadingTime)
            .InclusiveBetween(1, 100)
            .WithMessage("Reading time must be between 1 and 100 minutes");

        RuleFor(x => x.PublishedAt)
            .LessThanOrEqualTo(DateTime.UtcNow)
            .When(x => x.PublishedAt.HasValue)
            .WithMessage("Published date cannot be in the future");
    }
}

// Register in DI
builder.Services.AddValidatorsFromAssemblyContaining<CreateArticleRequestValidator>();
```

## Custom Validation Attributes

Sometimes your validation requirements extend beyond what built-in or library-based validators provide. Creating custom validation attributes allows you to encapsulate reusable domain-specific rules.

```csharp
[AttributeUsage(AttributeTargets.Property)]
public class ValidSlugAttribute : ValidationAttribute
{
    private static readonly Regex SlugRegex = new("^[a-z0-9]+(-[a-z0-9]+)*$");

    protected override ValidationResult? IsValid(object? value, ValidationContext context)
    {
        if (value is string slug && !SlugRegex.IsMatch(slug))
        {
            return new ValidationResult(
                "Slug must contain only lowercase letters, numbers, and hyphens");
        }
        return ValidationResult.Success;
    }
}
```

## References

- [Model Validation in ASP.NET Core MVC](https://learn.microsoft.com/en-us/aspnet/core/mvc/models/validation)
- [FluentValidation Documentation](https://docs.fluentvalidation.net/)
- [Custom Validation Attributes](https://learn.microsoft.com/en-us/aspnet/core/mvc/models/validation#custom-validation-attributes)
  $$,
  '11111111-1111-1111-1111-111111111111',
  2,
  1,
  6137,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000000c',
  'Custom Middleware in ASP.NET Core',
  'custom-middleware-in-aspnet-core',
  'A practical guide to building custom middleware in ASP.NET Core, covering convention-based and factory-based approaches, conditional branching, and real-world examples.',
  $$
## Introduction

Middleware is the backbone of the ASP.NET Core request processing pipeline. Each middleware component has the opportunity to examine, modify, or short-circuit the request and response. Understanding how to build custom middleware allows you to add cross-cutting concerns like logging, security headers, request transformation, and performance monitoring without polluting your application logic.

## Pipeline Architecture

The middleware pipeline follows a Russian doll pattern where each component wraps the next. Components execute in registration order on the way in and reverse order on the way out. This ordering is critical for correctly applying middleware like error handling, which must wrap everything else.

## Creating Convention-Based Middleware

The simplest approach follows a convention: a class with a constructor accepting RequestDelegate and an InvokeAsync method. This pattern works well for middleware that does not require scoped dependencies.

```csharp
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        var method = context.Request.Method;
        var path = context.Request.Path;

        _logger.LogInformation("Incoming request: {Method} {Path}", method, path);

        await _next(context);

        stopwatch.Stop();
        _logger.LogInformation(
            "Response for {Method} {Path}: {StatusCode} in {Elapsed}ms",
            method,
            path,
            context.Response.StatusCode,
            stopwatch.ElapsedMilliseconds);
    }
}

// Registration
app.UseMiddleware<RequestLoggingMiddleware>();
```

## Factory-Based Middleware

When your middleware requires scoped services from the DI container, use the IMiddleware interface. This gives the middleware its own lifetime and allows injecting scoped dependencies directly.

```csharp
public class SecurityHeadersMiddleware : IMiddleware
{
    public async Task InvokeAsync(HttpContext context, RequestDelegate next)
    {
        context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Append("X-Frame-Options", "DENY");
        context.Response.Headers.Append("X-XSS-Protection", "1; mode=block");
        context.Response.Headers.Append(
            "Content-Security-Policy",
            "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'");
        context.Response.Headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");

        await next(context);
    }
}

// Registration
builder.Services.AddScoped<SecurityHeadersMiddleware>();
app.UseMiddleware<SecurityHeadersMiddleware>();
```

## Conditional Middleware

Use the UseWhen and MapWhen extension methods to conditionally execute middleware based on request properties. This is useful for applying middleware only to specific paths, HTTP methods, or request conditions.

| Method | Purpose | Example |
|---|---|---|
| app.UseWhen | Conditionally branch and rejoin | Apply logging only to /api routes |
| app.MapWhen | Conditionally branch to separate pipeline | Serve static files from /admin |
| app.Map | Branch by path prefix | Version-specific API handling |

```csharp
// Apply middleware conditionally to API routes only
app.UseWhen(
    context => context.Request.Path.StartsWithSegments("/api"),
    appBuilder =>
    {
        appBuilder.UseMiddleware<RequestTimingMiddleware>();
        appBuilder.UseMiddleware<ApiKeyValidationMiddleware>();
    });

// Map separate pipeline for health checks
app.Map("/health", healthApp =>
{
    healthApp.UseMiddleware<HealthCheckMiddleware>();
});
```

## Real-World Middleware Examples

Common middleware applications include request logging, response compression, culture detection, API key validation, rate limiting, request body buffering, and exception handling. Each serves a specific purpose that is best implemented as a reusable pipeline component.

## References

- [ASP.NET Core Middleware Fundamentals](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/middleware/)
- [Write Custom Middleware](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/middleware/write)
- [Middleware Ordering Best Practices](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/middleware/#middleware-order)
  $$,
  '11111111-1111-1111-1111-111111111111',
  2,
  1,
  5472,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000000d',
  'Rate Limiting in ASP.NET Core 8',
  'rate-limiting-in-aspnet-core-8',
  'Explore the built-in rate limiting middleware in ASP.NET Core 8, including fixed window, sliding window, token bucket, and concurrency limiter policies with practical examples.',
  $$
## Introduction

Rate limiting is an essential mechanism for protecting APIs from abuse, ensuring fair resource allocation, and maintaining service stability. ASP.NET Core 8 introduced built-in rate limiting middleware in the Microsoft.AspNetCore.RateLimiting namespace, providing four powerful algorithms out of the box. This article covers configuration, customization, and best practices for each policy type.

## Fixed Window Limiter

The simplest rate limiting strategy divides time into fixed intervals and allows a maximum number of requests per interval. When the limit is reached, subsequent requests are rejected until the window resets. This approach is easy to understand but can suffer from burst traffic at window boundaries.

```csharp
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

    options.AddFixedWindowLimiter("FixedWindow", config =>
    {
        config.PermitLimit = 100;
        config.Window = TimeSpan.FromMinutes(1);
        config.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        config.QueueLimit = 10;
    });
});

var app = builder.Build();
app.UseRateLimiter();
```

## Sliding Window and Token Bucket

More sophisticated algorithms provide smoother request distribution and better burst handling.

| Algorithm | Behavior | Best For |
|---|---|---|
| Fixed Window | X requests per N seconds | Simple throttling |
| Sliding Window | X requests per rolling N-second window | Smooth rate enforcement |
| Token Bucket | Tokens replenish at a steady rate | Bursty workloads |
| Concurrency | Maximum concurrent requests | Resource protection |

```csharp
// Sliding window: limits to 200 requests per rolling 30-second window
options.AddSlidingWindowLimiter("SlidingWindow", config =>
{
    config.PermitLimit = 200;
    config.Window = TimeSpan.FromSeconds(30);
    config.SegmentsPerWindow = 3;
    config.QueueLimit = 5;
});

// Token bucket: 10 tokens per second with max burst of 20
options.AddTokenBucketLimiter("TokenBucket", config =>
{
    config.TokenLimit = 20;
    config.ReplenishmentPeriod = TimeSpan.FromSeconds(1);
    config.TokensPerPeriod = 10;
    config.QueueLimit = 5;
});

// Concurrency: max 15 simultaneous requests
options.AddConcurrencyLimiter("Concurrency", config =>
{
    config.PermitLimit = 15;
    config.QueueLimit = 5;
});
```

## Applying Policies to Endpoints

Different endpoints often need different rate limits. Public endpoints, authenticated endpoints, and administrative endpoints should each have their own policies.

```csharp
var app = builder.Build();
app.UseRateLimiter();

// Apply fixed window policy to all API endpoints
app.MapGet("/api/public", async () =>
{
    return Results.Ok(new { message = "Public endpoint" });
}).RequireRateLimiting("FixedWindow");

// More permissive policy for authenticated routes
app.MapGet("/api/authenticated", async (HttpContext context) =>
{
    var userId = context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    return Results.Ok(new { userId, message = "Authenticated endpoint" });
}).RequireRateLimiting("TokenBucket");

// No rate limit for admin endpoints (handled by authorization)
app.MapGet("/api/admin", async () =>
{
    return Results.Ok(new { message = "Admin endpoint" });
}).RequireRateLimiting("Concurrency");

// Partitioned rate limiting based on client IP or user ID
options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(context =>
{
    var userAgent = context.Request.Headers.UserAgent.ToString();
    return RateLimitPartition.GetFixedWindowLimiter(userAgent, _ => new FixedWindowRateLimiterOptions
    {
        PermitLimit = 50,
        Window = TimeSpan.FromMinutes(1)
    });
});
```

## Best Practices

- Return the Retry-After header so clients know when to retry
- Log rate limit violations for monitoring and alerting
- Use partitioned limiters to isolate noisy tenants from well-behaved ones
- Always set a reasonable queue limit to avoid dropping all burst traffic

## References

- [Rate Limiting in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/performance/rate-limit)
- [System.Threading.RateLimiting API Reference](https://learn.microsoft.com/en-us/dotnet/api/system.threading.ratelimiting)
- [Rate Limiting Patterns and Best Practices](https://learn.microsoft.com/en-us/azure/architecture/patterns/rate-limiting-pattern)
  $$,
  '11111111-1111-1111-1111-111111111111',
  2,
  1,
  3698,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000000e',
  'SignalR for Real-Time Web Features',
  'signalr-for-real-time-web-features',
  'Learn how to add real-time web functionality using ASP.NET Core SignalR, including hubs, groups, streaming, and scaling with a backplane for production deployments.',
  $$
## Introduction

SignalR is a real-time communication library for ASP.NET Core that enables server-side code to push content to connected clients instantly. It uses WebSockets as the primary transport with automatic fallback to Server-Sent Events or long polling when WebSockets are unavailable. SignalR is ideal for dashboards, chat applications, live notifications, collaborative editing, and real-time monitoring.

## Setting Up SignalR

Adding SignalR to your application requires configuring the service in Program.cs and mapping the hub endpoint. The client SDK is available for JavaScript, .NET, and other platforms via NuGet or npm.

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = builder.Environment.IsDevelopment();
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(30);
    options.MaximumReceiveMessageSize = 128 * 1024; // 128 KB
});

var app = builder.Build();

app.MapHub<NotificationHub>("/hubs/notifications");
app.MapHub<ChatHub>("/hubs/chat");
app.MapHub<DashboardHub>("/hubs/dashboard");
```

## Building a Hub

Hubs are the central abstraction in SignalR. They handle client connections and define methods that clients can call on the server. The server can also invoke methods on connected clients directly.

```csharp
public class ChatHub : Hub
{
    private static readonly ConcurrentDictionary<string, string> ConnectedUsers = new();
    private readonly ILogger<ChatHub> _logger;

    public ChatHub(ILogger<ChatHub> logger) => _logger = logger;

    public override async Task OnConnectedAsync()
    {
        var username = Context.User?.Identity?.Name ?? $"User-{Context.ConnectionId}";
        ConnectedUsers.TryAdd(Context.ConnectionId, username);
        _logger.LogInformation("User {Username} connected", username);

        await Clients.Others.SendAsync("UserConnected", username);
        await Clients.Caller.SendAsync("ConnectedUsers", ConnectedUsers.Values.ToList());

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        ConnectedUsers.TryRemove(Context.ConnectionId, out var username);
        _logger.LogInformation("User {Username} disconnected", username);
        await Clients.Others.SendAsync("UserDisconnected", username);
        await base.OnDisconnectedAsync(exception);
    }

    public async Task SendMessage(string room, string message)
    {
        var username = ConnectedUsers.GetValueOrDefault(Context.ConnectionId, "Unknown");
        var msg = new ChatMessage(username, message, DateTime.UtcNow);
        await Clients.Group(room).SendAsync("ReceiveMessage", msg);
    }

    public async Task JoinRoom(string room)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, room);
        _logger.LogInformation("User joined room: {Room}", room);
        await Clients.Group(room).SendAsync("RoomNotification",
            $"{ConnectedUsers[Context.ConnectionId]} joined {room}");
    }

    public async Task LeaveRoom(string room)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, room);
        await Clients.Group(room).SendAsync("RoomNotification",
            $"{ConnectedUsers[Context.ConnectionId]} left {room}");
    }
}
```

## Groups and Connections

Groups allow you to broadcast messages to subsets of connected clients. This is essential for room-based chat, organization-specific notifications, or tenant-isolated real-time updates.

| Feature | Method | Use Case |
|---|---|---|
| All clients | Clients.All | Global announcements |
| Caller only | Clients.Caller | Personal acknowledgements |
| Specific client | Clients.Client(connectionId) | Targeted notifications |
| Group members | Clients.Group(groupName) | Room-based chat |
| Multiple groups | Clients.Groups(groupNames) | Cross-group messaging |

## Client Integration

The JavaScript client connects to the hub and invokes or listens for methods. SignalR abstracts away the transport layer so your client code remains consistent across different connection types.

```javascript
const connection = new signalR.HubConnectionBuilder()
    .withUrl("/hubs/chat")
    .withAutomaticReconnect([0, 2000, 5000, 10000, 30000])
    .configureLogging(signalR.LogLevel.Information)
    .build();

connection.on("ReceiveMessage", (username, message, timestamp) => {
    console.log(`[${timestamp}] ${username}: ${message}`);
    addMessageToChat(username, message, timestamp);
});

connection.on("UserConnected", (username) => {
    showNotification(`${username} joined`);
});

connection.onreconnected(() => {
    console.log("Reconnected to SignalR hub");
    loadMissedMessages();
});

await connection.start();
```

## Scaling with a Backplane

In multi-server deployments, SignalR requires a backplane to route messages between servers. Azure SignalR Service, Redis backplane, or RabbitMQ can synchronize connections and messages across instances.

## References

- [SignalR Overview in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/signalr/introduction)
- [SignalR Hubs API Guide](https://learn.microsoft.com/en-us/aspnet/core/signalr/hubs)
- [SignalR Scaling with Azure](https://learn.microsoft.com/en-us/azure/azure-signalr/signalr-concept-scale-aspnet-core)
  $$,
  '11111111-1111-1111-1111-111111111111',
  2,
  1,
  8345,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000000f',
  'ASP.NET Core Best Practices',
  'aspnet-core-best-practices',
  'A collection of proven best practices for ASP.NET Core development covering project structure, performance, security, configuration management, and production readiness.',
  $$
## Introduction

Building production-ready ASP.NET Core applications requires more than just functional code. Following established best practices improves maintainability, performance, security, and team productivity. This article synthesizes recommendations from the ASP.NET Core team and the broader community into actionable guidelines.

## Project Structure and Organization

Organize your solution around Clean Architecture or Vertical Slices to maintain separation of concerns. Each layer should have clear responsibilities and dependencies should point inward toward the domain layer.

```csharp
// Recommended solution structure
MyApp.sln
├── src/
│   ├── MyApp.Domain/          // Entities, enums, business rules
│   │   ├── Entities/
│   │   ├── Enums/
│   │   └── Interfaces/
│   ├── MyApp.Application/     // CQRS commands, queries, DTOs
│   │   ├── Commands/
│   │   ├── Queries/
│   │   ├── DTOs/
│   │   └── Validators/
│   ├── MyApp.Infrastructure/  // EF Core, repositories, external services
│   │   ├── Data/
│   │   ├── Repositories/
│   │   └── Services/
│   └── MyApp.API/            // Controllers, middleware, configuration
│       ├── Controllers/
│       └── Middleware/
└── tests/
    ├── MyApp.UnitTests/
    └── MyApp.IntegrationTests/
```

## Performance Recommendations

| Practice | Impact | Implementation |
|---|---|---|
| Response caching | Reduces server load | Add [ResponseCache] attribute |
| Static file caching | Improves static asset delivery | Use StaticFileMiddleware with Cache-Control |
| Output caching (NET 8) | Caches entire responses | Use [OutputCache] attribute |
| JSON serialization options | Reduces payload size | Configure JsonSerializerOptions |
| Content compression | Reduces bandwidth | Use ResponseCompressionMiddleware |

```csharp
// Performance-oriented Program.cs configuration
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddResponseCaching();
builder.Services.AddOutputCache(options =>
{
    options.AddBasePolicy(policy => policy
        .Expire(TimeSpan.FromMinutes(10))
        .SetVaryByQuery("page", "size"));
});

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.SerializerOptions.DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull;
});

builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
    options.Providers.Add<BrotliCompressionProvider>();
    options.Providers.Add<GzipCompressionProvider>();
});
```

## Security Best Practices

Implement defense-in-depth with multiple security layers that protect your application at the edge, transport, and application level.

- Enforce HTTPS with HSTS in production environments
- Use anti-forgery tokens for all state-changing form submissions
- Validate and sanitize all user input to prevent injection attacks
- Store secrets in Azure Key Vault or GitHub Secrets, not in configuration files
- Apply the principle of least privilege for database connections and API keys
- Log security-relevant events and monitor for suspicious patterns

## Configuration and Environment Management

Use the options pattern with strongly-typed settings classes. Validate configuration at startup so failures are detected immediately rather than at runtime.

```bash
# Set environment-specific settings via environment variables
ASPNETCORE_ENVIRONMENT=Production
ConnectionStrings__Default=Server=prod-db;Database=MyApp;...
Jwt__SecretKey=<from-key-vault>
Jwt__ExpirationMinutes=15
```

## References

- [ASP.NET Core Best Practices Guide](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/best-practices)
- [ASP.NET Core Performance Best Practices](https://learn.microsoft.com/en-us/aspnet/core/performance/performance-best-practices)
- [Security Best Practices for ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/security/security-best-practices)
  $$,
  '11111111-1111-1111-1111-111111111111',
  2,
  1,
  7294,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000010',
  'OpenAPI Documentation with Swagger',
  'openapi-documentation-with-swagger',
  'Learn how to generate and customize OpenAPI documentation for ASP.NET Core APIs using Swashbuckle and NSwag, including XML comments, operation filters, and versioning.',
  $$
## Introduction

OpenAPI (formerly Swagger) is the industry-standard specification for describing RESTful APIs. ASP.NET Core integrates seamlessly with Swashbuckle and NSwag to automatically generate interactive API documentation from your code. Well-documented APIs improve developer experience, enable automated client generation, and serve as a single source of truth for API contracts.

## Setting Up Swashbuckle

Swashbuckle is the most popular OpenAPI library for ASP.NET Core. It reads API metadata from controllers, endpoints, XML comments, and custom attributes to generate a comprehensive OpenAPI specification.

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "DevWiki API",
        Version = "v1",
        Description = "Developer Knowledge Hub - REST API documentation",
        Contact = new OpenApiContact
        {
            Name = "DevWiki Team",
            Email = "support@devwiki.dev"
        },
        License = new OpenApiLicense
        {
            Name = "MIT License",
            Url = new Uri("https://opensource.org/licenses/MIT")
        }
    });

    // Enable XML comments
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
        options.IncludeXmlComments(xmlPath);

    // Add JWT authentication to Swagger UI
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        Description = "Enter your JWT token"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "DevWiki API v1");
        options.RoutePrefix = "api/docs";
        options.DocumentTitle = "DevWiki API Documentation";
    });
}

app.MapControllers();
app.Run();
```

## XML Comments for Rich Documentation

XML comments on controllers and models are automatically included in the generated OpenAPI spec, providing detailed descriptions for endpoints, parameters, and response types.

| Element | XML Tag | OpenAPI Effect |
|---|---|---|
| Controller | `<summary>` | Tag description |
| Action | `<summary>` | Operation summary |
| Parameter | `<param>` | Parameter description |
| Response | `<returns>` | Response description |
| Property | `<summary>` | Schema property description |
| Example | `<example>` | Schema property example value |

```csharp
/// <summary>
/// Manages article operations including CRUD and search.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
[Tags("Articles")]
public class ArticlesController : ControllerBase
{
    /// <summary>
    /// Retrieves a paginated list of articles with optional filtering.
    /// </summary>
    /// <param name="page">Page number (1-based).</param>
    /// <param name="size">Number of items per page (max 100).</param>
    /// <param name="categoryId">Optional category filter.</param>
    /// <returns>A paginated list of article summaries.</returns>
    /// <response code="200">Returns the paginated article list.</response>
    /// <response code="400">Invalid pagination parameters.</response>
    [HttpGet]
    [ProducesResponseType(typeof(PaginatedResult<ArticleSummaryDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<ActionResult<PaginatedResult<ArticleSummaryDto>>> GetArticles(
        [FromQuery] int page = 1,
        [FromQuery][Range(1, 100)] int size = 10,
        [FromQuery] Guid? categoryId = null)
    {
        var result = await _articleService.GetAllAsync(page, size, categoryId);
        return Ok(result);
    }
}
```

## Operation and Document Filters

Filters provide fine-grained control over the generated specification. Use operation filters to modify individual endpoints and document filters to add global metadata.

```csharp
public class AddCommonParametersFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        operation.Parameters ??= new List<OpenApiParameter>();

        operation.Parameters.Add(new OpenApiParameter
        {
            Name = "X-Correlation-Id",
            In = ParameterLocation.Header,
            Required = false,
            Schema = new OpenApiSchema { Type = "string", Format = "uuid" },
            Description = "Client-generated correlation ID for request tracing"
        });
    }
}

// Register the filter
options.OperationFilter<AddCommonParametersFilter>();
```

## References

- [Swashbuckle for ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/tutorials/web-api-help-pages-using-swagger)
- [OpenAPI Specification 3.0](https://spec.openapis.org/oas/v3.0.3)
- [NSwag for Client Generation](https://learn.microsoft.com/en-us/aspnet/core/tutorials/getting-started-with-nswag)
  $$,
  '11111111-1111-1111-1111-111111111111',
  2,
  1,
  4561,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
);

-- Refresh the sequence for generating future article IDs




