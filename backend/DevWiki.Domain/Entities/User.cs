using DevWiki.Domain.Enums;

namespace DevWiki.Domain.Entities;

public class User
{
    public Guid UserId { get; set; }
    public string Email { get; set; } = null!;
    public string NormalizedEmail { get; set; } = null!;
    public string PasswordHash { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public UserRole Role { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public ICollection<Article> Articles { get; set; } = new List<Article>();
    public ICollection<ArticleRevision> ArticleRevisions { get; set; } = new List<ArticleRevision>();
    public ICollection<AuditLog> AuditLogs { get; set; } = new List<AuditLog>();
}
