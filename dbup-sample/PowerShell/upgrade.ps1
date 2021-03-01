param(
    [string]$DatabaseName,
    [string]$DatabaseServer,
    [string]$ScriptPath = (Get-Location)
)

Add-Type -Path "${PSScriptRoot}/dbup-core.dll"
Add-Type -Path "${PSScriptRoot}/dbup-sqlserver.dll"

$dbUp = [DbUp.DeployChanges]::To
$dbUp = [SqlServerExtensions]::SqlDatabase($dbUp, "server=${databaseServer};database=${databaseName};Trusted_Connection=Yes;Connection Timeout=15;")
$dbUp = [StandardExtensions]::WithScriptsFromFileSystem($dbUp, (Resolve-Path $scriptPath))
$dbUp = [SqlServerExtensions]::JournalToSqlTable($dbUp, 'dbo', 'MyDbUpVersionTable')
$dbUp = [StandardExtensions]::LogToConsole($dbUp)

$upgradeResult = $dbUp.Build().PerformUpgrade()
