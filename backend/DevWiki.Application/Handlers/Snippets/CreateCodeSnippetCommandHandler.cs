using DevWiki.Application.Commands.Snippets;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Snippets;

public class CreateCodeSnippetCommandHandler : IRequestHandler<CreateCodeSnippetCommand, ApiResponse<CodeSnippetDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<CreateCodeSnippetCommandHandler> _logger;

    public CreateCodeSnippetCommandHandler(IUnitOfWork unitOfWork, ILogger<CreateCodeSnippetCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<ApiResponse<CodeSnippetDto>> Handle(CreateCodeSnippetCommand request, CancellationToken cancellationToken)
    {
        var article = await _unitOfWork.Articles.GetByIdAsync(request.ArticleId, cancellationToken);
        if (article == null)
            return ApiResponse<CodeSnippetDto>.ErrorResponse("Article not found", "ARTICLE_NOT_FOUND");

        var now = DateTime.UtcNow;
        var snippet = new CodeSnippet
        {
            SnippetId = Guid.NewGuid(),
            ArticleId = request.ArticleId,
            Title = request.Title,
            Description = request.Description,
            Language = request.Language,
            Code = request.Code,
            CreatedBy = request.CreatedBy,
            UpdatedBy = request.CreatedBy,
            CreatedAt = now,
            UpdatedAt = now
        };

        await _unitOfWork.CodeSnippets.AddAsync(snippet, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Code snippet created: {SnippetId} for article {ArticleId}", snippet.SnippetId, request.ArticleId);

        snippet.CreatedByUser = article.Author;

        return ApiResponse<CodeSnippetDto>.SuccessResponse(MapToDto(snippet));
    }

    private static CodeSnippetDto MapToDto(CodeSnippet snippet)
    {
        return new CodeSnippetDto
        {
            SnippetId = snippet.SnippetId,
            ArticleId = snippet.ArticleId,
            Title = snippet.Title,
            Description = snippet.Description,
            Language = snippet.Language,
            Code = snippet.Code,
            CreatedBy = snippet.CreatedBy,
            CreatedByName = snippet.CreatedByUser != null
                ? $"{snippet.CreatedByUser.FirstName} {snippet.CreatedByUser.LastName}"
                : "Unknown",
            CreatedAt = snippet.CreatedAt,
            UpdatedAt = snippet.UpdatedAt
        };
    }
}
