using Moq;
using DevWiki.Application.Commands.Snippets;
using DevWiki.Application.Handlers.Snippets;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace DevWiki.Tests.Unit.Application.Handlers.Snippets;

public class CreateCodeSnippetCommandHandlerTests
{
    private readonly Mock<IUnitOfWork> _unitOfWorkMock;
    private readonly Mock<ILogger<CreateCodeSnippetCommandHandler>> _loggerMock;
    private readonly CreateCodeSnippetCommandHandler _handler;
    private readonly Article _testArticle;

    public CreateCodeSnippetCommandHandlerTests()
    {
        _unitOfWorkMock = new Mock<IUnitOfWork>();
        _loggerMock = new Mock<ILogger<CreateCodeSnippetCommandHandler>>();
        _handler = new CreateCodeSnippetCommandHandler(_unitOfWorkMock.Object, _loggerMock.Object);

        _testArticle = new Article
        {
            ArticleId = Guid.NewGuid(),
            Title = "Test Article",
            Slug = "test-article",
            Content = "Content",
            Summary = "Summary",
            AuthorId = Guid.NewGuid(),
            CategoryId = 1,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
            Author = new User
            {
                UserId = Guid.NewGuid(),
                Email = "author@test.com",
                FirstName = "Author",
                LastName = "User"
            }
        };
    }

    [Fact]
    public async Task Handle_WithValidCommand_CreatesSnippet()
    {
        // Arrange
        var command = new CreateCodeSnippetCommand
        {
            ArticleId = _testArticle.ArticleId,
            Title = "AddScoped Example",
            Description = "Shows AddScoped usage",
            Language = "C#",
            Code = "services.AddScoped<IUserService, UserService>();",
            CreatedBy = Guid.NewGuid()
        };

        _unitOfWorkMock.Setup(u => u.Articles.GetByIdAsync(command.ArticleId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(_testArticle);

        _unitOfWorkMock.Setup(u => u.CodeSnippets.AddAsync(It.IsAny<CodeSnippet>(), It.IsAny<CancellationToken>()))
            .Returns(Task.CompletedTask);

        _unitOfWorkMock.Setup(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(1);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.True(result.Success);
        Assert.NotNull(result.Data);
        Assert.Equal(command.Title, result.Data.Title);
        Assert.Equal(command.Language, result.Data.Language);
        Assert.Equal(command.Code, result.Data.Code);
        Assert.Equal("Author User", result.Data.CreatedByName);

        _unitOfWorkMock.Verify(u => u.CodeSnippets.AddAsync(It.IsAny<CodeSnippet>(), It.IsAny<CancellationToken>()), Times.Once);
        _unitOfWorkMock.Verify(u => u.SaveChangesAsync(It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task Handle_WithNonExistentArticle_ReturnsError()
    {
        // Arrange
        var command = new CreateCodeSnippetCommand
        {
            ArticleId = Guid.NewGuid(),
            Title = "Test",
            Language = "C#",
            Code = "test",
            CreatedBy = Guid.NewGuid()
        };

        _unitOfWorkMock.Setup(u => u.Articles.GetByIdAsync(command.ArticleId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((Article?)null);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.False(result.Success);
        Assert.NotNull(result.Errors);
        Assert.Contains(result.Errors, e => e.Code == "ARTICLE_NOT_FOUND");
        _unitOfWorkMock.Verify(u => u.CodeSnippets.AddAsync(It.IsAny<CodeSnippet>(), It.IsAny<CancellationToken>()), Times.Never);
    }
}
