param(
    [string]$Container = "sqlserver",
    [string]$Password  = "Admin1234!"
)

$sqlcmd = "/opt/mssql-tools18/bin/sqlcmd"
$files  = @("schema.sql", "stored_procedures.sql", "seed.sql")

foreach ($file in $files) {
    $src  = Join-Path $PSScriptRoot $file
    $dest = "/$file"

    Write-Host "Running $file..."

    docker cp $src "${Container}:${dest}"
    docker exec $Container $sqlcmd -S localhost -U sa -P $Password -C -i $dest

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed on $file. Aborting."
        exit 1
    }
}

Write-Host "Database setup complete."
