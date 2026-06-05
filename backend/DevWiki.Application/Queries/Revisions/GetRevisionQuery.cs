using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Revisions;

public class GetRevisionQuery : IRequest<ApiResponse<RevisionDetailDto>>
{
    public Guid ArticleId { get; set; }
    public Guid RevisionId { get; set; }
}

public class RevisionDetailDto
{
    public Guid RevisionId { get; set; }
    public Guid ArticleId { get; set; }
    public int RevisionNumber { get; set; }
    public string Content { get; set; } = null!;
    public string UpdatedByName { get; set; } = null!;
    public DateTime UpdatedAt { get; set; }
    public string? ChangeDescription { get; set; }
}
