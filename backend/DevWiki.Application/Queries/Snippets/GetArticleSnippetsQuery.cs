using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Snippets;

public class GetArticleSnippetsQuery : IRequest<ApiResponse<List<CodeSnippetDto>>>
{
    public Guid ArticleId { get; set; }
}
