using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Tags;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Tags;

public class GetTagsQueryHandler : IRequestHandler<GetTagsQuery, ApiResponse<List<TagDto>>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetTagsQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<List<TagDto>>> Handle(GetTagsQuery request, CancellationToken cancellationToken)
    {
        var tags = await _unitOfWork.Tags.GetAllAsync(cancellationToken);

        var result = tags
            .Select(t => new TagDto
            {
                TagId = t.TagId,
                Name = t.Name,
                Slug = t.Slug
            })
            .ToList();

        return ApiResponse<List<TagDto>>.SuccessResponse(result);
    }
}
