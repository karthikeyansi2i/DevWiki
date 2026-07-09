using DevWiki.Domain.Entities;

namespace DevWiki.Domain.Interfaces;

public interface IRepository<T> where T : class
{
    Task<T?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<IEnumerable<T>> GetAllAsync(CancellationToken cancellationToken = default);
    Task AddAsync(T entity, CancellationToken cancellationToken = default);
    void Update(T entity);
    void Remove(T entity);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}

public interface IArticleRepository : IRepository<Article>
{
    Task<Article?> GetBySlugAsync(string slug, CancellationToken cancellationToken = default);
    Task<IEnumerable<Article>> GetByCategoryAsync(int categoryId, CancellationToken cancellationToken = default);
    Task<IEnumerable<Article>> GetActiveArticlesAsync(CancellationToken cancellationToken = default);
    Task<(IEnumerable<Article> Items, int TotalCount)> GetPaginatedAsync(int page, int pageSize, CancellationToken cancellationToken = default);
}

public interface ICategoryRepository : IRepository<Category>
{
    Task<Category?> GetBySlugAsync(string slug, CancellationToken cancellationToken = default);
    Task<Category?> GetByNameAsync(string name, CancellationToken cancellationToken = default);
}

public interface ITagRepository : IRepository<Tag>
{
    Task<Tag?> GetBySlugAsync(string slug, CancellationToken cancellationToken = default);
    Task<Tag?> GetByNameAsync(string name, CancellationToken cancellationToken = default);
}

public interface ICodeSnippetRepository : IRepository<CodeSnippet>
{
    Task<List<CodeSnippet>> GetByArticleAsync(Guid articleId, CancellationToken cancellationToken = default);
    Task<(List<CodeSnippet> Items, int TotalCount)> SearchAsync(string query, int page, int pageSize, CancellationToken cancellationToken = default);
    Task<(List<CodeSnippet> Items, int TotalCount)> GetByLanguageAsync(string language, int page, int pageSize, CancellationToken cancellationToken = default);
}

public interface IUnitOfWork : IDisposable, IAsyncDisposable
{
    IArticleRepository Articles { get; }
    ICategoryRepository Categories { get; }
    ITagRepository Tags { get; }
    ICodeSnippetRepository CodeSnippets { get; }
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
    Task BeginTransactionAsync(CancellationToken cancellationToken = default);
    Task CommitAsync(CancellationToken cancellationToken = default);
    Task RollbackAsync(CancellationToken cancellationToken = default);
}
