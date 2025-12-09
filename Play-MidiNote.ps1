

Function Play-MidiNote {
    Param(
        [ValidateSet('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B')]
        $Note = 'C',

        [ValidateRange(0,9)]
        [int]$Octave = 4, 

        [UInt]$Length = 1000,

        [ValidateRange(0, 15)]
        [int]$Group = 0,

        [int]$MidiChannel = 0,

        [Parameter(Mandatory)]
        $Connection
    )

    $chordsList = 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'

    # 32 bit
    $mt = 0x4 -shl 28
    $group = $Group -shl 24
    $midiNoteOn = 9 -shl 20
    $midiNoteOff = 8 -shl 20
    $midiChannel = $MidiChannel -shl 16


    [int]$octaveRange = ($Octave + 1) * 12
    $playNote = ($octaveRange + $chordsList.IndexOf($Note.ToUpper())) -shl 8

    $attribute = 82

    $onMessage = $mt -bor $group -bor $midiNoteOn -bor $MidiChannel -bor $playNote -bor $attribute
    $offMessage = $mt -bor $group -bor $midiNoteOff -bor $MidiChannel -bor $playNote -bor $attribute

    $o = "{0:x2}" -f $onMessage
    Write-Verbose $o
    Send-MidiMessage $connection ($onMessage, 0x02000000) -Timestamp 0
    Start-Sleep -Milliseconds $Length
    $o = "{0:x2}" -f $offMessage
    Write-Verbose $o
    Send-MidiMessage $connection ($offMessage, 0x02000000) -Timestamp 0
}
