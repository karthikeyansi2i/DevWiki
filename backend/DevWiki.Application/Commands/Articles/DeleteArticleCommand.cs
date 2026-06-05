using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Articles;

public class DeleteArticleCommand : IRequest<ApiResponse<object>>
{
    public Guid ArticleId { get; set; }
}
