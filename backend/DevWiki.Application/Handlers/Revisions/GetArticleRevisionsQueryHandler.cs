using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Revisions;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Revisions;

public class GetArticleRevisionsQueryHandler : IRequestHandler<GetArticleRevisionsQuery, ApiResponse<List<ArticleRevisionDto>>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetArticleRevisionsQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<List<ArticleRevisionDto>>> Handle(
        GetArticleRevisionsQuery request,
        CancellationToken cancellationToken)
    {
        var article = await _unitOfWork.Articles.GetByIdAsync(request.ArticleId, cancellationToken);
        if (article == null)
        {
            return ApiResponse<List<ArticleRevisionDto>>.ErrorResponse("Article not found", "ARTICLE_NOT_FOUND");
        }

        var revisions = article.Revisions
            .OrderByDescending(r => r.RevisionNumber)
            .Select(r => new ArticleRevisionDto
            {
                RevisionId = r.RevisionId,
                RevisionNumber = r.RevisionNumber,
                UpdatedByName = $"{r.UpdatedByUser.FirstName} {r.UpdatedByUser.LastName}",
                UpdatedAt = r.UpdatedAt,
                ChangeDescription = r.ChangeDescription
            })
            .ToList();

        return ApiResponse<List<ArticleRevisionDto>>.SuccessResponse(revisions);
    }
}
