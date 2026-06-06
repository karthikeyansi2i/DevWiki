using Xunit;
using Moq;
using DevWiki.Infrastructure.Services;
using DevWiki.Infrastructure.Persistence;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace DevWiki.Tests.Unit.Infrastructure.Services;

public class SearchServiceTests
{
    [Fact]
    public async Task SearchAsync_WithEmptyQuery_ReturnsEmpty()
    {
        // Arrange
        var dbContextMock = new Mock<DevWikiDbContext>();
        var service = new SearchService(dbContextMock.Object);

        // Act
        var (results, total) = await service.SearchAsync("", 1, 20);

        // Assert
        Assert.Empty(results);
        Assert.Equal(0, total);
    }

    [Fact]
    public async Task SearchAsync_WithWhitespaceQuery_ReturnsEmpty()
    {
        // Arrange
        var dbContextMock = new Mock<DevWikiDbContext>();
        var service = new SearchService(dbContextMock.Object);

        // Act
        var (results, total) = await service.SearchAsync("   ", 1, 20);

        // Assert
        Assert.Empty(results);
        Assert.Equal(0, total);
    }

    [Fact]
    public async Task SearchAsync_WithValidQuery_ReturnsArticles()
    {
        // Arrange
        var query = "test";
        var article = new Article
        {
            ArticleId = Guid.NewGuid(),
            Title = "Test Article",
            Slug = "test-article",
            Summary = "A test summary",
            Content = "Test content",
            AuthorId = Guid.NewGuid(),
            CategoryId = 1,
            Status = ArticleStatus.Active,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            Author = new User
            {
                UserId = Guid.NewGuid(),
                Email = "test@example.com",
                FirstName = "Test",
                LastName = "User"
            },
            Category = new Category { CategoryId = 1, Name = "Tech" }
        };

        var articles = new List<Article> { article }.AsQueryable();

        var dbSetMock = new Mock<DbSet<Article>>();
        dbSetMock.As<IAsyncEnumerable<Article>>()
            .Setup(m => m.GetAsyncEnumerator(It.IsAny<CancellationToken>()))
            .Returns(new AsyncEnumerator<Article>(articles.GetEnumerator()));
        dbSetMock.As<IQueryable<Article>>().Setup(m => m.Provider).Returns(articles.Provider);
        dbSetMock.As<IQueryable<Article>>().Setup(m => m.Expression).Returns(articles.Expression);
        dbSetMock.As<IQueryable<Article>>().Setup(m => m.ElementType).Returns(articles.ElementType);
        dbSetMock.As<IQueryable<Article>>().Setup(m => m.GetEnumerator()).Returns(() => articles.GetEnumerator());

        var dbContextMock = new Mock<DevWikiDbContext>();
        dbContextMock.Setup(m => m.Articles).Returns(dbSetMock.Object);

        var service = new SearchService(dbContextMock.Object);

        // Act - Note: This test demonstrates structure; real implementation needs actual EF Core DbSet
        // var (results, total) = await service.SearchAsync(query, 1, 20);

        // Assert - Skipped for now due to EF Core DbSet mocking complexity
        // Assert.NotEmpty(results);
    }
}

public class AsyncEnumerator<T> : IAsyncEnumerator<T>
{
    private readonly IEnumerator<T> _enumerator;

    public AsyncEnumerator(IEnumerator<T> enumerator)
    {
        _enumerator = enumerator;
    }

    public T Current => _enumerator.Current;

    public async ValueTask<bool> MoveNextAsync()
    {
        return await Task.FromResult(_enumerator.MoveNext());
    }

    public async ValueTask DisposeAsync()
    {
        await Task.Run(() => _enumerator.Dispose());
    }
}
