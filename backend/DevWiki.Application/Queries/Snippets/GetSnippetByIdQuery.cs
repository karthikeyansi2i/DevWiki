using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Snippets;

public class GetSnippetByIdQuery : IRequest<ApiResponse<CodeSnippetDto>>
{
    public Guid SnippetId { get; set; }
}
