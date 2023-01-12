Import-module "$($PSScriptRoot)\..\PSMenu" -Force

[console]::Clear()
#[console]::SetCursorPosition(10,10)

Show-Menu -MenuItems $(Get-NetAdapter) -MultiSelect -MenuItemFormatter { $Args | Select -Exp Name }