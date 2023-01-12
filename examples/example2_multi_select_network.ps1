Import-module "$($PSScriptRoot)\PSMenu"

[console]::Clear()
#[console]::SetCursorPosition(10,10)

Show-Menu -MenuItems $(Get-NetAdapter) -MultiSelect -MenuItemFormatter { $Args | Select -Exp Name }