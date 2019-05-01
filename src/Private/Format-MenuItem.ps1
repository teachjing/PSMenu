function Format-MenuItem(
    [Parameter(Mandatory)] $MenuItem, 
    [Switch] $MultiSelect, 
    [Parameter(Mandatory)][bool] $IsItemSelected, 
    [Parameter(Mandatory)][bool] $IsItemFocused) {
    $SelectionPrefix = ''
    if ($MultiSelect) {
        $SelectionPrefix = if ($SelectionPrefix) { '[x] ' } else { '[ ] ' }
    }

    $WindowWidth = (Get-Host).UI.RawUI.WindowSize.Width
    $ItemText = $MenuItem.ToString().PadRight($WindowWidth - ($Item.Length + 2), ' ')
    $FocusPrefix = if ($IsItemFocused) { '> ' } else { '  ' }

    $Text = "{0}{1}{2}" -f $FocusPrefix, $SelectionPrefix, $ItemText

    Return $Text
}

function Format-MenuItemDefault($MenuItem) {
    Return $MenuItem.ToString()
}
