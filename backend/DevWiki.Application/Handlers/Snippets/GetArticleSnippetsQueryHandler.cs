using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Snippets;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Snippets;

public class GetArticleSnippetsQueryHandler : IRequestHandler<GetArticleSnippetsQuery, ApiResponse<List<CodeSnippetDto>>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetArticleSnippetsQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<List<CodeSnippetDto>>> Handle(GetArticleSnippetsQuery request, CancellationToken cancellationToken)
    {
        var snippets = await _unitOfWork.CodeSnippets.GetByArticleAsync(request.ArticleId, cancellationToken);
        var dtos = snippets.Select(MapToDto).ToList();
        return ApiResponse<List<CodeSnippetDto>>.SuccessResponse(dtos);
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
