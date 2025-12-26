Function Send-PSMidiMessage {
    Param(
        [Parameter(Mandatory)]
        $Connection,

        [Parameter(Mandatory, ValueFromPipeline)]
        $Message
    )
    
    Send-MidiMessage -Connection $Connection -Words $($Message.Word0, $Message.Word1)
}
