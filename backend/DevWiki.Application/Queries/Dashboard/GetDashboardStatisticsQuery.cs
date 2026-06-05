using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Dashboard;

public class GetDashboardStatisticsQuery : IRequest<ApiResponse<DashboardStatisticsDto>>
{
}

public class DashboardStatisticsDto
{
    public int TotalArticles { get; set; }
    public int TotalCategories { get; set; }
    public int TotalTags { get; set; }
    public int ActiveEditors { get; set; }
    public int ArticlesThisMonth { get; set; }
    public int MostViewedCount { get; set; }
}
