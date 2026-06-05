using System.Text;
using System.Text.RegularExpressions;

namespace DevWiki.Infrastructure.Services;

public interface ISlugGenerator
{
    string Generate(string text);
}

public class SlugGenerator : ISlugGenerator
{
    public string Generate(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return string.Empty;

        var normalizedString = text.Normalize(NormalizationForm.FormD);
        var stringBuilder = new StringBuilder();

        foreach (var c in normalizedString)
        {
            var unicodeCategory = System.Globalization.CharUnicodeInfo.GetUnicodeCategory(c);
            if (unicodeCategory != System.Globalization.UnicodeCategory.NonSpacingMark)
            {
                stringBuilder.Append(c);
            }
        }

        var slug = stringBuilder.ToString().Normalize(NormalizationForm.FormC);
        slug = Regex.Replace(slug, @"[^a-zA-Z0-9\s-]", string.Empty);
        slug = Regex.Replace(slug, @"\s+", "-").ToLower();
        slug = Regex.Replace(slug, @"-+", "-").Trim('-');

        return slug;
    }
}
