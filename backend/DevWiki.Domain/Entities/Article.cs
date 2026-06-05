namespace DevWiki.Domain.Entities;

public class Article
{
    public Guid ArticleId { get; set; }
    public string Title { get; set; } = null!;
    public string Slug { get; set; } = null!;
    public string Summary { get; set; } = null!;
    public string Content { get; set; } = null!;
    public Guid AuthorId { get; set; }
    public int CategoryId { get; set; }
    public ArticleStatus Status { get; set; } = ArticleStatus.Active;
    public int ViewCount { get; set; } = 0;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public User Author { get; set; } = null!;
    public Category Category { get; set; } = null!;
    public ICollection<ArticleTag> ArticleTags { get; set; } = new List<ArticleTag>();
    public ICollection<ArticleRevision> Revisions { get; set; } = new List<ArticleRevision>();
}
