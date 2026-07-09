using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Search;

public class SearchCombinedQuery : IRequest<ApiResponse<CombinedSearchResultDto>>
{
    public string Query { get; set; } = null!;
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}
