param([Switch]$NoNewShell)

$MyPath = $PSScriptRoot

if ($NoNewShell -eq $false) {
    Write-Host "Opening new shell..."
    & powershell @("-NoExit", "-File", "$MyPath\Test-Module.ps1", "-NoNewShell")
    Exit $LASTEXITCODE
}

Clear-Host
Import-Module .\src\PSMenu.psm1 -Verbose

function Test-MenuWithStringOptions() {
    $Opts = @(
        "Cheesecake",
        "Fries",
        "Yoghurt"
    )

    $Chosen = Show-Menu -MenuItems $Opts

    Write-Host "You chose: $Chosen"
}

class MyMenuOption {
    [String]$DisplayName
    [ScriptBlock]$ExecuteCallback

    [String]ToString() {
        Return $This.DisplayName
    }

    [Void]Execute() {
        & $This.ExecuteCallback
    }
}

function New-MenuItem([String]$DisplayName, [ScriptBlock]$ExecuteCallback) {
    $MenuItem = [MyMenuOption]::new()
    $MenuItem.DisplayName = $DisplayName
    $MenuItem.ExecuteCallback = $ExecuteCallback
    Return $MenuItem
}

function Get-TestMenuItems() {
    Return @(
        $(New-MenuItem -DisplayName "Say Hello" -ExecuteCallback { Write-Host "Hello!" }),
        $(New-MenuItem -DisplayName "Say Bye!" -ExecuteCallback { Write-Host "Bye!" })
    )
}

function Test-MenuWithClassOptions() {
    $Opts = Get-TestMenuItems

    $Chosen = Show-Menu -MenuItems $Opts
    Write-Host "You chose: $Chosen"

    Write-Host ""
    $Chosen.Execute()
    Write-Host ""
}