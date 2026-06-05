using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Categories;

public class CreateCategoryCommand : IRequest<ApiResponse<CategoryDto>>
{
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
}
