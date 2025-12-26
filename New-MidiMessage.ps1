

Function New-MidiMessage {
    [CmdletBinding(DefaultParameterSetName = 'Note')]
    Param(
        [Parameter(ParameterSetName = 'Note')]
        [Parameter(ParameterSetName = 'Pitch')]
        [ValidateSet('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B')]
        $Note = 'C',

        [Parameter(ParameterSetName = 'Note')]
        [Parameter(ParameterSetName = 'Pitch')]
        [ValidateRange(0, 9)]
        [int]$Octave = 4, 

        [Parameter(ParameterSetName = 'Note')]
        [Parameter(ParameterSetName = 'Pitch')]
        [ValidateRange(0, 15)]
        [int]$Group = 0,

        [Parameter(ParameterSetName = 'Note')]
        [Parameter(ParameterSetName = 'Pitch')]
        [Microsoft.Windows.Devices.Midi2.Messages.Midi2ChannelVoiceMessageStatus]$MessageStatus = 'NoteOn',

        [Parameter(ParameterSetName = 'Note')]
        [Parameter(ParameterSetName = 'Pitch')]
        [ValidateRange(0, 15)]
        [int]$MidiChannel = 0,

        [Parameter(ParameterSetName = 'Note')]
        [Parameter(ParameterSetName = 'Pitch')]
        [ValidateRange(0, 65535)]
        [uint]$Velocity = 65535,

        [Parameter(ParameterSetName = 'Pitch')]
        [switch]$Pitch,

        [Parameter(ParameterSetName = 'Pitch')]
        [ValidateRange(0, 65535)]
        [int]$AttributeData
    )

    <#
(0x40915364, 0x02001111)
0x
    4 = Midi channel voice message
    0 = group
    9 = note on - 8 = note off
    1 = Midi channel
    5364 = index
        53 = note number (C, D, E etc)
        64 = Attribute type

0x
    0200 = MIDI 2.0 velocity, range 0x0000 to 0xFFFF
    1111 = ???Attribute data????
#>

    if ($PSBoundParameters.Keys.Contains('Pitch')) {
        $attributeType = 3
    }
    else {
        $attributeType = 0
        $AttributeData = 0
    }

    $chordsList = 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
    [int]$octaveRange = ($Octave + 1) * 12
    $playNote = (($octaveRange + $chordsList.IndexOf($Note.ToUpper())) -shl 8) -bor $attributeType

    [uint]$messageData = ($Velocity -shl 16) -bor $AttributeData

    [Microsoft.Windows.Devices.Midi2.Messages.MidiMessageBuilder]::BuildMidi2ChannelVoiceMessage(
        ((Get-Date).ToFileTimeUtc()),
        [Microsoft.Windows.Devices.Midi2.MidiGroup]::new($Group),
        $MessageStatus,
        [Microsoft.Windows.Devices.Midi2.MidiChannel]::new($MidiChannel),
        $playNote,
        $messageData
    )
}
