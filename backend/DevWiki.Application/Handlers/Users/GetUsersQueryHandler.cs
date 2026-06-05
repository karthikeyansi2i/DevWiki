using DevWiki.Application.DTOs.Responses;
using DevWiki.Application.Queries.Users;
using DevWiki.Domain.Interfaces;
using MediatR;

namespace DevWiki.Application.Handlers.Users;

public class GetUsersQueryHandler : IRequestHandler<GetUsersQuery, ApiResponse<List<UserDetailDto>>>
{
    private readonly IUnitOfWork _unitOfWork;

    public GetUsersQueryHandler(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<ApiResponse<List<UserDetailDto>>> Handle(GetUsersQuery request, CancellationToken cancellationToken)
    {
        var users = await _unitOfWork.Articles.GetAllAsync(cancellationToken);
        var allUsers = users.Select(a => a.Author).Distinct().ToList();

        var userDtos = allUsers
            .Select(u => new UserDetailDto
            {
                UserId = u.UserId,
                Email = u.Email,
                FirstName = u.FirstName,
                LastName = u.LastName,
                Role = u.Role.ToString(),
                IsActive = u.IsActive,
                CreatedAt = u.CreatedAt
            })
            .ToList();

        return ApiResponse<List<UserDetailDto>>.SuccessResponse(userDtos);
    }
}
