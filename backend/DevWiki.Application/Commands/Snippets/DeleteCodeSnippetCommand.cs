using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Snippets;

public class DeleteCodeSnippetCommand : IRequest<ApiResponse<object>>
{
    public Guid SnippetId { get; set; }
}
