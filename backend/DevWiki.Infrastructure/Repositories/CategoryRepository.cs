using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace DevWiki.Infrastructure.Repositories;

public class CategoryRepository : ICategoryRepository
{
    private readonly DevWikiDbContext _context;

    public CategoryRepository(DevWikiDbContext context)
    {
        _context = context;
    }

    public async Task<Category?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var categoryId = Convert.ToInt32(id.ToString("N").Substring(24), 16);
        return await _context.Categories.FirstOrDefaultAsync(c => c.CategoryId == categoryId, cancellationToken);
    }

    public async Task<Category?> GetBySlugAsync(string slug, CancellationToken cancellationToken = default)
    {
        return await _context.Categories.FirstOrDefaultAsync(c => c.Slug == slug, cancellationToken);
    }

    public async Task<Category?> GetByNameAsync(string name, CancellationToken cancellationToken = default)
    {
        return await _context.Categories.FirstOrDefaultAsync(c => c.Name == name, cancellationToken);
    }

    public async Task<IEnumerable<Category>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Categories
            .OrderBy(c => c.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Category entity, CancellationToken cancellationToken = default)
    {
        await _context.Categories.AddAsync(entity, cancellationToken);
    }

    public void Update(Category entity)
    {
        _context.Categories.Update(entity);
    }

    public void Remove(Category entity)
    {
        _context.Categories.Remove(entity);
    }

    public async Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        await _context.SaveChangesAsync(cancellationToken);
    }
}
