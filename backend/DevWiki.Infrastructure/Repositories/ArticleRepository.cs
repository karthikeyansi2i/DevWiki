using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace DevWiki.Infrastructure.Repositories;

public class ArticleRepository : IArticleRepository
{
    private readonly DevWikiDbContext _context;

    public ArticleRepository(DevWikiDbContext context)
    {
        _context = context;
    }

    public async Task<Article?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.Articles
            .Include(a => a.Author)
            .Include(a => a.Category)
            .Include(a => a.ArticleTags)
            .ThenInclude(at => at.Tag)
            .FirstOrDefaultAsync(a => a.ArticleId == id, cancellationToken);
    }

    public async Task<Article?> GetBySlugAsync(string slug, CancellationToken cancellationToken = default)
    {
        return await _context.Articles
            .Include(a => a.Author)
            .Include(a => a.Category)
            .Include(a => a.ArticleTags)
            .ThenInclude(at => at.Tag)
            .FirstOrDefaultAsync(a => a.Slug == slug, cancellationToken);
    }

    public async Task<IEnumerable<Article>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Articles
            .Include(a => a.Author)
            .Include(a => a.Category)
            .Include(a => a.ArticleTags)
            .ThenInclude(at => at.Tag)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Article>> GetByCategoryAsync(int categoryId, CancellationToken cancellationToken = default)
    {
        return await _context.Articles
            .Where(a => a.CategoryId == categoryId)
            .Include(a => a.Author)
            .Include(a => a.Category)
            .Include(a => a.ArticleTags)
            .ThenInclude(at => at.Tag)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Article>> GetActiveArticlesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Articles
            .Where(a => a.Status == Domain.Enums.ArticleStatus.Active)
            .Include(a => a.Author)
            .Include(a => a.Category)
            .Include(a => a.ArticleTags)
            .ThenInclude(at => at.Tag)
            .OrderByDescending(a => a.UpdatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<(IEnumerable<Article> Items, int TotalCount)> GetPaginatedAsync(
        int page, int pageSize, CancellationToken cancellationToken = default)
    {
        var query = _context.Articles
            .Where(a => a.Status == Domain.Enums.ArticleStatus.Active)
            .Include(a => a.Author)
            .Include(a => a.Category)
            .Include(a => a.ArticleTags)
            .ThenInclude(at => at.Tag)
            .OrderByDescending(a => a.UpdatedAt);

        var totalCount = await query.CountAsync(cancellationToken);
        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync(cancellationToken);

        return (items, totalCount);
    }

    public async Task AddAsync(Article entity, CancellationToken cancellationToken = default)
    {
        await _context.Articles.AddAsync(entity, cancellationToken);
    }

    public void Update(Article entity)
    {
        _context.Articles.Update(entity);
    }

    public void Remove(Article entity)
    {
        _context.Articles.Remove(entity);
    }

    public async Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        await _context.SaveChangesAsync(cancellationToken);
    }
}
