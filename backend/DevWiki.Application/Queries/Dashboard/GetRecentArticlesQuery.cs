using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Dashboard;

public class GetRecentArticlesQuery : IRequest<ApiResponse<List<RecentArticleDto>>>
{
    public int Limit { get; set; } = 10;
}

public class RecentArticleDto
{
    public Guid ArticleId { get; set; }
    public string Title { get; set; } = null!;
    public string Slug { get; set; } = null!;
    public string AuthorName { get; set; } = null!;
    public DateTime UpdatedAt { get; set; }
}
