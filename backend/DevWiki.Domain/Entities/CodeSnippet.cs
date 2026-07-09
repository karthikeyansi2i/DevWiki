namespace DevWiki.Domain.Entities;

public class CodeSnippet
{
    public Guid SnippetId { get; set; }
    public Guid ArticleId { get; set; }
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public string Language { get; set; } = null!;
    public string Code { get; set; } = null!;
    public Guid CreatedBy { get; set; }
    public Guid? UpdatedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public Article Article { get; set; } = null!;
    public User CreatedByUser { get; set; } = null!;
    public User? UpdatedByUser { get; set; }
}
