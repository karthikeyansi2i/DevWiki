using DevWiki.Application.Commands.Snippets;
using FluentValidation;

namespace DevWiki.Application.Validators;

public class CreateCodeSnippetCommandValidator : AbstractValidator<CreateCodeSnippetCommand>
{
    private static readonly string[] AllowedLanguages =
    [
        "C#", "SQL", "TypeScript", "JavaScript", "HTML", "CSS",
        "JSON", "YAML", "XML", "Bash", "PowerShell"
    ];

    public CreateCodeSnippetCommandValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Title is required")
            .MaximumLength(255).WithMessage("Title must not exceed 255 characters");

        RuleFor(x => x.Language)
            .NotEmpty().WithMessage("Language is required")
            .Must(l => AllowedLanguages.Contains(l))
            .WithMessage($"Language must be one of: {string.Join(", ", AllowedLanguages)}");

        RuleFor(x => x.Code)
            .NotEmpty().WithMessage("Code is required");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Description must not exceed 500 characters");
    }
}
