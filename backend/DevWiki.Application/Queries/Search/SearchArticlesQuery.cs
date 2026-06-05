using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Articles;
using MediatR;

namespace DevWiki.Application.Queries.Search;

public class SearchArticlesQuery : IRequest<ApiResponse<PaginatedResult<ArticleListItemDto>>>
{
    public string Query { get; set; } = null!;
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}
