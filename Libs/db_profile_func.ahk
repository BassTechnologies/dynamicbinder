/*

*/

profile:
gui, submit, nohide
OurProfile := move4
MsgBox, 262180, Dynamic Binder, Load Profile %move4% ?
IfMsgBox, No
	return
IfExist, %A_WorkingDir%\Res\config.txt
	FileDelete, %A_WorkingDir%\Res\config.txt
FileAppend, [Load Profile = %OurProfile%], %A_WorkingDir%\Res\config.txt
	Reload

; CD#5 | Local here: t1, t2, t3, c1, n1, h1, s1, sl1, e1, sh1, sc1
; Load profile
loadprofile:
FileReadLine, var, %A_WorkingDir%\Profiles\%OurProfile%, 1
RegExMatch(var, "Global count = (\d\d?)", e)
Gui, 1:destroy
Gui, settingsmenu:Destroy

winsizew := "460"
winsizeh := "146"
hotkeysizex := "40"
hotkeysizey := "59"
winpossettingsy := 30
controlsettingsy := 0
gosub, GUI

GuiControl, 1:, currentprofile, Actual Profile: %OurProfile%
gui, key2:show
loop, % e1
	gosub, addhotkey
Loop, read, %A_WorkingDir%\Profiles\%OurProfile%
{
	Loop, parse, A_LoopReadLine, %A_Tab%
	{
		if (Regexmatch(A_LoopField, "Count = (\d\d?)", c))	{
			t1++
			Control, choose, % c1, % countarray[t1], Dynamic Binder
			GuiControl, 1:disable, % countarray[t1]
		}
		if (Regexmatch(A_LoopField, "Name = (.*)", n))	{
			t2++
			GuiControl, 1:, % namesarray[t2], % n1
		}
		if (Regexmatch(A_LoopField, "\[(.*)\]", h))	{
			t3++
			GuiControl, 1:, % hotkeysarray[t3], % h1
		}
		if (Regexmatch(A_LoopField, "String = (.*)", s))
			7reserve.push(s1)
		if (Regexmatch(A_LoopField, "Sleep = (\d\d?\d?\d?\d?)", sl))
			8reserve.push(sl1)
		if (Regexmatch(A_LoopField, "Enter = (\d)", e))
			9reserve.push(e1)
		if (Regexmatch(A_LoopField, "Shift = (\d)", sh))
			10reserve.push(sh1)
		if (Regexmatch(A_LoopField, "Screen = (\d)", sc))
			11reserve.push(sc1)
	}
}
gui, key2:hide
gosub, saveall ; Apply hotkeys
return

; CD#3 | Local here: NameProfile
;  Create profile
createprofile:
Gui, settingsmenu:Destroy
InputBox, NameProfile, Dynamic Binder, Enter Profile Name Below:,,260,130

if ErrorLevel
    return
if (NameProfile = "")
	return
loop, % hotkeyscount
	if (hotkey%A_Index% = "")	{
		MsgBox, 262160, Dynamic Binder, Delete all blank hotkeys!
		return
	}
if (hotkeyscount = 0)
	return

IfExist, %A_WorkingDir%\Profiles\%NameProfile%.profile
	return
IfNotExist, % A_WorkingDir "\Profiles"
	FileCreateDir, % A_WorkingDir "\Profiles"
FileAppend, % "Global count = " hotkeyscount "`n", %A_WorkingDir%\Profiles\%NameProfile%.profile
loop, % hotkeyscount
{
	mainindex := A_Index
	temp := 0

    ; Now, bold selected hotkey by subtracting algorithm
    ; Collect the total number of lines for all hotkeys up to the selected (incl.)
	loop, % mainindex
		temp += counthotkeys%A_Index%

    ; Subtracting the selected hotkey number from the total
	temp -= counthotkeys%mainindex%

    ; Enter to first string of selected hotkey (each hotkey have a N'count of hotkey strings to reproduce)
	temp++
	FileAppend, % "[" hotkey%mainindex% "]`n" "Name = "namehotkeys%mainindex% "`nCount = " counthotkeys%mainindex% "`n", %A_WorkingDir%\Profiles\%NameProfile%.profile
	loop, % counthotkeys%mainindex%
	{
		FileAppend, % "String = " 7reserve[temp] "`nSleep = " 8reserve[temp] "`nEnter = " 9reserve[temp] "`nShift = " 10reserve[temp] "`nScreen = " 11reserve[temp] "`n", %A_WorkingDir%\Profiles\%NameProfile%.profile
		temp++
	}
}
gosub, update ;  Update profile's list from folder
return

; CD#4
; Remove profile
deleteprofile:
FileDelete, %A_WorkingDir%\Res\config.txt
Gui, 1:destroy
Gui, settingsmenu:Destroy

winsizew := "460"
winsizeh := "116"
hotkeysizex := "40"
hotkeysizey := "59"
winpossettingsy := 30
controlsettingsy := 0
hotkeyscount := 0
hotkeysarray := []
settingsarray := []
deletesarray := []
namesarray := []
countarray := []
textnumber := []
7reserve := [], 8reserve := [], 9reserve := [], 10reserve := [], 11reserve := []

gosub, GUI ; Update GUI menu
gui 1:show
return