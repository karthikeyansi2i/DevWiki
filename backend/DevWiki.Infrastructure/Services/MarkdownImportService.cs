using DevWiki.Domain.Entities;
using System.Text;

namespace DevWiki.Infrastructure.Services;

public class MarkdownImportDto
{
    public string Title { get; set; } = null!;
    public string Content { get; set; } = null!;
    public int CategoryId { get; set; }
    public List<int> TagIds { get; set; } = new();
}

public interface IMarkdownImportService
{
    List<MarkdownImportDto> ParseMarkdownFile(string content, int categoryId, List<int> tagIds);
}

public class MarkdownImportService : IMarkdownImportService
{
    public List<MarkdownImportDto> ParseMarkdownFile(string content, int categoryId, List<int> tagIds)
    {
        var articles = new List<MarkdownImportDto>();

        if (string.IsNullOrWhiteSpace(content))
        {
            return articles;
        }

        var lines = content.Split(new[] { "\r\n", "\r", "\n" }, StringSplitOptions.None);
        var currentArticle = new StringBuilder();
        var currentTitle = "";
        var firstH1Found = false;

        foreach (var line in lines)
        {
            if (line.StartsWith("# ") && !firstH1Found)
            {
                firstH1Found = true;
                currentTitle = line.Substring(2).Trim();
                continue;
            }

            if (line.StartsWith("# ") && firstH1Found)
            {
                if (!string.IsNullOrWhiteSpace(currentTitle) && !string.IsNullOrWhiteSpace(currentArticle.ToString()))
                {
                    articles.Add(new MarkdownImportDto
                    {
                        Title = currentTitle,
                        Content = currentArticle.ToString().Trim(),
                        CategoryId = categoryId,
                        TagIds = tagIds
                    });
                }

                currentTitle = line.Substring(2).Trim();
                currentArticle.Clear();
                continue;
            }

            if (firstH1Found)
            {
                currentArticle.AppendLine(line);
            }
        }

        if (!string.IsNullOrWhiteSpace(currentTitle) && !string.IsNullOrWhiteSpace(currentArticle.ToString()))
        {
            articles.Add(new MarkdownImportDto
            {
                Title = currentTitle,
                Content = currentArticle.ToString().Trim(),
                CategoryId = categoryId,
                TagIds = tagIds
            });
        }

        return articles;
    }
}
