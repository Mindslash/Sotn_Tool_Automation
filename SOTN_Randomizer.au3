#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=randomizer_ico_m8p_icon.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs
TODO:
	#1 Randomization Options.
	* Safe Randomize for bosses ( maintains original values for bosses, Chaotic for all other enemies.) [OK]
	* Enhanced Attribute Randomization of bosses. Elements are rerolled for bosses but no immunities /absorb[OK]
	* Chaotic Randomization. Currently , affects all enemies , except bosses when options are selected. [OK]
	* For Future: Redesign GUI, changing Randomization Radios options to 2 only options: Simple Randomization and Cherry Picked Randomization.
	* For Future: Include a Checkbox under Randomization Radios to "Include Bosses". Not selecting this option will not change the bosses.
	* For Future: Cherry Picked Randomization is intended to substitute "Enhanced Randomization" by providing difficulty levels based on ammount of Vulnerable Elements.
	* For Future: Maybe a mode making all enemies immune to Hit / Cut Attacks.
	* Reading examples from DSVania and AOSVania, I've saw examples of weakness and strenghts randomizations. This got me some ideas:
		- Store Original Vulnerabilities (None, Weak, Strong) and Invulnerabilities ( Imune, Absorb) and randomize them ( for example, enemy is vulnerable to 2 elements and invulnerable to other 2, just randomize it.
		- Adding Difficulty Levels. This can be done by three ways:
			1. By Increasing Monster tolerance level by 1 for each difficulty: (diablo mode)
				1.1 Starter - Raise original tolerance levels by 1 (No weak monsters anymore. Minimum level is "Not affected, or None")
				1.2 Veteran - Raise original tolerance levels by 2 (No weak/Unnafected monsters anymore. Minimum level is Strong) ( things to considerate: some monsters does not have weakness to be exploited. At this point, all monsters that are Unnafected becomes Imunn)
			2. By Adding Vulnerabilities and Invulnerabilities based on dif level without considering original values
				2.1 Easy : Randomize for 3 Weak, 3 Unnafected, 3 Strong, 1 Immune , 1 Absorb)
				2.2 Normal: Randomize for 2 Weak , 2 Unnafected, 3 Strong, 2 Immune , 2 Absorb)
				2.3 Hard : Randomize for 1 Weak, 1 Unnafected, 3 Strong, 3 Immune, 3 Absorb)
				2.4 Hell : Randomize for 0 Weak , 0 Unnafected, 1 Strong 4 Immune , 4 Absorb) ( prevent Strong = Water)
			3. By Adding extra Vulnerabilities, keeping the originals and changing the "none" values . Make use of the Unnafected slots to do the distribution (aos dos mode)
				3.1 Level 1 : Takes 2 None Level and adds 1 vulnerable and 1 invulnerable
				3.2 Level 2 : takes 4 None Level and adds 2 vulnerable and 2 invulnerable
				3.3 Level 3 : Takes 6 None Level and adds 3 vulnerable and 3 invulnerable
				3.4 Level 4:  Takes 8 none Levels and adds 4 vulenrable and 4 invulnerable
			4. Making enemies Immune to Either Hit or Cut, bot not both




	#2 Multiply Options
		* Multiplying enemy factor (2x,3x,4x,5x)(ATK, HP and DEF) [OK]
		* Multiplying enemy Exp/LV (1.25,1.33,1.5,2)(round) [OK]

	#3 Reset Option. [REMOVED]
		* For Future. Not sure If I want to reset the ISO everytime its run or take advantage of current settings. It may increases the complexity a bit.

	#4 Refactor code. 
		* Better New  Element Selected Display
		* Improve GUI Code to return only one value for radioGroups and update main code here.
		* Refactor variable names and functions
		* Study changes for adding/removing global and local variables
		* Maybe using ENUMS or preventing the use of Maps, so the beta wont be needed... also cleaning the code to be shorter and more readable.

	#5 Shop Modifier Randomizer. Not sure if I want to do this. Current shop is good, but Firebrand, IceBrand and ThunderBrand must display on Shop. Maybe include Stone and Poison Sword.

BUGS:
* if no selected option on main menu of the tool, the changes to elements are not patched. I will be selecting richter custom sub circle
* Due to locale, float numbers were incorrectly filling states. Fixed by using Rounding
* Wrong Switch usage at attribute multiplier, causing to second multiplier always be active
* _checkMultiplyOptions() was incorrectly comparing  ComboAttrb1 twice, making Exp/LVL only modifications to not work.

CHANGES:
* Implemented a method to retrieve current elements instead of just randomizing and assigning the radiobuttons. With this, is possible to do future implementations of randomization.
* Improved Console Writting for logging purporses
* Added Comments on all functions to make it easier to understand.
#ce

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
Global Const $BossesList[32] = [0, 1, 18, 21, 34, 37, 59, 66, 74, 75, 80, 87, 90, 92, 93, 94, 99, 111, 128, 130, 131, 132, 133, 134, 136, 137, 141, 143, 145, 146, 147, 148]
Global $MapSelectedOptions[] ;
Global $MapKeys = ""
Global $bRandElems = False
Global $bMultiFactor = False

;4 Set Desired Hot Keys. // NOT NEEDED

;5 Create the GUI.;6 Display the GUI.7. Set/Update control information.
_Pre_GUI_Init()
_SOTN_Tool_Init()
_EnemyEditor()
_CloseWindow()

; Runs SOTN_Randomizer_GUI to capture options and fills the map and mapkeys necessary to identify what needs to be changed.
Func _Pre_GUI_Init()
	$MapSelectedOptions = _RandomizerGUILoop()
	If @error Then
		ConsoleWrite("Something went wrong..Exiting app")
		Exit
	EndIf
	$MapKeys = MapKeys($MapSelectedOptions)

	; Making sure that the selected options are there.
	For $key In $MapKeys
		ConsoleWrite("Writing map of values: Key: " & $key & " Value : " & $MapSelectedOptions[$key] & @CRLF)
	Next
EndFunc   ;==>_Pre_GUI_Init

; Runs the Tool. Loads the Correct Iso. Send the user to Enemy Tab
Func _SOTN_Tool_Init()
	Local $Castlevania_Tool_Window_title = "PSX Castlevania Symphony of The Night USA"
	Local $Castlevania_Editor_Path = $MapSelectedOptions["ToolPath"]    
	Local $Castlevania_ISO_Long_Path = $MapSelectedOptions["ISOPath"]    
	Run($Castlevania_Editor_Path)
	WinWaitActive($Castlevania_Tool_Window_title)
	Sleep(3000)
	;ControlClick("", "", "[NAME:btnMusic]") 
	ControlClick("", "", "[NAME:btnPatch]")
	Sleep(1000)
	ControlSetText("", "", "[CLASS:Edit; INSTANCE:1]", $Castlevania_ISO_Long_Path)
	ControlClick("", "", "[CLASS:Button; INSTANCE:1]")
	Sleep(500)
	; For the Element Select Bug, it needs at least an option selected other than elements attributes. I'm making the choice to change subs with L1 and R1
	If Not (ControlCommand("", "", "[NAME:chkSubRichter]", "isChecked")) Then
		ControlCommand("", "", "[NAME:chkSubRichter]", "Check")
	EndIf
	Sleep(500)
	ControlClick("", "", "[NAME:tabMain]")
	Send("{RIGHT}")
EndFunc   ;==>_SOTN_Tool_Init

; Checks If have changes to be made and call _MonsterIteration() if true.
Func _EnemyEditor()
	ControlClick("", "", "[NAME:listNames]")
	ControlFocus("", "", "[NAME:listNames]")
	Send("{HOME}")
	$bRandElems = _CheckRandomizerOptions()
	$bMultiFactor = _CheckMultiplyOptions()
	If $bRandElems = True Or $bMultiFactor = True Then
		_MonsterIteration()
	Else
		ConsoleWrite("No changes for Elements and Attributes were made")
		Return
	EndIf

EndFunc   ;==>_EnemyEditor

; Verifies if any Element Randomization Option is selected. Returns false if no option is selected on GUI and true if at least one option is selected.
Func _CheckRandomizerOptions()
	If $MapSelectedOptions["RadioElemOpt1"] = 0 And $MapSelectedOptions["RadioElemOpt2"] = 0 And $MapSelectedOptions["RadioElemOpt3"] = 0 Then
		Return False
	Else
		Return True
	EndIf
EndFunc   ;==>_CheckRandomizerOptions

; Verifies the value of Combos. If both combos does have default value (0), No multiply changes are needed and it will return false. Anything else will return true.
Func _CheckMultiplyOptions()
	If $MapSelectedOptions["ComboAttrb1"] = 0 And $MapSelectedOptions["ComboAttrb2"] = 0 Then
		Return False
	Else
		Return True
	EndIf

EndFunc   ;==>_CheckMultiplyOptions

; Iterate a list of monsters and for each monster retrieve elements and/or attributes and make the changes selected on GUI.
; Not sure if a Design Pattern could be used here to prevent multiple fors for each option. better than add 3 ifs to be validated 148 times.
Func _MonsterIteration()
	Local $hMonsterList = ControlGetHandle("", "", "[NAME:listNames]")
	;Local $MonsterCount = 15 ; for debug
	Local $MonsterCount = _GUICtrlListBox_GetCount($hMonsterList) ; real value
	Local $MonsterElemArray[11]
	Local $aGUIMonsterTolerance[11]
	Local $Multiplier1 = $MapSelectedOptions["ComboAttrb1"]
	Local $Multiplier2 = $MapSelectedOptions["ComboAttrb2"]

	If $bRandElems = True And $bMultiFactor = False Then
		For $monsterId = 0 To $MonsterCount - 1
			ConsoleWrite("Enemy index: " & $monsterId & " - " & _GUICtrlListBox_GetText($hMonsterList, $monsterId) & @CRLF)
			
			$aGUIMonsterTolerance = ""
			$MonsterElemArray = ""

			$aGUIMonsterTolerance = _RetrieveElem() ; Retrieve monster current elements. It will have a future application.

			$MonsterElemArray = _RandomAttributes($monsterId)
			$MonsterElemArray = _TranslateMonsterArray($MonsterElemArray)
			_AssignAttributes($MonsterElemArray)
			_PatchChanges($hMonsterList)
		Next
	ElseIf $bRandElems = False And $bMultiFactor = True Then
		For $monsterId = 0 To $MonsterCount - 1
			ConsoleWrite("Enemy index: " & $monsterId & " - " & _GUICtrlListBox_GetText($hMonsterList, $monsterId) & @CRLF)
			
			$MonsterArrayStats = ""
			
			$MonsterArrayStats = _RetrieveStats()
			$MonsterArrayStats = _MultiplyStats($MonsterArrayStats, $Multiplier1, $Multiplier2)
			_AssignStats($MonsterArrayStats)
			
			_PatchChanges($hMonsterList)
		Next
	Else ; When both bRandsElems and bMultiFactor are true.
		For $monsterId = 0 To $MonsterCount - 1
			ConsoleWrite("Enemy index: " & $monsterId & " - " & _GUICtrlListBox_GetText($hMonsterList, $monsterId) & @CRLF)
			
			; Clear variable states
			$aGUIMonsterTolerance = ""
			$MonsterElemArray = ""
			$MonsterArrayStats = ""
			
			; Tolerance is Handled first
			$aGUIMonsterTolerance = _RetrieveElem()
			$MonsterElemArray = _RandomAttributes($monsterId)
			$MonsterElemArray = _TranslateMonsterArray($MonsterElemArray)
			_AssignAttributes($MonsterElemArray)
	
			; States are Handled Later
			$MonsterArrayStats = _RetrieveStats()
			$MonsterArrayStats = _MultiplyStats($MonsterArrayStats, $Multiplier1, $Multiplier2)
			_AssignStats($MonsterArrayStats)
			
			_PatchChanges($hMonsterList)
		Next
	EndIf

EndFunc   ;==>_MonsterIteration

; Retrieve Current Array of Monster Elements.
Func _RetrieveElem()
	Local $aMonsterArray[11]
	Local $aToleranceArray[5] = ["N", "W", "S", "I", "A"]
	For $Elem = 0 To 10
		ConsoleWrite($mElementsArray[$Elem] & " CurSel:")
		For $Tolerance = 0 To 4
			$RadioHandler = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[NAME:rad" & $aToleranceArray[$Tolerance] & $mElementsArray[$Elem] & "]")
			If _IsElemRadChecked($RadioHandler) Then
				$aMonsterArray[$Elem] = $Tolerance
				ConsoleWrite($Tolerance & @CRLF)
			EndIf
		Next
	Next
	Return $aMonsterArray
EndFunc   ;==>_RetrieveElem

; Receive a Handler ( a RadioButton handler) , Retrieve the Style of that RadioButton and check if it matches with "Selected" Style and returns a boolean.
; This was needed because other options such as ControlCommand("","",handler, "IsChecked") was not returning true when checked.
Func _IsElemRadChecked($handler)
	$ostyle = "0x" & Hex(_WinAPI_GetWindowLong($handler, $GWL_STYLE), 8)
	; 0x561000B is the Hex representation of the Radio when selected.
	If $ostyle = 0x5601000B Then
		Return True
	Else
		Return False
	EndIf
EndFunc   ;==>_IsElemRadChecked

#cs Randomize the Tolerance Levels of the Attributes.Currently its randomizing everything without taking consideration previous tolerance levels.Here are the values:
0 = Normal (1x)
1 = Weak  (2x)
2 = Resilient (0.5x)
3 = Immune (0x)
4 = Absorb (-1x)

Desired Options on GUI:
1 - Safe ( Bosses unnafected) (DONE)
2 - Enhanced ( Bosses affected, but removes any Imunity/ Absorb properties). (DONE) (This actually can make some bosses easier, so I`m looking for some tweeks.)
3 - Chaotic ( No Exceptions. In some cases, unbeatable) (DONE)
(4) - Hardenned ( Bosses can have multiple Immunities / Absorb , but must be vulnerable to at least one common Damage type ( HIT/ CUT) . Needs to Cherry Pick. Future implementation.

Note: Tolerance Levels can be stored now due to _RetrieveElem() implementation. This can bring changes and major refactor here.
#ce 

Func _RandomAttributes($id)
	; Choose between randomization methods based on the parameter
	Dim $MonsterAttributes[11]

	If $MapSelectedOptions["RadioElemOpt1"] = 1 Then ; Safe Distribution (bosses unnaffected)
		If _ArraySearch($BossesList, $id) < 0 Then ; $BossesList contains non-negative values . If the function does not match any values, it returns a negative result. So, if not a boss, randomize it.
			For $i = 0 To UBound($MonsterAttributes) - 1
				$MonsterAttributes[$i] = Random(0, 4, 1)
			Next
		EndIf
		Return $MonsterAttributes
	ElseIf $MapSelectedOptions["RadioElemOpt2"] = 1 Then     ; Enhanced Distribution ( no Immune/ Absorb. It will make bosses that are Imune or Absorb to be vulnerable)
		If _ArraySearch($BossesList, $id) >= 0 Then
			For $i = 0 To UBound($MonsterAttributes) - 1
				$MonsterAttributes[$i] = Random(0, 2, 1)
			Next
		Else ; Case for normal
			For $i = 0 To UBound($MonsterAttributes) - 1
				$MonsterAttributes[$i] = Random(0, 4, 1)
			Next
		EndIf
		Return $MonsterAttributes

	ElseIf $MapSelectedOptions["RadioElemOpt3"] = 1 Then     ; Chaotic Distribution
		For $i = 0 To UBound($MonsterAttributes) - 1
			$MonsterAttributes[$i] = Random(0, 4, 1)
		Next
		Return $MonsterAttributes
	Else
		ConsoleWrite("If this is printed, something is wrong with Attribute Selection...")
		Return $MonsterAttributes
	EndIf

EndFunc   ;==>_RandomAttributes

; Translates the Array and Clicks on GUI
Func _TranslateMonsterArray($MonsterArray)

	If $MonsterArray <> "" Then
		For $Elem = 0 To UBound($MonsterArray) - 1
			Select
				Case $MonsterArray[$Elem] = 0
					$MonsterArray[$Elem] = "N"
				Case $MonsterArray[$Elem] = 1
					$MonsterArray[$Elem] = "W"
				Case $MonsterArray[$Elem] = 2
					$MonsterArray[$Elem] = "S"
				Case $MonsterArray[$Elem] = 3
					$MonsterArray[$Elem] = "I"
				Case $MonsterArray[$Elem] = 4
					$MonsterArray[$Elem] = "A"
			EndSelect
		Next
	EndIf
	Return $MonsterArray
EndFunc   ;==>_TranslateMonsterArray

; Clicks on GUI to AssignAttributes.
Func _AssignAttributes($Monster)
	If $Monster <> "" Then
		For $item = 0 To UBound($Monster) - 1
			ControlClick("", "", "[NAME:rad" & $Monster[$item] & $mElementsArray[$item] & "]")
			ConsoleWrite($mElementsArray[$item] & " New Sel: " & "[NAME:rad" & $Monster[$item] & $mElementsArray[$item] & "]" & @CRLF)
			;Sleep(100)
		Next
		ConsoleWrite(@CRLF)
	EndIf
EndFunc   ;==>_AssignAttributes

; Retrieves current stats.
Func _RetrieveStats()
	Local $AttributesArray[5]
	$hDEF = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:5]")
	$hSTR = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:6]")
	$hHP = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:7]")
	$hEXP = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:8]")
	$hLV = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:9]")

	$DEF = ControlGetText("", "", $hDEF)
	$STR = ControlGetText("", "", $hSTR)
	$HP = ControlGetText("", "", $hHP)
	$EXP = ControlGetText("", "", $hEXP)
	$LV = ControlGetText("", "", $hLV)


	$AttributesArray[0] = $DEF
	$AttributesArray[1] = $STR
	$AttributesArray[2] = $HP
	$AttributesArray[3] = $EXP
	$AttributesArray[4] = $LV

	ConsoleWrite("Current stats: " & @CRLF & "DEF : " & $DEF & @CRLF & "STR : " & $STR & @CRLF & "HP : " & $HP & @CRLF & "EXP : " & $EXP & @CRLF & "LV : " & $LV & @CRLF)

	Return $AttributesArray
EndFunc   ;==>_RetrieveStats

; Takes advantage of the Map value of multiply options.
Func _MultiplyStats($arrayStats, $multiOpt1, $multiOpt2)
	
	;ConsoleWrite("Array antes da multiplicação:")
	For $i = 0 To UBound($arrayStats) -1
		ConsoleWrite($arrayStats[$i] & "-")
	Next
	ConsoleWrite(@CRLF)
		
	Switch $multiOpt1
		Case 0
			$arrayStats[0] = $arrayStats[0] * 1
			$arrayStats[1] = $arrayStats[1] * 1
			$arrayStats[2] = $arrayStats[2] * 1
		Case 1 ; por algum bug, o default sempre ta passando aqui.
			$arrayStats[0] = $arrayStats[0] * 2
			$arrayStats[1] = $arrayStats[1] * 2
			$arrayStats[2] = $arrayStats[2] * 2
		Case 2
			$arrayStats[0] = $arrayStats[0] * 3
			$arrayStats[1] = $arrayStats[1] * 3
			$arrayStats[2] = $arrayStats[2] * 3
		Case 3
			$arrayStats[0] = $arrayStats[0] * 4
			$arrayStats[1] = $arrayStats[1] * 4
			$arrayStats[2] = $arrayStats[2] * 4
		Case 4
			$arrayStats[0] = $arrayStats[0] * 5
			$arrayStats[1] = $arrayStats[1] * 5
			$arrayStats[2] = $arrayStats[2] * 5
	EndSwitch

	Switch $multiOpt2
		Case 0
			$arrayStats[3] = $arrayStats[3] * 1
			$arrayStats[4] = $arrayStats[4] * 1
		Case 1 ; por algum bug, o default sempre ta passando aqui.
			$arrayStats[3] = Round($arrayStats[3] * 1.25)
			$arrayStats[4] = Round($arrayStats[4] * 1.25)
		Case 2
			$arrayStats[3] = Round($arrayStats[3] * 1.33)
			$arrayStats[4] = Round($arrayStats[4] * 1.33)
		Case 3
			$arrayStats[3] = Round($arrayStats[3] * 1.5)
			$arrayStats[4] = Round($arrayStats[4] * 1.5)
		Case 4
			$arrayStats[3] = $arrayStats[3] * 2
			$arrayStats[4] = $arrayStats[4] * 2
	EndSwitch
	
	;ConsoleWrite("Array apos multiplicação:")
	For $i = 0 To UBound($arrayStats) -1
		ConsoleWrite($arrayStats[$i] & "-")
	Next
	ConsoleWrite(@CRLF)
	
	Return $arrayStats

EndFunc   ;==>_MultiplyStats

; Clicks on GUI to Assign Stats
Func _AssignStats($MonsterStats)
	$hDEF = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:5]")
	$hSTR = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:6]")
	$hHP = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:7]")
	$hEXP = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:8]")
	$hLV = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:9]")

	ControlSetText("", "", $hDEF, $MonsterStats[0])
	ControlSetText("", "", $hSTR, $MonsterStats[1])
	ControlSetText("", "", $hHP, $MonsterStats[2])
	ControlSetText("", "", $hEXP, $MonsterStats[3])
	ControlSetText("", "", $hLV, $MonsterStats[4])

	ControlClick("", "", $hDEF)
	ControlClick("", "", $hSTR)
	ControlClick("", "", $hHP)
	ControlClick("", "", $hEXP)
	ControlClick("", "", $hLV)

	ConsoleWrite("New stats: " & @CRLF & "DEF : " & $MonsterStats[0] & @CRLF & "STR : " & $MonsterStats[1] & @CRLF & "HP : " & $MonsterStats[2] & @CRLF & "EXP : " & $MonsterStats[3] & @CRLF & "LV : " & $MonsterStats[4] & @CRLF)

EndFunc   ;==>_AssignStats

; Patch all changes for the current monster
Func _PatchChanges($hMList)
	ControlClick("", "", "[NAME:btnPatch]")
	Sleep(100)
	ControlClick("", "", "[CLASS:Button; INSTANCE:1]")
	ControlFocus("", "", $hMList)
	Send("{DOWN}")
EndFunc   ;==>_PatchChanges

; Finishes the program
Func _CloseWindow()
	WinClose("[CLASS:WindowsForms10.Window.8.app.0.34f5582_r9_ad1]")
EndFunc   ;==>_CloseWindow


