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

        var baseQuery = _context.Articles
            .Where(a => a.Status == ArticleStatus.Active &&
                        (a.Title.ToLower().Contains(searchQuery) ||
                         a.Summary.ToLower().Contains(searchQuery) ||
                         a.Content.ToLower().Contains(searchQuery) ||
                         a.ArticleTags.Any(at => at.Tag.Name.ToLower().Contains(searchQuery))));

        var totalCount = await baseQuery.CountAsync(cancellationToken);

        var scoredIds = await baseQuery
            .Select(a => new
            {
                a.ArticleId,
                a.UpdatedAt,
                Score = (a.Title.ToLower().Contains(searchQuery) ? 10 : 0) +
                        (a.ArticleTags.Any(at => at.Tag.Name.ToLower().Contains(searchQuery)) ? 5 : 0) +
                        (a.Summary.ToLower().Contains(searchQuery) ? 3 : 0) +
                        (a.Content.ToLower().Contains(searchQuery) ? 1 : 0)
            })
            .OrderByDescending(x => x.Score)
            .ThenByDescending(x => x.UpdatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => x.ArticleId)
            .ToListAsync(cancellationToken);

        var items = await _context.Articles
            .Where(a => scoredIds.Contains(a.ArticleId))
            .Include(a => a.Author)
            .Include(a => a.Category)
            .Include(a => a.ArticleTags)
            .ThenInclude(at => at.Tag)
            .ToListAsync(cancellationToken);

        var orderedItems = scoredIds
            .Select(id => items.First(a => a.ArticleId == id))
            .ToList();

        return (orderedItems, totalCount);
    }
}
