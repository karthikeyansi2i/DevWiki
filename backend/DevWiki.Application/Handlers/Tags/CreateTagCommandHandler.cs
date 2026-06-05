using DevWiki.Application.Commands.Tags;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Interfaces;
using DevWiki.Infrastructure.Services;
using MediatR;

namespace DevWiki.Application.Handlers.Tags;

public class CreateTagCommandHandler : IRequestHandler<CreateTagCommand, ApiResponse<TagDto>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ISlugGenerator _slugGenerator;
    private readonly ILogger<CreateTagCommandHandler> _logger;

    public CreateTagCommandHandler(
        IUnitOfWork unitOfWork,
        ISlugGenerator slugGenerator,
        ILogger<CreateTagCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _slugGenerator = slugGenerator;
        _logger = logger;
    }

    public async Task<ApiResponse<TagDto>> Handle(CreateTagCommand request, CancellationToken cancellationToken)
    {
        var existing = await _unitOfWork.Tags.GetByNameAsync(request.Name, cancellationToken);
        if (existing != null)
        {
            return ApiResponse<TagDto>.ErrorResponse("Tag already exists", "TAG_EXISTS");
        }

        var tag = new Tag
        {
            Name = request.Name,
            Slug = _slugGenerator.Generate(request.Name),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _unitOfWork.Tags.AddAsync(tag, cancellationToken);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Tag created: {TagId} - {Name}", tag.TagId, tag.Name);

        return ApiResponse<TagDto>.SuccessResponse(new TagDto
        {
            TagId = tag.TagId,
            Name = tag.Name,
            Slug = tag.Slug
        });
    }
}
