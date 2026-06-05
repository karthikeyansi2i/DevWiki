using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Queries.Tags;

public class GetTagsQuery : IRequest<ApiResponse<List<TagDto>>>
{
}
