namespace DevWiki.Application.DTOs.Responses;

public class ApiResponse<T>
{
    public bool Success { get; set; }
    public T? Data { get; set; }
    public List<ErrorDetail>? Errors { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;

    public static ApiResponse<T> SuccessResponse(T data)
    {
        return new ApiResponse<T>
        {
            Success = true,
            Data = data
        };
    }

    public static ApiResponse<T> ErrorResponse(string message, string code = "ERROR")
    {
        return new ApiResponse<T>
        {
            Success = false,
            Errors = new List<ErrorDetail>
            {
                new ErrorDetail { Code = code, Message = message }
            }
        };
    }

    public static ApiResponse<T> ErrorResponse(List<ErrorDetail> errors)
    {
        return new ApiResponse<T>
        {
            Success = false,
            Errors = errors
        };
    }
}

public class ErrorDetail
{
    public string Code { get; set; } = null!;
    public string Message { get; set; } = null!;
    public string? Field { get; set; }
}
