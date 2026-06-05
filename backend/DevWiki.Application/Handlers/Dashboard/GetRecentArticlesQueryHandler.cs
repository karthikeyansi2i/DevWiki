using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Dashboard;
using DevWiki.Domain.Enums;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Dashboard;

public class GetRecentArticlesQueryHandler : IRequestHandler<GetRecentArticlesQuery, ApiResponse<List<RecentArticleDto>>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetRecentArticlesQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<List<RecentArticleDto>>> Handle(
        GetRecentArticlesQuery request,
        CancellationToken cancellationToken)
    {
        var articles = await _unitOfWork.Articles.GetAllAsync(cancellationToken);

        var recent = articles
            .Where(a => a.Status == ArticleStatus.Active)
            .OrderByDescending(a => a.UpdatedAt)
            .Take(request.Limit)
            .Select(a => new RecentArticleDto
            {
                ArticleId = a.ArticleId,
                Title = a.Title,
                Slug = a.Slug,
                AuthorName = $"{a.Author.FirstName} {a.Author.LastName}",
                UpdatedAt = a.UpdatedAt
            })
            .ToList();

        return ApiResponse<List<RecentArticleDto>>.SuccessResponse(recent);
    }
}
