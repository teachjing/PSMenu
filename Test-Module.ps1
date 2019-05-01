param([Switch]$NoNewShell, [Switch]$SmokeTest)

$MyPath = $PSScriptRoot

if ($NoNewShell -eq $false) {
    Write-Host "Opening new shell..."

    $PsArgs = @("-NoExit", "-File", "$MyPath\Test-Module.ps1", "-NoNewShell")

    if ($SmokeTest) {
        $PsArgs += @("-SmokeTest")
    }

    & powershell $PsArgs
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

function Test-MenuWithCustomFormatter() {
    Show-Menu -MenuItems $(Get-NetAdapter) -MenuItemFormatter { Param($M) $M.Name }
}

if ($SmokeTest) {
    Write-Host "Test-MenuWithClassOptions" -ForegroundColor Cyan
    Test-MenuWithClassOptions

    Write-Host "Test-MenuWithCustomFormatter" -ForegroundColor Cyan
    Test-MenuWithCustomFormatter
    Exit 0
}
