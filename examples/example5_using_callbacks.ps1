Import-module "$($PSScriptRoot)\..\PSMenu" -Force

Clear-Host
Write-Host "Current time: $(Get-Date)"
Write-Host ""
$response = Show-Menu @("Option A", "Option B") -Callback {
    $lastTop = [Console]::CursorTop
    [System.Console]::SetCursorPosition(0, 0)
    Write-Host "Current time: $(Get-Date)"
    [System.Console]::SetCursorPosition(0, $lastTop)
}

Write-Host "User selected $($response)"