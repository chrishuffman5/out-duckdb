# Usage Examples

This directory contains example scripts demonstrating various usage scenarios for the Out-DuckDB module.

## Examples

### 1. [example_sqlserver_to_s3.ps1](example_sqlserver_to_s3.ps1)

Direct export with hardcoded values - matches your exact scenario:

```powershell
# Connection Details
Server: DESKTOP-NJQ8413
Database: FFB
Username: myuser
Password: ff2ErT1dJMLcRzUX+ESK28oYpRxUKV0aEXbuQ7PXENg=

# AWS Profile: myprofile (from ~/.aws/credentials)
```

**Usage:**
```powershell
cd examples
.\example_sqlserver_to_s3.ps1
```

### 2. [example_with_prompt.ps1](example_with_prompt.ps1)

Interactive version that prompts for all credentials (more secure):

**Usage:**
```powershell
cd examples
.\example_with_prompt.ps1
```

You'll be prompted for:
- Database username
- Database password (hidden input)
- AWS profile name
- S3 bucket path
- Server name
- Database name

## AWS Profile Setup

Before running these examples, ensure your AWS credentials are configured:

### Option 1: AWS CLI Configuration

```powershell
# Install AWS CLI if not already installed
# Then configure your profile:
aws configure --profile myprofile
```

Enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-east-1)
- Default output format (json)

### Option 2: Manual Configuration

Create/edit `~/.aws/credentials`:

```ini
[myprofile]
aws_access_key_id = AKIAXXXXXXXXXXXXXXXX
aws_secret_access_key = your-secret-key-here
```

Create/edit `~/.aws/config`:

```ini
[profile myprofile]
region = us-east-1
output = json
```

### Option 3: Temporary Credentials (STS/IAM Role)

For temporary credentials with session token:

```ini
[myprofile]
aws_access_key_id = ASIAXXXXXXXXXXXXXXXX
aws_secret_access_key = your-temporary-secret-key
aws_session_token = your-very-long-session-token
```

## SQL Server Connection Options

The examples use SQL Authentication, but Windows Authentication is also supported:

### Windows Authentication

```powershell
Out-DuckDB `
    -DatabaseType SqlServer `
    -ServerName "DESKTOP-NJQ8413" `
    -DatabaseName "FFB" `
    -AuthenticationType Windows `
    -S3BucketPath "s3://mybucket/ffb-exports" `
    -AwsProfile "myprofile"
```

Note: Windows Authentication doesn't require username/password parameters.

## Expected Output

When running the export, you'll see:

```
Starting database export: FFB from DESKTOP-NJQ8413
Loading AWS credentials from profile: myprofile
  ✓ Found long-term credentials
  ✓ Using region from config: us-east-1
Executing export via Python DuckDB interface...

================================================================================
DuckDB Database Export Tool
================================================================================
Source: sqlserver - FFB@DESKTOP-NJQ8413
Target: s3://mybucket/ffb-exports
================================================================================

Initializing DuckDB with S3 support...
Using AWS profile: myprofile
DuckDB initialized successfully
Connecting to sqlserver database: FFB@DESKTOP-NJQ8413...
Connected to source database successfully
Extracting database metadata...
Saving metadata to: s3://mybucket/ffb-exports/metadata/metadata_20250101_120000.json
...
Export completed successfully!
```

## Troubleshooting

### Profile Not Found

If you get "Profile 'myprofile' not found", check:

```powershell
# Verify credentials file exists
Test-Path "$env:USERPROFILE\.aws\credentials"

# View contents (be careful - contains secrets!)
Get-Content "$env:USERPROFILE\.aws\credentials"
```

### ODBC Driver Error

If you get ODBC driver errors:

1. Install ODBC Driver 17 for SQL Server
2. Verify installation:

```powershell
# Open ODBC Administrator
odbcad32.exe

# Check "Drivers" tab for "ODBC Driver 17 for SQL Server"
```

### S3 Access Denied

Ensure your AWS credentials have permissions:
- `s3:PutObject`
- `s3:GetObject`
- `s3:ListBucket`

Test S3 access:

```powershell
# Using AWS CLI
aws s3 ls s3://mybucket/ --profile myprofile
```

## Output Structure

Your export will create this structure in S3:

```
s3://mybucket/ffb-exports/
├── metadata/
│   ├── metadata_TIMESTAMP.json
│   ├── tables/
│   │   ├── dbo/
│   │   │   ├── Table1.sql
│   │   │   └── Table2.sql
│   ├── views/
│   └── procedures/
├── dbo/
│   ├── Table1/
│   │   └── Table1.parquet
│   └── Table2/
│       └── Table2.parquet
```

## Next Steps

After export, you can query the data using DuckDB:

```python
import duckdb

# Configure AWS credentials
import os
os.environ['AWS_PROFILE'] = 'myprofile'

# Connect and query
conn = duckdb.connect()
conn.execute("INSTALL httpfs; LOAD httpfs;")

# Query parquet files directly from S3
result = conn.execute("""
    SELECT * FROM 's3://mybucket/ffb-exports/dbo/Table1/Table1.parquet'
    LIMIT 10
""").fetchall()

print(result)
```
