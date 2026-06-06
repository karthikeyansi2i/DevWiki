using Xunit;
using DevWiki.Infrastructure.Authentication;

namespace DevWiki.Tests.Unit.Infrastructure.Authentication;

public class PasswordHasherTests
{
    private readonly PasswordHasher _passwordHasher = new();

    [Fact]
    public void HashPassword_WithValidPassword_ReturnsHash()
    {
        // Arrange
        var password = "SecurePassword123!";

        // Act
        var hash = _passwordHasher.HashPassword(password);

        // Assert
        Assert.NotNull(hash);
        Assert.NotEmpty(hash);
        Assert.NotEqual(password, hash);
    }

    [Fact]
    public void HashPassword_WithSamePassword_ReturnsDifferentHashes()
    {
        // Arrange
        var password = "SecurePassword123!";

        // Act
        var hash1 = _passwordHasher.HashPassword(password);
        var hash2 = _passwordHasher.HashPassword(password);

        // Assert
        Assert.NotEqual(hash1, hash2);
    }

    [Fact]
    public void VerifyPassword_WithCorrectPassword_ReturnsTrue()
    {
        // Arrange
        var password = "SecurePassword123!";
        var hash = _passwordHasher.HashPassword(password);

        // Act
        var result = _passwordHasher.VerifyPassword(password, hash);

        // Assert
        Assert.True(result);
    }

    [Fact]
    public void VerifyPassword_WithIncorrectPassword_ReturnsFalse()
    {
        // Arrange
        var password = "SecurePassword123!";
        var wrongPassword = "WrongPassword456!";
        var hash = _passwordHasher.HashPassword(password);

        // Act
        var result = _passwordHasher.VerifyPassword(wrongPassword, hash);

        // Assert
        Assert.False(result);
    }

    [Fact]
    public void VerifyPassword_WithEmptyPassword_ReturnsFalse()
    {
        // Arrange
        var password = "SecurePassword123!";
        var hash = _passwordHasher.HashPassword(password);

        // Act
        var result = _passwordHasher.VerifyPassword("", hash);

        // Assert
        Assert.False(result);
    }
}
