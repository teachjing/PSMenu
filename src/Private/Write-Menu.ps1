function Write-MenuItem(
    [Parameter(Mandatory)][String] $MenuItem,
    [Switch]$IsFocused,
    [ConsoleColor]$FocusColor) {
    if ($IsFocused) {
        Write-Host $MenuItem -ForegroundColor $FocusColor
    }
    else {
        Write-Host $MenuItem
    }
}

function Write-Menu {
    param (
        [Parameter(Mandatory)][Array] $MenuItems, 
        [Parameter(Mandatory)][Int] $MenuPosition,
        [Parameter()][Array] $CurrentSelection, 
        [Parameter(Mandatory)][ConsoleColor] $ItemFocusColor,
        [Parameter(Mandatory)][ScriptBlock] $MenuItemFormatter,
        [Switch] $MultiSelect
    )
    
    $MenuItemCount = $MenuItems.Count
    $WindowHeight = Get-ConsoleHeight

    $CurrentIndex = 0;

    if ($MenuItemCount -gt $WindowHeight) {
        $MenuItemCount = $WindowHeight;
        if ($MenuPosition -gt $MenuItemCount) {
            $CurrentIndex = $MenuPosition - $MenuItemCount;
        }
    }

    for ($i = 0; $i -le $MenuItemCount; $i++) {
        if ($null -eq $MenuItems[$CurrentIndex]) {
            Continue
        }

        $MenuItemStr = & $MenuItemFormatter $($MenuItems[$CurrentIndex])
        if (!$MenuItemStr) {
            Throw "'MenuItemFormatter' returned an empty string for item #$CurrentIndex"
        }

        $IsItemSelected = $CurrentSelection -contains $CurrentIndex
        $IsItemFocused = $CurrentIndex -eq $MenuPosition

        $DisplayText = Format-MenuItem -MenuItem $MenuItemStr -MultiSelect:$MultiSelect -IsItemSelected:$IsItemSelected -IsItemFocused:$IsItemFocused
        Write-MenuItem -MenuItem $DisplayText -IsFocused:$IsItemFocused -FocusColor $ItemFocusColor

        $CurrentIndex++;
    }

    if ($Commands.Count -ne 0) {
        Write-Host ($Commands -join ", ")
    }
}
