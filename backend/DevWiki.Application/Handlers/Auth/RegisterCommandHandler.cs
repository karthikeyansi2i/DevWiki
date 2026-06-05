using DevWiki.Application.Commands.Auth;
using DevWiki.Application.DTOs.Responses;
using DevWiki.Domain.Entities;
using DevWiki.Domain.Enums;
using DevWiki.Infrastructure.Authentication;
using DevWiki.Infrastructure.Persistence;
using MediatR;

namespace DevWiki.Application.Handlers.Auth;

public class RegisterCommandHandler : IRequestHandler<RegisterCommand, ApiResponse<UserDto>>
{
    private readonly DevWikiDbContext _dbContext;
    private readonly IPasswordHasher _passwordHasher;

    public RegisterCommandHandler(DevWikiDbContext dbContext, IPasswordHasher passwordHasher)
    {
        _dbContext = dbContext;
        _passwordHasher = passwordHasher;
    }

    public async Task<ApiResponse<UserDto>> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        var normalizedEmail = request.Email.ToLower();
        var existingUser = _dbContext.Users.FirstOrDefault(u => u.NormalizedEmail == normalizedEmail);

        if (existingUser != null)
        {
            return ApiResponse<UserDto>.ErrorResponse("Email already registered", "EMAIL_EXISTS");
        }

        var user = new User
        {
            UserId = Guid.NewGuid(),
            Email = request.Email,
            NormalizedEmail = normalizedEmail,
            PasswordHash = _passwordHasher.HashPassword(request.Password),
            FirstName = request.FirstName,
            LastName = request.LastName,
            Role = UserRole.Viewer,
            IsActive = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync(cancellationToken);

        var userDto = new UserDto
        {
            UserId = user.UserId,
            Email = user.Email,
            FirstName = user.FirstName,
            LastName = user.LastName,
            Role = user.Role.ToString()
        };

        return ApiResponse<UserDto>.SuccessResponse(userDto);
    }
}
