using DevWiki.Application.DTOs.Responses;
using MediatR;

namespace DevWiki.Application.Commands.Auth;

public class RegisterCommand : IRequest<ApiResponse<UserDto>>
{
    public string Email { get; set; } = null!;
    public string Password { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
}
