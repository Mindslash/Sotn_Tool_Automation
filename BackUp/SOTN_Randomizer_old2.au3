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
  
  #2 Multiply Options
  * Multiplying enemy factor (2x,3x,4x,5x)(ATK, HP and DEF) [OK]
  * Multiplying enemy Exp/LV (1.25,1.33,1.5,2)(round) [OK]
  
  #3 Reset Option.
  * For Future. Not sure If I want to reset the ISO everytime its run or take advantage of current settings. It may increases the complexity a bit.

  #4 Refactor code. Maybe using ENUMS or preventing the use of Maps, so the beta wont be needed... also cleaning the code to be shorter and more readable.
  
  #5 Shop Modifier Randomizer. Not sure if I want to do this. Current shop is good, but Firebrand, IceBrand and ThunderBrand must display on Shop. Maybe include Stone and Poison Sword.

BUGS:
* if no selected option on main menu of the tool, the changes to elements are not patched. I will be selecting richter custom sub circle
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
    Local $Castlevania_Editor_Path = $MapSelectedOptions["ToolPath"]    ;
    Local $Castlevania_ISO_Long_Path = $MapSelectedOptions["ISOPath"]    ;
    Run($Castlevania_Editor_Path)
    WinWaitActive($Castlevania_Tool_Window_title)
    Sleep(4000)
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

; Checks Changes to be made.
Func _EnemyEditor()
    ControlClick("", "", "[NAME:listNames]")
    Sleep(500)

    Send("{HOME}")
    $bRandElems = _CheckRandomizerOptions()
    $bMultiFactor = _CheckMultiplyOptions()
    If $bRandElems = True Or $bMultiFactor = True Then
        _MonsterIteration()
    Else
        ConsoleWrite("No changes for Elements and Attributes were made")
        Return
    EndIf

EndFunc   

; Verifies if any Element Randomization Option is selected. Returns false if no option is selected on GUI. However, this can be improved since its a radiobutton.
Func _CheckRandomizerOptions()
    If $MapSelectedOptions["RadioElemOpt1"] = 0 And $MapSelectedOptions["RadioElemOpt2"] = 0 And $MapSelectedOptions["RadioElemOpt3"] = 0 Then
        Return False
    Else
        Return True
    EndIf
EndFunc   

; Verifies the value of Combos. If Default option is selected ( itemId = 0 ) Returns False. If nothing is selected, is still considered as Default, hence returns False.
Func _CheckMultiplyOptions()
    If $MapSelectedOptions["ComboAttrb1"] = 0 And $MapSelectedOptions["ComboAttrb1"] = 0 Then
        Return False
    Else
        Return True
    EndIf

EndFunc   

; Not sure if a Design Pattern could be used here to prevent multiple fors for each option. better than add 3 ifs to be validated 148 times.
Func _MonsterIteration()
    Local $hMonsterList = ControlGetHandle("", "", "[NAME:listNames]")
    Local $MonsterElemArray[11]
    Local $MonsterArrayStats[5]
    Local $Multiplier1 = $MapSelectedOptions["ComboAttrb1"]
    Local $Multiplier2 = $MapSelectedOptions["ComboAttrb2"]

    If $bRandElems = True And $bMultiFactor = False Then
        For $monsterId = 0 To _GUICtrlListBox_GetCount($hMonsterList) - 1
            ConsoleWrite("Enemy index: " & $monsterId & @CRLF)
            $MonsterElemArray = ""
            $MonsterElemArray = _RandomAttributes($monsterId)
            $MonsterElemArray = _TranslateMonsterArray($MonsterElemArray)
            _AssignAttributes($MonsterElemArray)
            _PatchChanges($hMonsterList)
        Next
    ElseIf $bRandElems = False And $bMultiFactor = True Then
        For $monsterId = 0 To _GUICtrlListBox_GetCount($hMonsterList) - 1
            ConsoleWrite("Enemy index: " & $monsterId & @CRLF)
            $MonsterArrayStats = ""
            $MonsterArrayStats = _RetrieveStats() ; TODO
            $MonsterArrayStats = _MultiplyStats($MonsterArrayStats,$Multiplier1,$Multiplier2) ; TODO
            _AssignStats($MonsterArrayStats) ; Todo
            _PatchChanges($hMonsterList)
        Next
    Else ; When both $bRandElems and $bMultiFactor are true.
        For $monsterId = 0 To _GUICtrlListBox_GetCount($hMonsterList) - 1
            ConsoleWrite("Enemy index: " & $monsterId & @CRLF)
            $MonsterElemArray = ""
            $MonsterArrayStats = ""

            $MonsterElemArray = _RandomAttributes($monsterId)
            $MonsterElemArray = _TranslateMonsterArray($MonsterElemArray)
            _AssignAttributes($MonsterElemArray)

            $MonsterArrayStats = _RetrieveStats() ; TODO
            $MonsterArrayStats = _MultiplyStats($MonsterArrayStats,$Multiplier1,$Multiplier2) ; TODO
            _AssignStats($MonsterArrayStats) ; Todo

            _PatchChanges($hMonsterList)
        Next
    EndIf

EndFunc   ;==>_MonsterIteration


#cs Randomize the Tolerance Levels of the Attributes.Here are the values:
0 = Normal (1x)
1 = Weak  (2x)
2 = Resilient (0.5x)
3 = Immune (0x)
4 = Absorb (-1x)

Options on GUI:
1 - Safe ( Bosses unnafected) ( Needs to implement Bosses Ignore)
2 - Enhanced ( Bosses affected, but with no Imunity/ Absorb). This actually can make some bosses easier, so I`m looking for some tweeks.
3 - Chaotic ( No Exceptions. In some cases, unbeatable) (Already Implemented)
(4) - Hardenned ( Bosses can have multiple Immunities / Absorb , but must be vulnerable to at least one common Damage type ( HIT/ CUT) . Needs to Cherry Pick. Future implementation.
#ce Randomize the Tolerance Levels of the Attributes.Here are the values:
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
    EndIf
    Return $MonsterArray
EndFunc   ;==>_TranslateMonsterArray

; Clicks on GUI to AssignAttributes.
Func _AssignAttributes($Monster)
    If $Monster <> "" Then
        For $item = 0 To UBound($Monster) - 1
            ControlClick("", "", "[NAME:rad" & $Monster[$item] & $mElementsArray[$item] & "]")
            ConsoleWrite("[NAME:rad" & $Monster[$item] & $mElementsArray[$item] & "]")
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
    $hLV = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:8]")
    $hEXP = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:9]")

    $DEF = ControlGetText("", "", $hDEF)
    $STR = ControlGetText("", "", $hSTR)
    $HP = ControlGetText("", "", $hHP)
    $LV = ControlGetText("", "", $hLV)
    $EXP = ControlGetText("", "", $hEXP)
    
    $AttributesArray[0] = $DEF
    $AttributesArray[1] = $STR
    $AttributesArray[2] = $HP
    $AttributesArray[3] = $LV 
    $AttributesArray[4] = $EXP
    
    ConsoleWrite("Current stats: " & @CRLF & "DEF : " & $DEF & @CRLF & "STR : " & $STR & @CRLF & "HP : " & $HP & @CRLF & "LV : " & $LV & @CRLF & "EXP : " & $EXP & @CRLF)

    Return $AttributesArray
EndFunc   

; Takes advantage of the Map value of multiply options.
Func _MultiplyStats(ByRef $arrayStats,$multiOpt1, $multiOpt2 )
    Switch $multiOpt1
        Case $multiOpt1 = 0
            $arrayStats[0] = $arrayStats[0] * 1
            $arrayStats[1] = $arrayStats[1] * 1
            $arrayStats[2] = $arrayStats[2] * 1
        Case $multiOpt1 = 1
            $arrayStats[0] = $arrayStats[0] * 2
            $arrayStats[1] = $arrayStats[1] * 2
            $arrayStats[2] = $arrayStats[2] * 2
        Case $multiOpt1 = 2
            $arrayStats[0] = $arrayStats[0] * 3
            $arrayStats[1] = $arrayStats[1] * 3
            $arrayStats[2] = $arrayStats[2] * 3
        Case $multiOpt1 = 3
            $arrayStats[0] = $arrayStats[0] * 4
            $arrayStats[1] = $arrayStats[1] * 4
            $arrayStats[2] = $arrayStats[2] * 4
        Case $multiOpt1 = 4
            $arrayStats[0] = $arrayStats[0] * 5
            $arrayStats[1] = $arrayStats[1] * 5
            $arrayStats[2] = $arrayStats[2] * 5
    EndSwitch
    
    Switch $multiOpt2
        Case $multiOpt2 = 0
            $arrayStats[3] = $arrayStats[3] * 1
            $arrayStats[4] = $arrayStats[4] * 1
        Case $multiOpt2 = 1
            $arrayStats[3] = $arrayStats[3] * 1.25
            $arrayStats[4] = $arrayStats[4] * 1.25
        Case $multiOpt2 = 2
            $arrayStats[3] = $arrayStats[3] * 1.33
            $arrayStats[4] = $arrayStats[4] * 1.33
        Case $multiOpt2 = 3
            $arrayStats[3] = $arrayStats[3] * 1.5
            $arrayStats[4] = $arrayStats[4] * 1.5
        Case $multiOpt2 = 4
            $arrayStats[3] = $arrayStats[3] * 2
            $arrayStats[4] = $arrayStats[4] * 2
    EndSwitch
    Return $arrayStats
             
EndFunc   

; Clicks on GUI to Assign Stats
Func _AssignStats($MonsterStats)
    $hDEF = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:5]")
    $hSTR = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:6]")
    $hHP = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:7]")
    $hLV = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:8]")
    $hEXP = ControlGetHandle("PSX Castlevania Symphony of The Night USA", "", "[CLASS:WindowsForms10.EDIT.app.0.34f5582_r9_ad1; INSTANCE:9]")

    ControlSetText("","",$hDEF,$MonsterStats[0])
    ControlSetText("","",$hSTR,$MonsterStats[1])
    ControlSetText("","",$hHP,$MonsterStats[2])
    ControlSetText("","",$hLV,$MonsterStats[3])
    ControlSetText("","",$hEXP,$MonsterStats[4])
    
    ControlClick("","",$hDEF)
    ControlClick("","",$hSTR)
    ControlClick("","",$hHP)
    ControlClick("","",$hLV)
    ControlClick("","",$hEXP)
    
    ConsoleWrite("New stats: " & @CRLF & "DEF : " & $MonsterStats[0] & @CRLF & "STR : " & $MonsterStats[1] & @CRLF & "HP : " & $MonsterStats[2] & @CRLF & "LV : " & $MonsterStats[3] & @CRLF & "EXP : " & $MonsterStats[4] & @CRLF)

EndFunc   

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


