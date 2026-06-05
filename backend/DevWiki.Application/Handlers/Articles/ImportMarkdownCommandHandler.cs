using DevWiki.Application.Commands.Articles;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Enums;
using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Services;
using MediatR;

namespace DevWiki.Application.Handlers.Articles;

public class ImportMarkdownCommandHandler : IRequestHandler<ImportMarkdownCommand, ImportMarkdownResult>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMarkdownImportService _markdownImportService;
    private readonly ISlugGenerator _slugGenerator;
    private readonly ILogger<ImportMarkdownCommandHandler> _logger;

    public ImportMarkdownCommandHandler(
        IUnitOfWork unitOfWork,
        IMarkdownImportService markdownImportService,
        ISlugGenerator slugGenerator,
        ILogger<ImportMarkdownCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _markdownImportService = markdownImportService;
        _slugGenerator = slugGenerator;
        _logger = logger;
    }

    public async Task<ImportMarkdownResult> Handle(ImportMarkdownCommand request, CancellationToken cancellationToken)
    {
        var result = new ImportMarkdownResult();

        try
        {
            var parsedArticles = _markdownImportService.ParseMarkdownFile(
                request.Content,
                request.CategoryId,
                request.TagIds);

            if (parsedArticles.Count == 0)
            {
                result.Errors.Add("No articles found in the provided markdown content");
                return result;
            }

            var category = await _unitOfWork.Categories.GetByIdAsync(
                new Guid($"00000000-0000-0000-0000-{request.CategoryId:000000000000}"),
                cancellationToken);

            if (category == null)
            {
                result.Errors.Add("Category not found");
                return result;
            }

            var createdCount = 0;

            foreach (var parsedArticle in parsedArticles)
            {
                try
                {
                    var slug = _slugGenerator.Generate(parsedArticle.Title);
                    var existingArticle = await _unitOfWork.Articles.GetBySlugAsync(slug, cancellationToken);

                    if (existingArticle != null)
                    {
                        slug = $"{slug}-{Guid.NewGuid().ToString().Substring(0, 8)}";
                    }

                    var summary = ExtractSummary(parsedArticle.Content, 200);

                    var article = new Article
                    {
                        ArticleId = Guid.NewGuid(),
                        Title = parsedArticle.Title,
                        Slug = slug,
                        Summary = summary,
                        Content = parsedArticle.Content,
                        AuthorId = request.AuthorId,
                        CategoryId = parsedArticle.CategoryId,
                        Status = ArticleStatus.Active,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    };

                    foreach (var tagId in parsedArticle.TagIds)
                    {
                        var tag = await _unitOfWork.Tags.GetByIdAsync(
                            new Guid($"00000000-0000-0000-0000-{tagId:000000000000}"),
                            cancellationToken);

                        if (tag != null)
                        {
                            article.ArticleTags.Add(new ArticleTag { ArticleId = article.ArticleId, TagId = tag.TagId });
                        }
                    }

                    await _unitOfWork.Articles.AddAsync(article, cancellationToken);
                    await _unitOfWork.SaveChangesAsync(cancellationToken);

                    createdCount++;
                    _logger.LogInformation("Article imported: {ArticleId} - {Title}", article.ArticleId, article.Title);
                }
                catch (Exception ex)
                {
                    result.Errors.Add($"Error importing article '{parsedArticle.Title}': {ex.Message}");
                    _logger.LogError(ex, "Error importing article: {Title}", parsedArticle.Title);
                }
            }

            result.Success = true;
            result.CreatedArticles = createdCount;
        }
        catch (Exception ex)
        {
            result.Errors.Add($"Import failed: {ex.Message}");
            _logger.LogError(ex, "Markdown import failed");
        }

        return result;
    }

    private string ExtractSummary(string content, int maxLength)
    {
        var lines = content.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None);
        var summary = string.Join(" ", lines.Where(l => !l.StartsWith("#") && !string.IsNullOrWhiteSpace(l)));

        if (summary.Length > maxLength)
        {
            summary = summary.Substring(0, maxLength) + "...";
        }

        return summary;
    }
}
