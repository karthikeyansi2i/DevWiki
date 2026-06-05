using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Dashboard;
using DevWiki.Domain.Enums;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Dashboard;

public class GetDashboardStatisticsQueryHandler : IRequestHandler<GetDashboardStatisticsQuery, ApiResponse<DashboardStatisticsDto>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetDashboardStatisticsQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<DashboardStatisticsDto>> Handle(
        GetDashboardStatisticsQuery request,
        CancellationToken cancellationToken)
    {
        var articles = await _unitOfWork.Articles.GetAllAsync(cancellationToken);
        var categories = await _unitOfWork.Categories.GetAllAsync(cancellationToken);
        var tags = await _unitOfWork.Tags.GetAllAsync(cancellationToken);

        var activeArticles = articles.Where(a => a.Status == ArticleStatus.Active).ToList();
        var thisMonth = DateTime.UtcNow.AddMonths(-1);
        var articlesThisMonth = activeArticles.Count(a => a.CreatedAt > thisMonth);
        var authorsWithEdits = activeArticles.Select(a => a.AuthorId).Distinct().Count();
        var mostViewed = activeArticles.Max(a => (int?)a.ViewCount) ?? 0;

        var statistics = new DashboardStatisticsDto
        {
            TotalArticles = activeArticles.Count,
            TotalCategories = categories.Count(),
            TotalTags = tags.Count(),
            ActiveEditors = authorsWithEdits,
            ArticlesThisMonth = articlesThisMonth,
            MostViewedCount = mostViewed
        };

        return ApiResponse<DashboardStatisticsDto>.SuccessResponse(statistics);
    }
}
