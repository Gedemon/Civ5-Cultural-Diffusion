-- Debug
-- Author: Gedemon
-- DateCreated: 1/30/2011 8:03:25 PM
--------------------------------------------------------------

print("Loading Culture Debug Functions...")
print("-------------------------------------")

-- Output debug text
function Dprint ( str, bOutput )
  if bOutput == nil then
    bOutput = true
  end
  if ( DEBUG_CULTURE and bOutput ) then
    print (str)
  end
end

-- Display Culture Map
function DisplayCultureMap()
	local cultureMap = MapModData.AH.CultureMap
	Dprint("Culture map :")
	Dprint("-------------------------------------")
	for key, plotCulture in pairs (cultureMap) do
		for i, civCulture in ipairs (plotCulture) do
			Dprint(" (" .. key .. ") :" .. civCulture.ID .. " civilization has " .. civCulture.Value .. " culture") 
		end
	end
	Dprint("-------------------------------------")
end

--[[
include( "FLuaVector" )
function ShowCityPlots(hexX, hexY)
	local mouseOverPlot = Map.GetPlot( hexX, hexY );
	if (mouseOverPlot ~= nil and mouseOverPlot:IsCity() ) then
		local mouseOverCity = mouseOverPlot:GetPlotCity()
		for i = 0, mouseOverCity:GetNumCityPlots() - 1, 1 do
			local plot = mouseOverCity:GetCityIndexPlot( i )
			Events.SerialEventHexHighlight( ToHexFromGrid( Vector2( plot:GetX(), plot:GetY() ) ), true, Vector4( 1.0, 1.0, 1.0, 1 ) )
			local city = plot:GetPlotCity()
			print (city)
		end
	else
		Events.ClearHexHighlights()
	end
end
Events.SerialEventMouseOverHex.Add( ShowCityPlots )
--]]