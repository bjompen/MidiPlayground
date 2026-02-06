
$keybdSource = @"

public class kbd
{
    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT { 
            public int type; // 0 = INPUT_MOUSE
                            // 1 = INPUT_KEYBOARD
                            // 2 = INPUT_HARDWARE
            public KEYBDINPUT ki;
        }

    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT {
        public int      wVk;
        public int      wScan;
        public int       dwFlags;
        public int       time;
        public ulong       dwExtraInfo;
    }

    [System.Runtime.InteropServices.DllImport("user32.dll", SetLastError = true)]
    public static extern uint SendInput(int cInputs, INPUT[] pInputs, int cbSize);

    // public static void SendKeyStroke(int wVk, int wScan, int dwFlags) 
    public static void SendKeyStroke() 
    {
        INPUT[] input = new INPUT[4];

        input[0].type = 1;
        input[0].ki.wVk = 91;
    
        input[1].type = 1;
        input[1].ki.wVk = 68;

        input[2].type = 1;
        input[2].ki.wVk = 68;
        input[2].ki.dwFlags = 2;

        input[3].type = 1;
        input[3].ki.wVk = 91;
        input[3].ki.dwFlags = 2;

        uint uSent = SendInput(input.Length, input, System.Runtime.InteropServices.Marshal.SizeOf(input[0]));

        if (uSent != input.Length)
        {
            System.Console.Write($"SendInput failed - uSent: {uSent}");
            System.Console.Write("SendInput failed: ");
            System.Console.WriteLine(System.Runtime.InteropServices.Marshal.GetLastWin32Error());
        } 
    }
}
"@

<#
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-sendinput
https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-keybdinput
https://pinvoke.net/default.aspx/user32.SendInput
https://stackoverflow.com/questions/39353073/how-i-can-send-mouse-click-in-powershell

#>

Add-Type -TypeDefinition $keybdSource

[kbd]::sendKeyStroke()
