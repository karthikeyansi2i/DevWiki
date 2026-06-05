using DevWiki.Application.Commands.Categories;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Services;
using MediatR;

namespace DevWiki.Application.Handlers.Categories;

public class CreateCategoryCommandHandler : IRequestHandler<CreateCategoryCommand, ApiResponse<CategoryDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ISlugGenerator _slugGenerator;
    private readonly ILogger<CreateCategoryCommandHandler> _logger;

    public CreateCategoryCommandHandler(
        IUnitOfWork unitOfWork,
        ISlugGenerator slugGenerator,
        ILogger<CreateCategoryCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _slugGenerator = slugGenerator;
        _logger = logger;
    }

    public async Task<ApiResponse<CategoryDto>> Handle(CreateCategoryCommand request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.Categories.GetByNameAsync(request.Name, cancellationToken);
        if (existing != null)
        {
            return ApiResponse<CategoryDto>.ErrorResponse("Category already exists", "CATEGORY_EXISTS");
        }

        var category = new Category
        {
            Name = request.Name,
            Slug = _slugGenerator.Generate(request.Name),
            Description = request.Description,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _unitOfWork.Categories.AddAsync(category, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Category created: {CategoryId} - {Name}", category.CategoryId, category.Name);

        return ApiResponse<CategoryDto>.SuccessResponse(new CategoryDto
        {
            CategoryId = category.CategoryId,
            Name = category.Name,
            Slug = category.Slug,
            Description = category.Description,
            ArticleCount = 0
        });
    }
}
