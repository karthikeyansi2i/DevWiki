using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Articles;

public class GetArticleBySlugQuery : IRequest<ApiResponse<ArticleDto>>
{
    public string Slug { get; set; } = null!;
}