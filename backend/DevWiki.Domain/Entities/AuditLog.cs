namespace DevWiki.Domain.Entities;

public class AuditLog
{
    public Guid AuditLogId { get; set; }
    public Guid UserId { get; set; }
    public string Action { get; set; } = null!;
    public string EntityType { get; set; } = null!;
    public string EntityId { get; set; } = null!;
    public string? Changes { get; set; }
    public DateTime CreatedAt { get; set; }

    public User User { get; set; } = null!;
}
