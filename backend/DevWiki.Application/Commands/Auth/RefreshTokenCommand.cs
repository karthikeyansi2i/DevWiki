using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Auth;

public class RefreshTokenCommand : IRequest<ApiResponse<RefreshTokenResponse>>
{
    public string RefreshToken { get; set; } = null!;
    public string AccessToken { get; set; } = null!;
}

public class RefreshTokenResponse
{
    public string AccessToken { get; set; } = null!;
    public int ExpiresIn { get; set; }
}
