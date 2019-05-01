function Get-PositionWithVKey([Array]$MenuItems, [int]$Position, $VKeyCode) {
    $MinPosition = 0
    $MaxPosition = $MenuItems.Count - 1
    $WindowHeight = Get-ConsoleHeight

    If (Test-KeyUp $VKeyCode) { 
        $Position--
    }

    If (Test-KeyDown $VKeyCode) {
        $Position++
    }

    If (Test-KeyPageDown $VKeyCode) {
        $Position = [Math]::Min($MaxPosition, $Position + $WindowHeight)
    }

    If (Test-KeyEnd $VKeyCode) {
        $Position = $MenuItems.Count - 1
    }

    IF (Test-KeyPageUp $VKeyCode) {
        $Position = [Math]::Max($MinPosition, $Position - $WindowHeight)
    }

    IF (Test-KeyHome $VKeyCode) {
        $Position = $MinPosition
    }

    $Position = Get-WrappedPosition $MenuItems $Position

    Return $Position
}