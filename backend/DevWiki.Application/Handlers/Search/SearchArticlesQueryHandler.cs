using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Articles;
using DevWiki.Application.Queries.Search;
using DevWiki.Infrastructure.Services;
using MediatR;

namespace DevWiki.Application.Handlers.Search;

public class SearchArticlesQueryHandler : IRequestHandler<SearchArticlesQuery, ApiResponse<PaginatedResult<ArticleListItemDto>>>
{
    private readonly ISearchService _searchService;

    public SearchArticlesQueryHandler(ISearchService searchService)
    {
        _searchService = searchService;
    }

    public async Task<ApiResponse<PaginatedResult<ArticleListItemDto>>> Handle(
        SearchArticlesQuery request,
        CancellationToken cancellationToken)
    {
        var (items, totalCount) = await _searchService.SearchAsync(
            request.Query,
            request.Page,
            request.PageSize,
            cancellationToken);

        var result = new PaginatedResult<ArticleListItemDto>
        {
            Items = items.Select(MapToListItemDto).ToList(),
            Page = request.Page,
            PageSize = request.PageSize,
            TotalItems = totalCount,
            TotalPages = (totalCount + request.PageSize - 1) / request.PageSize
        };

        return ApiResponse<PaginatedResult<ArticleListItemDto>>.SuccessResponse(result);
    }

    private ArticleListItemDto MapToListItemDto(Domain.Entities.Article article)
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
}
