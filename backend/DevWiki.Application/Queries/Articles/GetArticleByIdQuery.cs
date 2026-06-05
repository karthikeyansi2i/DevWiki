using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Articles;

public class GetArticleByIdQuery : IRequest<ApiResponse<ArticleDto>>
{
    public Guid ArticleId { get; set; }
}
