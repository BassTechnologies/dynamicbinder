
/*
< Credits >
	Miroslav Bass
	bassmiroslav@gmail.com

	Last stable version: [1.0] 11.12.2020
		~ Screenshot bug fixed
		~ Banned action to call other hotkeys during active operation
	Script version 7.6.2021: [1.1]
		~ [1.1.1] Added comment localization
		~ [1.1.2] Completed dev comments localization
	Current version: [1.2]
		~ [1.2.1] Added process selector menu (select the required process from the list of tasks)
	
*/

	; Sys.cmd
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
ListLines Off
DetectHiddenText, on
DetectHiddenWindows, on
FileEncoding, UTF-8

#NoEnv
#KeyHistory 0
#SingleInstance force

	; Run as Admin
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))	{
	try	{
		if A_IsCompiled
			Run *RunAs "%A_ScriptFullPath%" /restart
		else
			Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	}
	ExitApp
}

	; Initial elements coords variables 
;~ DropDownList
ddlx := 282
;~ Settings button
sb := 340
;~ Delete button
db := 400
;~ Edit
ee := 142
;~ Text
ts := 20

	; Initial menu window size
winsizew := "460"
winsizeh := "116"

	; Initial hotkeys elem coords
hotkeysizex := "40"
hotkeysizey := "59"

hotkeyscount := 0

hotkeysarray := []
settingsarray := []
deletesarray := []
namesarray := []
countarray := []
textnumber := []
7reserve := [], 8reserve := [], 9reserve := [], 10reserve := [], 11reserve := []

	; Auto load profile func
loading := true

	; Logic variables (don't touch)
advancemode := false
advancemode2 := false
hotkeyinprogress := false

Menu, Tray, Icon, Shell32.dll, 170
Menu, Tray, add, Process Settings, ProcessMenu,
; Menu, Tray, disable, GTA5 Binder
Menu, Tray, add,
Menu, Tray, add, Показать, Show,
Menu, Tray, Default, Показать,
Menu, Tray, add, Скрыть, Hide,
Menu, Tray, add
Menu, Tray, add, Перезапустить, Reload,
Menu, Tray, add, Создать профиль, createprofile
Menu, Tray, disable, Создать профиль
Menu, Tray, add, Выход, GuiClose,
Menu, Tray, NoStandard

GUI:
Gui, -SysMenu
Gui, Add, Button, x385 y2 w25 h16  vmenub2 ghide, --
Gui, Add, Button, x412 y2 w25 h16  vmenub3 gGuiClose, X
Gui, Add, Button, x12 y80 w150 h23 vsaveall gsaveall +Disabled, Применить настройки
Gui, Add, DropDownList, x335 y81 w100 vmove4 gprofile R5, 
Gui, Add, Button, x228 y80 w105 h23 vmove3 gcreateprofile, Создать профиль
Gui, Add, Text, x32 y49 w90 h20 , Клавиша
Gui, Add, Text, x280 y49 w100 h20 , Кол-во строк
Gui, Add, Text, x10 y13 w200 h14 vcurrentprofile, Текущий профиль: 
Gui, Add, Text, x142 y49 w100 h20 , Название хоткея
Gui, Add, Text, x12 y49 w20 h20 , №
Gui, Add, GroupBox, x5 y33 w350 h40 ,
Gui, Add, GroupBox, x365 y33 w70 h40 ,
Gui, Add, Button, x370 y44 w60 h23 gaddhotkey, Добавить
Gui, Show, w%winsizew% h%winsizeh% hide, GTA5RP BINDER R.

	/* Expanding a menu window for future hotkeys 
	(GUI link takes part in the work algorithms and therefore after remove a least hotkey we needed free space, which we create with a crutch) 
	*/
winsizeh += 29
ControlMove, Применить настройки,,(winsizeh-31),,,GTA5RP BINDER R.
	ControlMove, Создать профиль,,(winsizeh-31),,,GTA5RP BINDER R.
		ControlMove, Свернуть,,(winsizeh-31),,,GTA5RP BINDER R.
	ControlMove, ComboBox1,,(winsizeh-30),,,GTA5RP BINDER R.
WinMove, GTA5RP BINDER R.,,,, (winsizew), (winsizeh)

Gui, key:-SysMenu +Disabled +AlwaysOnTop
Gui, key:Add, Text, x65 y7 w350 h40 +Border +Center, `nУдаляем выбранный хоткей. Пожалуйста`, подождите `;)
Gui, key:Show, w484 h58 hide, Выполняем...

Gui, key2:-SysMenu +Disabled +AlwaysOnTop
Gui, key2:Add, Text, x65 y7 w350 h40 +Border +Center, `nЗагружаем выбранный профиль. Пожалуйста`, подождите `;)
Gui, key2:Show, w484 h58 hide, Выполняем...

/*
*/

	; Trying to load saved profile by reading the config file
If (loading)	{
FileReadLine, Prof, %A_WorkingDir%\Res\config.txt, 1
if (RegExMatch(Prof, "\[Load Profile = (.*)\]", profil))	{
	IfNotExist, %A_WorkingDir%\Profiles\%profil1%
	{
		MsgBox, 262160, GTA5RP BINDER R., Файл профиля %profil1% не найден!
		return
	}
	OurProfile := profil1
	loading := false
	gosub, loadprofile
}
}

	;  Update profile's list from folder
update:
SoundBeep, 1000, 100
GuiControl,, move4, | 
Loop, %A_WorkingDir%\Profiles\*profile, , 1
	GuiControl,, move4, %A_LoopFileName%
return

	;  Create profile
createprofile:
Gui, settingsmenu:Destroy
InputBox, NameProfile, GTA5RP BINDER R., Введите название для профиля ниже:,,260,130
if ErrorLevel
    return
if (NameProfile = "")
	return
loop,% hotkeyscount
	if (hotkey%A_Index% = "")
	{
		MsgBox, 262160, GTA5RP BINDER R., Для сохранения профиля необходимо убрать все пустые хоткеи!
		return
	}
if (hotkeyscount = 0)
	return
IfExist, %A_WorkingDir%\Profiles\%NameProfile%.profile
	return
dir := A_WorkingDir "\Profiles"
IfNotExist, % dir
	FileCreateDir, % dir
FileAppend, % "Global count = " hotkeyscount "`n", %A_WorkingDir%\Profiles\%NameProfile%.profile
loop, % hotkeyscount
{
	mainindex := A_Index
	temp = 0

; Now, bold selected hotkey by subtracting algorithm

; Collect the total number of lines for all hotkeys up to the selected (incl.)
	loop, % mainindex
		temp += counthotkeys%A_Index%

; Subtracting the selected hotkey number from the total
	temp -= counthotkeys%mainindex%

; Enter to first string of selected hotkey (each hotkey have a N'count of hotkey strings to reproduce)
	temp += 1
	FileAppend, % "[" hotkey%mainindex% "]`n" "Name = "namehotkeys%mainindex% "`nCount = " counthotkeys%mainindex% "`n", %A_WorkingDir%\Profiles\%NameProfile%.profile
	loop, % counthotkeys%mainindex%
	{
		FileAppend, % "String = " 7reserve[temp] "`nSleep = " 8reserve[temp] "`nEnter = " 9reserve[temp] "`nShift = " 10reserve[temp] "`nScreen = " 11reserve[temp] "`n", %A_WorkingDir%\Profiles\%NameProfile%.profile
			temp++
	}
}
gosub, update
return

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
gosub, GUI
gui 1:show
return

	; Load profile
profile:
gui, submit, nohide
OurProfile := move4
MsgBox, 262180, GTA5RP BINDER R., Загрузить профиль %move4% ?
IfMsgBox, No
	return
IfExist, %A_WorkingDir%\Res\config.txt
	FileDelete, %A_WorkingDir%\Res\config.txt
FileAppend, [Load Profile = %OurProfile%], %A_WorkingDir%\Res\config.txt
;~ MsgBox, 262180, GTA5RP BINDER R., Для корректной загрузки профиля, скрипт перед этим необходимо перезагрузить.`n Если вы ещё не делали перезагрузку, нажмите "Да" для принудительной перезагрузки.
;~ IfMsgBox, Yes
	Reload
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
GuiControl, 1:, currentprofile, Текущий профиль: %OurProfile%
gui, key2:show
loop, % e1
	gosub, addhotkey
Loop, read, %A_WorkingDir%\Profiles\%OurProfile%
{
	Loop, parse, A_LoopReadLine, %A_Tab%
	{
			if (Regexmatch(A_LoopField, "Count = (\d\d?)", c))	{
				t1++
				Control, choose, % c1, % countarray[t1], GTA5RP BINDER R.
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
			if (Regexmatch(A_LoopField, "String = (.*)", s))	{
				t4++
				7reserve.push(s1)
			}
			if (Regexmatch(A_LoopField, "Sleep = (\d\d?\d?\d?\d?)", sl))	{
				t5++
				8reserve.push(sl1)
			}
			if (Regexmatch(A_LoopField, "Enter = (\d)", e))	{
				t6++
				9reserve.push(e1)
			}
			if (Regexmatch(A_LoopField, "Shift = (\d)", sh))	{
				t7++
				10reserve.push(sh1)
			}
			if (Regexmatch(A_LoopField, "Screen = (\d)", sc))	{
				t8++
				11reserve.push(sc1)
			}
	}
}
gui, key2:hide
gosub, saveall
;~ gui, 1:show
return

	; Apply hotkeys
saveall:
if (GetLayout("A") != "En")  ; keyboard layout fix for russian/any another layout
	Send {LAlt Down}{Shift}{LAlt Up}
gui, settingsmenu:submit
gui, submit, nohide
loop, % listofhotkeys.count()
	Hotkey, % listofhotkeys[A_Index], off
loop,% hotkeyscount
	if (hotkey%A_Index% = "")
	{
		MsgBox, 262160, GTA5RP BINDER R., Для применения профиля необходимо убрать все пустые хоткеи! `n`nЕсли вы уже это сделали, нажмите кнопку сохранить в любом из хоткеев!
		return
	}
if (hotkeyscount = 0)	{
	MsgBox Количество хоткеев = 0
	return
}
listofhotkeys := []
loop, % hotkeyscount
{
	Hotkey, % hotkey%A_Index%, sendhotkey, on
	listofhotkeys.push(hotkey%A_Index%)
}
Gui, settingsmenu:Destroy
if (OurProfile = "")
	return
loop,% hotkeyscount
	if (hotkey%A_Index% = "")
		return
if (hotkeyscount = 0)
	return
IfExist, %A_WorkingDir%\Profiles\%OurProfile%
	FileDelete, %A_WorkingDir%\Profiles\%OurProfile%
dir := A_WorkingDir "\Profiles"
IfNotExist, % dir
	FileCreateDir, % dir
FileAppend, % "Global count = " hotkeyscount "`n", %A_WorkingDir%\Profiles\%OurProfile%
loop, % hotkeyscount
{
	mainindex := A_Index
	temp = 0

; Now, bold selected hotkey by subtracting algorithm

; Collect the total number of lines for all hotkeys up to the selected (incl.)
	loop, % mainindex
		temp += counthotkeys%A_Index%

; Subtracting the selected hotkey number from the total
	temp -= counthotkeys%mainindex%

; Enter to first string of selected hotkey (each hotkey have a N'count of hotkey strings to reproduce)
	temp += 1
	FileAppend, % "[" hotkey%mainindex% "]`n" "Name = "namehotkeys%mainindex% "`nCount = " counthotkeys%mainindex% "`n", %A_WorkingDir%\Profiles\%OurProfile%
	loop, % counthotkeys%mainindex%
	{
		FileAppend, % "String = " 7reserve[temp] "`nSleep = " 8reserve[temp] "`nEnter = " 9reserve[temp] "`nShift = " 10reserve[temp] "`nScreen = " 11reserve[temp] "`n", %A_WorkingDir%\Profiles\%OurProfile%
			temp++
	}
}
gosub, update
TrayTip, GTA5RP BINDER R.,  Загрузили профиль!, 1
return

	; Activate hotkey
sendhotkey:
if (hotkeyinprogress)	{
	SoundBeep, 200, 200
	return
}
hotkeyinprogress := true
Loop, % listofhotkeys.count()
	if (A_ThisHotkey = listofhotkeys[A_Index])
	{
		CurrentScreen := A_Index
		temp = 0

; Now, bold selected hotkey by subtracting algorithm

; Collect the total number of lines for all hotkeys up to the selected (incl.)
		loop, % A_Index
			temp += counthotkeys%A_Index%

; Subtracting the selected hotkey number from the total
		temp -= counthotkeys%A_Index%

; Enter to first string of selected hotkey (each hotkey have a N'count of hotkey strings to reproduce)
		temp += 1
		loop, % counthotkeys%A_Index%
		{
		SendMessage, 0x50,, 0x4190419,, A
		If GetKeyState("END", "P")	{
			SoundBeep, 2000, 50
			break
		}
		Sendinput, % "{T}{Text}" 7reserve[temp]
		if (9reserve[temp] = true)
			Sendinput, % "{enter}"
		if (10reserve[temp] = true)	{
			SendMessage, 0x50,, 0x4190419,, A
			SoundBeep, 500, 100
			KeyWait, RShift, D
			KeyWait, RShift
			SoundBeep, 1000, 50
		}
		if (11reserve[temp] = true)	{
			dir := A_WorkingDir "\Screenshots\" namehotkeys%CurrentScreen%
			dir2 := namehotkeys%CurrentScreen%
			IfNotExist, % dir
				fileCreateDir, % dir
			Run, "%A_WorkingDir%\Res\i_view32.exe" /capture=3 /convert=%dir%\_$U(%dir2%`_%OurProfile%`_`%Y-`%m-`%d_`%H`%M`%S).jpg
		}
		sleep % 8reserve[temp]
		temp++
		}
	}
hotkeyinprogress := false
return

	; Hotkey settings
settings:
ControlGetFocus, OutputVar, A
loop, % settingsarray.count()
{
	if (settingsarray[A_Index] = OutputVar)	{
		CurrentButton := A_Index
		break
	}
}
gui, submit, nohide
if (counthotkeys%CurrentButton% = "")	{
	MsgBox, 262192, GTA5RP Binder, Для открытия меню настроек выберите необходимое количество строк для бинда`, если это представляется возможным.
	return
}
winpossettingsy := 30
controlsettingsy := 0
Gui, settingsmenu:Destroy
Gui, settingsmenu:Font, bold,
Gui, settingsmenu:Add, Text, x18 y10 w280 h20 , Бинд (строка с текстом или командой)
Gui, settingsmenu:Add, Text, x520 y10 w120 h20, Задержка (мс)
Gui, settingsmenu:Add, Text, x620 y10 w40 h20 , Enter
Gui, settingsmenu:Add, Text, x670 y10 w40 h20, RShift
Gui, settingsmenu:Add, Text, x720 y10 w40 h20, Screen
Gui, settingsmenu:add, button, x772 y14 w82 h26 gsavehotkey, Сохранить
Gui, settingsmenu:Add, GroupBox, x14 y1 w751 h27 ,
Gui, settingsmenu:Add, GroupBox, x768 y1 w90 h47 ,
Gui, settingsmenu:Font, norm,
loop, % counthotkeys%CurrentButton%
{
	controlsettingsy += 30
	winpossettingsy += 30
	Gui, settingsmenu:Add, Edit, Center x520 y%controlsettingsy% w90 h20 +Number vsleep%CurrentButton%%A_Index%, 0
	Gui, settingsmenu:Add, Edit, x15 y%controlsettingsy% w490 h20 vstring%CurrentButton%%A_Index%,
	Gui, settingsmenu:Add, CheckBox, x630 y%controlsettingsy% w20 h20 venterb%CurrentButton%%A_Index%,
	Gui, settingsmenu:Add, CheckBox, x680 y%controlsettingsy% w20 h20 vshiftb%CurrentButton%%A_Index%,
	Gui, settingsmenu:Add, CheckBox, x730 y%controlsettingsy% w20 h20 vscreen%CurrentButton%%A_Index%,
}
Gui, settingsmenu:Show, center h%winpossettingsy% w870, % "Настройка хоткея " namehotkeys%CurrentButton%
gui, settingsmenu:submit, nohide
loop, % counthotkeys%CurrentButton%
{
	temp = 0
	loop, % CurrentButton
		temp += counthotkeys%A_Index%
	temp -= counthotkeys%CurrentButton%
	temp += A_Index
	GuiControl,settingsmenu:, string%CurrentButton%%A_Index%, % 7reserve[temp]
	GuiControl,settingsmenu:, sleep%CurrentButton%%A_Index%, % 8reserve[temp]
	if (8reserve[temp] = "")
		GuiControl,settingsmenu:, sleep%CurrentButton%%A_Index%, 0
	GuiControl,settingsmenu:, enterb%CurrentButton%%A_Index%, % 9reserve[temp]
	GuiControl,settingsmenu:, shiftb%CurrentButton%%A_Index%, % 10reserve[temp]
	GuiControl,settingsmenu:, screen%CurrentButton%%A_Index%, % 11reserve[temp]
}
return

	; Save hotkey
savehotkey:
gui, settingsmenu:submit, nohide
MsgBox, 262196, GTA5RP Binder, После сохранения параметров`, текущий хоткей и хоткеи до него потеряют свойства к расширению количества отправляемых строк!`n`nРедактировать их можно будет!`n`nСохранить?
IfMsgBox, No
	return

; When hotkey settings saving, disable the ability to change the number of lines in the future
GuiControl, 1:Disable, counthotkeys%CurrentButton%
loop, % CurrentButton
{
	temp := CurrentButton - A_Index
	GuiControl, 1:Disable, counthotkeys%temp%
}
;~ See. below ***
does := true

; Process all hotkey Lines
loop, % counthotkeys%CurrentButton%
{
temp = 0

; Now, bold selected hotkey by subtracting algorithm

; Collect the total number of lines for all hotkeys up to the selected (incl.)
	loop, % CurrentButton
		temp += counthotkeys%A_Index%

; Subtracting the selected hotkey number from the total
	temp -= counthotkeys%CurrentButton%

; Enter to first string of selected hotkey (each hotkey have a N'count of hotkey strings to reproduce)
	temp += A_Index
	
	; When we save hotkey changes, first of all remove last options.
	;~ ***
	if (does)	{
		7reserve.RemoveAt(temp, counthotkeys%CurrentButton%)
		8reserve.RemoveAt(temp, counthotkeys%CurrentButton%)
		9reserve.RemoveAt(temp, counthotkeys%CurrentButton%)
		10reserve.RemoveAt(temp, counthotkeys%CurrentButton%)
		11reserve.RemoveAt(temp, counthotkeys%CurrentButton%)
		does := false
	}	
	7reserve.InsertAt(temp, string%CurrentButton%%A_Index%) ; => ["A", "B"]
	8reserve.InsertAt(temp, sleep%CurrentButton%%A_Index%) ; => ["A", "B"]
	9reserve.InsertAt(temp, enterb%CurrentButton%%A_Index%) ; => ["A", "B"]
	10reserve.InsertAt(temp, shiftb%CurrentButton%%A_Index%) ; => ["A", "B"]
	11reserve.InsertAt(temp, screen%CurrentButton%%A_Index%) ; => ["A", "B"]
}
guicontrol, 1:Enable, saveall
gui, settingsmenu:destroy
; Arrays for saving values from win controls variables
return

	; Remove hotkey
delete:
advancemode2 := false
ControlGetFocus, OutputVar, GTA5RP BINDER R.
loop, % deletesarray.count()
{
	if (deletesarray[A_Index] = OutputVar)	{
		CurrentButton := A_Index
		break
	}
}
MsgBox, 262196, GTA5RP BINDER R., Вы действительно хотите удалить хоткей № %CurrentButton% ?
IfMsgBox, No
	return
; Arrays for saving values from win controls variables
1reserve := [], 2reserve := [], 3reserve := [], 4reserve := [], 5reserve := [], 6reserve := []
gui, submit, nohide
loop, % hotkeysarray.count()
{
	if (A_Index = CurrentButton)
		continue
	1reserve.push(deletesarray%A_Index%)
		2reserve.push(settingsarray%A_Index%)
			3reserve.push(namehotkeys%A_Index%)
			4reserve.push(counthotkeys%A_Index%)
		5reserve.push(hotkey%A_Index%)
	6reserve.push(textnumber%A_Index%)
}

	; Restore initial script params
winsizew := "460"
winsizeh := "116"
hotkeysizex := "40"
hotkeysizey := "59"
ddlx := 282
sb := 340
db := 400
ee := 142
ts := 20
gui, destroy
Gui, settingsmenu:Destroy

temp = 0
; Now, bold selected hotkey by subtracting algorithm

; Collect the total number of lines for all hotkeys up to the selected (incl.)
loop, % CurrentButton
	temp += counthotkeys%A_Index%

; Subtracting the selected hotkey number from the total
temp -= counthotkeys%CurrentButton%

; Enter to first string of selected hotkey (each hotkey have a N'count of hotkey strings to reproduce)
temp += 1
7reserve.RemoveAt(temp, counthotkeys%CurrentButton%)
8reserve.RemoveAt(temp, counthotkeys%CurrentButton%)
9reserve.RemoveAt(temp, counthotkeys%CurrentButton%)
10reserve.RemoveAt(temp, counthotkeys%CurrentButton%)
11reserve.RemoveAt(temp, counthotkeys%CurrentButton%)

;~ [ IF - Если всего 1 хоткей и его нужно удалить, ELSE - Если хоткеев больше одного ]
; IF hotkeys count == 1, remove, ELSE - hotkeys count > 1
if (deletesarray.count() = 1)	{
	deletesarray.RemoveAt(CurrentButton, 1)
		settingsarray.RemoveAt(CurrentButton, 1)
			namesarray.RemoveAt(CurrentButton, 1)
				countarray.RemoveAt(CurrentButton, 1)
			hotkeysarray.RemoveAt(CurrentButton, 1)
		textnumber.RemoveAt(CurrentButton, 1)
	hotkeyscount--
	gosub, GUI
}	else	{
		hotkeysarray := [], settingsarray := [], deletesarray := [], namesarray := [], countarray := [], textnumber := []
		temp1 :=hotkeyscount-1
		hotkeyscount := 0
		gosub, GUI
		Gui, key:Show
		;~ Gui, Show
		;~ MsgBox Количество %temp1%
		loop, % temp1
		{
			if (hotkeyscount >= 10)	{
				;~ MsgBox % hotkeyscount " " hotkeyscount
				if !(advancemode2)	{
				hotkeysizex := "473"
				hotkeysizey := "59"
				ddlx = 714
				sb = 775
				db = 835
				ee = 572
				ts = 450
				winsizew = 910
				;~ SoundBeep, 3000, 10
				advancemode2 := true
				;~ MsgBox 11
				}
			}
			else if (hotkeyscount <= 9)	{
				;~ MsgBox % hotkeyscount
	if !(advancemode2)
	{
	ddlx := 282
	sb := 340
	db := 400
	ee := 142
	ts := 20
	winsizew := "460"
	winsizeh := "176"
	hotkeysizex := "40"
	hotkeysizey := "59"
	advancemode2 := true
	}
					;~ winsizeh += 29
			;~ MsgBox plus
}
			;~ if (hotkeyscount = 8)	{
				;~ winsizeh += 52
			;~ MsgBox plus
			;~ }
			gosub, addhotkey
		}
	}
	
	;~ !!!
	;~ По сути, можно вообще убрать условие if (deletesarray.count() = 1), так как даже без него всё будет работать. Но вдруг нам нужно будет сделать конкретно с первым слотом что-либо.
	;~ !!!

; Blocking already created hotkeys
loop, % hotkeyscount
	GuiControl, 1:Disable, counthotkeys%A_Index%
	
; Removed required hotkey and  
GuiControl, 1:, currentprofile, Текущий профиль: %OurProfile%
gui, show
Gui, key:hide
return
;~ //////////////////////////////////////////////////////////////////

hotkeylabel:
gui, submit, nohide
guicontrol, Disable, saveall
return

	; Add hotkey
addhotkey:
gui, submit, nohide
guicontrol, enable, saveall

; Max 10 hotkeys on one page
if (hotkeyscount > 9)	{
	if !(advancemode)
	{
		hotkeysizex := "473"
		hotkeysizey := "59"
		ddlx = 714
		sb = 775
		db = 835
		ee = 572
		ts = 450
		winsizew = 910
		winsizeh := "410"
		advancemode := true
	ControlMove, U, 808,,,,GTA5RP BINDER R.
	ControlMove, --, 835,,,,GTA5RP BINDER R.
	ControlMove, X, 862,,,,GTA5RP BINDER R.
	ControlMove, Текущий профиль: , 330,,,,GTA5RP BINDER R.
	ControlMove, <a href="https://www.blast.hk/members/131470/">@bass_devware</a> , 370,,,,GTA5RP BINDER R.
		;~ MsgBox 1
	}
}	
if (hotkeyscount >= 20)	{
	SoundBeep, 1000, 100
	SoundBeep, 1000, 100
	return
}
if (hotkeyscount < 9)	{
	if (advancemode)
	{
	ddlx := 282
	sb := 340
	db := 400
	ee := 142
	ts := 20
	winsizew := "460"
	winsizeh := "176"
	hotkeysizex := "40"
	hotkeysizey := "59"
	advancemode := false
	ControlMove, U, 358,,,,GTA5RP BINDER R.
	ControlMove, --, 385,,,,GTA5RP BINDER R.
	ControlMove, X, 412,,,,GTA5RP BINDER R.
	ControlMove, Текущий профиль: , 130,,,,GTA5RP BINDER R.
	ControlMove, <a href="https://www.blast.hk/members/131470/">@bass_devware</a> , 130,,,,GTA5RP BINDER R.
	;~ MsgBox 2
	}
}
;~ MsgBox Z%hotkeyscount%Z
if (hotkeyscount = "0")	{
	ddlx := 282
	sb := 340
	db := 400
	ee := 142
	ts := 20
	winsizew := "460"
	winsizeh := "176"
	hotkeysizex := "40"
	hotkeysizey := "59"
	;~ MsgBox % hotkeyscount
}
ControlMove, Применить настройки,,(winsizeh-31),,,GTA5RP BINDER R.
	ControlMove, Создать профиль,,(winsizeh-31),,,GTA5RP BINDER R.
	ControlMove, ComboBox1,,(winsizeh-30),,,GTA5RP BINDER R.
WinMove, GTA5RP BINDER R.,,,, (winsizew), (winsizeh)

if !(advancemode)
{
	;~ MsgBox plus
	winsizeh += 26
}
hotkeyscount++
hotkeysizey += 26
temp1 := hotkeysizey+3

	; Creating elements with variables params
Gui, Add, Hotkey, x%hotkeysizex% y%hotkeysizey% w90 h20 vhotkey%hotkeyscount% ghotkeylabel, % alphabet[hotkeyscount]
Gui, Add, Text, x%ts% y%temp1% w19 h20 vnumb%hotkeyscount%, #%hotkeyscount%
Gui, Add, Edit, x%ee% y%hotkeysizey% w120 h20 vnamehotkeys%hotkeyscount%, Name%hotkeyscount%
Gui, Add, DropDownList, x%ddlx% y%hotkeysizey% w50 h20 Choose1 R5 vcounthotkeys%hotkeyscount%, Count%hotkeyscount%
Gui, Add, Button, x%sb% y%hotkeysizey% w61 h23 gsettings, S%hotkeyscount%
Gui, Add, Button, x%db% y%hotkeysizey% w50 h23 gdelete, D%hotkeyscount%

	; Define elements system
WinGet, controlz, ControlList, GTA5RP BINDER R.
Loop, parse, controlz, `n,
{
	gui, submit, nohide
	ControlGetText, temp2, %A_LoopField%, GTA5RP BINDER R.

	; Define settings button
	if (temp2 = "S" . hotkeyscount)
		settingsarray.push(A_LoopField)
	; Define remove button
	if (temp2 = "D" . hotkeyscount)
		deletesarray.push(A_LoopField)
	
; Define selected hotkey. ControlGetText doesnt see hotkey control text, then here is a crutch
	gui, submit, nohide
	if (hotkeysarray.count() <= 0)
		if (RegExMatch(A_LoopField, "msctls_hotkey(\d\d\d\d?)", num))
			hotkeysarray.push(string := "msctls_hotkey" . num1)
	
	finded := false
	if (RegExMatch(A_LoopField, "msctls_hotkey(\d\d\d\d?)", num))	{
		loop, % hotkeysarray.count()
		{
			
			if (hotkeysarray[A_Index] = "msctls_hotkey" . num1)
				finded := true
			if (A_Index = hotkeysarray.count())
				if (finded != true)
					hotkeysarray.push(string := "msctls_hotkey" . num1)
		}
	}
	
	; Define hotkey name
	if (temp2 = "Name" . hotkeyscount)
		namesarray.push(A_LoopField)
	; Define hotkey strings count
	if (temp2 = "Count" . hotkeyscount)
		countarray.push(A_LoopField)
	;~ Indicate numbering by gui, text
	if (temp2 = "#" . hotkeyscount)
		textnumber.push(A_LoopField)
}

; IF - restore hotkeys data from variables when we remove one of each hotkeys, ELSE - enter initial data
if  (5reserve[hotkeyscount] != "")	{
	GuiControl,, % namesarray[hotkeyscount], % 3reserve[hotkeyscount]
		GuiControl,, % settingsarray[hotkeyscount], Настройки
			GuiControl,, % deletesarray[hotkeyscount], Удалить
				Control, Delete, 1, % countarray[hotkeyscount], GTA5RP BINDER R.
			GuiControl,, % countarray[hotkeyscount], 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30
		Control, choose, % 4reserve[hotkeyscount], % countarray[hotkeyscount], GTA5RP BINDER R.
	GuiControl,, % hotkeysarray[hotkeyscount], % 5reserve[hotkeyscount]
}	else	{ 
		GuiControl,, % namesarray[hotkeyscount], HotName
			GuiControl,, % settingsarray[hotkeyscount], Настройки
				GuiControl,, % deletesarray[hotkeyscount], Удалить
				Control, Delete, 1, % countarray[hotkeyscount], GTA5RP BINDER R.
			GuiControl,, % countarray[hotkeyscount], 1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30
		Control, choose,1,% countarray[hotkeyscount]
	}
return

ChooseProcess:
Gui, process:Submit, NoHide
WTSEnumProcesses(), LV_Delete(), count := 0
loop % arrLIST.MaxIndex()
{
    if (InStr(arrLIST[A_Index, "Process"], search))
        LV_Add("", arrLIST[A_Index, "Process"]), count++
}
return

List:
gui, process:submit, nohide
if (A_GuiEvent = "DoubleClick")
{
    LV_GetText(Procname, A_EventInfo)  ; Get the text from the row's field.
    GuiControl,process:, Choose, Choose: %Procname%
	WinGet, ProcWinID, ID, ahk_exe %Procname%
    GuiControl, process:Enable, Choose
}
Return

ConfirmProcess:
gui, process:destroy
GroupAdd, ProcessWinIDGroup, ahk_id %ProcWinID%
#IfWinActive ahk_group ProcessWinIDGroup
return

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

!PrintScreen::
dir := A_WorkingDir "\Screenshots\KeyPressed\"
Run, "%A_WorkingDir%\Res\i_view32.exe" /capture=3 /convert=%dir%_$U(%OurProfile%`_`%Y-`%m-`%d_`%H`%M`%S).jpg
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

Show:
Gui, Show
return

Hide:
Gui, Hide
return

GuiClose:
ExitApp
return

Reload:
Reload
return