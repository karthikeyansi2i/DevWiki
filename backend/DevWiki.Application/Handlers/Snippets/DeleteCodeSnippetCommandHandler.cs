using DevWiki.Application.Commands.Snippets;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Snippets;

public class DeleteCodeSnippetCommandHandler : IRequestHandler<DeleteCodeSnippetCommand, ApiResponse<object>>
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ILogger<DeleteCodeSnippetCommandHandler> _logger;

    public DeleteCodeSnippetCommandHandler(IUnitOfWork unitOfWork, ILogger<DeleteCodeSnippetCommandHandler> logger)
    {
        _unitOfWork = unitOfWork;
        _logger = logger;
    }

    public async Task<ApiResponse<object>> Handle(DeleteCodeSnippetCommand request, CancellationToken cancellationToken)
    {
        var snippet = await _unitOfWork.CodeSnippets.GetByIdAsync(request.SnippetId, cancellationToken);
        if (snippet == null)
            return ApiResponse<object>.ErrorResponse("Code snippet not found", "SNIPPET_NOT_FOUND");

        _unitOfWork.CodeSnippets.Remove(snippet);
        await _unitOfWork.SaveChangesAsync(cancellationToken);

        _logger.LogInformation("Code snippet deleted: {SnippetId}", request.SnippetId);

        return ApiResponse<object>.SuccessResponse(new { snippetId = request.SnippetId });
    }
}
