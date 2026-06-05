using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Articles;

public class UpdateArticleCommand : IRequest<ApiResponse<ArticleDto>>
{
    public Guid ArticleId { get; set; }
    public string Title { get; set; } = null!;
    public string Summary { get; set; } = null!;
    public string Content { get; set; } = null!;
    public int CategoryId { get; set; }
    public List<int> TagIds { get; set; } = new();
    public string? ChangeDescription { get; set; }
}
