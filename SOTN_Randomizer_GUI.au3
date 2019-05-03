#cs
; Possible Improvements: 
1 - Changing Map to Array to not rely on Beta
2 - A confirm box displaying all selected options
3 - A logic to when all selected options of the Map are 0 ( Default), prevent the Patch button to be pressed or give an alert. Or maybe can be treated on the main.

TODO
1 - Add 1 when attribute is 0 ( HP, DEF, LVL, EXP)

#ce

#include-once
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <FileConstants.au3>
#include <GuiComboBox.au3>

Global $MapOfOptions[] ;
$MapOfOptions["ToolPath"] = ""
$MapOfOptions["ISOPath"] = ""
$MapOfOptions["RadioElemOpt1"] = 0
$MapOfOptions["RadioElemOpt2"] = 0
$MapOfOptions["RadioElemOpt3"] = 0
$MapOfOptions["ComboAttrb1"] = 0
$MapOfOptions["ComboAttrb2"] = 0

#Region ### START Koda GUI section ### Form=C:\Users\Avell 1513\Desktop\My-AutoIt\Randomizer_design.kxf
$Form1 = GUICreate("Castlevania SOTN Automated Randomizer", 385, 361, 625, 206)
; Exe and ISO Paths
$LabelStep1 = GUICtrlCreateLabel("Step 1: Select Path for both Tool and Bin to be patched", 8, 5)
$ButtonToolPath = GUICtrlCreateButton("Select Tool Path...", 8, 25, 99, 25)
$ButtonIsoBinPath = GUICtrlCreateButton("Select Clean Bin Path...", 8, 55, 99, 25)
$InputToolPath = GUICtrlCreateInput("", 112, 25, 257, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
$InputIsoBinPath = GUICtrlCreateInput("", 112, 55, 257, 21)
GUICtrlSetState(-1, $GUI_DISABLE)

; Element Randomizer options ( monsters get all random usually. The most problematic are the bosses.)
$LabelStep2 = GUICtrlCreateLabel("Step 2: Choose Element Randomization Options", 8, 85)
$CheckElemRandomizer = GUICtrlCreateCheckbox("Element Randomizer", 8, 105, 121, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
$GroupElement = GUICtrlCreateGroup("Element Options", 136, 105, 233, 85)
$RadioElemOpt1 = GUICtrlCreateRadio("Safe", 152, 120, 161, 17)      ;(Bosses are unnafected)
GUICtrlSetState(-1, $GUI_DISABLE)
$RadioElemOpt2 = GUICtrlCreateRadio("Enhanced", 152, 140, 185, 17)     ;(Bosses are affected. Removes Immunities and Absorbs). Thinking on future to change to include at least 1-3 vulnerable elements)
GUICtrlSetState(-1, $GUI_DISABLE)
$RadioElemOpt3 = GUICtrlCreateRadio("Chaotic", 152, 160, 201, 17)     ; ( Can render some seeds unbeatable without Glitches)
GUICtrlSetState(-1, $GUI_DISABLE)
;$RadioElemOpt4 = GUICtrlCreateRadio("Hardenned", 152, 160, 201, 17)     ; ( Hard Mode. Thinking on letting to have 1 or 2 vulnerable elements (Strong, Weak, None). The rest will be Immune or Absorb. Not sure if this will only apply for bosses)
;GUICtrlSetState(-1, $GUI_DISABLE)


; Stat Multiplier Options
$LabelStep3 = GUICtrlCreateLabel("Step 3: Choose Multiplier Options.", 8, 200)
$CheckStatsMulti = GUICtrlCreateCheckbox("Multipliers", 8, 220, 121, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$GroupStats = GUICtrlCreateGroup("Statistic Options", 136, 220, 233, 105)
$LabelAttrb1 = GUICtrlCreateLabel("HP/STR/DEF", 152, 240, 72, 17)
$ComboAttrb1 = GUICtrlCreateCombo("", 240, 240, 75, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetData(-1, "Default|2x|3x|4x|5x", "Default")
$LabelAttrb2 = GUICtrlCreateLabel("Exp/Level", 152, 274, 53, 17)
$ComboAttrb2 = GUICtrlCreateCombo("", 240, 272, 75, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetData(-1, "Default|1.25x|1.33x|1.5x|2x", "Default")

GUICtrlSetState(-1, $GUI_DISABLE)
$ButtonPatch = GUICtrlCreateButton("Patch!", 216, 328, 75, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$ButtonCancel = GUICtrlCreateButton("Cancel", 296, 328, 75, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

Func _RandomizerGUILoop()
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE, $ButtonCancel
				GUIDelete($Form1)
				Exit
			Case $ButtonToolPath, $ButtonIsoBinPath, $CheckElemRandomizer, $CheckStatsMulti, $RadioElemOpt1, $RadioElemOpt2, $RadioElemOpt3
				_Update_View($nMsg)
			Case $ButtonPatch
				_Fill_Option_Map() 
				_TranslateMap() 
				GUIDelete($Form1)
				Return $MapOfOptions ; Not sure if needed, but I think its necessary for the other script to read this value. Avoiding the calling of the Global var from here on the other file.
		EndSwitch
	WEnd
EndFunc   ;==>_RandomizerGUILoop

Func _Update_View($nMsg)
	Switch $nMsg
		Case $ButtonToolPath
			$PathTool = FileOpenDialog("Select a Valid Castlevania SOTN Editor Tool Exe...", @WorkingDir, "Tool file (*.exe)", BitAND($FD_FILEMUSTEXIST, $FD_PATHMUSTEXIST))
			If @error Then
				$PathTool = ""
			EndIf
			GUICtrlSetData($InputToolPath, $PathTool)
			_Enable_Disable_Checkboxes($InputToolPath, $InputIsoBinPath)
			_Enable_Disable_Elem_Random_Options()
			_Enable_Disable_Multipliers()
			_Enable_Disable_Patch_Button()
		Case $ButtonIsoBinPath
			$PathISO = FileOpenDialog("Select a Valid Castlevania Bin File...", @WorkingDir, "SOTN Bin file (*.bin)", BitAND($FD_FILEMUSTEXIST, $FD_PATHMUSTEXIST))
			If @error Then
				$PathISO = ""
			EndIf
			GUICtrlSetData($InputIsoBinPath, $PathISO)
			_Enable_Disable_Checkboxes($InputToolPath, $InputIsoBinPath)
			_Enable_Disable_Elem_Random_Options()
			_Enable_Disable_Multipliers()
			_Enable_Disable_Patch_Button()
		Case $CheckElemRandomizer
			_Enable_Disable_Elem_Random_Options()
			_Enable_Disable_Patch_Button()
		Case $CheckStatsMulti
			_Enable_Disable_Multipliers()
			_Enable_Disable_Patch_Button()
		Case $RadioElemOpt1, $RadioElemOpt2, $RadioElemOpt3
			_Enable_Disable_Patch_Button()
	EndSwitch

EndFunc   ;==>_Update_View

Func _Enable_Disable_Checkboxes($InputToolPath, $InputIsoBinPath)
	If GUICtrlRead($InputToolPath) <> "" And GUICtrlRead($InputIsoBinPath) <> "" Then
		GUICtrlSetState($CheckElemRandomizer, $GUI_ENABLE)
		GUICtrlSetState($CheckStatsMulti, $GUI_ENABLE)

	ElseIf GUICtrlRead($InputToolPath) = "" Or GUICtrlRead($InputIsoBinPath) = "" Then
		GUICtrlSetState($CheckElemRandomizer, $GUI_DISABLE + $GUI_UNCHECKED)
		GUICtrlSetState($CheckStatsMulti, $GUI_DISABLE + $GUI_UNCHECKED)
	EndIf
EndFunc   ;==>_Enable_Disable_Checkboxes

Func _Enable_Disable_Elem_Random_Options()
	If GUICtrlRead($CheckElemRandomizer) = $GUI_CHECKED Then
		GUICtrlSetState($RadioElemOpt1, $GUI_ENABLE)
		GUICtrlSetState($RadioElemOpt2, $GUI_ENABLE)
		GUICtrlSetState($RadioElemOpt3, $GUI_ENABLE)
	EndIf
	If GUICtrlRead($CheckElemRandomizer) = $GUI_UNCHECKED Then
		GUICtrlSetState($RadioElemOpt1, $GUI_DISABLE + $GUI_UNCHECKED)
		GUICtrlSetState($RadioElemOpt2, $GUI_DISABLE + $GUI_UNCHECKED)
		GUICtrlSetState($RadioElemOpt3, $GUI_DISABLE + $GUI_UNCHECKED)

	EndIf
EndFunc   ;==>_Enable_Disable_Elem_Random_Options

Func _Enable_Disable_Multipliers()
	If GUICtrlRead($CheckStatsMulti) = $GUI_CHECKED Then
		GUICtrlSetState($ComboAttrb1, $GUI_ENABLE)
		GUICtrlSetState($ComboAttrb2, $GUI_ENABLE)
	EndIf
	If GUICtrlRead($CheckStatsMulti) = $GUI_UNCHECKED Then
		GUICtrlSetState($ComboAttrb1, $GUI_DISABLE)
		GUICtrlSetState($ComboAttrb2, $GUI_DISABLE)
		_GUICtrlComboBox_SetCurSel($ComboAttrb1, Default)
		_GUICtrlComboBox_SetCurSel($ComboAttrb2, Default)
	EndIf
EndFunc   ;==>_Enable_Disable_Multipliers

Func _Enable_Disable_Patch_Button()
	If GUICtrlRead($RadioElemOpt1) = $GUI_CHECKED Or GUICtrlRead($RadioElemOpt2) = $GUI_CHECKED Or GUICtrlRead($RadioElemOpt3) = $GUI_CHECKED Or GUICtrlRead($CheckStatsMulti) = $GUI_CHECKED Then
		GUICtrlSetState($ButtonPatch, $GUI_ENABLE)
	EndIf
	If GUICtrlRead($RadioElemOpt1) = $GUI_UNCHECKED And GUICtrlRead($RadioElemOpt2) = $GUI_UNCHECKED And GUICtrlRead($RadioElemOpt3) = $GUI_UNCHECKED And GUICtrlRead($CheckStatsMulti) = $GUI_UNCHECKED Then
		GUICtrlSetState($ButtonPatch, $GUI_DISABLE)
	EndIf

EndFunc   ;==>_Enable_Disable_Patch_Button

Func _Fill_Option_Map()
	$MapOfOptions["ToolPath"] = GUICtrlRead($InputToolPath)
	$MapOfOptions["ISOPath"] = GUICtrlRead($InputIsoBinPath)
	$MapOfOptions["RadioElemOpt1"] = GUICtrlRead($RadioElemOpt1)
	$MapOfOptions["RadioElemOpt2"] = GUICtrlRead($RadioElemOpt2)
	$MapOfOptions["RadioElemOpt3"] = GUICtrlRead($RadioElemOpt3)
	$MapOfOptions["ComboAttrb1"] = _GUICtrlComboBox_GetCurSel($ComboAttrb1)
	$MapOfOptions["ComboAttrb2"] = _GUICtrlComboBox_GetCurSel($ComboAttrb2)
EndFunc   ;==>_Fill_Option_Map

; This translate map is to instead return values 1,2 or 4 relative to $GUI_CHECKED, $GUI_UNCHECKED and $GUI_DISABLE , return value 1 true and 0 if false for each radiobutton. 
; A Refactor is needed to return use only 1 Map option , since its a radiobutton and not a checkbox.
Func _TranslateMap()


	Switch $MapOfOptions["RadioElemOpt1"]
		Case $GUI_CHECKED
			$MapOfOptions["RadioElemOpt1"] = 1
		Case $GUI_UNCHECKED Or $GUI_DISABLE
			$MapOfOptions["RadioElemOpt1"] = 0
	EndSwitch
	Switch $MapOfOptions["RadioElemOpt2"]
		Case $GUI_CHECKED
			$MapOfOptions["RadioElemOpt2"] = 1
		Case $GUI_UNCHECKED Or $GUI_DISABLE
			$MapOfOptions["RadioElemOpt2"] = 0
	EndSwitch
	Switch $MapOfOptions["RadioElemOpt3"]
		Case $GUI_CHECKED
			$MapOfOptions["RadioElemOpt3"] = 1
		Case $GUI_UNCHECKED Or $GUI_DISABLE
			$MapOfOptions["RadioElemOpt3"] = 0
	EndSwitch

EndFunc   ;==>_TranslateMap
Func _GetMapOfOptions()
	Return $MapOfOptions
EndFunc   ;==>_GetMapOfOptions
