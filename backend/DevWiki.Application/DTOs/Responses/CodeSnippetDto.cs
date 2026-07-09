namespace DevWiki.Application.DTOs.Responses;

public class CodeSnippetDto
{
    public Guid SnippetId { get; set; }
    public Guid ArticleId { get; set; }
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public string Language { get; set; } = null!;
    public string Code { get; set; } = null!;
    public Guid CreatedBy { get; set; }
    public string CreatedByName { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public class CodeSnippetSearchResultDto
{
    public Guid SnippetId { get; set; }
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public string Language { get; set; } = null!;
    public string CodePreview { get; set; } = null!;
    public Guid ArticleId { get; set; }
    public string ArticleTitle { get; set; } = null!;
    public string ArticleSlug { get; set; } = null!;
}
