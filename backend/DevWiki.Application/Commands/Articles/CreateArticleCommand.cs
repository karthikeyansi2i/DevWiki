using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Articles;

public class CreateArticleCommand : IRequest<ApiResponse<ArticleDto>>
{
    public string Title { get; set; } = null!;
    public string Summary { get; set; } = null!;
    public string Content { get; set; } = null!;
    public int CategoryId { get; set; }
    public List<int> TagIds { get; set; } = new();
    public Guid AuthorId { get; set; }
}
