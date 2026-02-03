# Out-DuckDB PowerShell Module

A PowerShell module for exporting complete database schemas and data to DuckDB format on S3. Supports SQL Server, PostgreSQL, and Oracle databases.

## ⚡ Quick Setup

**Before using this module, install Python dependencies:**

```powershell
# Navigate to the module directory
cd C:\Users\chris\Github\out-duckdb

# Install required Python packages
pip install -r requirements.txt
```

**Required:** Python 3.8+ and the following packages will be installed:
- `duckdb` - DuckDB database engine with S3 support
- `pyodbc` - ODBC connectivity for SQL Server
- `psycopg2-binary` - PostgreSQL adapter
- `cx-Oracle` - Oracle database adapter

**Verify installation:**
```powershell
python -c "import duckdb, pyodbc; print('✓ Ready to use!')"
```

## Features

- **Complete Metadata Extraction**: Captures full database schema including:
  - Table DDL with all column definitions
  - Primary keys and foreign keys
  - Indexes (clustered, non-clustered, unique)
  - Views with complete definitions
  - Stored procedures and functions
  - Sequences (PostgreSQL, Oracle)

- **Intelligent Data Export**:
  - Exports table data maintaining proper sort order based on clustered/primary indexes
  - Falls back to first column sort for heap tables
  - Uses DuckDB with nanodbc for optimal performance
  - Outputs to compressed Parquet format on S3

- **Multi-Database Support**:
  - SQL Server (Windows & SQL Authentication)
  - PostgreSQL
  - Oracle

## Prerequisites

### Windows ODBC Drivers

1. **SQL Server**: [ODBC Driver 17 for SQL Server](https://docs.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)
2. **PostgreSQL**: [PostgreSQL ODBC Driver](https://www.postgresql.org/ftp/odbc/versions/msi/)
3. **Oracle**: Oracle Instant Client with ODBC driver

### Python Requirements

Python 3.8+ with the following packages:

```bash
pip install -r requirements.txt
```

Required packages:
- `duckdb` - DuckDB database engine with S3 support
- `pyodbc` - ODBC connectivity
- `psycopg2-binary` - PostgreSQL adapter
- `cx-Oracle` - Oracle database adapter

## Installation

1. Clone this repository:
```powershell
git clone <repository-url>
cd out-duckdb
```

2. Install Python dependencies:
```powershell
pip install -r requirements.txt
```

3. Import the PowerShell module:
```powershell
Import-Module .\OutDuckDB.psd1
```

## Quick Start

### Using AWS Profile (Recommended)

The easiest way to use the module is with an AWS profile:

```powershell
# Set up AWS credentials first (one-time setup)
aws configure --profile myprofile

# Then run the export
$dbPassword = Read-Host -AsSecureString -Prompt "Database Password"

Out-DuckDB `
    -DatabaseType SqlServer `
    -ServerName "DESKTOP-NJQ8413" `
    -DatabaseName "FFB" `
    -AuthenticationType SQL `
    -Username "myuser" `
    -Password $dbPassword `
    -S3BucketPath "s3://mybucket/ffb-exports" `
    -AwsProfile "myprofile"
```

See [examples/](examples/) directory for complete working examples.

## Usage

### SQL Server with Windows Authentication

```powershell
Out-DuckDB `
    -DatabaseType SqlServer `
    -ServerName "localhost" `
    -DatabaseName "AdventureWorks" `
    -AuthenticationType Windows `
    -S3BucketPath "s3://mybucket/database-exports" `
    -S3AccessKey "AKIAXXXXXXXX" `
    -S3SecretKey (Read-Host -AsSecureString -Prompt "S3 Secret Key")
```

### SQL Server with SQL Authentication

```powershell
$dbPassword = Read-Host -AsSecureString -Prompt "Database Password"
$s3Secret = Read-Host -AsSecureString -Prompt "S3 Secret Key"

Out-DuckDB `
    -DatabaseType SqlServer `
    -ServerName "sql-server.example.com" `
    -DatabaseName "MyDatabase" `
    -Port 1433 `
    -AuthenticationType SQL `
    -Username "dbuser" `
    -Password $dbPassword `
    -S3BucketPath "s3://mybucket/exports/mydb" `
    -S3AccessKey "AKIAXXXXXXXX" `
    -S3SecretKey $s3Secret `
    -S3Region "us-west-2"
```

### PostgreSQL

```powershell
$dbPassword = Read-Host -AsSecureString -Prompt "Database Password"
$s3Secret = Read-Host -AsSecureString -Prompt "S3 Secret Key"

Out-DuckDB `
    -DatabaseType PostgreSQL `
    -ServerName "pg.example.com" `
    -DatabaseName "production_db" `
    -Port 5432 `
    -AuthenticationType Password `
    -Username "postgres" `
    -Password $dbPassword `
    -S3BucketPath "s3://mybucket/pg-exports" `
    -S3AccessKey "AKIAXXXXXXXX" `
    -S3SecretKey $s3Secret
```

### Oracle

```powershell
$dbPassword = Read-Host -AsSecureString -Prompt "Database Password"
$s3Secret = Read-Host -AsSecureString -Prompt "S3 Secret Key"

Out-DuckDB `
    -DatabaseType Oracle `
    -ServerName "oracle.example.com" `
    -DatabaseName "ORCL" `
    -Port 1521 `
    -AuthenticationType Password `
    -Username "system" `
    -Password $dbPassword `
    -S3BucketPath "s3://mybucket/oracle-exports" `
    -S3AccessKey "AKIAXXXXXXXX" `
    -S3SecretKey $s3Secret
```

### Using Temporary AWS Credentials (STS/IAM Roles)

When using temporary credentials from AWS STS or IAM roles, include the session token:

```powershell
$dbPassword = Read-Host -AsSecureString -Prompt "Database Password"
$s3Secret = Read-Host -AsSecureString -Prompt "S3 Secret Key"
$s3Token = Read-Host -AsSecureString -Prompt "S3 Session Token"

Out-DuckDB `
    -DatabaseType SqlServer `
    -ServerName "localhost" `
    -DatabaseName "MyDatabase" `
    -AuthenticationType SQL `
    -Username "dbuser" `
    -Password $dbPassword `
    -S3BucketPath "s3://mybucket/exports" `
    -S3AccessKey "ASIAXXXXXXXX" `
    -S3SecretKey $s3Secret `
    -S3SessionToken $s3Token `
    -S3Region "us-east-1"
```

Note: Temporary credentials typically have Access Key IDs starting with "ASIA" instead of "AKIA".

## Output Structure

The module creates the following S3 structure:

```
s3://mybucket/database-exports/
├── metadata/
│   ├── metadata_YYYYMMDD_HHMMSS.json    # Complete metadata JSON
│   ├── tables/
│   │   ├── schema1/
│   │   │   ├── table1.sql
│   │   │   └── table2.sql
│   │   └── schema2/
│   │       └── table3.sql
│   ├── views/
│   │   └── schema1/
│   │       └── view1.sql
│   └── procedures/
│       └── schema1/
│           ├── proc1.sql
│           └── func1.sql
├── schema1/
│   ├── table1/
│   │   └── table1.parquet
│   └── table2/
│       └── table2.parquet
└── schema2/
    └── table3/
        └── table3.parquet
```

## Parameters

### Required Parameters

- `DatabaseType`: Database type (`SqlServer`, `PostgreSQL`, or `Oracle`)
- `ServerName`: Database server hostname or IP
- `DatabaseName`: Name of database to export
- `AuthenticationType`: Authentication method
  - SQL Server: `Windows` or `SQL`
  - PostgreSQL/Oracle: `Password`
- `S3BucketPath`: S3 bucket path (e.g., `s3://mybucket/exports`)

### Optional Parameters

- `Port`: Database port (defaults: SQL Server=1433, PostgreSQL=5432, Oracle=1521)
- `Username`: Username for SQL/Password authentication
- `Password`: SecureString password for SQL/Password authentication
- `S3AccessKey`: AWS Access Key ID (not needed if using `-AwsProfile`)
- `S3SecretKey`: AWS Secret Access Key (SecureString) (not needed if using `-AwsProfile`)
- `S3SessionToken`: AWS Session Token (SecureString) - Required for temporary credentials from STS/IAM roles
- `AwsProfile`: AWS CLI profile name - Reads credentials from `~/.aws/credentials` (recommended)
- `S3Region`: AWS region (default: `us-east-1`)
- `PythonPath`: Path to Python executable (default: `python`)

**Note:** You must provide either `-AwsProfile` OR both `-S3AccessKey` and `-S3SecretKey`, but not both.

## How It Works

1. **Metadata Extraction**: Connects to source database and extracts complete schema using system catalog queries
2. **Metadata Storage**: Saves all DDL scripts and metadata JSON to S3 `metadata/` folder
3. **Data Export**: For each table:
   - Determines optimal sort order (clustered index > primary key > unique index > first column)
   - Uses DuckDB to connect via ODBC and export data directly to S3 as Parquet
   - Maintains data order for efficient querying
4. **Transaction Safety**: Each table export runs in its own transaction

## Architecture

```
PowerShell (OutDuckDB.psm1)
    ↓
    ├─→ Passes config via environment variable
    ↓
Python (duckdb_export.py)
    ↓
    ├─→ Metadata Extractors (ODBC/Native drivers)
    │   ├─→ sqlserver_metadata.py
    │   ├─→ postgresql_metadata.py
    │   └─→ oracle_metadata.py
    ↓
    └─→ DuckDB Engine
        ├─→ nanodbc connection to source DB
        └─→ Direct write to S3 (httpfs extension)
```

## Performance Considerations

- **Parallelization**: Currently exports tables sequentially. Future versions may support parallel exports.
- **Memory**: DuckDB uses memory-efficient streaming for large tables
- **Compression**: Parquet files use ZSTD compression by default for better compression ratio (configurable)
- **Row Groups**: Default row group size of 100,000 rows balances file size and query performance

## Troubleshooting

### ODBC Driver Not Found

Ensure the appropriate ODBC driver is installed:
- SQL Server: Run `odbcad32.exe` and verify "ODBC Driver 17 for SQL Server" appears
- PostgreSQL: Install from [postgresql.org](https://www.postgresql.org/ftp/odbc/versions/msi/)
- Oracle: Install Oracle Instant Client

### Python Module Import Errors

```powershell
pip install --upgrade -r requirements.txt
```

### S3 Access Denied

Verify your AWS credentials have the following permissions:
- `s3:PutObject`
- `s3:GetObject`
- `s3:ListBucket`

**Using Temporary Credentials**: If using AWS STS or IAM role temporary credentials, ensure you provide all three parameters:
- `S3AccessKey` (starts with ASIA)
- `S3SecretKey`
- `S3SessionToken` (required for temporary credentials)

### Connection Timeout

Increase timeout or check firewall rules:
```powershell
# Add to connection string via custom ODBC DSN if needed
```

## Future Enhancements

- [ ] Parallel table export
- [ ] Incremental export support
- [ ] Delta/change data capture
- [ ] Custom filtering/table selection
- [ ] Progress indicators and ETA
- [ ] Resume capability for interrupted exports
- [ ] Compression options (gzip, zstd)
- [ ] Partition support for large tables

## License

MIT License

## Contributing

Contributions welcome! Please submit issues and pull requests.

## Credits

Built with:
- [DuckDB](https://duckdb.org/) - Fast analytical database
- [PowerShell](https://docs.microsoft.com/en-us/powershell/) - Automation framework
- [Python](https://www.python.org/) - Glue layer
