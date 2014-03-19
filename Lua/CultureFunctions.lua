-- Dynamic History Culture
-- Author: Gedemon
-- DateCreated: 2/1/2011 7:34:01 PM
--------------------------------------------------------------

print("Loading Culture Functions...")
print("-------------------------------------")


function GetPlotCulture( plotKey, cultureMap )
	-- return a table with all civs culture for a plot in cultureMap
	for key, plotCulture in pairs ( cultureMap ) do
		if (key == plotKey) then
			return plotCulture
		end
	end
	return false
end
 
function GetPlotTotalCulture( plotKey, cultureMap )
	-- return the total culture of a plot
	local bDebugOutput = false
	local totalCulture = 0
	for key, plotCulture in pairs (cultureMap) do
		if (key == plotKey) then
			for i = 1, #plotCulture do
				totalCulture = totalCulture + plotCulture[i].Value
			end
			Dprint("Total culture for ("..plotKey..") is : " .. totalCulture , bDebugOutput )
			Dprint ("---" , bDebugOutput )
			return totalCulture
		end
	end
	Dprint ("---" , bDebugOutput )
	return 0
end

function GetPlotCulturePercent( plotKey, cultureMap )
	-- return a table with civs culture % for a plot in cultureMap and the total culture
	local bDebugOutput = false
	local plotCulturePercent = {}
	local totalCulture = 0
	for key, plotCulture in pairs (cultureMap) do
		if (key == plotKey) then
			for i = 1, #plotCulture do
				totalCulture = totalCulture + plotCulture[i].Value
			end
			Dprint("Total culture for ("..plotKey..") is : " .. totalCulture , bDebugOutput )
			if (totalCulture > 0) then -- don't mess with the universe
				for i = 1, #plotCulture do
					table.insert (plotCulturePercent, { ID = plotCulture[i].ID, Value = (plotCulture[i].Value / totalCulture * 100) } )
					Dprint(" - ".. plotCulture[i].ID .. " have " .. (plotCulture[i].Value / totalCulture * 100) .. "%" , bDebugOutput )
				end
			end			
			Dprint ("---" , bDebugOutput )
			return plotCulturePercent, totalCulture
		end
	end
	Dprint ("---" , bDebugOutput )
	return false, 0
end

function GetCivPlotCulture ( plotKey, cultureMap, cultureID )	-- plotKey returned by GetPlotKey(plot), cultureID is civilization cultural ID 
																-- return the culture value for civilization (cultureID) of a given plot (plotKey)
	local civsCulture = GetPlotCulture(plotKey, cultureMap)
	if ( civsCulture ) then
		for i, culture in ipairs ( civsCulture ) do
			if culture.ID == cultureID then
				return culture.Value
			end
		end
	end
	return false
end

function PlotCultureThreshold( plot )
	if plot:IsMountain() then
		return CULTURE_MOUNTAIN_THRESHOLD
	else
		return CULTURE_THRESHOLD
	end
end

function GetCityCulturalOutput ( city, plotKey, cultureMap )
	local bDebugOutput = true

	Dprint ("-- city at (" .. plotKey.. ") : " .. city:GetName(), bDebugOutput)
	local PlayerID = city:GetOwner() 
	local player = Players [ PlayerID ]
	local ownerCultureID = GetCivTypeFromPlayer (PlayerID)
	local population = city:GetPopulation()
	local cityCultureProduction = city:GetJONSCulturePerTurn()
	Dprint (" - "..ownerCultureID .. " cityCultureProduction : " .. cityCultureProduction .. ", population : " .. population, bDebugOutput)

	local cityCulturalOutput = {}
	local civsCulture = GetPlotCulture(plotKey, cultureMap)
	local totalCulture = GetPlotTotalCulture( plotKey, cultureMap )
	local maxCulture = (population + cityCultureProduction) * CULTURE_CITY_CAPED_FACTOR
	Dprint (" - Max culture = ".. tostring(maxCulture) , bDebugOutput)
	Dprint (" - Total culture = ".. tostring(totalCulture) , bDebugOutput)
	Dprint (" - civsCulture = ".. tostring(civsCulture) , bDebugOutput)

	local bHasLibertyPolicy = false
	if USE_POLICIES then
		bHasLibertyPolicy = player:HasPolicy(GameInfo.Policies["POLICY_LIBERTY"].ID)
	end
	if bHasLibertyPolicy then
		Dprint (" - Player has adopted the liberty policy...", bDebugOutput)
	end

	if (totalCulture > maxCulture ) then
		-- should return negative values here ?
		Dprint (" - Max culture reached : ".. maxCulture , bDebugOutput)
		--for i, culture in ipairs ( civsCulture ) do
		--end
		cityCulturalOutput = false
		 
	elseif ( civsCulture ) then	
		Dprint (" - Civ culture table exist... " , bDebugOutput)
		local bOwnerHasCulture = false
		for i, culture in ipairs ( civsCulture ) do
			Dprint (" - culture.Value = ".. tostring(culture.Value) , bDebugOutput)
			Dprint (" - culture.ID = ".. tostring(culture.ID) , bDebugOutput)
			Dprint (" - ownerCultureID = ".. tostring(ownerCultureID) , bDebugOutput)
			if culture.Value > 0 and (culture.ID ~= SEPARATIST_TYPE) then -- separatist are converted, not created...
				local value = 0
				if (culture.ID == ownerCultureID) or bHasLibertyPolicy then
					if CULTURE_OUTPUT_USE_LOG then
						value = (population + cityCultureProduction) * math.log10(culture.Value * CULTURE_CITY_FACTOR) -- logarithmic progression
					else
						value = (population + cityCultureProduction) * math.sqrt(culture.Value * CULTURE_CITY_RATIO/100) -- sqrt progression
					end
					
					if (culture.ID == ownerCultureID) then
						bOwnerHasCulture = true -- if not set, initialize owner culture a few lines below.
					end
				else -- without the liberty policy, foreign CG does not benefit from city cultural output
					if CULTURE_OUTPUT_USE_LOG then
						value = population * math.log10(culture.Value * CULTURE_CITY_FACTOR)
					else
						value = population * math.sqrt(culture.Value * CULTURE_CITY_RATIO/100)
					end
				end
				value = value + CULTURE_CITY_BASE_PRODUCTION
				Dprint (" - output value for ".. culture.ID .." = " .. value, bDebugOutput)
				table.insert (cityCulturalOutput, { ID = culture.ID, Value = value } )
			end
		end
		
		if not bOwnerHasCulture then
			Dprint (" - ".. ownerCultureID .." has no culture, adding initial value", bDebugOutput)
			table.insert (cityCulturalOutput, { ID = ownerCultureID, Value = CULTURE_CITY_BASE_PRODUCTION })
		end

	else
		Dprint (" - no culture yet, returning initial value...", bDebugOutput)
		table.insert (cityCulturalOutput, { ID = ownerCultureID, Value = CULTURE_CITY_BASE_PRODUCTION })
	end
	
	Dprint ("------------------ ", bDebugOutput)
	return cityCulturalOutput
end

function UpdatePlotOwnership(cultureMap)

	local bDebugOutput = true

	Dprint ("------------------ ", bDebugOutput)
	Dprint ("Update plot ownership... ", bDebugOutput)

	-- get a dead civ table for checking
	-- I should have used PlayerID as cultureID, but that would have made this incompatible with my Dynamic History Mod...
	local deadCivTypes = {}
	for PlayerID = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
		local player = Players[PlayerID]
		if ( not player:IsAlive() ) then
			local bReportError = false					
			deadType = GetCivTypeFromPlayer (PlayerID, bReportError)
			if (deadType) then
				Dprint ("   - don't check for : " .. deadType .. ", is dead ", bDebugOutput)
				table.insert (deadCivTypes, deadType )
			end
		end
	end

	local lockedMap = LoadLockedMap()

	for key, plotCulture in pairs ( cultureMap ) do
		if lockedMap[key] and lockedMap[key] > 0 then -- plot is locked, don't try to change ownership...
			Dprint ("   - don't check for : (" .. key .. "), plot is locked", bDebugOutput)
		else
			local x,y = GetPlotXYFromKey (key)
			local plot = GetPlot(x,y)
			if not ( plot:IsCity() ) then
				local OwnerType = ""
				local OwnerValue = 0
				local OwnerID = nil

				for i, culture in ipairs ( plotCulture ) do
					if (culture.Value > OwnerValue) then
						local isDead = false
						for i, type in ipairs(deadCivTypes) do
							if (culture.ID == type) then
								isDead = true
							end
						end
						if not (isDead) then
							OwnerType = culture.ID
							OwnerValue = culture.Value
						end
					end 
				end
			
				if ( OwnerType ~= "" ) then 

					for row in GameInfo.Civilizations() do
						if row.Type == OwnerType then
							OwnerID = GetPlayerIDFromCivID (row.ID, false)
						end
					end
					if not OwnerID then
						for row in GameInfo.MinorCivilizations() do
							if row.Type == OwnerType then
								OwnerID = GetPlayerIDFromCivID (row.ID, true)
							end
						end
					end
					if OwnerID then
						-- if the civ with the most culture is different than the present owner and tile flipping is allowed and the culture value is enough
						-- or the tile was not owned and the culture value is enough then change tile owner...
						local bReportError = false
						local ancientOwner = GetCivTypeFromPlayer(plot:GetOwner(), bReportError) or "none"
						local ancientValue =  GetCivPlotCulture ( key, cultureMap, ancientOwner ) or 0
						local totalCulture = GetPlotTotalCulture ( key, cultureMap )
						local bAcquireNewPlot = ( ancientOwner == "none" and ALLOW_CIV4_SPREADING and OwnerValue > CULTURE_MINIMUM_OWNER )
						local bConvertPlot = ( ancientOwner ~= "none" and OwnerType ~=  ancientOwner and ALLOW_TILE_FLIPPING and OwnerValue > CULTURE_MINIMUM_OWNER and OwnerValue*CULTURE_FLIPPING_RATIO > ancientValue ) --OwnerValue > totalCulture*CULTURE_FLIPPING_RATIO)
						if	( bConvertPlot or bAcquireNewPlot )	then
							local bReportError = false
							local city = GetCloseCity ( OwnerID, plot )
							Dprint ("------------------ ", bDebugOutput)
							if	city ~= nil 
								and (Map.PlotDistance(city:GetX(), city:GetY(), plot:GetX(), plot:GetY()) <= CULTURE_FLIPPING_MAX_DISTANCE)
								and IsAdjacentToOwner(plot, OwnerID)
							then
								Dprint(" - ownership changed from " .. ancientOwner .. "(" .. ancientValue .. ") to " .. OwnerType .. "(".. OwnerValue .. ") at (" .. key .. ") => " .. city:GetName() , bDebugOutput)
								local player = Players[OwnerID]
								if ancientOwner ~= "none" then
									local ancientPlayer =  Players[plot:GetOwner()]
									player:AddNotification(NotificationTypes.NOTIFICATION_CITY_TILE, player:GetName() .. " has annexed a part of ".. ancientPlayer:GetName() .." territory with support of local culture group near ".. city:GetName(), player:GetName() .. "  has annexed ".. ancientPlayer:GetName() .." territory !", plot:GetX(), plot:GetY())
									ancientPlayer:AddNotification(NotificationTypes.NOTIFICATION_CITY_TILE, player:GetName() .. " has annexed a part of ".. ancientPlayer:GetName() .." territory with support of local culture group near ".. city:GetName(), player:GetName() .. "  has annexed ".. ancientPlayer:GetName() .." territory !", plot:GetX(), plot:GetY())
								else
									player:AddNotification(NotificationTypes.NOTIFICATION_CITY_TILE, player:GetName() .. " has acquired new territory with support of local culture group near ".. city:GetName(), player:GetName() .. "  has acquired new territory !", plot:GetX(), plot:GetY())
								end
								plot:SetOwner(OwnerID, city:GetID())
							else
						
								Dprint(" - WARNING : ownership can't be changed from " .. ancientOwner .. "(" .. ancientValue .. ") to " .. OwnerType .. "(".. OwnerValue .. ") at (" .. key .. ") : can't found close city or no adjacent plot of new owner found" , bDebugOutput)
							end	
						end
					else
						--Dprint(" - WARNING : ownership can't be changed to " ..  OwnerType .. " : can't found PlayerID" , bDebugOutput)
					end
				end
			end
		end
	end
	Dprint ("------------------ ", bDebugOutput)
end

-------------------------------------------------
-- Culture Map change/return functions 
-- use : cultureMap = function()
-------------------------------------------------
function ChangeCivPlotCulture ( plotKey, cultureMap, cultureID, value ) -- plotKey: returned by GetPlotKey(plot), cultureID: civ culture ID , value: change to apply
																		-- change a civ culture on a plot by value
																		-- todo : handle negative result
	local bDebugOutput = false

	local civsCulture = GetPlotCulture( plotKey, cultureMap )
	if ( civsCulture ) then
		for i, culture in ipairs ( civsCulture ) do
			if (culture.ID == cultureID) then
				Dprint (" - changing culture value of " .. cultureID .. " at " .. plotKey, bDebugOutput)
				cultureMap[plotKey][i].Value = math.floor(culture.Value + value)
				return cultureMap
			end
		end
		-- no entry for this civ, add it
		Dprint (" - first entry for " .. cultureID .. " at " .. plotKey, bDebugOutput)
		table.insert (cultureMap[plotKey], { ID = cultureID, Value = math.floor(value) } )
		return cultureMap
	else
		-- no entry for this plot, add it
		Dprint (" - plot first entry at (" .. plotKey .. "), first in are " .. cultureID, bDebugOutput)		
		cultureMap[plotKey] = { { ID = cultureID, Value = math.floor(value) } }
		return cultureMap
	end
end

function DecayCulture ( plotKey, cultureMap )

	local bDebugOutput = false
	local plot = GetPlotFromKey(plotKey)
	local ownerID = plot:GetOwner()
	Dprint ("-- Decaying culture at (" .. plotKey.. ")", bDebugOutput)
	local civsCulture = GetPlotCulture( plotKey, cultureMap )
	if ( civsCulture ) then
		for i, culture in ipairs ( civsCulture ) do
			local cultureDecay = (culture.Value * CULTURE_DECAY_RATE/100) + 1
			if (culture.Value - cultureDecay) < 0 then
				if ownerID ~= -1 and culture.ID == GetCivTypeFromPlayer(ownerID) then 
					Dprint (" - " .. cultureMap[plotKey][i].ID .. " is at minimal level of culture on own plot : ".. MINIMAL_CULTURE_ON_OWNED_PLOT , bDebugOutput)
					cultureMap[plotKey][i].Value = MINIMAL_CULTURE_ON_OWNED_PLOT
				else
					Dprint (" - removing " .. cultureMap[plotKey][i].ID , bDebugOutput)
					table.remove ( cultureMap[plotKey], i )
				end
			else
				cultureMap[plotKey][i].Value = math.floor(culture.Value - cultureDecay)
				Dprint (" - " .. cultureMap[plotKey][i].ID .. " lost ".. cultureDecay ..", new value = " .. cultureMap[plotKey][i].Value , bDebugOutput)
			end
		end
	end
	Dprint ("------------------ ", bDebugOutput)
	return cultureMap
end

function ConvertCulture ( plotKey, cultureMap )

	local bDebugOutput = true
	local plot = GetPlotFromKey(plotKey)
	local ownerID = plot:GetOwner()
	local player = Players[ownerID]
	Dprint ("-- Converting culture at (" .. plotKey.. ")", bDebugOutput)

	local convertRatio = CULTURE_CITY_CONVERSION_RATE

	-- Policies
	if USE_POLICIES then
		if player:HasPolicy(GameInfo.Policies["POLICY_TRADITION"].ID) then
			Dprint (" - Owner has adopted the tradition policy...", bDebugOutput)
			convertRatio = convertRatio + CULTURE_TRADITION_OPENER_CONVERTION_RATE
		end	
		if player:HasPolicy(GameInfo.Policies["POLICY_TRADITION_FINISHER"].ID) then
			Dprint (" - Owner has finished the tradition policy...", bDebugOutput)
			convertRatio = convertRatio + CULTURE_TRADITION_FINISHER_CONVERTION_RATE
		end
		if (not BRAVE_NEW_WORLD_ACTIVE) then
			if player:HasPolicy(GameInfo.Policies["POLICY_COMMUNISM"].ID) then
				Dprint (" - Owner has the communism policy...", bDebugOutput)
				convertRatio = convertRatio + CULTURE_COMMUNISM_CONVERTION_RATE
			end
			if player:HasPolicy(GameInfo.Policies["POLICY_DEMOCRACY"].ID) then
				Dprint (" - Owner has the democracy policy...", bDebugOutput)
				convertRatio = convertRatio + CULTURE_DEMOCRACY_CONVERTION_RATE
			end
			if player:HasPolicy(GameInfo.Policies["POLICY_POPULISM"].ID) then
				Dprint (" - Owner has the populism policy...", bDebugOutput)
				convertRatio = convertRatio + CULTURE_POPULISM_CONVERTION_RATE
			end
		else
			if player:HasPolicy(GameInfo.Policies["POLICY_SOCIALIST_REALISM"].ID) then
				Dprint (" - Owner has the socialist realism policy...", bDebugOutput)
				convertRatio = convertRatio + CULTURE_SOCIALIST_REALISM_CONVERTION_RATE
			end
			if player:HasPolicy(GameInfo.Policies["POLICY_MEDIA_CULTURE"].ID) then
				Dprint (" - Owner has the media culture policy...", bDebugOutput)
				convertRatio = convertRatio + CULTURE_MEDIA_CULTURE_CONVERTION_RATE
			end
			if player:HasPolicy(GameInfo.Policies["POLICY_NATIONALISM"].ID) then
				Dprint (" - Owner has thenationalism policy...", bDebugOutput)
				convertRatio = convertRatio + CULTURE_NATIONALISM_CONVERTION_RATE
			end
		end
	end

	-- Buildings
	local city = plot:GetPlotCity()
	if city then
		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_LIBRARY"].ID) then	
			Dprint (" - City has library...", bDebugOutput)
			convertRatio = convertRatio + CULTURE_LIBRARY_CONVERTION_RATE
		end
		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_UNIVERSITY"].ID) then	
			Dprint (" - City has university...", bDebugOutput)
			convertRatio = convertRatio + CULTURE_UNIVERSITY_CONVERTION_RATE
		end
		if city:IsHasBuilding(GameInfo.Buildings["BUILDING_PUBLIC_SCHOOL"].ID) then	
			Dprint (" - City has public school...", bDebugOutput)
			convertRatio = convertRatio + CULTURE_PUBLIC_SCHOOL_CONVERTION_RATE
		end
	end

	if convertRatio > 0 then
		local ownerType = GetCivTypeFromPlayer(ownerID)
		local civsCulture = GetPlotCulture( plotKey, cultureMap )
		if ( civsCulture ) then
			for i, culture in ipairs ( civsCulture ) do
				if (culture.ID ~= ownerType) and (culture.ID ~= SEPARATIST_TYPE) then -- Separatists are not affected by foreign culture groups convertion
					local toConvert = Round(culture.Value * convertRatio  /100)
					Dprint ("  - converting " .. toConvert .. " of " .. culture.ID .. " (".. culture.Value ..") to "..ownerType, bDebug)
					cultureMap = ChangeCivPlotCulture ( plotKey, cultureMap, culture.ID, - toConvert ) -- value near 0 are handled in decay function
					cultureMap = ChangeCivPlotCulture ( plotKey, cultureMap, ownerType, toConvert )
				end
			end
		end
	else
		Dprint (" - no convertion here", bDebugOutput)
	end
	Dprint ("------------------ ", bDebugOutput)
	return cultureMap
end

function DiffuseCulture ( plot, cultureMap, cultureID, value )

	local bDebugOutput = false

	local x = plot:GetX()
	local y = plot:GetY()

	-- debuging around Paris on YnAEMP giant map...
	if ( x > 11 and x < 15 and y > 63 and y < 67 ) then bDebugOutput = true; end

	if ( value > PlotCultureThreshold(plot) ) then
		Dprint ("Culture diffusion at ("..x..","..y.."), value = " .. value .. " point(s) from ".. cultureID, bDebugOutput) 
		Dprint ("------------------------------------------------------------------------------------------------------", bDebugOutput) 

		local direction_types = {
			DirectionTypes.DIRECTION_NORTHEAST,
			DirectionTypes.DIRECTION_EAST,
			DirectionTypes.DIRECTION_SOUTHEAST,
			DirectionTypes.DIRECTION_SOUTHWEST,
			DirectionTypes.DIRECTION_WEST,
			DirectionTypes.DIRECTION_NORTHWEST
			}

		for loop, direction in ipairs(direction_types) do
			local adjPlot = Map.PlotDirection( x, y, direction)
			if ( adjPlot ~= nil ) then

				local adjKey = GetPlotKey ( adjPlot )

				-- default values
				local bonus = 0
				local malus = 0
				local diffusion = CULTURE_DIFFUSION -- value diffusion per mil
				local baseThresholdFactor = CULTURE_THRESHOLD / 100
				local plotMax = value * (CULTURE_NORMAL_MAX / 100)
				Dprint ("Base numbers : ", bDebugOutput)
				Dprint ("   - diffusion = CULTURE_DIFFUSION = " .. tostring(CULTURE_DIFFUSION), bDebugOutput)
				Dprint ("   - baseThresholdFactor = CULTURE_THRESHOLD / 100 = " .. tostring(baseThresholdFactor), bDebugOutput)
				Dprint ("   - plotMax = value * (CULTURE_NORMAL_MAX / 100) = " .. tostring(plotMax), bDebugOutput)
				Dprint ("--------------------------", bDebugOutput)

				-- no difusion on lake, sea, ocean 
				if ( adjPlot:IsWater() ) then
					Dprint ("Culture as drown to " .. adjKey, bDebugOutput)
					diffusion = 0
					plotMax = 0
				else
					-- bonus : following road 
					if ( plot:IsRoute() and adjPlot:IsRoute() ) then -- to do : check for river/bridge, but need to call team, so player and all that, CPU intensive in this boucle ?
						Dprint ("Following road to " .. adjKey .. ", bonus = " .. tostring(bonus) .. " + CULTURE_FOLLOW_ROAD_BONUS, plotmax = " .. tostring(plotMax) .." * CULTURE_FOLLOW_ROAD_MAX / 100", bDebugOutput)
						bonus = bonus + CULTURE_FOLLOW_ROAD_BONUS
						plotMax = plotMax * (CULTURE_FOLLOW_ROAD_MAX / 100)
						Dprint ("   - new values : bonus = " .. tostring(bonus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end

					-- bonus : following a river 
					if plot:IsRiverConnection(direction) and not plot:IsRiverCrossing(direction) then
						Dprint ("Following river to " .. adjKey, bDebugOutput)
						bonus = bonus + CULTURE_FOLLOW_RIVER_BONUS
						plotMax = plotMax * (CULTURE_FOLLOW_RIVER_MAX / 100)
						Dprint ("   - new values : bonus = " .. tostring(bonus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end
				
					-- malus : crossing forest
					if (adjPlot:GetFeatureType() == FeatureTypes.FEATURE_FOREST) then
						Dprint ("Crossing FOREST to " .. adjKey, bDebugOutput)
						if value > CULTURE_CROSS_FOREST_THRESHOLD * baseThresholdFactor then
							malus = malus + CULTURE_CROSS_FOREST_PENALTY
							plotMax = plotMax * (CULTURE_CROSS_FOREST_MAX / 100)  
						else
							diffusion = 0
							plotMax = plotMax * (CULTURE_CROSS_FOREST_MAX / 100) 
						end
						Dprint ("   - new values : malus = " .. tostring(malus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end

					-- malus : crossing hills
					if (adjPlot:GetPlotType() == PlotTypes.PLOT_HILLS) then
						Dprint ("Crossing hills to " .. adjKey, bDebugOutput)
						if value > CULTURE_CROSS_HILLS_THRESHOLD * baseThresholdFactor then
							malus = malus + CULTURE_CROSS_HILLS_PENALTY
							plotMax = plotMax * (CULTURE_CROSS_HILLS_MAX / 100)  
						else
							diffusion = 0
							plotMax = plotMax * (CULTURE_CROSS_HILLS_MAX / 100) 
						end
						Dprint ("   - new values : malus = " .. tostring(malus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end

					-- malus : crossing a tundra
					if (adjPlot:GetTerrainType() == TerrainTypes.TERRAIN_TUNDRA) then
						Dprint ("Crossing tundra to " .. adjKey, bDebugOutput)
						if value > CULTURE_CROSS_TUNDRA_THRESHOLD * baseThresholdFactor then
							malus = malus +  CULTURE_CROSS_TUNDRA_PENALTY
							plotMax =  plotMax * (CULTURE_CROSS_TUNDRA_MAX / 100) 
						else
							diffusion = 0
							plotMax =  plotMax * (CULTURE_CROSS_TUNDRA_MAX / 100) 
						end
						Dprint ("   - new values : malus = " .. tostring(malus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end

					-- malus : crossing a river
					if plot:IsRiverCrossing(direction) then
						Dprint ("Crossing river to " .. adjKey, bDebugOutput)
						if value > CULTURE_CROSS_RIVER_THRESHOLD * baseThresholdFactor then
							malus = malus + CULTURE_CROSS_RIVER_PENALTY
							plotMax = plotMax * (CULTURE_CROSS_RIVER_MAX / 100) 
						else
							diffusion = 0
							plotMax = plotMax * (CULTURE_CROSS_RIVER_MAX / 100) 
						end
						Dprint ("   - new values : malus = " .. tostring(malus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end
				
					-- malus : crossing a desert
					if (adjPlot:GetTerrainType() == TerrainTypes.TERRAIN_DESERT) then
						Dprint ("Crossing desert to " .. adjKey, bDebugOutput)
						if value > CULTURE_CROSS_DESERT_THRESHOLD * baseThresholdFactor then
							malus = malus + CULTURE_CROSS_DESERT_PENALTY
							plotMax = plotMax * (CULTURE_CROSS_DESERT_MAX / 100)  
						else
							diffusion = 0
							plotMax = plotMax * (CULTURE_CROSS_DESERT_MAX / 100) 
						end
						Dprint ("   - new values : malus = " .. tostring(malus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end

					-- malus : crossing snow
					if (adjPlot:GetTerrainType() == TerrainTypes.TERRAIN_SNOW) then
						Dprint ("Crossing snow to " .. adjKey, bDebugOutput)
						if value > CULTURE_CROSS_SNOW_THRESHOLD * baseThresholdFactor then
							malus = malus + CULTURE_CROSS_SNOW_PENALTY
							plotMax = plotMax * (CULTURE_CROSS_SNOW_MAX / 100) 
						else
							diffusion = 0
							plotMax = plotMax * (CULTURE_CROSS_SNOW_MAX / 100) 
						end
						Dprint ("   - new values : malus = " .. tostring(malus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end
				
					-- malus : crossing jungle
					if (adjPlot:GetFeatureType() == FeatureTypes.FEATURE_JUNGLE) then
						Dprint ("Crossing jungle to " .. adjKey, bDebugOutput)
						if value > CULTURE_CROSS_JUNGLE_THRESHOLD * baseThresholdFactor then
							malus = malus + CULTURE_CROSS_JUNGLE_PENALTY
							plotMax = plotMax * (CULTURE_CROSS_JUNGLE_MAX / 100)  
						else
							diffusion = 0
							plotMax = plotMax * (CULTURE_CROSS_JUNGLE_MAX / 100) 
						end
						Dprint ("   - new values : malus = " .. tostring(malus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end

					-- malus : crossing a marsh
					if (adjPlot:GetFeatureType() == FeatureTypes.FEATURE_MARSH) then
						Dprint ("Crossing marsh to " .. adjKey, bDebugOutput)
						if value > CULTURE_CROSS_MARSH_THRESHOLD * baseThresholdFactor then
							malus = malus + CULTURE_CROSS_MARSH_PENALTY
							plotMax = plotMax * (CULTURE_CROSS_MARSH_MAX / 100) 
						else
							diffusion = 0
							plotMax = plotMax * (CULTURE_CROSS_MARSH_MAX / 100) 
						end
						Dprint ("   - new values : malus = " .. tostring(malus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end
				
					-- malus : escalading mountain 
					if adjPlot:IsMountain() then
						Dprint ("Escalading mountain to " .. adjKey, bDebugOutput)
						if value > CULTURE_MOUNTAIN_THRESHOLD * baseThresholdFactor then
							malus = malus + CULTURE_MOUNTAIN_PENALTY
							plotMax = plotMax * (CULTURE_MOUNTAIN_MAX / 100) 
						else
							diffusion = 0
							plotMax = plotMax * (CULTURE_MOUNTAIN_MAX / 100) 
						end
						Dprint ("   - new values : malus = " .. tostring(malus) .. ",  plotmax " .. tostring(plotMax), bDebugOutput)
					end				
 				end
				
				plotMax =  math.min( plotMax, value*(CULTURE_MAX_PERCENT / 100) )

				Dprint ("Total bonus = " .. bonus .. ", total malus = " .. malus, bDebugOutput)
				Dprint ("Plotmax = math.min( plotMax, value*(CULTURE_MAX_PERCENT / 100) ) = " .. plotMax, bDebugOutput)
				Dprint ("Diffused culture calculation : diffusedCulture = value * ( (diffusion + (diffusion*bonus/100)) / (1000 + (1000*malus/100) ) )", bDebugOutput)

				diffusedCulture = value * ( (diffusion + (diffusion*bonus/100)) / (1000 + (1000*malus/100) ) )

				Dprint ("                               diffusedCulture = " .. tostring(value) .. "* ( (" .. tostring(diffusion) .." + (" .. tostring(diffusion) .."*".. tostring(bonus) .."/100)) / (1000 + (1000*".. tostring(malus) .."/100) ) )", bDebugOutput)
				Dprint ("                               diffusedCulture = " .. tostring(diffusedCulture), bDebugOutput)

				-- Dont diffuse more than plotmax !
				local prevCulture =	GetCivPlotCulture ( adjKey, cultureMap, cultureID ) or 0
				local nextCulture = math.min( plotMax, prevCulture + diffusedCulture)
				local calculatedDiffusedCulture = diffusedCulture
				diffusedCulture = nextCulture - prevCulture
								
				Dprint ("prevCulture = " .. prevCulture, bDebugOutput)
				Dprint ("nextCulture = math.min( plotMax, prevCulture + diffusedCulture) = " .. nextCulture, bDebugOutput)
				Dprint ("FINAL diffusedCulture = nextCulture - prevCulture = " .. diffusedCulture, bDebugOutput)

				if diffusedCulture > 0 then
					cultureMap = ChangeCivPlotCulture ( adjKey, cultureMap, cultureID, diffusedCulture )
					Dprint (adjKey .. " received " .. diffusedCulture .. " culture, new =" .. nextCulture .. ", (previous =" .. prevCulture .. ", max = " .. plotMax .. ")", bDebugOutput) 
				else
					Dprint (adjKey .. " didn't received any of the " .. calculatedDiffusedCulture .. " culture points, already at max value from diffusing plot... (previous =" .. prevCulture .. ", max = " .. plotMax .. ")", bDebugOutput) 
				end
			end
			Dprint ("--------------------------", bDebugOutput)
		end		
		Dprint ("------------------------------------------------------------------------------------------------------", bDebugOutput) 
	end
	return cultureMap 
end

-------------------------------------------------
-- Main Culture functions
-- Those functions load and save the culture map, don't mix them !
-------------------------------------------------

function CityCultureOnCapture (hexPos, PlayerID, cityID, newPlayerID)

	local pCityPlot = Map.GetPlot( ToGridFromHex( hexPos.x, hexPos.y ) )
	local cityPlotKey = GetPlotKey(pCityPlot)
	local cultureMap = MapModData.AH.CultureMap
	local bDebugOutput = true
	local pCity = pCityPlot:GetPlotCity()
	Dprint ("-- Change city owner and culture after city capture at (" .. cityPlotKey.. ")", bDebugOutput)

	for i = 0, pCity:GetNumCityPlots() - 1, 1 do
		local plot = pCity:GetCityIndexPlot( i )

		-- this loop does not return only the tiles owned by a city as I thought, but all tiles in this city radius
		-- I have not found a way to get only those tiles, so there's another imperfect check here, as it is 
		-- there is more culture removed than it should when city radius (owned by the conqueror) overlap
		-- well let's call it collateral damage... 

		if (plot ~= nil and (plot:GetOwner() == pCity:GetOwner()) ) then
			local plotKey = GetPlotKey(plot)
			local civsCulture = GetPlotCulture( plotKey, cultureMap )
			if ( civsCulture ) then
				local totalCultureLost = 0
				for i, culture in ipairs ( civsCulture ) do
					-- culture lost for all civs
					local cultureLost = (culture.Value * CULTURE_LOST_CONQUEST/100)
					if (culture.Value - cultureLost) < 0 then
						Dprint (" - removing " .. cultureMap[plotKey][i].ID .. " culture at (" .. plotKey.. ")", bDebugOutput)
						table.remove ( cultureMap[plotKey], i ) 
					else
						cultureMap[plotKey][i].Value = math.floor(culture.Value - cultureLost)
						Dprint (" - " .. cultureMap[plotKey][i].ID .. " lost ".. cultureLost .." culture at (" .. plotKey.. "), new value = " .. cultureMap[plotKey][i].Value , bDebugOutput)
					end
					totalCultureLost = totalCultureLost + cultureLost
				end
				-- culture gain for capturing civ
				local cultureGain = totalCultureLost * CULTURE_GAIN_CONQUEST / 100
				local conqueror = GetCivTypeFromPlayer(newPlayerID)
				cultureMap = ChangeCivPlotCulture ( plotKey, cultureMap, conqueror, cultureGain )
				Dprint (" - " .. conqueror .. " gain ".. cultureGain .." culture at (" .. plotKey.. "), new value = " .. GetCivPlotCulture ( plotKey, cultureMap, conqueror ) , bDebugOutput)
			end
		end
	end
	Dprint ("------------------ ", bDebugOutput)
	MapModData.AH.CultureMap = cultureMap
end

function UpdateCultureMap()

	-- chrono
	local t_diff1
	local t_diff2
	local t_difft = 0

	local t1 = os.clock()

	print ("Update culture Map") -- Not using Dprint here: I want update performance for this function to be always shown in Lua.log...
	print ("------------------") -- (but details are shown only if DEBUG_CULTURE = true)

	local cultureMap = MapModData.AH.CultureMap
	local lockedMap = LoadLockedMap()
	local bDebugOutput = false

	local t2 = os.clock()
	-- loop the map plots to add culture from builders ( cities, tribes, great artists) and apply decay
	for iPlotLoop = 0, Map.GetNumPlots()-1, 1 do
		local plot = Map.GetPlotByIndex(iPlotLoop)

		-- no culture on water, don't waste time
		if not ( plot:IsWater() ) then

			local plotKey = GetPlotKey ( plot )
			--local cultureID
			local plotCulture = GetPlotCulture(plotKey, cultureMap)

			-- apply decay and diffuse culture
			if ( plotCulture ) then
				cultureMap = DecayCulture (plotKey, cultureMap)
				t_diff1 = os.clock()
				for i, culture in ipairs ( plotCulture ) do
					if culture.ID ~= SEPARATIST_TYPE then -- separatist culture does not diffuse
						cultureMap = DiffuseCulture ( plot, cultureMap, culture.ID, culture.Value )
					end
				end
				t_diff2 = os.clock()
				t_difft = t_difft + (t_diff2-t_diff1)
			end

			-- add culture in city
			if plot:IsCity() then
				local city = plot:GetPlotCity() 
				-- Get culture produced
				local cultureTab = GetCityCulturalOutput ( city, plotKey, cultureMap )
				if ( cultureTab ) then
					for i, culturalOutput in ipairs ( cultureTab ) do
						cultureMap = ChangeCivPlotCulture ( plotKey, cultureMap, culturalOutput.ID, culturalOutput.Value )
						Dprint(culturalOutput.Value .. " - city cultural points generated for " .. culturalOutput.ID .. " at (" .. plotKey .. ")" , bDebugOutput)
						Dprint ("------------------ ", bDebugOutput)
					end
				end
				-- Convert culture (Policies effect)
				cultureMap = ConvertCulture ( plotKey, cultureMap ) -- save time, convert only in cities
			end	
		
			-- while we're here, remove dead people ownership
			if ( ALLOW_CIV4_SPREADING ) then
				local PlayerID = plot:GetOwner()
				if PlayerID ~= -1 then
					if ( not Players[PlayerID]:IsAlive() ) then
						Dprint ("Removing dead ownership at " .. plotKey , bDebugOutput)
						plot:SetOwner(-1, -1)
					end
				end
			end	
		end		
	end   
	local t3 = os.clock()

	-- Update plot ownership
	if ( ALLOW_CIV4_SPREADING or ALLOW_TILE_FLIPPING) then
		UpdatePlotOwnership(cultureMap)
	end

	local t4 = os.clock()
	
	-- Update locked map
	if ( ALLOW_CULTURE_CONQUEST ) then
		for key, counter in pairs (lockedMap) do
			if counter and counter > 0 then
				lockedMap[key] = counter - 1
			end
		end
	end

	local t5 = os.clock()

	MapModData.AH.CultureMap = cultureMap
	SaveLockedMap( lockedMap )

	local t6 = os.clock()

	print("Updating Culture execution time : ") 
	print("Load tables      = " .. t2 - t1) 
	print("Add Culture      = " .. t3 - t2) 
	print(" (inc. diffusion = " .. t_difft .." )")
	print("Update ownership = " .. t4 - t3) 
	print("Update LockedMap = " .. t5 - t4) 
	print("Save tables      = " .. t6 - t5) 
	print("Total time       = " .. t6 - t1) 
	print("-------------------------------------")
end

function OnCultureChangePlot(iHexX, iHexY, PlayerID, bUnknown)

	if PlayerID ~= -1 then
		local bDebugOutput = false
		local x, y = ToGridFromHex( iHexX, iHexY )
		local plotKey = x..","..y
		local plot = GetPlotFromKey(plotKey)

		if plot and not plot:IsWater() then
			Dprint ("Update culture on plot ("..plotKey..")", bDebugOutput)
			Dprint ("------------------", bDebugOutput)

			local cultureMap = MapModData.AH.CultureMap
			local plotCulture = GetPlotCulture(plotKey, cultureMap)
			local cultureID = GetCivTypeFromPlayer(PlayerID)
			if (not GetCivPlotCulture ( plotKey, cultureMap, cultureID ) ) and MINIMAL_CULTURE_ON_OWNED_PLOT > 0 then
				cultureMap = ChangeCivPlotCulture ( plotKey, cultureMap, cultureID, MINIMAL_CULTURE_ON_OWNED_PLOT )
				MapModData.AH.CultureMap = cultureMap
			end
		end
	end
end


-------------------------------------------------
-- Tested functions
-------------------------------------------------

function GetCultureValueString(value)
	if value < 50 then
		return "feeble"
	end
	if value < 200 then
		return "low"
	end
	if value < 500 then
		return "sparse"
	end
	if value < 2000 then
		return "average"
	end
	if value < 5000 then
		return "established"
	end
	return "entrenched"
end

function UnitCaptureTile(PlayerID, UnitID, x, y)

	local bDebug = false

	if not ALLOW_CULTURE_CONQUEST then
		return
	end

	local plot = Map.GetPlot(x,y)
	if (plot == nil) then
		return
	end
	
	if ( plot:IsCity() or plot:IsWater() ) then
		return
	end

	-- check here if an unit can't capture a tile and return
	local player = Players[ PlayerID ]
	local unit = player:GetUnitByID(UnitID)
	if not ( unit:IsCombatUnit() ) then
		return
	end
	
	local lockedMap = LoadLockedMap()

	local plotKey = GetPlotKey ( plot )
	local ownerID = plot:GetOwner()

	-- If the unit is moving on another player territory...
	if (PlayerID ~= ownerID and ownerID ~= -1) then
		Dprint("-------------------------------------", bDebug)
		Dprint("Unit moving on tile ("..x..","..y..") is in another civ (id="..ownerID..") territory", bDebug)

		local player2 = Players[ ownerID ]		
		local team = Teams[ player:GetTeam() ]
		local team2 = Teams[ player2:GetTeam() ]

		-- If we are at war with the other player :
		if team:IsAtWar( player2:GetTeam() ) then
			Dprint(" - Unit owner (id="..PlayerID..") and tile owner (id="..ownerID..") are at war", bDebug)

			
			local unitCultureID = GetCivTypeFromPlayer(PlayerID)
			local ownerCultureID = GetCivTypeFromPlayer(ownerID)

			local cultureMap = MapModData.AH.CultureMap

			local unitCultureValue = GetCivPlotCulture ( plotKey, cultureMap, unitCultureID ) or 0
			local ownerCultureValue = GetCivPlotCulture ( plotKey, cultureMap, ownerCultureID ) or 0
			
			-- test for capture
			if	(unitCultureValue > ownerCultureValue or CULTURE_CONQUEST_EVEN_LOWER)
				and	(unitCultureValue >= MINIMAL_CULTURE_FOR_CONQUEST or CULTURE_CONQUEST_EVEN_NONE)
				then

				Dprint(" - Unit is capturing territory...", bDebug)
				--local capitalCity = player:GetCapitalCity()
				--plot:SetOwner(PlayerID, capitalCity:GetID() )				
				local closeCity = GetCloseCity ( PlayerID, plot )					
				if closeCity and (Map.PlotDistance(closeCity:GetX(), closeCity:GetY(), plot:GetX(), plot:GetY()) <= CULTURE_FLIPPING_MAX_DISTANCE) then
					plot:SetOwner(PlayerID, closeCity:GetID() )

					lockedMap[plotKey] = LOCKED_TURN_ON_CONQUEST

				else
					Dprint(" - But is too far away from own cities to hold it !", bDebug)
				end

			--[[
			-- capturing current owner territory			
			elseif ( ownerID == firstOwner) then
				Dprint(" - Unit is capturing territory", bDebug)
				--local capitalCity = player:GetCapitalCity()
				--plot:SetOwner(PlayerID, capitalCity:GetID() )
				
				local closeCity = GetCloseCity ( PlayerID, plot )					
				if closeCity then
					plot:SetOwner(PlayerID, closeCity:GetID() )
				else
					plot:SetOwner(PlayerID, -1 )
				end
			else
				-- don't free old owner territory if we're at war !
				local player3 = Players[ firstOwner ]				
				if team:IsAtWar( player3:GetTeam() ) then
					Dprint(" - Unit is capturing territory, old owner civ (id=".. firstOwner ..") is also at war with unit owner", bDebug)
					--local capitalCity = player:GetCapitalCity()
					--plot:SetOwner(PlayerID, capitalCity:GetID() )	
					plot:SetOwner(PlayerID, -1 )			
				elseif ( not player3:IsAlive() ) then
					Dprint(" - Unit is capturing territory, old owner civ (id=".. firstOwner ..") is dead", bDebug)
					--local capitalCity = player:GetCapitalCity()
					--plot:SetOwner(PlayerID, capitalCity:GetID() )	
					local closeCity = GetCloseCity ( PlayerID, plot )
					if closeCity then
						plot:SetOwner(PlayerID, closeCity:GetID() )
					else
						plot:SetOwner(PlayerID, -1 )
					end
				else
				-- liberating old owner territory
					Dprint(" - Unit is liberating this territory belonging to another civ (id=".. firstOwner ..")", bDebug)

					local closeCity = GetCloseCity ( firstOwner, plot )					
					if closeCity then
						plot:SetOwner(firstOwner, closeCity:GetID() )
					else
						plot:SetOwner(firstOwner, -1 )
					end					
					if player3:IsMinorCiv() and not player:IsMinorCiv() then
						player3:ChangeMinorCivFriendshipWithMajor( PlayerID, LIBERATE_MINOR_TERRITORY_BONUS ) -- give diplo bonus for liberating minor territory
					end
				end --]]
			end
		end
	end
	
	SaveLockedMap( lockedMap )

end
--GameEvents.UnitSetXY.Add( UnitCaptureTile )


function GetRelationValueString(value)
	if not value then
		Dprint("ERROR: value is nil for GetRelationValueString(value)")
		return nil
	end
	if value < THRESHOLD_EXASPERATED then
		return "[COLOR_NEGATIVE_TEXT]exasperated[ENDCOLOR]"
	end
	if value < THRESHOLD_WOEFUL then
		return "[COLOR_NEGATIVE_TEXT]woeful[ENDCOLOR]"
	end
	if value < THRESHOLD_UNHAPPY then
		return "unhappy"
	end
	if value < THRESHOLD_CONTENT then
		return "content"
	end
	if value < THRESHOLD_HAPPY then
		return "happy"
	end
	if value < THRESHOLD_JOYFUL then
		return "[COLOR_POSITIVE_TEXT]joyful[ENDCOLOR]"
	end
	return "[COLOR_POSITIVE_TEXT]enthusiastic[ENDCOLOR]"
end

function GetCultureTypeAdj(cultureID)
	local civAdj = ""
	for row in GameInfo.Civilizations() do
		if row.Type == cultureID then
			civAdj = Locale.ConvertTextKey (row.Adjective)
		end
	end
	if civAdj == "" then
		for row in GameInfo.MinorCivilizations() do
			if row.Type == cultureID then
				civAdj = Locale.ConvertTextKey (row.Adjective)
			end
		end
	end

	if cultureID == "SEPARATIST" then
		civAdj = "Separatist"
	end
	return civAdj
end

function InitializeGameOption()
	if not OVERRIDE_OPTION_MENU then
		-- initialize rules based on selected options
		if(PreGame.GetGameOption("GAMEOPTION_TILE_FLIPPING") ~= nil) then
			if (PreGame.GetGameOption("GAMEOPTION_TILE_FLIPPING") > 0) then
				ALLOW_TILE_FLIPPING = true
			else
				ALLOW_TILE_FLIPPING = false
			end
		end
		if(PreGame.GetGameOption("GAMEOPTION_CIV4_SPREADING") ~= nil) then			
			if (PreGame.GetGameOption("GAMEOPTION_CIV4_SPREADING") > 0) then
				ALLOW_CIV4_SPREADING = true
			else
				ALLOW_CIV4_SPREADING = false
			end
		end
		if(PreGame.GetGameOption("GAMEOPTION_TILE_CONQUEST") ~= nil) then
			if (PreGame.GetGameOption("GAMEOPTION_TILE_CONQUEST") > 0) then
				ALLOW_CULTURE_CONQUEST = true
			else
				ALLOW_CULTURE_CONQUEST = false
			end
		end
		if(PreGame.GetGameOption("GAMEOPTION_DYNHIST_USE_POLICIES") ~= nil) then
			if (PreGame.GetGameOption("GAMEOPTION_DYNHIST_USE_POLICIES") > 0) then
				USE_POLICIES = true
			else
				USE_POLICIES = false
			end
		end
	end
end

function UpdateCultureOnEmigration(fromCity, toCity)

	local bDebugOutput = true

	Dprint("------------------------------------------------------------------",bDebugOutput)
	Dprint("Updating culture on emigration from " .. tostring(fromCity:GetName()) .. " to " .. tostring(toCity:GetName()),bDebugOutput)
	Dprint("------------------------------------------------------------------",bDebugOutput)

	local cultureMap = MapModData.AH.CultureMap
	
	local fromPopulation = fromCity:GetPopulation()
	local fromPlotKey = GetPlotKey(fromCity:Plot())
	local fromCulture = GetPlotCulture( fromPlotKey, cultureMap )
	local fromTotalCulture = GetPlotTotalCulture( fromPlotKey, cultureMap )
	
	Dprint("- fromPopulation = " .. fromPopulation,bDebugOutput)

	local migrantCulture = {}
	for i, culture in ipairs ( fromCulture ) do
		migrantCulture[i].Value = Round(culture.Value / fromPopulation)
		migrantCulture[i].ID = culture.ID
		cultureMap[plotKey][i].Value = culture.Value - migrantCulture[i].Value
		Dprint (" - " .. cultureMap[plotKey][i].ID .. " lost ".. cultureLost .." culture at (" .. plotKey.. "), new value = " .. cultureMap[plotKey][i].Value , bDebugOutput)
	end

	local destinationPopulation = toCity:GetPopulation()
	local destinationPlotKey = GetPlotKey(toCity:Plot())
	local destinationCulture = GetPlotCulture( destinationPlotKey, cultureMap )
	local destinationTotalCulture = GetPlotTotalCulture( destinationPlotKey, cultureMap )

	Dprint("- destinationPopulation = " .. destinationPopulation,bDebugOutput)

end
--EmigrationCompleted.Add(UpdateCultureOnEmigration)
--LuaEvents.OnEmigration.Add(UpdateCultureOnEmigration)

function SetDiffusionFactorFromGameSetting()
	
	local bDebug = true

	Dprint("------------------------------------------------------------------",bDebug)
	Dprint("Set culture diffusion rate from game setings... ",bDebug)
	Dprint("------------------------------------------------------------------",bDebug)


	local factor = 1
	
	-- from game speed

	local numTurns = 0
	local standardTurns = 500
	local gameSpeedType = GameInfo.GameSpeeds[ PreGame.GetGameSpeed() ].Type

	for row in DB.Query([[SELECT TurnsPerIncrement FROM GameSpeed_Turns WHERE GameSpeedType = ? ORDER BY rowid ASC]], gameSpeedType) do
		numTurns = numTurns + row.TurnsPerIncrement
	end
	
	factor = factor * (standardTurns / numTurns)

	Dprint("- Game turns from speed = " .. numTurns,bDebug)
	Dprint("  - Factor from speed = " .. (standardTurns / numTurns),bDebug)

	-- from map size
	local iW, iH = Map.GetGridSize()
	local size = iW * iH	
	local standardSize = 80 * 52
	
	factor = factor * (size / standardSize)
	
	Dprint("- Map size = " .. size,bDebug)
	Dprint("  - Factor from map size = " .. (size / standardSize),bDebug)	
	
	Dprint("- Default Culture Diffusion rate  = " .. tonumber(CULTURE_DIFFUSION/10) .. "%",bDebug)
	Dprint("  - Final factor  = " .. factor,bDebug)

	CULTURE_DIFFUSION = Round(CULTURE_DIFFUSION * factor)

	Dprint("- NEW CULTURE DIFFUSION RATE  = " .. tonumber(CULTURE_DIFFUSION/10) .. "%",bDebug)
	
end

function IsAdjacentToOwner(plot, OwnerID)
	local plotList = GetAdjacentPlots(plot)
	local adjacentToOwner = false
	for i, adjacentPlot in pairs(plotList) do			
		if adjacentPlot:GetOwner() == OwnerID then
			adjacentToOwner = true
		end
	end
	return adjacentToOwner
end