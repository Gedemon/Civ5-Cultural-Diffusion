-- Dynamic History Main
-- Author: Gedemon
-- DateCreated: 1/29/2011 10:32:50 PM
--------------------------------------------------------------

print("---------------------------------------------------------------------------------------------------------------")
print("-------------------------------------- Cultural Diffusion script started --------------------------------------")
print("---------------------------------------------------------------------------------------------------------------")

--------------------------------------------------------------
-- Mod related initialization (before include)
--------------------------------------------------------------

DynHistModID = "97837c72-d198-49d2-accd-31101cfc048a"
bDynHist = false

RevolutionModID = "cbda59cb-f254-41ad-8d69-ea5053e048f8"
bRevolution = false

local unsortedInstalledMods = Modding.GetInstalledMods()
for key, modInfo in pairs(unsortedInstalledMods) do
	if modInfo.Enabled then
		if (modInfo.Name) then
			if ( modInfo.ID == DynHistModID) then
				bDynHist = true
			end
			if ( modInfo.ID == RevolutionModID) then
				bRevolution = true
			end
		end
	end
end

--------------------------------------------------------------
--------------------------------------------------------------
WARN_NOT_SHARED = false
include( "ShareData.lua" )
include( "SaveUtils" )
MY_MOD_NAME = DynHistModID -- To share data between all DynHist mod components
--------------------------------------------------------------

include ("CultureDefines")
--if bDynHist or bRevolution then include ("CultureSpecDefines") else include ("CultureDefines") end
include ("CultureUtils")
include ("CultureDebug")
include ("CultureFunctions")
include ("CultureUIFunctions")

--------------------------------------------------------------

local bWaitBeforeInitialize = true

local endTurnTime = 0
local startTurnTime = 0

function NewTurnSummary()
	local year = Game.GetGameTurnYear()
	startTurnTime = os.clock()
	Dprint("------------- NEW TURN --------------")
	Dprint ("Game year = " .. year)
	if endTurnTime > 0 then
		Dprint ("AI turn execution time = " .. startTurnTime - endTurnTime )	
	end
	Dprint("-------------------------------------")
end

function EndTurnsummary()
	endTurnTime = os.clock()
	Dprint("-------------------------------------")
	Dprint ("Your turn execution time = " .. endTurnTime - startTurnTime )
	Dprint("-------------------------------------")
end

-----------------------------------------
-- Initializing functions
-----------------------------------------

-- functions to call at beginning of turn
function OnNewTurn ()
	UpdateCultureMap()
	NewTurnSummary()
end
Events.ActivePlayerTurnStart.Add( OnNewTurn )

-- functions to call at end of turn
function OnEndTurn ()
	EndTurnsummary()
	SaveAllTable()
end
Events.ActivePlayerTurnEnd.Add( OnEndTurn )

-- functions to call at first turn
function OnFirstTurn ()
	ShareGlobalTables()
	Events.SerialEventHexCultureChanged.Add(OnCultureChangePlot)
	InitializeGameOption()
	SetDiffusionFactorFromGameSetting()
	NewTurnSummary()
end

-- functions to call after loading a game
function OnLoading ()
	ShareGlobalTables()
	Events.SerialEventHexCultureChanged.Add(OnCultureChangePlot)
	InitializeGameOption()
	SetDiffusionFactorFromGameSetting()
end

-- Initialize when DynHistMain is loaded
if ( bWaitBeforeInitialize ) then
	bWaitBeforeInitialize = false
	if Game.GetGameTurn() == 0 then
		OnFirstTurn()
	else
		OnLoading()
	end
end

-----------------------------------------
-- Register events
-----------------------------------------

function SaveInputHandler( uiMsg, wParam, lParam )
	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_F11 then

			-- table data saving here
			SaveAllTable()

		    Dprint("-------------------------------------")
		    Dprint("Quicksaving...")
		    Dprint("-------------------------------------")

			UI.QuickSave()
        	return true
		end
	end	
end
--ContextPtr:SetInputHandler( SaveInputHandler ) -- Added in ContextPtr:SetInputHandler for Culture tooltip in CultureUIFunctions.Lua

--Events.SerialEventCityDestroyed.Add(UpdateCultureMap)
Events.SerialEventCityCaptured.Add(CityCultureOnCapture)
LuaEvents.OnEmigration.Add(UpdateCultureOnEmigration)
GameEvents.UnitSetXY.Add( UnitCaptureTile )
Events.LocalMachineAppUpdate.Add( SaveOnGameMenuCalled )
GameEvents.PlayerDoTurn.Add( SaveTableOnBarbarianTurn )

print("---------------------------------------------------------------------------------------------------------------")
print("-------------------------------------- Cultural Diffusion script loaded ! -------------------------------------")
print("---------------------------------------------------------------------------------------------------------------")
 