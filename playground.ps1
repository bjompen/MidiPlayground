import-module WindowsMidiServices
$sdkinfo = Start-Midi | Write-Output


#region Send single keyboard things
$EDI = Get-MidiEndpointDeviceInfoList
$endpointDeviceId = $EDI[1].EndpointDeviceId
Get-MidiEndpointDeviceInfo $endpointDeviceId
$session = Start-MidiSession "Powershell Demo Session"
$connection = Open-MidiEndpointConnection $session $endpointDeviceId

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


MIDI 1.0 package - 0x25971234
#>

$messages = (0x40903c52, 0x02001111), (0x40803c52, 0x02000000)#, (0x40904664, 0x02001111), (0x40804664, 0x02000000), (0x40904864, 0x02001111), (0x40804864, 0x02000000)

foreach ($message in $messages) {
    Send-MidiMessage $connection $message -Timestamp 0
    start-sleep -Seconds 5
}


#endregion

#region Send multiple keyboard things
$EDI = Get-MidiEndpointDeviceInfoList
$endpoint1DeviceId = $EDI[0].EndpointDeviceId
$endpoint2DeviceId = $EDI[1].EndpointDeviceId
$endpoint3DeviceId = $EDI[2].EndpointDeviceId
$endpoint4DeviceId = $EDI[3].EndpointDeviceId

$session = Start-MidiSession "Powershell Demo Session"
$connection1 = Open-MidiEndpointConnection $session $endpoint1DeviceId
$connection2 = Open-MidiEndpointConnection $session $endpoint2DeviceId
$connection3 = Open-MidiEndpointConnection $session $endpoint3DeviceId
$connection4 = Open-MidiEndpointConnection $session $endpoint4DeviceId

Start-Job -ScriptBlock {
    import-module WindowsMidiServices
    $sdkinfo = Start-Midi 
    $EDI = Get-MidiEndpointDeviceInfoList
    $endpoint1DeviceId = $EDI[0].EndpointDeviceId
    $session = Start-MidiSession "Powershell Demo Session"
    $connection1 = Open-MidiEndpointConnection $session $endpoint1DeviceId

    while ($true) {
        play-MidiNote -Note E -Connection $connection1 -Length 200
        Start-Sleep -Milliseconds 287
    }
} -InitializationScript $sb

Start-Job -ScriptBlock {
    import-module WindowsMidiServices
    $sdkinfo = Start-Midi 
    $EDI = Get-MidiEndpointDeviceInfoList
    $endpoint2DeviceId = $EDI[1].EndpointDeviceId
    $session = Start-MidiSession "Powershell Demo Session"
    $connection2 = Open-MidiEndpointConnection $session $endpoint2DeviceId
    
    while ($true) {
        play-MidiNote -Note E -Connection $connection2 -Length 10000
        play-MidiNote -Note C -Connection $connection2 -Length 10000
    }
    
} -InitializationScript $sb


Get-Job | Stop-Job
Get-Job | Remove-Job
#endregion

#region receive keyboard things
$endpoints = Get-MidiEndpointDeviceInfoList 
# Select endpoint 
$selectedEndpoint = $endpoints[-1]


$session = Start-MidiSession "Powershell Demo Session"
$connection = Open-MidiEndpointConnection $session $selectedEndpoint.EndpointDeviceId

$eventHandlerAction = {
    #Write-Host "Message Received"
    #Write-Host $EventArgs.Timestamp
    Get-MidiMessageInfo $EventArgs.Words
}

# wire up the event handler and start the background job. These events are on a different thread.
$job = Register-ObjectEvent -SourceIdentifier "OnMessageReceivedHandler" -InputObject $connection -EventName "MessageReceived" -Action $eventHandlerAction

# just spin until a key is pressed
do {
    # get the output from our background job
    $r = Receive-Job -Job $job
    if ($r.MessageTypeHasChannelField) {
        $r.WordsHex
    }
} until ([System.Console]::KeyAvailable)

Get-Job | Stop-Job
Get-Job | Remove-Job


-and ($r.WordsHex -match '00$')
do {
    # get the output from our background job
    $r = Receive-Job -Job $job
    if ($r.MessageTypeHasChannelField) {
        if (($r.MessageType.ToString() -like "Midi*Voice32") -and ($r.WordsHex -match '00$')) {
            $key = $r.WordsHex -replace '^\d{4}', '' -replace '\d{2}$', ''
            Send-VirtualKeyboard -key "0x$key"
        }
    }
} until ([System.Console]::KeyAvailable)
#endregion


#region Superconnection


function New-PSMidiEndpointConnectionList {
    [CmdletBinding()]
    param ()

    #TODO: Check if Start-Midi is run, if not, do it. Maybe do this in the module psm1?
    $PSMidiSession = Start-MidiSession -Name 'PSMidiSession'
    $edi = Get-MidiEndpointDeviceInfoList
    $connectionList = @{}
    foreach ($endpoint in $edi) {
        $connection = Open-MidiEndpointConnection -Session $PSMidiSession -EndpointDeviceId $endpoint.EndpointDeviceId
        $connectionList.Add($endpoint.Name, $connection)
    }
    $connectionList
}
#endregion


#region clock
# https://microsoft.github.io/MIDI/sdk-reference/MidiClock/

[Microsoft.Windows.Devices.Midi2.MidiClock] | gm -s
[Microsoft.Windows.Devices.Midi2.MidiClock]::TimestampFrequency
[Microsoft.Windows.Devices.Midi2.MidiClock]::TimestampConstantSendImmediately
[Microsoft.Windows.Devices.Midi2.MidiClock]::TimestampConstantMessageQueueMaximumFutureTicks
[Microsoft.Windows.Devices.Midi2.MidiClock]::Now
[Microsoft.Windows.Devices.Midi2.MidiClock]::ConvertTimestampTicksToMicroseconds
[Microsoft.Windows.Devices.Midi2.MidiClock]::ConvertTimestampTicksToMicroseconds([Microsoft.Windows.Devices.Midi2.MidiClock]::Now)
[Microsoft.Windows.Devices.Midi2.MidiClock]::ConvertTimestampTicksToseconds([Microsoft.Windows.Devices.Midi2.MidiClock]::Now)
[Microsoft.Windows.Devices.Midi2.MidiClock]::OffsetTimestampByMicroseconds
[Microsoft.Windows.Devices.Midi2.MidiClock]::OffsetTimestampBySeconds([Microsoft.Windows.Devices.Midi2.MidiClock]::Now, 10)
[Microsoft.Windows.Devices.Midi2.MidiClock]::Now ; [Microsoft.Windows.Devices.Midi2.MidiClock]::OffsetTimestampBySeconds([Microsoft.Windows.Devices.Midi2.MidiClock]::Now, 10)



#TODO: script ska ha ett kösystem.


$testTimer = {
    $null = [int]$totalBeats++
    $null = [int]$currentBeat++
    if ($totalBeats -le 2) {
        $s = [System.Diagnostics.Stopwatch]::new()
    }
    Write-Output "Current beat: $CurrentBeat"
    Write-Output "Total beats: $TotalBeats"
    Write-Output "Delay $($s.Elapsed.TotalMilliseconds)"
    $s.Restart()
    if ($CurrentBeat -eq 4) {
        $CurrentBeat = 0
    }
}

Start-Metronome -BPM 60 -ScriptBlock $testTimer


# $chordList = [System.Collections.Generic.Queue[chord]]::new()
# $chordList.Enqueue([chord]::new('C3'))
# $chordList.Enqueue([chord]::new('D4'))
# $chordList.Enqueue([chord]::new('E1'))
# $chordList.Enqueue([chord]::new('Fb2'))



# ## Kösystem!

# $q = [System.Collections.Generic.PriorityQueue[object, int]]::new()
# $s = Get-Service
# $s | % { $q.Enqueue($_.Name, (Get-Random -Minimum 1 -Maximum 100)) }
# $q.Dequeue()
# $q.enqueue('a', 1)
# $q.Dequeue()
# $q.Dequeue()

# Use a linked list maybe?
# https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.linkedlist-1?view=net-6.0
# https://github.com/jstnryan/midi-dot-net/blob/master/Midi/MessageQueue.cs#L34