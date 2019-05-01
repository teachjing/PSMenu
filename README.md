# PSMenu

Simple module to generate interactive console menus (like yeoman)

# Examples:

```powershell
Show-Menu @("option 1", "option 2", "option 3")
```

Custom formatting of menu items:

```powershell
Show-Menu -MenuItems $(Get-NetAdapter) -MenuItemFormatter { Param($M) $M.Name }
```

You can also use custom (enriched options), for instance:

```powershell
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
```

This will show the menu items like you expect.

# Installation

You can install it from the PowerShellGallery using PowerShellGet

```powershell
Install-Module PSMenu
```

# Features

- Returns value of selected menu item
- Returns index of selected menu item (using `-ReturnIndex` switch)
- Returns an array of items (using `-MultiSelect` switch)
- Display an array of commands with list items (using `-commands` param)
- Navigation with `up/down` arrows
- Navigation with `j/k` (vim style)
- Longer list scroll within window
- Esc key quits the menu (`null` value returned)

# Contributing

- Source hosted at [GitHub][repo]
- Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome!
