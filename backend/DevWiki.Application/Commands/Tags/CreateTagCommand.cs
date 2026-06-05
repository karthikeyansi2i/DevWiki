using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Tags;

public class CreateTagCommand : IRequest<ApiResponse<TagDto>>
{
    public string Name { get; set; } = null!;
}
