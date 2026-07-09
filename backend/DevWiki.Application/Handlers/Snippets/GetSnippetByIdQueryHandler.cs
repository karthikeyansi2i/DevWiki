using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Snippets;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Snippets;

public class GetSnippetByIdQueryHandler : IRequestHandler<GetSnippetByIdQuery, ApiResponse<CodeSnippetDto>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetSnippetByIdQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<CodeSnippetDto>> Handle(GetSnippetByIdQuery request, CancellationToken cancellationToken)
    {
        var snippet = await _unitOfWork.CodeSnippets.GetByIdAsync(request.SnippetId, cancellationToken);
        if (snippet == null)
            return ApiResponse<CodeSnippetDto>.ErrorResponse("Code snippet not found", "SNIPPET_NOT_FOUND");

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
