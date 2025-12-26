Function Get-PSNoteIndexFromNoteName {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidatePattern('^[a-gA-G][#b]?(-?[1-2]|[0-8])$', ErrorMessage = 'Input must match pattern <note><octave>')]
        [string]$NoteName
    )

    $null = $NoteName -match '^(?<BaseNote>[a-gA-G][#b]?)(?<Octave>(-?[1-2]|[0-8])$)'
    
    $noteNames  = 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'

    ($noteNames.IndexOf($Matches['BaseNote'].ToUpper())) + (([int]$Matches['Octave'] + 2) * 12)
}