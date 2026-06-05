using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Auth;

public class LoginCommand : IRequest<ApiResponse<LoginResponse>>
{
    public string Email { get; set; } = null!;
    public string Password { get; set; } = null!;
}
