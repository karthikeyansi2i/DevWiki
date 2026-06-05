using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Revisions;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Revisions;

public class GetRevisionQueryHandler : IRequestHandler<GetRevisionQuery, ApiResponse<RevisionDetailDto>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetRevisionQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<RevisionDetailDto>> Handle(
        GetRevisionQuery request,
        CancellationToken cancellationToken)
    {
        var article = await _unitOfWork.Articles.GetByIdAsync(request.ArticleId, cancellationToken);
        if (article == null)
        {
            return ApiResponse<RevisionDetailDto>.ErrorResponse("Article not found", "ARTICLE_NOT_FOUND");
        }

        var revision = article.Revisions.FirstOrDefault(r => r.RevisionId == request.RevisionId);
        if (revision == null)
        {
            return ApiResponse<RevisionDetailDto>.ErrorResponse("Revision not found", "REVISION_NOT_FOUND");
        }

        var dto = new RevisionDetailDto
        {
            RevisionId = revision.RevisionId,
            ArticleId = revision.ArticleId,
            RevisionNumber = revision.RevisionNumber,
            Content = revision.Content,
            UpdatedByName = $"{revision.UpdatedByUser.FirstName} {revision.UpdatedByUser.LastName}",
            UpdatedAt = revision.UpdatedAt,
            ChangeDescription = revision.ChangeDescription
        };

        return ApiResponse<RevisionDetailDto>.SuccessResponse(dto);
    }
}
