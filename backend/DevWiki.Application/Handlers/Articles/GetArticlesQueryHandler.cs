using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Articles;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Articles;

public class GetArticlesQueryHandler : IRequestHandler<GetArticlesQuery, ApiResponse<PaginatedResult<ArticleListItemDto>>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetArticlesQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<PaginatedResult<ArticleListItemDto>>> Handle(
        GetArticlesQuery request,
        CancellationToken cancellationToken)
    {
        var (items, totalCount) = await _unitOfWork.Articles.GetPaginatedAsync(request.Page, request.PageSize, cancellationToken);

        if (request.CategoryId.HasValue)
        {
            items = items.Where(a => a.CategoryId == request.CategoryId).ToList();
        }

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
