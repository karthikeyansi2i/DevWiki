using DevWiki.Application.Commands.Snippets;
using DevWiki.Application.DTOs.Requests;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Snippets;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DevWiki.API.Controllers;

[ApiController]
[Authorize]
public class SnippetsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<SnippetsController> _logger;

    public SnippetsController(IMediator mediator, ILogger<SnippetsController> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    [HttpGet("api/articles/{articleId}/snippets")]
    [AllowAnonymous]
    public async Task<IActionResult> GetArticleSnippets(Guid articleId)
    {
        var query = new GetArticleSnippetsQuery { ArticleId = articleId };
        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("api/snippets/{id}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetSnippetById(Guid id)
    {
        var query = new GetSnippetByIdQuery { SnippetId = id };
        var result = await _mediator.Send(query);
        if (!result.Success)
            return NotFound(result);
        return Ok(result);
    }

    [HttpPost("api/articles/{articleId}/snippets")]
    public async Task<IActionResult> CreateSnippet(Guid articleId, [FromBody] CreateCodeSnippetRequest request)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userId, out var createdBy))
            return Unauthorized();

        try
        {
            var command = new CreateCodeSnippetCommand
            {
                ArticleId = articleId,
                Title = request.Title,
                Description = request.Description,
                Language = request.Language,
                Code = request.Code,
                CreatedBy = createdBy
            };

            var result = await _mediator.Send(command);
            if (!result.Success)
                return BadRequest(result);

            return CreatedAtAction(nameof(GetSnippetById), new { id = result.Data?.SnippetId }, result);
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

    [HttpPut("api/snippets/{id}")]
    public async Task<IActionResult> UpdateSnippet(Guid id, [FromBody] UpdateCodeSnippetRequest request)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userId, out var updatedBy))
            return Unauthorized();

        try
        {
            var command = new UpdateCodeSnippetCommand
            {
                SnippetId = id,
                Title = request.Title,
                Description = request.Description,
                Language = request.Language,
                Code = request.Code,
                UpdatedBy = updatedBy
            };

            var result = await _mediator.Send(command);
            if (!result.Success)
                return NotFound(result);

            return Ok(result);
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

    [HttpDelete("api/snippets/{id}")]
    public async Task<IActionResult> DeleteSnippet(Guid id)
    {
        var command = new DeleteCodeSnippetCommand { SnippetId = id };
        var result = await _mediator.Send(command);
        if (!result.Success)
            return NotFound(result);
        return Ok(result);
    }

    [HttpGet("api/snippets/search")]
    [AllowAnonymous]
    public async Task<IActionResult> SearchSnippets(
        [FromQuery] string q,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        if (string.IsNullOrWhiteSpace(q))
            return BadRequest(new { error = "Search query is required" });

        var query = new SearchSnippetsQuery
        {
            Query = q,
            Page = page,
            PageSize = pageSize
        };

        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("api/snippets")]
    [AllowAnonymous]
    public async Task<IActionResult> GetSnippetsByLanguage(
        [FromQuery] string? language,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        if (string.IsNullOrWhiteSpace(language))
            return BadRequest(new { error = "Language parameter is required" });

        var query = new GetSnippetsByLanguageQuery
        {
            Language = language,
            Page = page,
            PageSize = pageSize
        };

        var result = await _mediator.Send(query);
        return Ok(result);
    }
}
