using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Revisions;

public class GetArticleRevisionsQuery : IRequest<ApiResponse<List<ArticleRevisionDto>>>
{
    public Guid ArticleId { get; set; }
}

public class ArticleRevisionDto
{
    public Guid RevisionId { get; set; }
    public int RevisionNumber { get; set; }
    public string UpdatedByName { get; set; } = null!;
    public DateTime UpdatedAt { get; set; }
    public string? ChangeDescription { get; set; }
}
