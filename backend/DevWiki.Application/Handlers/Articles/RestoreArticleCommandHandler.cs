using DevWiki.Application.Commands.Articles;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Articles;

public class RestoreArticleCommandHandler : IRequestHandler<RestoreArticleCommand, ApiResponse<ArticleDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<RestoreArticleCommandHandler> _logger;

    public RestoreArticleCommandHandler(IUnitOfWork unitOfWork, ILogger<RestoreArticleCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<ApiResponse<ArticleDto>> Handle(RestoreArticleCommand request, CancellationToken cancellationToken)
    {
        var article = await _unitOfWork.Articles.GetByIdAsync(request.ArticleId, cancellationToken);
        if (article == null)
        {
            return ApiResponse<ArticleDto>.ErrorResponse("Article not found", "ARTICLE_NOT_FOUND");
        }

        var revisions = await _unitOfWork.Articles.GetByIdAsync(request.ArticleId, cancellationToken);
        if (revisions?.Revisions == null || !revisions.Revisions.Any(r => r.RevisionId == request.RevisionId))
        {
            return ApiResponse<ArticleDto>.ErrorResponse("Revision not found", "REVISION_NOT_FOUND");
        }

        var targetRevision = revisions.Revisions.First(r => r.RevisionId == request.RevisionId);

        var maxRevisionNumber = revisions.Revisions.Max(r => r.RevisionNumber);
        var newRevision = new ArticleRevision
        {
            RevisionId = Guid.NewGuid(),
            ArticleId = article.ArticleId,
            Content = article.Content,
            RevisionNumber = maxRevisionNumber + 1,
            UpdatedBy = article.AuthorId,
            UpdatedAt = DateTime.UtcNow,
            ChangeDescription = $"Restored from revision {targetRevision.RevisionNumber}"
        };

        article.Content = targetRevision.Content;
        article.UpdatedAt = DateTime.UtcNow;

        await _unitOfWork.Articles.AddAsync(newRevision, cancellationToken);
        _unitOfWork.Articles.Update(article);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Article restored: {ArticleId} from revision {RevisionId}", article.ArticleId, request.RevisionId);

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
