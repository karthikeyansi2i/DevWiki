namespace DevWiki.Application.DTOs.Responses;

public class CombinedSearchResultDto
{
    public List<ArticleListItemDto> Articles { get; set; } = new();
    public List<CodeSnippetSearchResultDto> CodeSnippets { get; set; } = new();
    public int TotalArticles { get; set; }
    public int TotalSnippets { get; set; }
    public string Query { get; set; } = null!;
}
