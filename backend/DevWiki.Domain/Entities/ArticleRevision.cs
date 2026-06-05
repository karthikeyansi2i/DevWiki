namespace DevWiki.Domain.Entities;

public class ArticleRevision
{
    public Guid RevisionId { get; set; }
    public Guid ArticleId { get; set; }
    public string Content { get; set; } = null!;
    public int RevisionNumber { get; set; }
    public Guid UpdatedBy { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string? ChangeDescription { get; set; }

    public Article Article { get; set; } = null!;
    public User UpdatedByUser { get; set; } = null!;
}
