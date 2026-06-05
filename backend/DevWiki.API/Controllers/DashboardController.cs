using DevWiki.Application.Queries.Dashboard;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DevWiki.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DashboardController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<DashboardController> _logger;

    public DashboardController(IMediator mediator, ILogger<DashboardController> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    [HttpGet("statistics")]
    public async Task<IActionResult> GetStatistics()
    {
        var query = new GetDashboardStatisticsQuery();
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("recent-articles")]
    public async Task<IActionResult> GetRecentArticles([FromQuery] int limit = 10)
    {
        var query = new GetRecentArticlesQuery { Limit = limit };
        var result = await _mediator.Send(query);
        return Ok(result);
    }
}
