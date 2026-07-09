namespace DevWiki.Application.DTOs.Requests;

public class CreateCodeSnippetRequest
{
    public string Title { get; set; } = null!;
    public string? Description { get; set; }
    public string Language { get; set; } = null!;
    public string Code { get; set; } = null!;
}
