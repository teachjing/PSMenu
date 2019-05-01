function Get-PositionWithVKey([Array]$MenuItems, [int]$Position, $VKeyCode) {
    If (Test-KeyUp $VKeyCode) { 
        $Position--
    }

    If (Test-KeyDown $VKeyCode) {
        $Position++
    }

    If (Test-KeyPageDown $VKeyCode) {
        $Position = $MenuItems.Count - 1
    }

    If (Test-KeyEnd $VKeyCode) {
        $Position = $MenuItems.Count - 1
    }

    IF (Test-KeyPageUp $VKeyCode) {
        $Position = 0
    }

    IF (Test-KeyHome $VKeyCode) {
        $Position = 0
    }

    $Position = Get-WrappedPosition $MenuItems $Position

    Return $Position
}