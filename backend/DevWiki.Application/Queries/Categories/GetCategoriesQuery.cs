using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Categories;

public class GetCategoriesQuery : IRequest<ApiResponse<List<CategoryDto>>>
{
}
