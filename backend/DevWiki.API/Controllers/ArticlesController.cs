using DevWiki.Application.Commands.Articles;
using DevWiki.Application.DTOs.Requests;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Articles;
using DevWiki.Application.Queries.Revisions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace DevWiki.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ArticlesController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<ArticlesController> _logger;

    public ArticlesController(IMediator mediator, ILogger<ArticlesController> logger)
    {
        _mediator = mediator;
        _logger = logger;
    }

    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> GetArticles(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] int? categoryId = null)
    {
        var query = new GetArticlesQuery
        {
            Page = page,
            PageSize = pageSize,
            CategoryId = categoryId
        };

        var result = await _mediator.Send(query);
        return Ok(result);
    }

    [HttpGet("by-slug/{slug}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetArticleBySlug(string slug)
    {
        var query = new GetArticleBySlugQuery { Slug = slug };
        var result = await _mediator.Send(query);

        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    [HttpGet("{id}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetArticleById(Guid id)
    {
        var query = new GetArticleByIdQuery { ArticleId = id };
        var result = await _mediator.Send(query);

        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    [HttpPost]
    [Authorize]
    public async Task<IActionResult> CreateArticle([FromBody] CreateArticleRequest request)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userId, out var authorId))
        {
            return Unauthorized();
        }

        try
        {
            var command = new CreateArticleCommand
            {
                Title = request.Title,
                Summary = request.Summary,
                Content = request.Content,
                CategoryId = request.CategoryId,
                TagIds = request.TagIds,
                AuthorId = authorId
            };

            var result = await _mediator.Send(command);

            if (!result.Success)
            {
                return BadRequest(result);
            }

            return CreatedAtAction(nameof(GetArticleById), new { id = result.Data?.ArticleId }, result);
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

    [HttpPut("{id}")]
    [Authorize]
    public async Task<IActionResult> UpdateArticle(Guid id, [FromBody] UpdateArticleRequest request)
    {
        try
        {
            var command = new UpdateArticleCommand
            {
                ArticleId = id,
                Title = request.Title,
                Summary = request.Summary,
                Content = request.Content,
                CategoryId = request.CategoryId,
                TagIds = request.TagIds,
                ChangeDescription = request.ChangeDescription
            };

            var result = await _mediator.Send(command);

            if (!result.Success)
            {
                return NotFound(result);
            }

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

    [HttpDelete("{id}")]
    [Authorize]
    public async Task<IActionResult> DeleteArticle(Guid id)
    {
        var command = new DeleteArticleCommand { ArticleId = id };
        var result = await _mediator.Send(command);

        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    [HttpGet("{id}/revisions")]
    [Authorize]
    public async Task<IActionResult> GetRevisions(Guid id)
    {
        var query = new GetArticleRevisionsQuery { ArticleId = id };
        var result = await _mediator.Send(query);

        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    [HttpGet("{id}/revisions/{revisionId}")]
    [Authorize]
    public async Task<IActionResult> GetRevision(Guid id, Guid revisionId)
    {
        var query = new GetRevisionQuery { ArticleId = id, RevisionId = revisionId };
        var result = await _mediator.Send(query);

        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    [HttpPost("{id}/revisions/{revisionId}/restore")]
    [Authorize]
    public async Task<IActionResult> RestoreRevision(Guid id, Guid revisionId)
    {
        var command = new RestoreArticleCommand { ArticleId = id, RevisionId = revisionId };
        var result = await _mediator.Send(command);

        if (!result.Success)
        {
            return NotFound(result);
        }

        return Ok(result);
    }

    [HttpPost("import")]
    [Authorize]
    public async Task<IActionResult> ImportMarkdown([FromBody] ImportMarkdownRequest request)
    {
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userId, out var authorId))
        {
            return Unauthorized();
        }

        var command = new ImportMarkdownCommand
        {
            Content = request.Content,
            CategoryId = request.CategoryId,
            TagIds = request.TagIds,
            AuthorId = authorId
        };

        var result = await _mediator.Send(command);
        return Ok(result);
    }
}

public class ImportMarkdownRequest
{
    public string Content { get; set; } = null!;
    public int CategoryId { get; set; }
    public List<int> TagIds { get; set; } = new();
}
