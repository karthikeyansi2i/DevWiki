using Xunit;
using DevWiki.Infrastructure.Services;

namespace DevWiki.Tests.Unit.Infrastructure.Services;

public class MarkdownImportServiceTests
{
    private readonly MarkdownImportService _service = new();

    [Fact]
    public void ParseMarkdownFile_WithEmptyContent_ReturnsEmpty()
    {
        // Arrange
        var content = "";
        var categoryId = 1;
        var tagIds = new List<int>();

        // Act
        var result = _service.ParseMarkdownFile(content, categoryId, tagIds);

        // Assert
        Assert.Empty(result);
    }

    [Fact]
    public void ParseMarkdownFile_WithSingleArticle_ReturnsSingleArticle()
    {
        // Arrange
        var content = "# Article Title\nThis is the article content.";
        var categoryId = 1;
        var tagIds = new List<int> { 1, 2 };

        // Act
        var result = _service.ParseMarkdownFile(content, categoryId, tagIds);

        // Assert
        Assert.Single(result);
        Assert.Equal("Article Title", result[0].Title);
        Assert.Contains("article content", result[0].Content);
        Assert.Equal(categoryId, result[0].CategoryId);
        Assert.Equal(tagIds.Count, result[0].TagIds.Count);
    }

    [Fact]
    public void ParseMarkdownFile_WithMultipleArticles_ReturnsMultipleArticles()
    {
        // Arrange
        var content = "# Article One\nContent one.\n\n# Article Two\nContent two.\n\n# Article Three\nContent three.";
        var categoryId = 1;
        var tagIds = new List<int>();

        // Act
        var result = _service.ParseMarkdownFile(content, categoryId, tagIds);

        // Assert
        Assert.Equal(3, result.Count);
        Assert.Equal("Article One", result[0].Title);
        Assert.Equal("Article Two", result[1].Title);
        Assert.Equal("Article Three", result[2].Title);
    }

    [Fact]
    public void ParseMarkdownFile_WithMultilineContent_PreservesFormatting()
    {
        // Arrange
        var content = "# Article\n## Heading\nParagraph one.\n\nParagraph two.";
        var categoryId = 1;
        var tagIds = new List<int>();

        // Act
        var result = _service.ParseMarkdownFile(content, categoryId, tagIds);

        // Assert
        Assert.Single(result);
        Assert.Contains("## Heading", result[0].Content);
        Assert.Contains("Paragraph one", result[0].Content);
        Assert.Contains("Paragraph two", result[0].Content);
    }

    [Fact]
    public void ParseMarkdownFile_WithoutH1_ReturnsEmpty()
    {
        // Arrange
        var content = "## Heading\nContent without h1";
        var categoryId = 1;
        var tagIds = new List<int>();

        // Act
        var result = _service.ParseMarkdownFile(content, categoryId, tagIds);

        // Assert
        Assert.Empty(result);
    }

    [Fact]
    public void ParseMarkdownFile_AssignsCorrectCategoryAndTags()
    {
        // Arrange
        var content = "# Article\nContent";
        var categoryId = 5;
        var tagIds = new List<int> { 10, 20, 30 };

        // Act
        var result = _service.ParseMarkdownFile(content, categoryId, tagIds);

        // Assert
        Assert.Single(result);
        Assert.Equal(categoryId, result[0].CategoryId);
        Assert.Equal(3, result[0].TagIds.Count);
        Assert.Contains(10, result[0].TagIds);
        Assert.Contains(20, result[0].TagIds);
        Assert.Contains(30, result[0].TagIds);
    }
}
