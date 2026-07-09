-- ============================================
-- 11_articles_systemdesign.sql
-- 6 articles in the System Design category (CategoryId = 8)
-- ============================================

INSERT INTO "Articles" ("ArticleId", "Title", "Slug", "Summary", "Content", "AuthorId", "CategoryId", "Status", "ViewCount", "CreatedAt", "UpdatedAt")
VALUES
(
  'a0000001-0000-0000-0000-00000000002c',
  'Clean Architecture in Practice',
  'clean-architecture-in-practice',
  'A practical guide to implementing Clean Architecture in .NET applications, covering layer separation, dependency inversion, and real-world project structure patterns for maintainable enterprise software.',
  $$
## Introduction

Clean Architecture, popularized by Robert C. Martin, is a software design philosophy that emphasizes separation of concerns through concentric layers. The core principle is that business logic should be independent of frameworks, databases, and UI concerns. This article walks through a practical .NET implementation.

## The Layered Structure

Clean Architecture typically consists of four layers:

| Layer | Responsibility | Dependencies |
|---|---|---|
| Domain | Entities, value objects, business rules | None |
| Application | Use cases, CQRS commands/queries, DTOs | Domain |
| Infrastructure | Database, external services, file system | Application (inward) |
| Presentation | API controllers, UI, middleware | Application |

The dependency rule states that source code dependencies can only point inward. Outer layers depend on inner layers, never the reverse.

## Project Structure

A typical .NET solution follows this layout:

```
MyApp.sln
├── MyApp.Domain/           # Entities, enums, interfaces
├── MyApp.Application/      # Commands, queries, handlers, DTOs
├── MyApp.Infrastructure/   # EF Core, repositories, external services
└── MyApp.API/              # Controllers, middleware, Program.cs
```

### Domain Layer

The domain layer contains enterprise-wide business rules. It has no external dependencies:

```csharp
public class Article
{
    public Guid Id { get; private set; }
    public string Title { get; private set; }
    public string Content { get; private set; }
    public ArticleStatus Status { get; private set; }

    private Article() { } // For EF Core

    public Article(string title, string content)
    {
        Id = Guid.NewGuid();
        Title = title;
        Content = content;
        Status = ArticleStatus.Draft;
    }

    public void Publish()
    {
        if (Status != ArticleStatus.Draft)
            throw new DomainException("Only draft articles can be published.");
        Status = ArticleStatus.Published;
    }
}
```

### Application Layer

The application layer orchestrates use cases. It depends only on the domain layer:

```csharp
public class CreateArticleCommand : IRequest<ApiResponse<ArticleDto>>
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public Guid CategoryId { get; set; }
}

public class CreateArticleCommandHandler : IRequestHandler<CreateArticleCommand, ApiResponse<ArticleDto>>
{
    private readonly IArticleRepository _repository;
    private readonly IUnitOfWork _unitOfWork;

    public CreateArticleCommandHandler(IArticleRepository repository, IUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<ArticleDto>> Handle(CreateArticleCommand request, CancellationToken cancellationToken)
    {
        var article = new Article(request.Title, request.Content);
        await _repository.AddAsync(article);
        await _unitOfWork.SaveChangesAsync(cancellationToken);
        return ApiResponse<ArticleDto>.Success(ArticleDto.FromEntity(article));
    }
}
```

### Infrastructure Layer

The infrastructure layer implements interfaces defined in the domain or application layer:

```csharp
public class EfArticleRepository : IArticleRepository
{
    private readonly AppDbContext _context;

    public EfArticleRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<Article?> GetByIdAsync(Guid id)
    {
        return await _context.Articles.FindAsync(id);
    }

    public async Task AddAsync(Article article)
    {
        await _context.Articles.AddAsync(article);
    }
}
```

## Dependency Injection Wiring

Wire everything together in `Program.cs`:

```csharp
builder.Services.AddScoped<IArticleRepository, EfArticleRepository>();
builder.Services.AddScoped<IUnitOfWork, EfUnitOfWork>();
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(CreateArticleCommandHandler).Assembly));
```

## Testing Benefits

Clean Architecture significantly improves testability:

- **Domain logic** can be tested without database or HTTP context
- **Application handlers** can be unit tested with mocked repositories
- **Infrastructure** code can be integration tested against a test database

```csharp
[Fact]
public async Task CreateArticle_WithValidData_ReturnsSuccess()
{
    var repo = new Mock<IArticleRepository>();
    var uow = new Mock<IUnitOfWork>();
    var handler = new CreateArticleCommandHandler(repo.Object, uow.Object);

    var result = await handler.Handle(new CreateArticleCommand
    {
        Title = "Test",
        Content = "Content",
        CategoryId = Guid.NewGuid()
    }, CancellationToken.None);

    Assert.True(result.Success);
}
```

## Common Pitfalls

| Pitfall | Consequence | Solution |
|---|---|---|
| Domain depends on EF | Tight coupling to ORM | Keep domain POCO |
| Application references Infrastructure | Circular dependencies | Use DI and interface inversion |
| Skip application layer | Business logic leaks to controllers | Always use MediatR or similar |
| Anemic domain model | Business rules scatter everywhere | Add behavior to entities |

## References

- [Clean Architecture by Robert C. Martin](https://www.oreilly.com/library/view/clean-architecture-a/9780134494272/)
- [Microsoft eShopOnWeb Reference App](https://github.com/dotnet-architecture/eShopOnWeb)
- [Jason Taylor Clean Architecture Template](https://github.com/jasontaylordev/CleanArchitecture)
  $$,
  '11111111-1111-1111-1111-111111111111',
  8, 1, 4532,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000002d',
  'CQRS Pattern Implementation',
  'cqrs-pattern-implementation',
  'A deep dive into implementing the Command Query Responsibility Segregation pattern with MediatR in .NET, covering command and query separation, pipeline behaviors, and validation strategies.',
  $$
## Introduction

Command Query Responsibility Segregation (CQRS) separates read and write operations into distinct models. Instead of using a single model for both queries and commands, CQRS introduces separate interfaces, handlers, and often separate data stores. This article demonstrates a practical implementation using MediatR in .NET.

## Core Concepts

CQRS divides operations into two categories:

| Operation | Purpose | Returns Data | Mutates State |
|---|---|---|---|
| Command | Perform an action | No (void) | Yes |
| Query | Retrieve data | Yes | No |

This separation enables optimized read models, simplified write models, and independent scaling.

## Commands

A command represents an intent to change state. Commands are named in the imperative:

```csharp
public class UpdateArticleCommand : IRequest<ApiResponse<Unit>>
{
    public Guid ArticleId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
}
```

Command handlers encapsulate the write logic:

```csharp
public class UpdateArticleCommandHandler : IRequestHandler<UpdateArticleCommand, ApiResponse<Unit>>
{
    private readonly IArticleRepository _repository;
    private readonly IUnitOfWork _unitOfWork;

    public UpdateArticleCommandHandler(IArticleRepository repository, IUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<Unit>> Handle(UpdateArticleCommand request, CancellationToken ct)
    {
        var article = await _repository.GetByIdAsync(request.ArticleId);
        if (article is null)
            return ApiResponse<Unit>.Fail("Article not found.");

        article.UpdateTitle(request.Title);
        article.UpdateContent(request.Content);
        await _unitOfWork.SaveChangesAsync(ct);

        return ApiResponse<Unit>.Success(Unit.Value);
    }
}
```

## Queries

Queries retrieve data without side effects. They can return shapes optimized for the view:

```csharp
public class GetArticleListQuery : IRequest<ApiResponse<PaginatedResult<ArticleSummaryDto>>>
{
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
    public string? SearchTerm { get; set; }
}

public class GetArticleListQueryHandler : IRequestHandler<GetArticleListQuery, ApiResponse<PaginatedResult<ArticleSummaryDto>>>
{
    private readonly IArticleReadRepository _readRepository;

    public GetArticleListQueryHandler(IArticleReadRepository readRepository)
    {
        _readRepository = readRepository;
    }

    public async Task<ApiResponse<PaginatedResult<ArticleSummaryDto>>> Handle(
        GetArticleListQuery request, CancellationToken ct)
    {
        var articles = await _readRepository.GetPagedAsync(
            request.Page, request.PageSize, request.SearchTerm, ct);

        return ApiResponse<PaginatedResult<ArticleSummaryDto>>.Success(articles);
    }
}
```

## Pipeline Behaviors

MediatR pipeline behaviors add cross-cutting concerns without modifying handlers:

```csharp
public class ValidationBehavior<TRequest, TResponse> : IPipelineBehavior<TRequest, TResponse>
    where TRequest : IRequest<TResponse>
{
    private readonly IEnumerable<IValidator<TRequest>> _validators;

    public ValidationBehavior(IEnumerable<IValidator<TRequest>> validators)
    {
        _validators = validators;
    }

    public async Task<TResponse> Handle(TRequest request, RequestHandlerDelegate<TResponse> next, CancellationToken ct)
    {
        if (!_validators.Any())
            return await next();

        var context = new ValidationContext<TRequest>(request);
        var failures = _validators
            .Select(v => v.Validate(context))
            .SelectMany(r => r.Errors)
            .Where(e => e is not null)
            .ToList();

        if (failures.Count != 0)
            throw new ValidationException(failures);

        return await next();
    }
}
```

## When to Use CQRS

CQRS is not always the right choice. Consider it when:

- Read and write workloads have significantly different patterns
- The domain model is complex with many business rules
- You need different data shapes for reads versus writes
- Team scalability requires separate read/write ownership

For simple CRUD applications, CQRS introduces unnecessary complexity without meaningful benefit.

## Validation Strategy

Pair commands and queries with FluentValidation validators:

```csharp
public class UpdateArticleCommandValidator : AbstractValidator<UpdateArticleCommand>
{
    public UpdateArticleCommandValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty()
            .MaximumLength(200);

        RuleFor(x => x.Content)
            .NotEmpty()
            .MinimumLength(50);
    }
}
```

Register validators and the validation behavior in the DI container:

```csharp
builder.Services.AddValidatorsFromAssembly(typeof(UpdateArticleCommandValidator).Assembly);
builder.Services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));
```

## References

- [Microsoft: CQRS Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/cqrs)
- [MediatR GitHub Repository](https://github.com/jbogard/MediatR)
- [FluentValidation Documentation](https://docs.fluentvalidation.net/)
  $$,
  '11111111-1111-1111-1111-111111111111',
  8, 1, 6124,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000002e',
  'Repository Pattern with Unit of Work',
  'repository-pattern-with-unit-of-work',
  'Understanding the Repository and Unit of Work patterns in .NET — how to abstract data access, compose transactional operations, and write testable data layer code with EF Core.',
  $$
## Introduction

The Repository pattern mediates between the domain and data mapping layers, acting like an in-memory collection of domain objects. The Unit of Work pattern maintains a list of objects affected by a business transaction and coordinates the persistence of changes. Together, they provide a clean abstraction over data access.

## Repository Pattern

A repository encapsulates the logic for retrieving and persisting objects. It presents the illusion of an in-memory collection:

```csharp
public interface IArticleRepository
{
    Task<Article?> GetByIdAsync(Guid id);
    Task<IEnumerable<Article>> GetAllAsync();
    Task<PaginatedResult<Article>> GetPagedAsync(int page, int pageSize);
    Task AddAsync(Article article);
    void Update(Article article);
    void Delete(Article article);
}
```

The implementation delegates to the data store:

```csharp
public class ArticleRepository : IArticleRepository
{
    private readonly AppDbContext _context;

    public ArticleRepository(AppDbContext context)
    {
        _context = context;
    }

    public async Task<Article?> GetByIdAsync(Guid id)
    {
        return await _context.Articles
            .Include(a => a.Category)
            .Include(a => a.Tags)
            .FirstOrDefaultAsync(a => a.Id == id);
    }

    public async Task<PaginatedResult<Article>> GetPagedAsync(int page, int pageSize)
    {
        var query = _context.Articles.OrderByDescending(a => a.CreatedAt);
        var total = await query.CountAsync();
        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return new PaginatedResult<Article>(items, total, page, pageSize);
    }

    public async Task AddAsync(Article article)
    {
        await _context.Articles.AddAsync(article);
    }

    public void Update(Article article)
    {
        _context.Articles.Update(article);
    }

    public void Delete(Article article)
    {
        _context.Articles.Remove(article);
    }
}
```

## Generic Repository

A generic repository reduces boilerplate for basic CRUD:

```csharp
public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(Guid id);
    Task<IEnumerable<T>> GetAllAsync();
    Task AddAsync(T entity);
    void Update(T entity);
    void Delete(T entity);
}

public class EfRepository<T> : IRepository<T> where T : class
{
    protected readonly AppDbContext _context;
    protected readonly DbSet<T> _dbSet;

    public EfRepository(AppDbContext context)
    {
        _context = context;
        _dbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(Guid id) => await _dbSet.FindAsync(id);
    public async Task<IEnumerable<T>> GetAllAsync() => await _dbSet.ToListAsync();
    public async Task AddAsync(T entity) => await _dbSet.AddAsync(entity);
    public void Update(T entity) => _dbSet.Update(entity);
    public void Delete(T entity) => _dbSet.Remove(entity);
}
```

Use the generic repository for standard entities and create specific repositories for complex querying needs.

## Unit of Work

The Unit of Work ensures multiple repository operations are committed atomically:

```csharp
public interface IUnitOfWork
{
    IArticleRepository Articles { get; }
    ICategoryRepository Categories { get; }
    Task<int> SaveChangesAsync(CancellationToken ct = default);
    Task BeginTransactionAsync();
    Task CommitTransactionAsync();
    Task RollbackTransactionAsync();
}

public class EfUnitOfWork : IUnitOfWork
{
    private readonly AppDbContext _context;
    private IArticleRepository? _articles;
    private ICategoryRepository? _categories;

    public EfUnitOfWork(AppDbContext context)
    {
        _context = context;
    }

    public IArticleRepository Articles =>
        _articles ??= new ArticleRepository(_context);

    public ICategoryRepository Categories =>
        _categories ??= new CategoryRepository(_context);

    public async Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        return await _context.SaveChangesAsync(ct);
    }

    public async Task BeginTransactionAsync()
    {
        await _context.Database.BeginTransactionAsync();
    }

    public async Task CommitTransactionAsync()
    {
        await _context.Database.CommitTransactionAsync();
    }

    public async Task RollbackTransactionAsync()
    {
        await _context.Database.RollbackTransactionAsync();
    }
}
```

## Transactional Example

```csharp
public async Task<ApiResponse<ArticleDto>> CreateArticleWithTagsAsync(
    CreateArticleCommand command, CancellationToken ct)
{
    await _unitOfWork.BeginTransactionAsync();
    try
    {
        var article = new Article(command.Title, command.Content);
        await _unitOfWork.Articles.AddAsync(article);

        foreach (var tagId in command.TagIds)
        {
            var tag = await _unitOfWork.Categories.GetByIdAsync(tagId);
            if (tag is not null)
                article.AddTag(tag);
        }

        await _unitOfWork.SaveChangesAsync(ct);
        await _unitOfWork.CommitTransactionAsync();

        return ApiResponse<ArticleDto>.Success(ArticleDto.FromEntity(article));
    }
    catch
    {
        await _unitOfWork.RollbackTransactionAsync();
        throw;
    }
}
```

## Testing Benefits

Mocking repositories and unit of work enables isolated unit tests:

```csharp
[Fact]
public async Task CreateArticle_WithTags_CommitsTransaction()
{
    var uow = new Mock<IUnitOfWork>();
    var repo = new Mock<IArticleRepository>();
    uow.Setup(x => x.Articles).Returns(repo.Object);

    var handler = new CreateArticleWithTagsHandler(uow.Object);
    var result = await handler.Handle(new CreateArticleCommand
    {
        Title = "Test",
        Content = "Long enough content...",
        TagIds = new List<Guid> { Guid.NewGuid() }
    }, CancellationToken.None);

    uow.Verify(x => x.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    uow.Verify(x => x.CommitTransactionAsync(), Times.Once);
}
```

## References

- [Martin Fowler: Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [Martin Fowler: Unit of Work](https://martinfowler.com/eaaCatalog/unitOfWork.html)
- [Microsoft: Persistence Patterns](https://docs.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/infrastructure-persistence-layer-design)
  $$,
  '11111111-1111-1111-1111-111111111111',
  8, 1, 3789,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-00000000002f',
  'Designing RESTful APIs',
  'designing-restful-apis',
  'Best practices for designing RESTful APIs — resource modeling, HTTP verb usage, status codes, versioning strategies, pagination, and securing endpoints with authentication and authorization.',
  $$
## Introduction

REST (Representational State Transfer) is an architectural style for designing networked applications. A well-designed RESTful API is intuitive, consistent, and scalable. This article covers the core principles and practical patterns for building REST APIs with ASP.NET Core.

## Resource Modeling

Resources are the key abstraction in REST. Model them as nouns:

| Resource | HTTP Verb | Endpoint | Purpose |
|---|---|---|---|
| Articles | GET | `/api/articles` | List articles |
| Articles | GET | `/api/articles/{id}` | Get single article |
| Articles | POST | `/api/articles` | Create article |
| Articles | PUT | `/api/articles/{id}` | Replace article |
| Articles | PATCH | `/api/articles/{id}` | Partial update |
| Articles | DELETE | `/api/articles/{id}` | Delete article |

Use plural nouns for collection resources and nest related resources:

```
GET    /api/articles/{articleId}/comments
POST   /api/articles/{articleId}/comments
GET    /api/articles/{articleId}/comments/{commentId}
DELETE /api/articles/{articleId}/comments/{commentId}
```

## HTTP Status Codes

Use standard HTTP status codes consistently:

| Code | Meaning | When to Use |
|---|---|---|
| 200 OK | Success | GET, PUT, PATCH succeeded |
| 201 Created | Resource created | POST succeeded |
| 204 No Content | Success, no body | DELETE succeeded |
| 400 Bad Request | Invalid input | Validation failure |
| 401 Unauthorized | Missing/invalid auth | No valid JWT |
| 403 Forbidden | Insufficient role | Valid auth but no permission |
| 404 Not Found | Resource missing | Invalid ID |
| 409 Conflict | State conflict | Duplicate or version conflict |
| 500 Server Error | Unexpected failure | Unhandled exception |

## Request Validation

Always validate input at the API boundary:

```csharp
public class CreateArticleRequest
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    [MinLength(50)]
    public string Content { get; set; } = string.Empty;

    [Required]
    public Guid CategoryId { get; set; }

    public List<Guid> TagIds { get; set; } = new();
}

[HttpPost]
public async Task<IActionResult> CreateArticle([FromBody] CreateArticleRequest request)
{
    if (!ModelState.IsValid)
        return BadRequest(ModelState);

    var command = _mapper.Map<CreateArticleCommand>(request);
    var result = await _mediator.Send(command);

    if (!result.Success)
        return BadRequest(new { error = result.Message });

    return CreatedAtAction(nameof(GetArticle), new { id = result.Data.Id }, result.Data);
}
```

## Pagination and Filtering

Always paginate list endpoints and return metadata:

```csharp
[HttpGet]
public async Task<IActionResult> GetArticles(
    [FromQuery] int page = 1,
    [FromQuery] int pageSize = 20,
    [FromQuery] string? search = null,
    [FromQuery] Guid? categoryId = null)
{
    var query = new GetArticleListQuery
    {
        Page = page,
        PageSize = pageSize,
        SearchTerm = search,
        CategoryId = categoryId
    };

    var result = await _mediator.Send(query);
    return Ok(result);
}
```

Response with pagination metadata:

```json
{
  "success": true,
  "data": {
    "items": [...],
    "totalCount": 143,
    "page": 1,
    "pageSize": 20,
    "totalPages": 8,
    "hasPreviousPage": false,
    "hasNextPage": true
  }
}
```

## Versioning

Version your API to manage breaking changes:

```csharp
// URL path versioning
builder.Services.AddApiVersioning(options =>
{
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.ReportApiVersions = true;
    options.ApiVersionReader = new UrlSegmentApiVersionReader();
});

// Controller attribute
[ApiVersion("1.0")]
[Route("api/v{version:apiVersion}/articles")]
[ApiController]
public class ArticlesController : ControllerBase
{
}
```

## Security

Secure your API with JWT authentication and role-based authorization:

```csharp
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:SecretKey"]!))
        };
    });

[HttpPost]
[Authorize(Roles = "Admin,Editor")]
public async Task<IActionResult> CreateArticle([FromBody] CreateArticleRequest request)
{
    // Only Admin or Editor roles can create articles
}
```

## References

- [Microsoft: RESTful API Design](https://docs.microsoft.com/en-us/azure/architecture/best-practices/api-design)
- [REST API Tutorial](https://restfulapi.net/)
- [Roy Fielding: Architectural Styles and REST](https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm)
  $$,
  '11111111-1111-1111-1111-111111111111',
  8, 1, 8251,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000030',
  'Microservices Communication Patterns',
  'microservices-communication-patterns',
  'Explore the key communication patterns for microservices architectures — synchronous HTTP, asynchronous messaging, event-driven design, and service discovery with practical .NET examples.',
  $$
## Introduction

Microservices communicate over the network, introducing challenges that monolithic applications never face. Choosing the right communication pattern is critical for system reliability, performance, and maintainability. This article covers the most common patterns with .NET implementation examples.

## Communication Styles

Microservices use two primary communication styles:

| Style | Mechanism | Coupling | Use Case |
|---|---|---|---|
| Synchronous | HTTP/gRPC | Temporal | Request-response queries |
| Asynchronous | Message broker | Loose | Event notifications, background processing |

## Synchronous with HTTP

The simplest approach uses HTTP requests between services:

```csharp
public class OrderServiceClient
{
    private readonly HttpClient _httpClient;

    public OrderServiceClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<OrderDto?> GetOrderAsync(Guid orderId)
    {
        var response = await _httpClient.GetAsync($"/api/orders/{orderId}");
        if (!response.IsSuccessStatusCode)
            return null;

        return await response.Content.ReadFromJsonAsync<OrderDto>();
    }
}
```

Register with resilience policies:

```csharp
builder.Services.AddHttpClient<IOrderServiceClient, OrderServiceClient>(client =>
{
    client.BaseAddress = new Uri("https://order-service.internal");
    client.Timeout = TimeSpan.FromSeconds(5);
})
.AddTransientHttpErrorPolicy(p => p.RetryAsync(3))
.AddTransientHttpErrorPolicy(p => p.CircuitBreakerAsync(5, TimeSpan.FromSeconds(30)));
```

## Asynchronous Messaging

Use a message broker like RabbitMQ or Azure Service Bus for asynchronous communication:

```csharp
public class OrderCreatedEvent : IEvent
{
    public Guid OrderId { get; set; }
    public Guid CustomerId { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime CreatedAt { get; set; }
}

// Publisher
public class EventPublisher : IEventPublisher
{
    private readonly IConnection _connection;

    public EventPublisher(IConnection connection)
    {
        _connection = connection;
    }

    public async Task PublishAsync<T>(T @event, CancellationToken ct) where T : IEvent
    {
        using var channel = await _connection.CreateChannelAsync();
        await channel.ExchangeDeclareAsync("orders", ExchangeType.Topic, durable: true);

        var body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(@event));
        await channel.BasicPublishAsync("orders", @event.GetType().Name, body);
    }
}

// Consumer (runs in a background service)
public class OrderCreatedConsumer : BackgroundService
{
    private readonly IConnection _connection;
    private readonly IServiceScopeFactory _scopeFactory;

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var channel = await _connection.CreateChannelAsync();
        await channel.ExchangeDeclareAsync("orders", ExchangeType.Topic, durable: true);
        var queue = await channel.QueueDeclareAsync("inventory-orders", durable: true);
        await channel.QueueBindAsync(queue, "orders", "OrderCreatedEvent");

        while (!stoppingToken.IsCancellationRequested)
        {
            var result = await channel.BasicConsumeAsync(queue, autoAck: false);
            // Process the event...
        }
    }
}
```

## Event-Driven Architecture

Event-driven systems publish domain events that multiple services consume:

```
┌─────────────┐     ┌──────────────────┐     ┌──────────────┐
│  Order      │────→│  Message Broker  │────→│  Inventory   │
│  Service    │     │  (RabbitMQ/Kafka)│     │  Service     │
└─────────────┘     └──────────────────┘     └──────────────┘
                           │
                           ├────────────────→┌──────────────┐
                           │                 │  Notification│
                           │                 │  Service     │
                           │                 └──────────────┘
                           ├────────────────→┌──────────────┐
                           │                 │  Analytics   │
                           │                 │  Service     │
                           │                 └──────────────┘
```

## Service Discovery

In containerized environments, use service discovery to locate service instances:

```bash
# Docker Compose with internal DNS
services:
  order-service:
    image: myapp/orders:latest
    ports:
      - "5001:80"
    environment:
      - INVENTORY_URL=http://inventory-service:80

  inventory-service:
    image: myapp/inventory:latest
    ports:
      - "5002:80"

  rabbitmq:
    image: rabbitmq:3-management
    ports:
      - "5672:5672"
      - "15672:15672"
```

## Choosing the Right Pattern

| Factor | Choose Sync (HTTP/gRPC) | Choose Async (Messaging) |
|---|---|---|
| Response required immediately | Yes | No |
| Fault tolerance | Low | High |
| Coupling acceptance | Temporal only | Loose |
| Complexity tolerance | Lower | Higher |
| Scaling needs | Per-request | Eventual consistency OK |

## Saga Pattern for Distributed Transactions

Use the Saga pattern to maintain data consistency across services:

```csharp
public class CreateOrderSaga
{
    private readonly IOrderServiceClient _orders;
    private readonly IPaymentServiceClient _payments;
    private readonly IInventoryServiceClient _inventory;

    public async Task<bool> ExecuteAsync(CreateOrderRequest request)
    {
        var orderId = await _orders.ReserveOrderAsync(request);
        var paymentOk = await _payments.ProcessPaymentAsync(orderId, request.Amount);

        if (!paymentOk)
        {
            await _orders.CancelOrderAsync(orderId);
            return false;
        }

        var inventoryOk = await _inventory.ReserveItemsAsync(request.Items);

        if (!inventoryOk)
        {
            await _orders.CancelOrderAsync(orderId);
            await _payments.RefundPaymentAsync(orderId);
            return false;
        }

        await _orders.ConfirmOrderAsync(orderId);
        return true;
    }
}
```

## References

- [Microsoft: Microservices Communication](https://docs.microsoft.com/en-us/azure/architecture/patterns/category/communication)
- [Saga Pattern in Microservices](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/saga/saga)
- [RabbitMQ .NET Client Guide](https://www.rabbitmq.com/dotnet.html)
  $$,
  '11111111-1111-1111-1111-111111111111',
  8, 1, 5467,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
),
(
  'a0000001-0000-0000-0000-000000000031',
  'Caching Strategies for Web Applications',
  'caching-strategies-for-web-applications',
  'A comprehensive overview of caching strategies for web applications — in-memory caching, distributed caching, HTTP caching, cache invalidation patterns, and implementing them in .NET.',
  $$
## Introduction

Caching is one of the most effective techniques for improving web application performance. By storing frequently accessed data in a fast-access layer, caching reduces database load, lowers latency, and improves throughput. This article covers the major caching strategies and their .NET implementation.

## Caching Layers

Web applications benefit from caching at multiple levels:

| Layer | Storage | Latency | Duration |
|---|---|---|---|
| Browser cache | Local disk | Sub-ms | Minutes to hours |
| CDN | Edge servers | 5-50 ms | Minutes to days |
| In-memory cache | App server RAM | < 1 ms | Seconds to minutes |
| Distributed cache | Redis/Memcached | 1-5 ms | Minutes to hours |
| Database cache | Buffer pool | 5-20 ms | Transient |

## In-Memory Caching

.NET provides an in-memory cache via `IMemoryCache`:

```csharp
public class ArticleCacheService
{
    private readonly IMemoryCache _cache;
    private readonly IArticleRepository _repository;

    public ArticleCacheService(IMemoryCache cache, IArticleRepository repository)
    {
        _cache = cache;
        _repository = repository;
    }

    public async Task<ArticleDto?> GetArticleAsync(Guid id)
    {
        var cacheKey = $"article:{id}";

        if (_cache.TryGetValue(cacheKey, out ArticleDto? cached))
            return cached;

        var article = await _repository.GetByIdAsync(id);
        if (article is null)
            return null;

        var dto = ArticleDto.FromEntity(article);

        _cache.Set(cacheKey, dto, new MemoryCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5),
            SlidingExpiration = TimeSpan.FromMinutes(1),
            Priority = CacheItemPriority.High
        });

        return dto;
    }

    public void InvalidateArticle(Guid id)
    {
        _cache.Remove($"article:{id}");
    }
}
```

## Distributed Caching with Redis

For multi-instance deployments, use a distributed cache:

```csharp
// Program.cs
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = builder.Configuration.GetConnectionString("Redis");
    options.InstanceName = "DevWiki:";
});

// Usage
public class DistributedArticleCache
{
    private readonly IDistributedCache _cache;

    public DistributedArticleCache(IDistributedCache cache)
    {
        _cache = cache;
    }

    public async Task<ArticleDto?> GetArticleAsync(Guid id)
    {
        var cacheKey = $"article:{id}";
        var cached = await _cache.GetStringAsync(cacheKey);

        if (cached is not null)
            return JsonSerializer.Deserialize<ArticleDto>(cached);

        return null;
    }

    public async Task SetArticleAsync(Guid id, ArticleDto dto)
    {
        var cacheKey = $"article:{id}";
        var options = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(30)
        };

        await _cache.SetStringAsync(cacheKey, JsonSerializer.Serialize(dto), options);
    }
}
```

## Cache-Aside Pattern

The most common caching pattern is cache-aside:

```csharp
public async Task<ArticleDto> GetArticleWithCacheAsideAsync(Guid id)
{
    var cacheKey = $"article:{id}";

    // 1. Check cache
    var cached = await _distributedCache.GetStringAsync(cacheKey);
    if (cached is not null)
        return JsonSerializer.Deserialize<ArticleDto>(cached)!;

    // 2. Cache miss — load from database
    var article = await _repository.GetByIdAsync(id);
    if (article is null)
        throw new NotFoundException("Article not found.");

    var dto = ArticleDto.FromEntity(article);

    // 3. Populate cache
    var options = new DistributedCacheEntryOptions
    {
        AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(30)
    };
    await _distributedCache.SetStringAsync(cacheKey, JsonSerializer.Serialize(dto), options);

    return dto;
}
```

## Cache Invalidation Strategies

Invalidation is the hardest problem in caching:

| Strategy | Mechanism | Pros | Cons |
|---|---|---|---|
| TTL-based | Time expiration | Simple, automatic | Stale data until expiry |
| Write-through | Update cache on write | Always fresh | More write latency |
| Write-behind | Async cache update | Fast writes | Potential inconsistency |
| Manual removal | Explicit `Remove()` | Precise control | Requires developer discipline |
| Pub/sub invalidation | Broadcast invalidation events | Scalable across instances | More infrastructure |

Implement invalidation on write operations:

```csharp
public async Task<ApiResponse<Unit>> UpdateArticleAsync(UpdateArticleCommand command)
{
    var article = await _repository.GetByIdAsync(command.ArticleId);
    if (article is null)
        return ApiResponse<Unit>.Fail("Article not found.");

    article.UpdateTitle(command.Title);
    article.UpdateContent(command.Content);
    await _unitOfWork.SaveChangesAsync();

    // Invalidate cache
    await _cacheService.InvalidateArticleAsync(command.ArticleId);

    return ApiResponse<Unit>.Success(Unit.Value);
}
```

## HTTP Caching Headers

Leverage browser and CDN caching with response headers:

```csharp
[HttpGet("{id}")]
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByQueryKeys = ["id"])]
public async Task<IActionResult> GetArticle(Guid id)
{
    var article = await _mediator.Send(new GetArticleQuery { Id = id });
    return Ok(article);
}
```

This produces the following response headers:

```http
HTTP/1.1 200 OK
Cache-Control: public, max-age=300
Vary: id
```

## Performance Metrics

Real-world caching benefits:

| Scenario | Without Cache | With Cache | Improvement |
|---|---|---|---|
| Article detail page | 120 ms | 3 ms | 97.5% |
| Category listing | 250 ms | 8 ms | 96.8% |
| Search results | 450 ms | 15 ms | 96.7% |
| Dashboard metrics | 2.1 s | 45 ms | 97.9% |

## Monitoring Cache Performance

Track key metrics to validate your caching strategy:

- **Hit ratio**: Percentage of requests served from cache
- **Miss ratio**: Percentage that fall through to the database
- **Eviction rate**: How often cache entries are removed
- **Memory usage**: RAM consumption by the cache

```bash
# Redis monitoring
redis-cli INFO stats
redis-cli INFO memory
```

## References

- [Microsoft: Caching in .NET](https://docs.microsoft.com/en-us/dotnet/core/extensions/caching)
- [Redis Documentation](https://redis.io/documentation)
- [Martin Fowler: Cache Aside Pattern](https://martinfowler.com/bliki/CacheAsidePattern.html)
  $$,
  '11111111-1111-1111-1111-111111111111',
  8, 1, 9834,
  '2026-07-08T10:00:00Z',
  '2026-07-08T10:00:00Z'
);

-- Refresh the sequence for generating future article IDs




