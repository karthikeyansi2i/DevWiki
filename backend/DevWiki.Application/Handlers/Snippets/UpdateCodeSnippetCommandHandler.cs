using DevWiki.Application.Commands.Snippets;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Snippets;

public class UpdateCodeSnippetCommandHandler : IRequestHandler<UpdateCodeSnippetCommand, ApiResponse<CodeSnippetDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<UpdateCodeSnippetCommandHandler> _logger;

    public UpdateCodeSnippetCommandHandler(IUnitOfWork unitOfWork, ILogger<UpdateCodeSnippetCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<ApiResponse<CodeSnippetDto>> Handle(UpdateCodeSnippetCommand request, CancellationToken cancellationToken)
    {
        var snippet = await _unitOfWork.CodeSnippets.GetByIdAsync(request.SnippetId, cancellationToken);
        if (snippet == null)
            return ApiResponse<CodeSnippetDto>.ErrorResponse("Code snippet not found", "SNIPPET_NOT_FOUND");

        snippet.Title = request.Title;
        snippet.Description = request.Description;
        snippet.Language = request.Language;
        snippet.Code = request.Code;
        snippet.UpdatedBy = request.UpdatedBy;
        snippet.UpdatedAt = DateTime.UtcNow;

        _unitOfWork.CodeSnippets.Update(snippet);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Code snippet updated: {SnippetId}", snippet.SnippetId);

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
