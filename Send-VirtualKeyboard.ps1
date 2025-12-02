function Send-VirtualKeyboard
{
    [cmdletbinding(DefaultParameterSetName='action')]
    [Alias('vkey')]
    [OutputType([void])]
    Param
    (
        # Specifies a key to send to console.
        [Parameter(Mandatory = $true,
                   parametersetname = 'key',
                   Position = 0)]
        [byte]$key,

        # Specifies a preset action to perform.
        [Parameter(Mandatory = $true,
                   parametersetname = 'action',
                   Position = 0)]
                   [ValidateSet('Play/Pause','Stop','Next','prev','VolUp','VolDown','VolMute','StartMP','StartApp1','StartApp2','PrtScn','NumLock','ScrollLock','CapsLock')]
        [String]$action
    )

    Begin
    {
        [byte]$KeyUpEvent   = 0x0002
        [byte]$KeyDownEvent = 0x0001
        
        [byte]$Play         = 0xB3
        [byte]$Stop         = 0xB2
        [byte]$Next         = 0xB0
        [byte]$prev         = 0xB1
        [byte]$VolUp        = 0xAF
        [byte]$VolDown      = 0xAE
        [byte]$VolMute      = 0xAD
        [byte]$StartMP      = 0xB5
        
        [byte]$StartApp1    = 0xB6
        [byte]$StartApp2    = 0xB7
        [byte]$PrtScn       = 0x2C
        [byte]$NumLock      = 0x90
        [byte]$ScrollLock   = 0x91
        [byte]$CapsLock     = 0x14

        $keybd = @'
            [DllImport("user32.dll")]
            public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
'@
            Try
            { 
                IF (! ('KeybdEvent.Win32Utils' -as [type]) )
                { 
                    $type = Add-Type -MemberDefinition $keybd -Name Win32Utils -Namespace KeybdEvent -PassThru 
                }
                ELSE
                {
                    $type = 'KeybdEvent.win32utils' -as [Type]
                }
            }
            catch
            {
                Write-Error 'Failed to pInvoke user32.dll'
                $_.Exception.message
                break
            }
    }
    Process
    {
        Switch ($PSCmdlet.ParameterSetName)
        {
            'action' 
            {
                Switch ($action)
                {
                    'Play/Pause' { $KeyPressed = $Play        }
                    'Stop'       { $KeyPressed = $Stop        }
                    'Next'       { $KeyPressed = $Next        }
                    'prev'       { $KeyPressed = $prev        }
                    'VolUp'      { $KeyPressed = $VolUp       }
                    'VolDown'    { $KeyPressed = $VolDown     }
                    'VolMute'    { $KeyPressed = $VolMute     }
                    'StartMP'    { $KeyPressed = $StartMP     }
                    'StartApp1'  { $KeyPressed = $StartApp1   }
                    'StartApp2'  { $KeyPressed = $StartApp2   }
                    'PrtScn'     { $KeyPressed = $PrtScn      }
                    'NumLock'    { $KeyPressed = $NumLock     }
                    'ScrollLock' { $KeyPressed = $ScrollLock  }
                    'CapsLock'   { $KeyPressed = $CapsLock    }
                }                                
            }

            'key' {
                $KeyPressed = [byte]$key
            }
        
        }

        $type::keybd_event($KeyPressed,0,$KeyDownEvent,[System.UIntPtr]::Zero)
        $type::keybd_event($KeyPressed,0,$KeyUpEvent,[System.UIntPtr]::Zero)
    }
    End
    {
    }
}