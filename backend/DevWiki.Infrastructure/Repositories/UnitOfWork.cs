using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Persistence;

namespace DevWiki.Infrastructure.Repositories;

public class UnitOfWork : IUnitOfWork
{
    private readonly DevWikiDbContext _context;
    private IArticleRepository? _articleRepository;
    private ICategoryRepository? _categoryRepository;
    private ITagRepository? _tagRepository;
    private ICodeSnippetRepository? _codeSnippetRepository;

    public UnitOfWork(DevWikiDbContext context)
    {
        _context = context;
    }

    public IArticleRepository Articles => _articleRepository ??= new ArticleRepository(_context);
    public ICategoryRepository Categories => _categoryRepository ??= new CategoryRepository(_context);
    public ITagRepository Tags => _tagRepository ??= new TagRepository(_context);
    public ICodeSnippetRepository CodeSnippets => _codeSnippetRepository ??= new CodeSnippetRepository(_context);

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task BeginTransactionAsync(CancellationToken cancellationToken = default)
    {
        await _context.Database.BeginTransactionAsync(cancellationToken);
    }

    public async Task CommitAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            await SaveChangesAsync(cancellationToken);
            await _context.Database.CommitTransactionAsync(cancellationToken);
        }
        catch
        {
            await RollbackAsync(cancellationToken);
            throw;
        }
    }

    public async Task RollbackAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            await _context.Database.RollbackTransactionAsync(cancellationToken);
        }
        catch (InvalidOperationException)
        {
            // No transaction to rollback
        }
    }

    public void Dispose()
    {
        _context?.Dispose();
    }

    public async ValueTask DisposeAsync()
    {
        if (_context != null)
        {
            await _context.DisposeAsync();
        }
    }
}
