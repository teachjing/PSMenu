function Format-MenuItem(
    [Parameter(Mandatory)] $MenuItem, 
    [Switch] $MultiSelect, 
    [Parameter(Mandatory)][bool] $IsItemSelected, 
    [Parameter(Mandatory)][bool] $IsItemFocused) {
    $SelectionPrefix = ''
    if ($MultiSelect) {
        $SelectionPrefix = if ($IsItemSelected) { '[x] ' } else { '[ ] ' }
    }

    $WindowWidth = (Get-Host).UI.RawUI.WindowSize.Width
    $ItemText = $MenuItem.ToString()
    $FocusPrefix = if ($IsItemFocused) { '> ' } else { '  ' }

    $Text = "{0}{1}{2}" -f $FocusPrefix, $SelectionPrefix, $ItemText
    $Text = $Text.PadRight($WindowWidth - ($Text.Length + 2), ' ')

    Return $Text
}

function Format-MenuItemDefault($MenuItem) {
    Return $MenuItem.ToString()
}
