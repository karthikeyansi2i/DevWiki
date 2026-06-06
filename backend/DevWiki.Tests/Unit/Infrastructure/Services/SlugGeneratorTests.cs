using Xunit;
using DevWiki.Infrastructure.Services;

namespace DevWiki.Tests.Unit.Infrastructure.Services;

public class SlugGeneratorTests
{
    private readonly SlugGenerator _slugGenerator = new();

    [Fact]
    public void Generate_WithSimpleText_ReturnsSlug()
    {
        // Arrange
        var text = "Hello World";

        // Act
        var slug = _slugGenerator.Generate(text);

        // Assert
        Assert.Equal("hello-world", slug);
    }

    [Fact]
    public void Generate_WithMultipleSpaces_CollapsesToSingleDash()
    {
        // Arrange
        var text = "Hello   Multiple   Spaces";

        // Act
        var slug = _slugGenerator.Generate(text);

        // Assert
        Assert.Equal("hello-multiple-spaces", slug);
    }

    [Fact]
    public void Generate_WithSpecialCharacters_RemovesThem()
    {
        // Arrange
        var text = "Hello@World#Test!";

        // Act
        var slug = _slugGenerator.Generate(text);

        // Assert
        Assert.Equal("helloworld-test", slug);
    }

    [Fact]
    public void Generate_WithUpperCase_ReturnsLowerCase()
    {
        // Arrange
        var text = "HELLO WORLD";

        // Act
        var slug = _slugGenerator.Generate(text);

        // Assert
        Assert.Equal("hello-world", slug);
    }

    [Fact]
    public void Generate_WithNumbers_PreservesNumbers()
    {
        // Arrange
        var text = "Article 123 Test";

        // Act
        var slug = _slugGenerator.Generate(text);

        // Assert
        Assert.Equal("article-123-test", slug);
    }

    [Fact]
    public void Generate_WithLeadingTrailingSpaces_Trims()
    {
        // Arrange
        var text = "  Hello World  ";

        // Act
        var slug = _slugGenerator.Generate(text);

        // Assert
        Assert.Equal("hello-world", slug);
    }

    [Fact]
    public void Generate_WithEmptyString_ReturnsEmpty()
    {
        // Arrange
        var text = "";

        // Act
        var slug = _slugGenerator.Generate(text);

        // Assert
        Assert.Empty(slug);
    }

    [Fact]
    public void Generate_WithOnlySpaces_ReturnsEmpty()
    {
        // Arrange
        var text = "   ";

        // Act
        var slug = _slugGenerator.Generate(text);

        // Assert
        Assert.Empty(slug);
    }
}
