using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Search;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Services;
using MediatR;

namespace DevWiki.Application.Handlers.Search;

public class SearchCombinedQueryHandler : IRequestHandler<SearchCombinedQuery, ApiResponse<CombinedSearchResultDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ISearchService _searchService;

    public SearchCombinedQueryHandler(IUnitOfWork unitOfWork, ISearchService searchService)
    {
        _unitOfWork = unitOfWork;
        _searchService = searchService;
    }

    public async Task<ApiResponse<CombinedSearchResultDto>> Handle(
        SearchCombinedQuery request, CancellationToken cancellationToken)
    {
        var (articles, totalArticles) = await _searchService.SearchAsync(
            request.Query, request.Page, request.PageSize, cancellationToken);

        var (snippets, totalSnippets) = await _unitOfWork.CodeSnippets.SearchAsync(
            request.Query, request.Page, request.PageSize, cancellationToken);

        var result = new CombinedSearchResultDto
        {
            Articles = articles.Select(MapToArticleListItem).ToList(),
            CodeSnippets = snippets.Select(MapToSnippetSearchResult).ToList(),
            TotalArticles = totalArticles,
            TotalSnippets = totalSnippets,
            Query = request.Query
        };

        return ApiResponse<CombinedSearchResultDto>.SuccessResponse(result);
    }

    private static ArticleListItemDto MapToArticleListItem(Domain.Entities.Article article)
    {
        return new ArticleListItemDto
        {
            ArticleId = article.ArticleId,
            Title = article.Title,
            Slug = article.Slug,
            Summary = article.Summary,
            AuthorId = article.AuthorId,
            AuthorName = $"{article.Author.FirstName} {article.Author.LastName}",
            CategoryId = article.CategoryId,
            CategoryName = article.Category.Name,
            Tags = article.ArticleTags.Select(at => new TagDto { TagId = at.Tag.TagId, Name = at.Tag.Name, Slug = at.Tag.Slug }).ToList(),
            ViewCount = article.ViewCount,
            CreatedAt = article.CreatedAt,
            UpdatedAt = article.UpdatedAt
        };
    }

    private static CodeSnippetSearchResultDto MapToSnippetSearchResult(CodeSnippet snippet)
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
