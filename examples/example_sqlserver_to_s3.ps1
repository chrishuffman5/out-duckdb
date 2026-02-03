# Example: Export SQL Server database to S3 using AWS profile
# This script demonstrates exporting the FFB database from DESKTOP-NJQ8413 to S3
#
# The Python exporter will generate DuckDB SQL similar to:
#
# CREATE OR REPLACE SECRET secret (
#     TYPE s3,
#     PROVIDER config,
#     KEY_ID 'AKIAIOSFODNN7EXAMPLE',
#     SECRET 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
#     REGION 'us-east-1'
# );
#
# INSTALL nanodbc FROM community;
# LOAD nanodbc;
#
# INSTALL httpfs;
# LOAD httpfs;
#
# COPY (
# SELECT * FROM odbc_query(
#     connection='Driver={SQL Server};Server=localhost;Database=FFB;Uid=sa;Pwd=***',
#     query='SELECT * FROM dbo.Players'
# )) TO 's3://mybucket/exports/players.parquet'
# (FORMAT PARQUET, COMPRESSION ZSTD);


# Import the module
Import-Module ..\OutDuckDB.psd1 -Force

# Database credentials
$dbUsername = "myuser"
$dbPassword = ConvertTo-SecureString "ff2ErT1dJMLcRzUX+ESK28oYpRxUKV0aEXbuQ7PXENg=" -AsPlainText -Force

# AWS Configuration
$awsProfile = "myprofile"  # Name of AWS profile from ~/.aws/credentials
$s3Bucket = "s3://mybucket/ffb-exports"

# Execute the export
Out-DuckDB `
    -DatabaseType SqlServer `
    -ServerName "DESKTOP-NJQ8413" `
    -DatabaseName "FFB" `
    -AuthenticationType SQL `
    -Username $dbUsername `
    -Password $dbPassword `
    -S3BucketPath $s3Bucket `
    -AwsProfile $awsProfile `
    -Verbose

Write-Host "`nExport complete! Check your S3 bucket at: $s3Bucket" -ForegroundColor Green
