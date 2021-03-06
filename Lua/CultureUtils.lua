-- Culture Utils
-- Author: Gedemon
-- DateCreated: 1/29/2011 11:52:55 PM
--------------------------------------------------------------

print("Loading Culture Utils Function...")
print("-------------------------------------")

--------------------------------------------------------------
-- Map functions 
--------------------------------------------------------------

--	here (x,y) = (0,0) is bottom left of map in Worldbuilder.
function GetPlot (x,y)
	local plot = Map:GetPlotXY(y,x)
	return plot
end

function GetPlotKey ( plot )
	-- set the key string used in cultureMap
	-- structure : g_CultureMap[plotKey] = { { ID = CIV_CULTURAL_ID, Value = cultureForThisCiv }, }
	local x = plot:GetX()
	local y = plot:GetY()
	local plotKey = x..","..y
	return plotKey
end

-- return the plot refered by the key string
function GetPlotFromKey ( plotKey )
	local pos = string.find(plotKey, ",")
	local x = string.sub(plotKey, 1 , pos -1)
	local y = string.sub(plotKey, pos +1)
	local plot = Map:GetPlotXY(y,x)
	return plot
end

function GetPlotXYFromKey ( plotKey )
	local pos = string.find(plotKey, ",")
	local x = string.sub(plotKey, 1 , pos -1)
	local y = string.sub(plotKey, pos +1)
	return x, y
end

function GetCloseCity ( PlayerID, plot )
	local pPlayer = Players[PlayerID]
	local distance = 1000
	local closeCity = nil
	for pCity in pPlayer:Cities() do
		distanceToCity = Map.PlotDistance(pCity:GetX(), pCity:GetY(), plot:GetX(), plot:GetY())
		if ( distanceToCity < distance) then
			distance = distanceToCity
			closeCity = pCity
		end
	end
	return closeCity
end

function GetAdjacentPlots(plot, bIncludeSelf)
	local bDebug = false
	Dprint("   - Getting adjacent plots for " .. plot:GetX() .. ",".. plot:GetY(), bDebug)
	
	if not plot then
		Dprint("- WARNING ! plot is nil for GetAdjacentPlots()")
	end

	local plotList = {}
	if bIncludeSelf and plot then
		table.insert(plotList, plot)
	end
	local direction_types = {
		DirectionTypes.DIRECTION_NORTHEAST,
		DirectionTypes.DIRECTION_EAST,
		DirectionTypes.DIRECTION_SOUTHEAST,
		DirectionTypes.DIRECTION_SOUTHWEST,
		DirectionTypes.DIRECTION_WEST,
		DirectionTypes.DIRECTION_NORTHWEST
	}
	for loop, direction in ipairs(direction_types) do
		local adjPlot = Map.PlotDirection( plot:GetX(), plot:GetY(), direction)
		if ( adjPlot ~= nil ) then
			Dprint("      - adding plot at " .. adjPlot:GetX() .. ",".. adjPlot:GetY(), bDebug)
			table.insert(plotList, adjPlot)
		end
	end
	Dprint("   - num adjacent plots = " .. #plotList, bDebug)
	return plotList
end


--------------------------------------------------------------
-- Save/Load functions 
--------------------------------------------------------------

function LoadCultureMap()
	local pPlayer = Players[PLAYER_SAVE_SLOT]
	local cultureMap = load( pPlayer, "CultureMap" ) or {}
	return cultureMap
end
function SaveCultureMap( cultureMap )
	local pPlayer = Players[PLAYER_SAVE_SLOT]
	save( pPlayer, "CultureMap", cultureMap )
end

-- Locked plots (just capturad by military units, don't flip back immediatly from culture...
function LoadLockedMap()
	--[[
	local pPlayer = Players[PLAYER_SAVE_SLOT]
	local LockedMap = load( pPlayer, "LockedMap" ) or {}
	return LockedMap
	--]]
	return LoadData( "LockedMap", {} )
end
function SaveLockedMap( LockedMap )
	--[[
	local pPlayer = Players[PLAYER_SAVE_SLOT]
	save( pPlayer, "LockedMap", LockedMap )
	--]]
	SaveData( "LockedMap", LockedMap )
end

function LoadData( name, defaultValue, key )
	local startTime = os.clock()
	local plotKey = key or DEFAULT_SAVE_KEY
	local pPlot = GetPlotFromKey ( plotKey )
	if pPlot then
		local value = load( pPlot, name ) or defaultValue
		local endTime = os.clock()
		local totalTime = endTime - startTime
		Dprint ("LoadData() used " .. tostring(totalTime) .. " sec to retrieve " .. tostring(name) .. " from plot " .. tostring(plotKey) .. " (#entries = " .. tostring(GetSize(value)) ..")", DEBUG_PERFORMANCE)
		return value
	else
		Dprint("ERROR: trying to load script data from invalid plot (" .. tostring(plotKey) .."), data = " .. tostring(name))
		return nil
	end
end
function SaveData( name, value, key )
	local startTime = os.clock()
	local plotKey = key or DEFAULT_SAVE_KEY
	local pPlot = GetPlotFromKey ( plotKey )	
	if pPlot then
		save( pPlot, name, value )
		local endTime = os.clock()
		local totalTime = endTime - startTime
		Dprint ("SaveData() used " .. tostring(totalTime) .. " sec to store " .. tostring(name) .. " in plot " .. tostring(plotKey) .. " (#entries = " .. tostring(GetSize(value)) ..")", DEBUG_PERFORMANCE)
	else
		Dprint("ERROR: trying to save script data to invalid plot (" .. tostring(plotKey) .."), data = " .. tostring(name) .. " value = " .. tostring(value))
	end
end

function SaveAllTable()
	print("-------------------------------------")
	print("Saving data table ...")
	local bDebugPerformance = DEBUG_PERFORMANCE
	DEBUG_PERFORMANCE = true	
	local t1 = os.clock()
	
	SaveCultureMap( MapModData.AH.CultureMap )

	local t2 = os.clock()
	print("  - Total time for all tables :		" .. t2 - t1 .. " s")
	DEBUG_PERFORMANCE = bDebugPerformance
end


function SaveOnGameMenuCalled()
	if (ContextPtr:LookUpControl("/InGame/GameMenu/"):IsHidden()) then
		TABLE_SAVED = false
		return
	end	
	if not TABLE_SAVED then
		SaveAllTable()
		TABLE_SAVED = true
	end
end
--Events.SerialEventGameDataDirty.Add(SaveOnOptionMenuCalled)

function SaveTableOnBarbarianTurn(PlayerID)
	if PlayerID == BARBARIAN_PLAYER then
		SaveAllTable()
	end
end

--------------------------------------------------------------
-- Math functions 
--------------------------------------------------------------

function Round(num)
    under = math.floor(num)
    upper = math.floor(num) + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then
        return under
    else
        return upper
    end
end

function Shuffle(t)
  local n = #t
 
  while n >= 2 do
    -- n is now the last pertinent index
    local k = math.random(n) -- 1 <= k <= n
    -- Quick swap
    t[n], t[k] = t[k], t[n]
    n = n - 1
  end
 
  return t
end

function GetSize(t)

	if type(t) ~= "table" then
		return 1 
	end

	local n = #t 
	if n == 0 then
		for k, v in pairs(t) do
			n = n + 1
		end
	end 
	return n
end

--------------------------------------------------------------
-- Database functions 
--------------------------------------------------------------

-- return the first PlayerID using this CivilizationID or MinorcivID
function GetPlayerIDFromCivID (id, bIsMinor, bReportError)
	if ( bIsMinor ) then
		for player_num = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIV_PLAYERS - 1, 1 do
			local player = Players[player_num]
			if ( id == player:GetMinorCivType() ) then
				return player_num
			end
		end
	else
		for player_num = 0, GameDefines.MAX_MAJOR_CIVS-1 do
			local player = Players[player_num]
			if ( id == player:GetCivilizationType() ) then
				return player_num
			end
		end
	end
	if (id) then 
		Dprint ("WARNING : can't find Player ID for civ ID = " .. id , bReportError) 
	else	
		Dprint ("WARNING : civID is NILL or FALSE", bReportError) 
	end
	return false
end

-- return Civ type ID for PlayerID
function GetCivIDFromPlayerID (PlayerID, bReportError)
	if (PlayerID ~= -1) then
		if PlayerID <= GameDefines.MAX_MAJOR_CIVS-1 then
			local civID = Players[PlayerID]:GetCivilizationType()
			if (civID ~= -1) then
				return civID
			else
				Dprint ("WARNING : no major civ for PlayerID = " .. PlayerID , bReportError) 
				return false
			end
		else 
			local civID = Players[PlayerID]:GetMinorCivType()
			if (civID ~= -1) then
				return civID
			else
				Dprint ("WARNING : no minor civ for PlayerID = " .. PlayerID, bReportError) 
				return false
			end
		end
	else
		Dprint ("WARNING : trying to find CivType for PlayerID = -1", bReportError) 
		return false
	end
end

function GetCivTypeFromPlayer (PlayerID, bReportError)
	if (PlayerID ~= -1) then
		if PlayerID <= GameDefines.MAX_MAJOR_CIVS-1 then
			local civID = Players[PlayerID]:GetCivilizationType()
			if (civID ~= -1) then
				return GameInfo.Civilizations[civID].Type
			else
				Dprint ("WARNING : no major civ for PlayerID = " .. PlayerID , bReportError) 
				return false
			end
		else 
			local civID = Players[PlayerID]:GetMinorCivType()
			if (civID ~= -1) then
				return GameInfo.MinorCivilizations[civID].Type
			else
				Dprint ("WARNING : no minor civ for PlayerID = " .. PlayerID, bReportError) 
				return false
			end
		end
	else
		Dprint ("WARNING : trying to find CivType for PlayerID = -1", bReportError) 
		return false
	end
end

-- update localized text
function SetText ( str, tag )
	-- in case of language change mid-game :
	local query = "UPDATE Language_en_US SET Text = '".. str .."' WHERE Tag = '".. tag .."'"
	for result in DB.Query(query) do
	end
	--Dprint (query)
	-- that's the table used ingame :
	local query = "UPDATE LocalizedText SET Text = '".. str .."' WHERE Tag = '".. tag .."'"
	for result in DB.Query(query) do
	end	
	--Dprint (query)
end

-- return the first PlayerID using this Civilization or Minorciv type
function GetPlayerIDFromCivType (type, bIsMinor, bReportError)
	if (type) then 
		local civID = nil
		if GameInfo.Civilizations[type] then
			civID = GameInfo.Civilizations[type].ID
			return GetPlayerIDFromCivID (civID, false, bReportError)
		elseif GameInfo.MinorCivilizations[type] then
			civID = GameInfo.MinorCivilizations[type].ID
			return GetPlayerIDFromCivID (civID, true, bReportError)
		end
		Dprint ("WARNING : can't find Player ID for civ Type = " .. type , bReportError) 
	else	
		Dprint ("WARNING : civID is NILL or FALSE", bReportError) 
	end
	return false
end

function ShareGlobalTables()
	print("Sharing Global Tables...")
	MapModData.AH.CultureMap = LoadCultureMap()
end