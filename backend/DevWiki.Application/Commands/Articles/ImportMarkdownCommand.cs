using MediatR;

namespace DevWiki.Application.Commands.Articles;

public class ImportMarkdownCommand : IRequest<ImportMarkdownResult>
{
    public string Content { get; set; } = null!;
    public int CategoryId { get; set; }
    public List<int> TagIds { get; set; } = new();
    public Guid AuthorId { get; set; }
}

public class ImportMarkdownResult
{
    public bool Success { get; set; }
    public int CreatedArticles { get; set; }
    public List<string> Errors { get; set; } = new();
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}
