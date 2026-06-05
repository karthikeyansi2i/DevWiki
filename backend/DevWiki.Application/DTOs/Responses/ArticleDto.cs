namespace DevWiki.Application.DTOs.Responses;

public class ArticleDto
{
    public Guid ArticleId { get; set; }
    public string Title { get; set; } = null!;
    public string Slug { get; set; } = null!;
    public string Summary { get; set; } = null!;
    public string Content { get; set; } = null!;
    public Guid AuthorId { get; set; }
    public string AuthorName { get; set; } = null!;
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = null!;
    public List<TagDto> Tags { get; set; } = new();
    public string Status { get; set; } = null!;
    public int ViewCount { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class ArticleListItemDto
{
    public Guid ArticleId { get; set; }
    public string Title { get; set; } = null!;
    public string Slug { get; set; } = null!;
    public string Summary { get; set; } = null!;
    public Guid AuthorId { get; set; }
    public string AuthorName { get; set; } = null!;
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = null!;
    public List<TagDto> Tags { get; set; } = new();
    public int ViewCount { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class TagDto
{
    public int TagId { get; set; }
    public string Name { get; set; } = null!;
    public string Slug { get; set; } = null!;
}
