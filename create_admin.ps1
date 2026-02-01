$url = "https://school-backend-oiun.onrender.com/api/auth/register"
$body = @{
    email = "admin@school.com"
    password = "admin123"
    name = "System Admin"
    role = "admin"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
    Write-Host "Admin user created successfully!" -ForegroundColor Green
    Write-Host "Email: admin@school.com"
    Write-Host "Password: admin123"
    Write-Host "Token: $($response.token)"
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
}
