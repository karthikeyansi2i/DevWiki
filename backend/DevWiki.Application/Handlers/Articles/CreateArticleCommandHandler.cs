using DevWiki.Application.Commands.Articles;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Enums;
using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Services;
using MediatR;

namespace DevWiki.Application.Handlers.Articles;

public class CreateArticleCommandHandler : IRequestHandler<CreateArticleCommand, ApiResponse<ArticleDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ISlugGenerator _slugGenerator;
    private readonly ILogger<CreateArticleCommandHandler> _logger;

    public CreateArticleCommandHandler(
        IUnitOfWork unitOfWork,
        ISlugGenerator slugGenerator,
        ILogger<CreateArticleCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _slugGenerator = slugGenerator;
        _logger = logger;
    }

    public async Task<ApiResponse<ArticleDto>> Handle(
        CreateArticleCommand request,
        CancellationToken cancellationToken)
    {
        var category = await _unitOfWork.Categories.GetByIdAsync(new Guid($"00000000-0000-0000-0000-{request.CategoryId:000000000000}"), cancellationToken);
        if (category == null)
        {
            return ApiResponse<ArticleDto>.ErrorResponse("Category not found", "CATEGORY_NOT_FOUND");
        }

        var slug = _slugGenerator.Generate(request.Title);
        var existingArticle = await _unitOfWork.Articles.GetBySlugAsync(slug, cancellationToken);
        if (existingArticle != null)
        {
            slug = $"{slug}-{Guid.NewGuid().ToString().Substring(0, 8)}";
        }

        var article = new Article
        {
            ArticleId = Guid.NewGuid(),
            Title = request.Title,
            Slug = slug,
            Summary = request.Summary,
            Content = request.Content,
            AuthorId = request.AuthorId,
            CategoryId = request.CategoryId,
            Status = ArticleStatus.Active,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        foreach (var tagId in request.TagIds)
        {
            var tag = await _unitOfWork.Tags.GetByIdAsync(new Guid($"00000000-0000-0000-0000-{tagId:000000000000}"), cancellationToken);
            if (tag != null)
            {
                article.ArticleTags.Add(new ArticleTag { ArticleId = article.ArticleId, TagId = tag.TagId });
            }
        }

        await _unitOfWork.Articles.AddAsync(article, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Article created: {ArticleId} by {AuthorId}", article.ArticleId, article.AuthorId);

        return ApiResponse<ArticleDto>.SuccessResponse(MapToDto(article));
    }

    private ArticleDto MapToDto(Article article)
    {
        return new ArticleDto
        {
            ArticleId = article.ArticleId,
            Title = article.Title,
            Slug = article.Slug,
            Summary = article.Summary,
            Content = article.Content,
            AuthorId = article.AuthorId,
            AuthorName = $"{article.Author.FirstName} {article.Author.LastName}",
            CategoryId = article.CategoryId,
            CategoryName = article.Category.Name,
            Tags = article.ArticleTags
                .Select(at => new TagDto
                {
                    TagId = at.Tag.TagId,
                    Name = at.Tag.Name,
                    Slug = at.Tag.Slug
                })
                .ToList(),
            Status = article.Status.ToString(),
            ViewCount = article.ViewCount,
            CreatedAt = article.CreatedAt,
            UpdatedAt = article.UpdatedAt
        };
    }
}
