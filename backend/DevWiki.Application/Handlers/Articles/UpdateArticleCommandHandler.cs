using DevWiki.Application.Commands.Articles;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Articles;

public class UpdateArticleCommandHandler : IRequestHandler<UpdateArticleCommand, ApiResponse<ArticleDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<UpdateArticleCommandHandler> _logger;

    public UpdateArticleCommandHandler(IUnitOfWork unitOfWork, ILogger<UpdateArticleCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<ApiResponse<ArticleDto>> Handle(UpdateArticleCommand request, CancellationToken cancellationToken)
    {
        var article = await _unitOfWork.Articles.GetByIdAsync(request.ArticleId, cancellationToken);
        if (article == null)
        {
            return ApiResponse<ArticleDto>.ErrorResponse("Article not found", "ARTICLE_NOT_FOUND");
        }

        article.Title = request.Title;
        article.Summary = request.Summary;
        article.Content = request.Content;
        article.CategoryId = request.CategoryId;
        article.UpdatedAt = DateTime.UtcNow;

        article.ArticleTags.Clear();
        foreach (var tagId in request.TagIds)
        {
            var tag = await _unitOfWork.Tags.GetByIdAsync(new Guid($"00000000-0000-0000-0000-{tagId:000000000000}"), cancellationToken);
            if (tag != null)
            {
                article.ArticleTags.Add(new ArticleTag { ArticleId = article.ArticleId, TagId = tag.TagId });
            }
        }

        _unitOfWork.Articles.Update(article);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Article updated: {ArticleId}", article.ArticleId);

        return ApiResponse<ArticleDto>.SuccessResponse(MapToDto(article));
    }

    private ArticleDto MapToDto(Article article)
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
