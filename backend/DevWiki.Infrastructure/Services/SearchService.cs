using DevWiki.Domain.Entities;
using DevWiki.Domain.Enums;
using DevWiki.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace DevWiki.Infrastructure.Services;

public interface ISearchService
{
    Task<(List<Article> Items, int TotalCount)> SearchAsync(
        string query,
        int page = 1,
        int pageSize = 20,
        CancellationToken cancellationToken = default);
}

public class SearchService : ISearchService
{
    private readonly DevWikiDbContext _context;

    public SearchService(DevWikiDbContext context)
    {
        _context = context;
    }

    public async Task<(List<Article> Items, int TotalCount)> SearchAsync(
        string query,
        int page = 1,
        int pageSize = 20,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(query))
        {
            return (new List<Article>(), 0);
        }

        var searchQuery = query.Trim().ToLower();

        var results = _context.Articles
            .Where(a => a.Status == ArticleStatus.Active &&
                        (EF.Functions.Like(a.Title, $"%{searchQuery}%") ||
                         EF.Functions.Like(a.Summary, $"%{searchQuery}%") ||
                         EF.Functions.Like(a.Content, $"%{searchQuery}%")))
            .Include(a => a.Author)
            .Include(a => a.Category)
            .Include(a => a.ArticleTags)
            .ThenInclude(at => at.Tag)
            .OrderByDescending(a => a.UpdatedAt);

        var totalCount = await results.CountAsync(cancellationToken);

        var items = await results
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }
}
