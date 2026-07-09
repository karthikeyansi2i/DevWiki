using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Snippets;

public class CreateCodeSnippetCommand : IRequest<ApiResponse<CodeSnippetDto>>
{
    public Guid ArticleId { get; set; }
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public string Language { get; set; } = null!;
    public string Code { get; set; } = null!;
    public Guid CreatedBy { get; set; }
}
