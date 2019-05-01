
function Get-CurrentSelectedValue {
    Param($Command, $Value)
    if ($Command -ne '') {
        Return @($Command, @($Value));
    }
    else {
        Return $Value;
    }
}

