using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Articles;
using MediatR;

namespace DevWiki.Application.Queries.Snippets;

public class GetSnippetsByLanguageQuery : IRequest<ApiResponse<PaginatedResult<CodeSnippetSearchResultDto>>>
{
    public string Language { get; set; } = null!;
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}
