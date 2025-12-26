$s = 0
$chordsList = 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
 
gc .\chords.txt  | sort | % {
    """$_"";""$($chordsList[$s])"";""$([char][int]([Convert]::Tostring("0x$_",10)))"""
    $s++
    if ($s -ge ($chordsList.Length -1)) { $s = 0 }
}