using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Articles;

public class RestoreArticleCommand : IRequest<ApiResponse<ArticleDto>>
{
    public Guid ArticleId { get; set; }
    public Guid RevisionId { get; set; }
}
