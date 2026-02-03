# Test Out-DuckDB Prerequisites
Write-Host "=== Out-DuckDB Setup Verification ===" -ForegroundColor Cyan
Write-Host ""

# 1. Check Python
Write-Host "1. Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>&1
    Write-Host "   ✓ $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Python not found!" -ForegroundColor Red
}

# 2. Check Python packages
Write-Host "`n2. Checking Python packages..." -ForegroundColor Yellow
$packages = @('duckdb', 'pyodbc', 'psycopg2', 'cx_Oracle')
foreach ($pkg in $packages) {
    try {
        $result = python -c "import $pkg; print($pkg.__version__)" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✓ $pkg : $result" -ForegroundColor Green
        } else {
            Write-Host "   ✗ $pkg : Not installed" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ✗ $pkg : Error checking" -ForegroundColor Red
    }
}

# 3. Check ODBC Drivers (for metadata extraction only)
Write-Host "`n3. Checking ODBC Drivers (for metadata)..." -ForegroundColor Yellow
$sqlDrivers = Get-OdbcDriver | Where-Object {$_.Name -like '*SQL Server*'} | Select-Object -ExpandProperty Name -Unique
if ($sqlDrivers -contains 'ODBC Driver 17 for SQL Server') {
    Write-Host "   ✓ ODBC Driver 17 for SQL Server" -ForegroundColor Green
} else {
    Write-Host "   ⚠ ODBC Driver 17 for SQL Server not found" -ForegroundColor Yellow
    Write-Host "     Available: $($sqlDrivers -join ', ')" -ForegroundColor Gray
}

# 4. Check AWS credentials
Write-Host "`n4. Checking AWS credentials..." -ForegroundColor Yellow
$awsCredFile = Join-Path $env:USERPROFILE ".aws\credentials"
if (Test-Path $awsCredFile) {
    Write-Host "   ✓ AWS credentials file exists" -ForegroundColor Green

    # Check for default profile
    $credContent = Get-Content $awsCredFile -Raw
    if ($credContent -match "\[default\]") {
        Write-Host "   ✓ 'default' profile found" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ 'default' profile not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ AWS credentials file not found: $awsCredFile" -ForegroundColor Red
}

# 5. Check DuckDB extensions
Write-Host "`n5. Checking DuckDB extensions..." -ForegroundColor Yellow
try {
    $checkExtensions = @"
import duckdb
conn = duckdb.connect(':memory:')

# Check which extensions can be installed
try:
    conn.execute('INSTALL httpfs')
    print('✓ httpfs')
except Exception as e:
    print(f'✗ httpfs: {e}')

try:
    conn.execute('INSTALL sqlserver')
    print('✓ sqlserver')
except Exception as e:
    print(f'✗ sqlserver: {e}')

conn.close()
"@

    $result = python -c $checkExtensions 2>&1
    Write-Host "   $result" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Error checking extensions" -ForegroundColor Red
}

# 6. Test database connection
Write-Host "`n6. Test SQL Server connection (optional)..." -ForegroundColor Yellow
Write-Host "   Enter SQL Server details to test (or press Enter to skip):" -ForegroundColor Gray
$testServer = Read-Host "   Server (default: DESKTOP-NJQ8413)"
if ([string]::IsNullOrWhiteSpace($testServer)) { $testServer = "DESKTOP-NJQ8413" }

if ($testServer -ne "DESKTOP-NJQ8413" -or (Read-Host "   Test connection? (y/n)") -eq 'y') {
    try {
        $conn = New-Object System.Data.Odbc.OdbcConnection
        $conn.ConnectionString = "Driver={ODBC Driver 17 for SQL Server};Server=$testServer;Database=master;Trusted_Connection=yes;"
        $conn.Open()
        Write-Host "   ✓ Connection successful!" -ForegroundColor Green
        $conn.Close()
    } catch {
        Write-Host "   ✗ Connection failed: $_" -ForegroundColor Red
    }
}

Write-Host "`n=== Setup Verification Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. If any checks failed, install missing components" -ForegroundColor Gray
Write-Host "2. Configure AWS credentials if needed: aws configure --profile default" -ForegroundColor Gray
Write-Host "3. Run: Import-Module .\OutDuckDB.psd1" -ForegroundColor Gray
Write-Host "4. Run: Out-DuckDB with your database details" -ForegroundColor Gray
