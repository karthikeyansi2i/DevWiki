using Xunit;
using Moq;
using System.Linq.Expressions;
using DevWiki.Application.Commands.Auth;
using DevWiki.Application.Handlers.Auth;
using DevWiki.Infrastructure.Authentication;
using DevWiki.Infrastructure.Persistence;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace DevWiki.Tests.Unit.Application.Handlers.Auth;

public class RegisterCommandHandlerTests
{
    private readonly Mock<DevWikiDbContext> _dbContextMock;
    private readonly Mock<IPasswordHasher> _passwordHasherMock;
    private readonly RegisterCommandHandler _handler;

    public RegisterCommandHandlerTests()
    {
        _dbContextMock = new Mock<DevWikiDbContext>();
        _passwordHasherMock = new Mock<IPasswordHasher>();
        _handler = new RegisterCommandHandler(_dbContextMock.Object, _passwordHasherMock.Object);
    }

    [Fact]
    public async Task Handle_WithValidCommand_CreatesNewUser()
    {
        // Arrange
        var command = new RegisterCommand
        {
            Email = "test@example.com",
            Password = "SecurePassword123!",
            FirstName = "John",
            LastName = "Doe"
        };

        var users = new List<User>();
        var userDbSetMock = new Mock<DbSet<User>>();
        userDbSetMock.Setup(m => m.AddAsync(It.IsAny<User>(), It.IsAny<CancellationToken>()))
            .Callback((User user, CancellationToken ct) => users.Add(user));
        userDbSetMock.Setup(m => m.FirstOrDefaultAsync(It.IsAny<Expression<Func<User, bool>>>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((User)null);

        _dbContextMock.Setup(m => m.Users).Returns(userDbSetMock.Object);
        _dbContextMock.Setup(m => m.SaveChangesAsync(It.IsAny<CancellationToken>())).ReturnsAsync(1);
        _passwordHasherMock.Setup(m => m.HashPassword(It.IsAny<string>())).Returns("hashedpassword");

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.True(result.Success);
        Assert.NotNull(result.Data);
        Assert.Equal(command.Email, result.Data.Email);
        Assert.Equal(command.FirstName, result.Data.FirstName);
        Assert.Equal(UserRole.Viewer.ToString(), result.Data.Role);
    }

    [Fact]
    public async Task Handle_WithDuplicateEmail_ReturnsError()
    {
        // Arrange
        var command = new RegisterCommand
        {
            Email = "existing@example.com",
            Password = "SecurePassword123!",
            FirstName = "John",
            LastName = "Doe"
        };

        var existingUser = new User
        {
            UserId = Guid.NewGuid(),
            Email = "existing@example.com",
            NormalizedEmail = "existing@example.com",
            PasswordHash = "hash",
            FirstName = "Existing",
            LastName = "User",
            Role = UserRole.Viewer
        };

        var userDbSetMock = new Mock<DbSet<User>>();
        userDbSetMock.Setup(m => m.FirstOrDefaultAsync(It.IsAny<Expression<Func<User, bool>>>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(existingUser);

        _dbContextMock.Setup(m => m.Users).Returns(userDbSetMock.Object);

        // Act
        var result = await _handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.False(result.Success);
        Assert.NotNull(result.Errors);
        Assert.Contains(result.Errors, e => e.Code == "EMAIL_EXISTS");
    }

    [Fact]
    public async Task Handle_WithValidCommand_HashesPassword()
    {
        // Arrange
        var command = new RegisterCommand
        {
            Email = "test@example.com",
            Password = "SecurePassword123!",
            FirstName = "John",
            LastName = "Doe"
        };

        var users = new List<User>();
        var userDbSetMock = new Mock<DbSet<User>>();
        userDbSetMock.Setup(m => m.AddAsync(It.IsAny<User>(), It.IsAny<CancellationToken>()))
            .Callback((User user, CancellationToken ct) => users.Add(user));
        userDbSetMock.Setup(m => m.FirstOrDefaultAsync(It.IsAny<Expression<Func<User, bool>>>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((User)null);

        _dbContextMock.Setup(m => m.Users).Returns(userDbSetMock.Object);
        _dbContextMock.Setup(m => m.SaveChangesAsync(It.IsAny<CancellationToken>())).ReturnsAsync(1);
        _passwordHasherMock.Setup(m => m.HashPassword(command.Password)).Returns("hashedpassword");

        // Act
        await _handler.Handle(command, CancellationToken.None);

        // Assert
        _passwordHasherMock.Verify(m => m.HashPassword(command.Password), Times.Once);
    }
}
