import-module WindowsMidiServices
$sdkinfo = Start-Midi | Write-Output


#region Send single keyboard things
$EDI = Get-MidiEndpointDeviceInfoList
$endpointDeviceId = $EDI[1].EndpointDeviceId
Get-MidiEndpointDeviceInfo $endpointDeviceId
$session = Start-MidiSession "Powershell Demo Session"
$connection = Open-MidiEndpointConnection $session $endpointDeviceId


<#
(0x40905364, 0x02001111)
0x
    4 = Midi channel voice message
    0 = group
    90 = note on - 80 = note off
    53 = note number (C, D, E etc)
    64 = ??Attribute type???? 0x03 = pitch _OR_ is it velocity?

0x
    0200 = MIDI 2.0 velocity, range 0x0000 to 0xFFFF
    1111 = ???Attribute data????


MIDI 1.0 package - 0x25971234
#>
$messages = (0x40905364, 0x02001111), (0x40805364, 0x02000000)#, (0x40904664, 0x02001111), (0x40804664, 0x02000000), (0x40904864, 0x02001111), (0x40804864, 0x02000000)

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
#endregion