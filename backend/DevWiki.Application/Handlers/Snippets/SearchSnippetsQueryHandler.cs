using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Articles;
using DevWiki.Application.Queries.Snippets;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Snippets;

public class SearchSnippetsQueryHandler : IRequestHandler<SearchSnippetsQuery, ApiResponse<PaginatedResult<CodeSnippetSearchResultDto>>>
{
    private readonly IUnitOfWork _unitOfWork;

    public SearchSnippetsQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<PaginatedResult<CodeSnippetSearchResultDto>>> Handle(
        SearchSnippetsQuery request, CancellationToken cancellationToken)
    {
        var (items, totalCount) = await _unitOfWork.CodeSnippets.SearchAsync(
            request.Query, request.Page, request.PageSize, cancellationToken);

        var result = new PaginatedResult<CodeSnippetSearchResultDto>
        {
            Items = items.Select(MapToSearchResult).ToList(),
            Page = request.Page,
            PageSize = request.PageSize,
            TotalItems = totalCount,
            TotalPages = (totalCount + request.PageSize - 1) / request.PageSize
        };

        return ApiResponse<PaginatedResult<CodeSnippetSearchResultDto>>.SuccessResponse(result);
    }

    private static CodeSnippetSearchResultDto MapToSearchResult(CodeSnippet snippet)
    {
        return new CodeSnippetSearchResultDto
        {
            SnippetId = snippet.SnippetId,
            Title = snippet.Title,
            Description = snippet.Description,
            Language = snippet.Language,
            CodePreview = snippet.Code.Length > 100 ? snippet.Code[..100] + "..." : snippet.Code,
            ArticleId = snippet.ArticleId,
            ArticleTitle = snippet.Article?.Title ?? "Unknown",
            ArticleSlug = snippet.Article?.Slug ?? ""
        };
    }
}
