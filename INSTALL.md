# Installation Guide

## Quick Start

### 1. Install ODBC Drivers

#### Windows

**SQL Server**
```powershell
# Download and install ODBC Driver 17 for SQL Server
# https://docs.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server
```

**PostgreSQL**
```powershell
# Download and install PostgreSQL ODBC driver
# https://www.postgresql.org/ftp/odbc/versions/msi/
# Example: psqlodbc_13_02_0000-x64.zip
```

**Oracle**
```powershell
# Download Oracle Instant Client
# https://www.oracle.com/database/technologies/instant-client/downloads.html
# Install both Basic and ODBC packages
```

### 2. Verify ODBC Drivers

```powershell
# Open ODBC Data Source Administrator (64-bit)
odbcad32.exe

# Go to "Drivers" tab and verify:
# - ODBC Driver 17 for SQL Server (or later)
# - PostgreSQL Unicode
# - Oracle in OraClient19Home1 (or your Oracle version)
```

### 3. Install Python Dependencies

```powershell
# Ensure Python 3.8+ is installed
python --version

# Install required packages
pip install -r requirements.txt
```

### 4. Verify Python Packages

```powershell
python -c "import duckdb; print('DuckDB version:', duckdb.__version__)"
python -c "import pyodbc; print('pyodbc installed')"
python -c "import psycopg2; print('psycopg2 installed')"
python -c "import cx_Oracle; print('cx_Oracle installed')"
```

### 5. Configure AWS Credentials (Optional)

If not passing credentials via parameters, configure AWS CLI:

```powershell
# Install AWS CLI
# https://aws.amazon.com/cli/

# Configure credentials
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)
```

### 6. Import PowerShell Module

```powershell
# Navigate to module directory
cd C:\path\to\out-duckdb

# Import module
Import-Module .\OutDuckDB.psd1

# Verify module is loaded
Get-Command -Module OutDuckDB
```

## Detailed Setup

### Python Virtual Environment (Recommended)

```powershell
# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt
```

### Oracle Specific Setup

Oracle requires additional configuration:

1. **Install Oracle Instant Client**:
   - Download from Oracle website
   - Extract to a directory (e.g., `C:\oracle\instantclient_19_18`)

2. **Set Environment Variables**:
```powershell
# Add to PATH
$env:PATH += ";C:\oracle\instantclient_19_18"

# Set TNS_ADMIN if using tnsnames.ora
$env:TNS_ADMIN = "C:\oracle\instantclient_19_18\network\admin"

# Make permanent (requires admin)
[Environment]::SetEnvironmentVariable("PATH", $env:PATH, "Machine")
```

3. **Configure ODBC Driver**:
```powershell
# Run odbcad32.exe and add Oracle ODBC driver manually if not auto-detected
```

### PostgreSQL Specific Setup

1. **Install PostgreSQL ODBC Driver**:
   - Download and run installer
   - Both ANSI and Unicode versions will be installed
   - Use Unicode version for better character support

2. **Test Connection**:
```powershell
# Create test DSN in ODBC Administrator
# Or test with connection string directly
```

### SQL Server Specific Setup

1. **Install ODBC Driver 17** (or 18):
```powershell
# Download from Microsoft
# Install both x64 and x86 if needed
```

2. **Test Windows Authentication**:
```powershell
# Ensure your Windows user has access to the database
# Check SQL Server permissions
```

## Troubleshooting Installation

### Python Package Installation Failures

**Issue**: `pip install` fails for `psycopg2-binary`
```powershell
# Try installing Visual C++ Build Tools
# Or use pre-built wheel:
pip install --only-binary :all: psycopg2-binary
```

**Issue**: `cx_Oracle` fails to install
```powershell
# Ensure Oracle Instant Client is in PATH
# Try:
pip install cx_Oracle --upgrade
```

### ODBC Driver Issues

**Issue**: "Data source name not found"
```powershell
# Verify driver name exactly matches:
Get-OdbcDriver

# Common names:
# - "ODBC Driver 17 for SQL Server"
# - "PostgreSQL Unicode"
# - "Oracle in OraClient19Home1"
```

**Issue**: "Driver's SQLAllocHandle on SQL_HANDLE_ENV failed"
```powershell
# Reinstall the ODBC driver
# Ensure you're using 64-bit Python with 64-bit ODBC drivers
```

### DuckDB Issues

**Issue**: DuckDB fails to install S3 extension
```python
# Manually install extension:
import duckdb
conn = duckdb.connect()
conn.execute("INSTALL httpfs;")
conn.execute("LOAD httpfs;")
```

## Testing Your Setup

### Test Script

Create a test file `test_setup.ps1`:

```powershell
# Test SQL Server connection
try {
    $testConn = New-Object System.Data.Odbc.OdbcConnection
    $testConn.ConnectionString = "Driver={ODBC Driver 17 for SQL Server};Server=localhost;Database=master;Trusted_Connection=yes;"
    $testConn.Open()
    Write-Host "✓ SQL Server ODBC connection successful" -ForegroundColor Green
    $testConn.Close()
} catch {
    Write-Host "✗ SQL Server ODBC connection failed: $_" -ForegroundColor Red
}

# Test Python and packages
try {
    python -c "import duckdb, pyodbc, psycopg2, cx_Oracle; print('✓ All Python packages installed')"
} catch {
    Write-Host "✗ Python package test failed: $_" -ForegroundColor Red
}

# Test module import
try {
    Import-Module .\OutDuckDB.psd1 -ErrorAction Stop
    Write-Host "✓ PowerShell module loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "✗ Module import failed: $_" -ForegroundColor Red
}
```

Run the test:
```powershell
.\test_setup.ps1
```

## Next Steps

After successful installation, proceed to [README.md](README.md) for usage examples.
