Import-module "$($PSScriptRoot)\..\PSMenu" -Force

class MyMenuOption {
    [String]$DisplayName
    [ScriptBlock]$Script

    [String]ToString() {
        Return $This.DisplayName
    }
}

function New-MenuItem([String]$DisplayName, [ScriptBlock]$Script) {
    $MenuItem = [MyMenuOption]::new()
    $MenuItem.DisplayName = $DisplayName
    $MenuItem.Script = $Script
    Return $MenuItem
}

$Opts = @(
    $(New-MenuItem -DisplayName "Say Hello" -Script { Write-Host "Hello!" }),
    $(New-MenuItem -DisplayName "Say Bye!" -Script { Write-Host "Bye!" })
)

$Chosen = Show-Menu -MenuItems $Opts

& $Chosen.Script