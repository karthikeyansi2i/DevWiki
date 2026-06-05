using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Articles;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Articles;

public class GetArticleByIdQueryHandler : IRequestHandler<GetArticleByIdQuery, ApiResponse<ArticleDto>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetArticleByIdQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<ArticleDto>> Handle(GetArticleByIdQuery request, CancellationToken cancellationToken)
    {
        var article = await _unitOfWork.Articles.GetByIdAsync(request.ArticleId, cancellationToken);

        if (article == null)
        {
            return ApiResponse<ArticleDto>.ErrorResponse("Article not found", "ARTICLE_NOT_FOUND");
        }

        return ApiResponse<ArticleDto>.SuccessResponse(MapToDto(article));
    }

    private ArticleDto MapToDto(Domain.Entities.Article article)
    {
        return new ArticleDto
        {
            ArticleId = article.ArticleId,
            Title = article.Title,
            Slug = article.Slug,
            Summary = article.Summary,
            Content = article.Content,
            AuthorId = article.AuthorId,
            AuthorName = $"{article.Author.FirstName} {article.Author.LastName}",
            CategoryId = article.CategoryId,
            CategoryName = article.Category.Name,
            Tags = article.ArticleTags.Select(at => new TagDto { TagId = at.Tag.TagId, Name = at.Tag.Name, Slug = at.Tag.Slug }).ToList(),
            Status = article.Status.ToString(),
            ViewCount = article.ViewCount,
            CreatedAt = article.CreatedAt,
            UpdatedAt = article.UpdatedAt
        };
    }
}
