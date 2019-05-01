param([Switch]$NoNewShell, [Switch]$SmokeTest, [String]$EncCmd, [ScriptBlock] $AutoExec, [Switch]$Exit)

$MyPath = $PSScriptRoot

if ($NoNewShell -eq $false) {
    Write-Host "Opening new shell..."

    [string[]]$PsArgs = @()
    
    if (!$Exit) {
        $PsArgs += @("-NoExit")
    }

    $PsArgs += @("-File", "$MyPath\Test-Module.ps1", "-NoNewShell")

    if ($SmokeTest) {
        $PsArgs += @("-SmokeTest")
    }

    if ($AutoExec) {
        $EncCmd = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($AutoExec.ToString()))
        $PsArgs += @("-EncCmd", $EncCmd)
    }

    

    Write-Host "powershell $PsArgs"
    & powershell $PsArgs
    Exit $LASTEXITCODE
}

Clear-Host
Import-Module .\src\PSMenu\PSMenu.psm1 -Verbose

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

function Get-TestMenuItemsByCount($Count) {
    for ($Index = 1; $Index -le $Count; $Index++) {
        New-MenuItem -DisplayName "Test Menuitem $Index" -ExecuteCallback { Write-Host "This was #$Index" }.GetNewClosure()
    }
}

function Test-MenuWithClassOptions() {
    $Opts = Get-TestMenuItems

    $Chosen = Show-Menu -MenuItems $Opts
    Write-Host "You chose: $Chosen"

    Write-Host ""
    $Chosen.Execute()
    Write-Host ""
}

function Test-ScrollingMenu([int]$SurplusItems = 5, [Switch]$MultiSelect) {
    $ItemsToGenerate = [Console]::WindowHeight + $SurplusItems

    Write-Host "Generating $ItemsToGenerate menu items"
    $MenuItems = Get-TestMenuItemsByCount -Count $ItemsToGenerate

    Show-Menu -MenuItems $MenuItems -MultiSelect:$MultiSelect
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

if ($EncCmd) {
    $Cmd = [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($EncCmd))

    Write-Host "Executing: $Cmd"
    Invoke-Expression -Command $Cmd
}
