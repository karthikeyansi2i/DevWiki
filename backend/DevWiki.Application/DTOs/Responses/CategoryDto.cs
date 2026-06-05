namespace DevWiki.Application.DTOs.Responses;

public class CategoryDto
{
    public int CategoryId { get; set; }
    public string Name { get; set; } = null!;
    public string Slug { get; set; } = null!;
    public string? Description { get; set; }
    public int ArticleCount { get; set; }
}
