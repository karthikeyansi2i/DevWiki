using DevWiki.Application.Commands.Tags;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Tags;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DevWiki.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TagsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<TagsController> _logger;

    public TagsController(IMediator mediator, ILogger<TagsController> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetTags()
    {
        var query = new GetTagsQuery();
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpPost]
    [Authorize]
    public async Task<IActionResult> CreateTag([FromBody] CreateTagRequest request)
    {
        try
        {
            var command = new CreateTagCommand { Name = request.Name };
            var result = await _mediator.Send(command);

            if (!result.Success)
            {
                return BadRequest(result);
            }

            return CreatedAtAction(nameof(GetTags), result);
        }
        catch (FluentValidation.ValidationException ex)
        {
            var errors = ex.Errors.Select(e => new ErrorDetail
            {
                Code = "VALIDATION_ERROR",
                Message = e.ErrorMessage,
                Field = e.PropertyName
            }).ToList();

            return BadRequest(ApiResponse<object>.ErrorResponse(errors));
        }
    }
}

public class CreateTagRequest
{
    public string Name { get; set; } = null!;
}
