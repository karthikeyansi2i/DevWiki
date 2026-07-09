using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace DevWiki.Infrastructure.Repositories;

public class TagRepository : ITagRepository
{
    private readonly DevWikiDbContext _context;

    public TagRepository(DevWikiDbContext context)
    {
        _context = context;
    }

    public async Task<Tag?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var tagId = Convert.ToInt32(id.ToString("N").Substring(24), 16);
        return await _context.Tags.FirstOrDefaultAsync(t => t.TagId == tagId, cancellationToken);
    }

    public async Task<Tag?> GetBySlugAsync(string slug, CancellationToken cancellationToken = default)
    {
        return await _context.Tags.FirstOrDefaultAsync(t => t.Slug == slug, cancellationToken);
    }

    public async Task<Tag?> GetByNameAsync(string name, CancellationToken cancellationToken = default)
    {
        return await _context.Tags.FirstOrDefaultAsync(t => t.Name == name, cancellationToken);
    }

    public async Task<IEnumerable<Tag>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Tags
            .OrderBy(t => t.Name)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Tag entity, CancellationToken cancellationToken = default)
    {
        await _context.Tags.AddAsync(entity, cancellationToken);
    }

    public void Update(Tag entity)
    {
        _context.Tags.Update(entity);
    }

    public void Remove(Tag entity)
    {
        _context.Tags.Remove(entity);
    }

    public async Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        await _context.SaveChangesAsync(cancellationToken);
    }
}
