
$keybdSource = @"

public class kbd
{
    public struct INPUT { 
            public int type; // 0 = INPUT_MOUSE
                            // 1 = INPUT_KEYBOARD
                            // 2 = INPUT_HARDWARE
            public KEYBDINPUT ki;
        }

    public struct KEYBDINPUT {
        public int      wVk;
        public int      wScan;
        public int       dwFlags;
        public int       time;
        public ulong       dwExtraInfo;
    }

    [System.Runtime.InteropServices.DllImport("user32.dll")]
    public static extern uint SendInput(int cInputs, INPUT[] pInputs, int cbSize);

}
"@

<#
https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-sendinput
https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-keybdinput
https://pinvoke.net/default.aspx/user32.SendInput
https://stackoverflow.com/questions/39353073/how-i-can-send-mouse-click-in-powershell

#>

<#
Det här, fast för keyboard

    public static void LeftClickAtPoint(int x, int y)
    {
        // Move the mouse
        INPUT[] input = new INPUT[3];

        input[0].mi.dx = x * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
        input[0].mi.dy = y * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
        input[0].mi.dwFlags = MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE;

        // Left mouse button down
        input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;

        // Left mouse button up
        input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;

        SendInput(3, input, Marshal.SizeOf(input[0]));
    }
#>

Add-Type -TypeDefinition $keybdSource

[kbd]::doThing()