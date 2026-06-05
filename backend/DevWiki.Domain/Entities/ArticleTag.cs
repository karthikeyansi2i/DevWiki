namespace DevWiki.Domain.Entities;

public class ArticleTag
{
    public Guid ArticleId { get; set; }
    public int TagId { get; set; }

    public Article Article { get; set; } = null!;
    public Tag Tag { get; set; } = null!;
}
