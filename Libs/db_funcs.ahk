/*

*/

; Define system language. It is necessary for the correct saving of the configuration.
GetLayout(ID)
{
   hWnd := ID = "A" ? WinExist("A") : ID
   ThreadID := DllCall("GetWindowThreadProcessId", UInt, hWnd, UInt, 0)
   InputLocaleID := DllCall("GetKeyboardLayout", UInt, ThreadID, UInt)
   Return InputLocaleID = 0x4090409 ? "En" : "Ru"
}

WTSEnumProcesses()	{
    local tPtr := 0, pPtr := 0, nTTL := 0, LIST := ""
    if !(DllCall("Wtsapi32\WTSEnumerateProcesses", "Ptr", 0, "Int", 0, "Int", 1, "PtrP", pPtr, "PtrP", nTTL))
        return "", DllCall("SetLastError", "Int", -1)
    tPtr := pPtr
    arrLIST := []
    loop % (nTTL)	{
        arrLIST[A_Index, "Process"] := StrGet(NumGet(tPtr + 8))    ; Process
        tPtr += (A_PtrSize = 4 ? 16 : 24)                          ; sizeof(WTS_PROCESS_INFO)
    }

    DllCall("Wtsapi32\WTSFreeMemory", "Ptr", pPtr)
    return arrLIST, DllCall("SetLastError", "UInt", nTTL)
}