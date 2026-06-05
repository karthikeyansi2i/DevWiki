using DevWiki.Application.Commands.Articles;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Enums;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Articles;

public class DeleteArticleCommandHandler : IRequestHandler<DeleteArticleCommand, ApiResponse<object>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<DeleteArticleCommandHandler> _logger;

    public DeleteArticleCommandHandler(IUnitOfWork unitOfWork, ILogger<DeleteArticleCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<ApiResponse<object>> Handle(DeleteArticleCommand request, CancellationToken cancellationToken)
    {
        var article = await _unitOfWork.Articles.GetByIdAsync(request.ArticleId, cancellationToken);
        if (article == null)
        {
            return ApiResponse<object>.ErrorResponse("Article not found", "ARTICLE_NOT_FOUND");
        }

        article.Status = ArticleStatus.Archived;
        article.UpdatedAt = DateTime.UtcNow;

        _unitOfWork.Articles.Update(article);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Article archived: {ArticleId}", article.ArticleId);

        return ApiResponse<object>.SuccessResponse(new { articleId = article.ArticleId, status = "Archived" });
    }
}
