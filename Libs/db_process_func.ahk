/*

*/

; // Choose process
List:
gui, process:submit, nohide
if (A_GuiEvent = "DoubleClick")	{
    LV_GetText(Procname, A_EventInfo)  ; Get the text from the row's field.
    GuiControl,process:, Choose, Choose: %Procname%
	WinGet, ProcWinID, ID, ahk_exe %Procname%
    GuiControl, process:Enable, Choose
}
Return

; Find btn
ChooseProcess:
Gui, process:Submit, NoHide
WTSEnumProcesses(), LV_Delete(), count := 0
loop % arrLIST.MaxIndex()
{
    if (InStr(arrLIST[A_Index, "Process"], search))
        LV_Add("", arrLIST[A_Index, "Process"]), count++
}
return

; Choose btn
ConfirmProcess:
gui, process:destroy
GroupAdd, ProcessWinIDGroup, ahk_id %ProcWinID%
#IfWinActive ahk_group ProcessWinIDGroup
return

ProcessMenu:
Gui, process:Margin, 5, 5
Gui, process:Add, Edit, xm ym w100 hWndhSearch vsearch
DllCall("user32.dll\SendMessage", "Ptr", hSearch, "UInt", 0x1501, "Ptr", 1, "Str", "Process Name Here", "Ptr")
Gui, process:Add, ListView, xm y+5 w160 h90 gList, Name
Gui, process:Add, Button, xm+100 ym-1 w60 gChooseProcess, Find
Gui, process:Add, Button, xm ym+117 w160 disabled vChoose gConfirmProcess, Choose
Gui, process:Show, AutoSize, The script should work in...
return