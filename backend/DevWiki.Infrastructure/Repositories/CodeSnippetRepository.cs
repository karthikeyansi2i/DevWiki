using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace DevWiki.Infrastructure.Repositories;

public class CodeSnippetRepository : ICodeSnippetRepository
{
    private readonly DevWikiDbContext _context;

    public CodeSnippetRepository(DevWikiDbContext context)
    {
        _context = context;
    }

    public async Task<CodeSnippet?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.CodeSnippets
            .Include(s => s.Article)
            .Include(s => s.CreatedByUser)
            .FirstOrDefaultAsync(s => s.SnippetId == id, cancellationToken);
    }

    public async Task<IEnumerable<CodeSnippet>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.CodeSnippets
            .Include(s => s.Article)
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<List<CodeSnippet>> GetByArticleAsync(Guid articleId, CancellationToken cancellationToken = default)
    {
        return await _context.CodeSnippets
            .Where(s => s.ArticleId == articleId)
            .Include(s => s.CreatedByUser)
            .OrderByDescending(s => s.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<(List<CodeSnippet> Items, int TotalCount)> SearchAsync(
        string query, int page, int pageSize, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(query))
            return (new List<CodeSnippet>(), 0);

        var searchQuery = query.Trim().ToLower();

        var baseQuery = _context.CodeSnippets
            .Where(s => s.Title.ToLower().Contains(searchQuery) ||
                        s.Code.ToLower().Contains(searchQuery) ||
                        (s.Description != null && s.Description.ToLower().Contains(searchQuery)));

        var totalCount = await baseQuery.CountAsync(cancellationToken);

        var scoredIds = await baseQuery
            .Select(s => new
            {
                s.SnippetId,
                s.CreatedAt,
                Score = (s.Title.ToLower().Contains(searchQuery) ? 10 : 0) +
                        (s.Description != null && s.Description.ToLower().Contains(searchQuery) ? 3 : 0) +
                        (s.Code.ToLower().Contains(searchQuery) ? 1 : 0)
            })
            .OrderByDescending(x => x.Score)
            .ThenByDescending(x => x.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(x => x.SnippetId)
            .ToListAsync(cancellationToken);

        var items = await _context.CodeSnippets
            .Where(s => scoredIds.Contains(s.SnippetId))
            .Include(s => s.Article)
            .Include(s => s.CreatedByUser)
            .ToListAsync(cancellationToken);

        var orderedItems = scoredIds
            .Select(id => items.First(s => s.SnippetId == id))
            .ToList();

        return (orderedItems, totalCount);
    }

    public async Task<(List<CodeSnippet> Items, int TotalCount)> GetByLanguageAsync(
        string language, int page, int pageSize, CancellationToken cancellationToken = default)
    {
        var results = _context.CodeSnippets
            .Where(s => s.Language == language)
            .Include(s => s.Article)
            .Include(s => s.CreatedByUser)
            .OrderByDescending(s => s.CreatedAt);

        var totalCount = await results.CountAsync(cancellationToken);
        var items = await results
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public async Task AddAsync(CodeSnippet entity, CancellationToken cancellationToken = default)
        => await _context.CodeSnippets.AddAsync(entity, cancellationToken);

    public void Update(CodeSnippet entity)
        => _context.CodeSnippets.Update(entity);

    public void Remove(CodeSnippet entity)
        => _context.CodeSnippets.Remove(entity);

    public async Task SaveChangesAsync(CancellationToken cancellationToken = default)
        => await _context.SaveChangesAsync(cancellationToken);
}
