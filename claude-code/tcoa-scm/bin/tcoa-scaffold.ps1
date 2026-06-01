param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ArgsFromCaller
)

$ErrorActionPreference = 'Stop'

$skillsRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
$repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $skillsRoot))
$cliPath = Join-Path $repoRoot 'tcoa-scaffold\src\cli.js'

if (-not (Test-Path $cliPath)) {
    throw "未找到 tcoa-scaffold CLI: $cliPath"
}

$finalArgs = @()
$hasProjectRoot = $false

foreach ($arg in $ArgsFromCaller) {
    if ($arg -eq '--project-root') {
        $hasProjectRoot = $true
    }
    $finalArgs += $arg
}

if (-not $hasProjectRoot) {
    $finalArgs += @('--project-root', $repoRoot)
}

& node $cliPath @finalArgs
exit $LASTEXITCODE

