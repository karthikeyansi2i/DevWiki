using DevWiki.Application.Commands.Auth;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Infrastructure.Authentication;
using DevWiki.Infrastructure.Persistence;
using MediatR;

namespace DevWiki.Application.Handlers.Auth;

public class RefreshTokenCommandHandler : IRequestHandler<RefreshTokenCommand, ApiResponse<RefreshTokenResponse>>
{
    private readonly DevWikiDbContext _dbContext;
    private readonly IJwtTokenService _jwtTokenService;

    public RefreshTokenCommandHandler(DevWikiDbContext dbContext, IJwtTokenService jwtTokenService)
    {
        _dbContext = dbContext;
        _jwtTokenService = jwtTokenService;
    }

    public async Task<ApiResponse<RefreshTokenResponse>> Handle(RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        var principal = _jwtTokenService.GetPrincipalFromExpiredToken(request.AccessToken);

        if (principal == null)
        {
            return ApiResponse<RefreshTokenResponse>.ErrorResponse("Invalid token", "INVALID_TOKEN");
        }

        var userIdClaim = principal.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier);
        if (userIdClaim == null || !Guid.TryParse(userIdClaim.Value, out var userId))
        {
            return ApiResponse<RefreshTokenResponse>.ErrorResponse("Invalid token", "INVALID_TOKEN");
        }

        var user = await _dbContext.Users.FindAsync(new object[] { userId }, cancellationToken: cancellationToken);
        if (user == null || !user.IsActive)
        {
            return ApiResponse<RefreshTokenResponse>.ErrorResponse("User not found or inactive", "USER_NOT_FOUND");
        }

        var newAccessToken = _jwtTokenService.GenerateAccessToken(user);

        var response = new RefreshTokenResponse
        {
            AccessToken = newAccessToken,
            ExpiresIn = 3600
        };

        return ApiResponse<RefreshTokenResponse>.SuccessResponse(response);
    }
}
