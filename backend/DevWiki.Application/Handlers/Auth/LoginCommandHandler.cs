using DevWiki.Application.Commands.Auth;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Infrastructure.Authentication;
using DevWiki.Infrastructure.Persistence;
using MediatR;

namespace DevWiki.Application.Handlers.Auth;

public class LoginCommandHandler : IRequestHandler<LoginCommand, ApiResponse<LoginResponse>>
{
    private readonly DevWikiDbContext _dbContext;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenService _jwtTokenService;

    public LoginCommandHandler(
        DevWikiDbContext dbContext,
        IPasswordHasher passwordHasher,
        IJwtTokenService jwtTokenService)
    {
        _dbContext = dbContext;
        _passwordHasher = passwordHasher;
        _jwtTokenService = jwtTokenService;
    }

    public async Task<ApiResponse<LoginResponse>> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        var normalizedEmail = request.Email.ToLower();
        var user = _dbContext.Users.FirstOrDefault(u => u.NormalizedEmail == normalizedEmail);

        if (user == null || !_passwordHasher.VerifyPassword(request.Password, user.PasswordHash))
        {
            return ApiResponse<LoginResponse>.ErrorResponse("Invalid email or password", "INVALID_CREDENTIALS");
        }

        if (!user.IsActive)
        {
            return ApiResponse<LoginResponse>.ErrorResponse("User account is inactive", "ACCOUNT_INACTIVE");
        }

        var accessToken = _jwtTokenService.GenerateAccessToken(user);
        var refreshToken = _jwtTokenService.GenerateRefreshToken();

        var response = new LoginResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresIn = 3600,
            User = new UserDto
            {
                UserId = user.UserId,
                Email = user.Email,
                FirstName = user.FirstName,
                LastName = user.LastName,
                Role = user.Role.ToString()
            }
        };

        return ApiResponse<LoginResponse>.SuccessResponse(response);
    }
}
