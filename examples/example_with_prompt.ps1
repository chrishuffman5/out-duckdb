# Example: Export SQL Server database to S3 with interactive prompts
# This is a more secure version that prompts for the password

# Import the module
Import-Module ..\OutDuckDB.psd1 -Force

# Prompt for database password (more secure)
Write-Host "Enter database credentials:" -ForegroundColor Cyan
$dbUsername = Read-Host "Database Username"
$dbPassword = Read-Host "Database Password" -AsSecureString

# AWS Configuration
Write-Host "`nEnter AWS configuration:" -ForegroundColor Cyan
$awsProfile = Read-Host "AWS Profile Name (from ~/.aws/credentials)"
$s3Bucket = Read-Host "S3 Bucket Path (e.g., s3://mybucket/exports)"

# Database connection details
Write-Host "`nEnter database connection details:" -ForegroundColor Cyan
$serverName = Read-Host "SQL Server Name (default: localhost)"
if ([string]::IsNullOrWhiteSpace($serverName)) { $serverName = "localhost" }

$databaseName = Read-Host "Database Name"

# Execute the export
Write-Host "`nStarting export..." -ForegroundColor Yellow
Out-DuckDB `
    -DatabaseType SqlServer `
    -ServerName $serverName `
    -DatabaseName $databaseName `
    -AuthenticationType SQL `
    -Username $dbUsername `
    -Password $dbPassword `
    -S3BucketPath $s3Bucket `
    -AwsProfile $awsProfile

Write-Host "`nExport complete! Check your S3 bucket at: $s3Bucket" -ForegroundColor Green
