
#cs
TODO:
#1 GUI for selecting the modification
  * Randomize Atributes [OK] (Reset may be needed)
  * Smart Randomization [TODO] of bosses.
  * All enemies Immune/Absorb to Hit/CUT attacks
  * Multiplying enemy factor (2x,3x,4x,5x)(ATK, HP and DEF)(30000 HP max)(DEF maybe needs to be adjusted) (TODO)(Reset all)
  * Multiplying enemy Exp/LV (1.25,1.33,1.5,2)(round) (TODO)
  * Drop Modifier (TODO)

#2 WindowsDialog for selecting the file to be editted.( Can store the last location)
#3 Refactor code to use Dictionary instead of arrays, or make more readible.
#4 Shop Modifier Randomizer.

#ce

; Script Format Demonstration.

; 1. Place required include files.
; 2. Set Autoit options, as needed.
; 3. Declare Variables.
; 4. Set Desired Hot Keys.
; 5. Create the GUI.
; 6. Display the GUI.
; 7. Set/Update control information.
; 8. Set the Tray Menu
; 9. Start the Loop, and "Listen" for a message.
; 10. Create the Functions.

;1 - Required Files.
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <GuiListBox.au3>
#include <SOTN_Randomizer_GUI.au3>

;2 Autoit Opts
Opt("WinDetectHiddenText", 1)
Opt("WinSearchChildren", 1)
Opt("GUICloseOnESC", 1)

;3 Declare Variables 
Global Const $mElementsArray[11] = ["Curse", "Stone", "H2O", "Dark", "Holy", "Ice", "Thunder", "Fire", "Hit", "Cut", "Poison"] ; maybe use a map to iterate
Global $MapSelectedOptions[] ;
Global $MapKeys = ""
;4 Set Desired Hot Keys. // NOT NEEDED

;5 Create the GUI.;6 Display the GUI.7. Set/Update control information.
_Pre_GUI_Init()

;8 Set Tray Menu/ not needed

_SOTN_Tool_Init()
;Sleep(1000)
_EnemyEditor()
;_CloseWindow()

; Runs SOTN_Randomizer_GUI to capture options and fills the map and mapkeys necessary to identify what needs to be changed.
Func _Pre_GUI_Init()
	$MapSelectedOptions = _RandomizerGUILoop()
	If @error Then
		ConsoleWrite("Something went wrong..Exiting app?")
		Exit
	EndIf
	
	$MapKeys = MapKeys($MapSelectedOptions)
	
	; Making sure that the selected options are there.
	For $key In $MapKeys
		ConsoleWrite("Writing map of values: Key: " & $key & " Value : " & $MapSelectedOptions[$key] & @CRLF)
	Next
EndFunc   ;==>_Pre_GUI_Init

; Runs the Tool. Loads the Correct Iso,  Reset if the option is checked.
Func _SOTN_Tool_Init()
	Local $Castlevania_Tool_Window_title = "PSX Castlevania Symphony of The Night USA"
	Local $Castlevania_Editor_Path = $MapSelectedOptions["ToolPath"]    ;
	Local $Castlevania_ISO_Long_Path = $MapSelectedOptions["ISOPath"]    ;
	Run($Castlevania_Editor_Path)
	WinWaitActive($Castlevania_Tool_Window_title)
	Sleep(4000)
	ControlClick("", "", "[NAME:btnPatch]")
	Sleep(1000)
	ControlSetText("", "", "[CLASS:Edit; INSTANCE:1]", $Castlevania_ISO_Long_Path)
	ControlClick("", "", "[CLASS:Button; INSTANCE:1]")
	;_CheckReset()
	Sleep(100)
	ControlClick("", "", "[NAME:tabMain]")
	Send("{RIGHT}")
	
EndFunc   ;==>_SOTN_Tool_Init

Func _CheckReset()
EndFunc   ;==>_CheckReset
	
	
; Lost Function. Clicks on the ListView, Call Home, Creates clean ArrayOfElem, Iterates over 148 enemies; on each iteration call RandomAttributes and store monsterArray with that value, translate the array and click on correct radios (use Focus?)
Func _EnemyEditor()
	;Array of monsters to be used for each monster
	Local $MonsterElemArray[11]
	
	;Get the ListView handle 
	$hMonsterList = ControlGetHandle("","","[NAME:listNames]")
	
	ControlClick("", "", "[NAME:listNames]")
	Send("{HOME}")
	$iMonsterCount = _GUICtrlListBox_GetCount($hMonsterList)
	ConsoleWrite("Numero de Monstros: " & $iMonsterCount & @CRLF)
	
	For $i= 0 To $iMonsterCount -1;10 ;   when ready
		$MonsterElemArray = _RandomAttributes()
		$MonsterTranslatedArray = _TranslateMonsterArray($MonsterElemArray)
		_AssignAttributes($MonsterTranslatedArray)
		ControlClick("","","[NAME:btnPatch]")
		Sleep(100)
		ControlClick("","","[CLASS:Button; INSTANCE:1]")
		ControlFocus("","",$hMonsterList)
		Send("{DOWN}")
				
	Next
	
	
EndFunc   ;==>_EnemyEditor
#cs Randomize the Tolerance Levels of the Attributes.Here are the values:
0 = Normal (1x)
1 = Weak  (2x)
2 = Resilient (0.5x)
3 = Immune (0x)
4 = Absorb (-1x)
#ce Randomize the Tolerance Levels of the Attributes.Here are the values:
Func _RandomAttributes()
	Local $MonsterAttributes[11]
	For $i = 0 To UBound($MonsterAttributes) - 1
		$MonsterAttributes[$i] = Random(0, 4, 1)
	Next
	Return $MonsterAttributes
EndFunc   ;==>_RandomAttributes

; Translates the Array and Clicks on GUI
Func _TranslateMonsterArray($MonsterArray)

	For $elem = 0 To UBound($MonsterArray) - 1
		Select
			Case $MonsterArray[$elem] = 0
				$MonsterArray[$elem] = "N"
			Case $MonsterArray[$elem] = 1
				$MonsterArray[$elem] = "W"
			Case $MonsterArray[$elem] = 2
				$MonsterArray[$elem] = "S"
			Case $MonsterArray[$elem] = 3
				$MonsterArray[$elem] = "I"
			Case $MonsterArray[$elem] = 4
				$MonsterArray[$elem] = "A"
		EndSelect
	Next
	Return $MonsterArray
EndFunc   ;==>_TranslateMonsterArray

; Clicks on GUI to AssignAttributes.
Func _AssignAttributes($Monster)
	For $item = 0 To UBound($Monster) - 1
		ControlClick("", "", "[NAME:rad" & $Monster[$item] & $mElementsArray[$item] & "]")
		ConsoleWrite("[NAME:rad" & $Monster[$item] & $mElementsArray[$item] & "]")
		;Sleep(100)
	Next
	ConsoleWrite(@CRLF)
	;;Experimental code with maps
	; For $vKey in
EndFunc   ;==>_AssignAttributes

; Increases monsters HP, DEF and STR by multiples
Func _IncreaseMonsterStats($iMultiplier)

EndFunc   ;==>_IncreaseMonsterStats

; Finishes the program
Func _CloseWindow()
	WinClose("[CLASS:WindowsForms10.Window.8.app.0.34f5582_r9_ad1]")
EndFunc   ;==>_CloseWindow
