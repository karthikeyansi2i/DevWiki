namespace DevWiki.Application.DTOs.Requests;

public class UpdateArticleRequest
{
    public string Title { get; set; } = null!;
    public string Summary { get; set; } = null!;
    public string Content { get; set; } = null!;
    public int CategoryId { get; set; }
    public List<int> TagIds { get; set; } = new();
    public string? ChangeDescription { get; set; }
}
