-- Culture Defines for Dynamic History
-- Author: Gedemon
-- DateCreated: 3/11/2012 1:10:36 PM
--------------------------------------------------------------

print("Loading Culture Defines for Dynamic History...")
print("-------------------------------------")


-- Save/Load
PLAYER_SAVE_SLOT = 0

-- General settings
OVERRIDE_OPTION_MENU = false -- if true, the values from the option panel will be overriden by the values of the define file. Used to debug savegame only.
DEBUG_CULTURE = true -- if true will output debug text in the lua.log / firetuner console.
DEBUG_SHOW_PLOT_CULTURE = false -- if true will show the culture value and coordinate of a plot
DEBUG_PERFORMANCE = false
ALLOW_CIV4_SPREADING = false -- if true, allow civilizations to gain unowned tiles via culture
ALLOW_TILE_FLIPPING = true -- if true, allow flipping of tiles from one civ to another (check CULTURE_FLIPPING_RATIO)

--------------------------------------------------------------
-- Culture Map
--------------------------------------------------------------
-- CultureMap ["x,y"] = { { ID = CIVILIZATION_TYPE, Value = culturesum }, ... }
-- x,y converted to a string "x,y" used as a key
--
-- Initial culture value in cities
CULTURE_CITY_BASE_PRODUCTION = 10 -- default = 10
-- Base culture production factor in cities
CULTURE_CITY_FACTOR = 10000 -- 10 use logarithmic progression
------------------------------------------------------------------------------------------------------------------------
--
CULTURE_CITY_CAPED_FACTOR = 2000 -- maxCulture on a city plot = (population + cityCultureProduction) * CULTURE_CITY_CAPED_FACTOR
CULTURE_CITY_CONVERSION_RATE = 10 -- percent, not used atm
CULTURE_LOST_CONQUEST = 50 -- percentage of culture lost by each civs on a city plot on conquest
CULTURE_GAIN_CONQUEST = 60 -- percentage of the total lost culture gained by the conqueror
------------------------------------------------------------------------------------------------------------------------
--
-- Minimum culture value before a plot can have ownership, ratio applied to change ownership and max distance from city
CULTURE_MINIMUM_OWNER = 300 -- higher value means more stability (less tile flipping)
CULTURE_FLIPPING_RATIO = 0.65 -- 0.5 means a civ culture must be at least at 50% of the total plot culture to get it.
CULTURE_FLIPPING_RATIO_FEEBLE = 0.65 -- not implemented, todo : add a ratio by total value ?
CULTURE_FLIPPING_MAX_DISTANCE = 6 -- max distance from a civ city a plot may flip
MINIMAL_CULTURE_ON_OWNED_PLOT = 1 -- owned plot will have at least that culture value of the owner
------------------------------------------------------------------------------------------------------------------------
--
-- Minimum culture value before a plot start diffusing to normal adjacents plots
CULTURE_THRESHOLD = 100 -- higher value means slower diffusion
------------------------------------------------------------------------------------------------------------------------
--
-- Minimum culture value before a plot start diffusing to special adjacents plots
CULTURE_MOUNTAIN_THRESHOLD = 750
CULTURE_CROSS_MARSH_THRESHOLD = 500
CULTURE_CROSS_SNOW_THRESHOLD = 400
CULTURE_CROSS_DESERT_THRESHOLD = 300
CULTURE_CROSS_TUNDRA_THRESHOLD = 250
CULTURE_CROSS_RIVER_THRESHOLD = 200
------------------------------------------------------------------------------------------------------------------------
--
-- Rate of diffusion
CULTURE_DIFFUSION = 55 --	percentage*10 : if CULTURE_DIFFUSION = 1000 then diffusion is 100% of diffusing plot value.
--							Defaut is 55 = 5,5% diffusion
------------------------------------------------------------------------------------------------------------------------
--
-- Rate of decay
CULTURE_DECAY_RATE = 5 -- percentage of culture lost on a plot each turn
------------------------------------------------------------------------------------------------------------------------
--
-- Maximum value of adjacent plot in percent of diffusing plot value
-- Those are factored, for example when following a road and a river from a plot with a culture value of 250
-- Max diffused culture = 250 * (CULTURE_NORMAL_MAX/100) * (CULTURE_FOLLOW_RIVER_MAX/100) * (CULTURE_FOLLOW_ROAD_MAX/100)
-- so bonus tile must be > 100 to act as bonus should, the total will always be capped by 250 * (CULTURE_MAX_PERCENT/100)
--
CULTURE_MAX_PERCENT = 75 -- percent
--
CULTURE_NORMAL_MAX = 40 -- base percentage, always used
--
CULTURE_FOLLOW_RIVER_MAX = 180
CULTURE_FOLLOW_ROAD_MAX = 250
--
CULTURE_CROSS_TUNDRA_MAX = 40
CULTURE_CROSS_RIVER_MAX = 30
CULTURE_CROSS_DESERT_MAX = 30
CULTURE_CROSS_SNOW_MAX = 25
CULTURE_CROSS_MARSH_MAX = 20
CULTURE_MOUNTAIN_MAX = 10
------------------------------------------------------------------------------------------------------------------------
--
-- Rate of diffusion modifiers
-- Malus, 100 = halve the diffusion rate
CULTURE_CROSS_TUNDRA_PENALTY = 25 -- percentage
CULTURE_CROSS_RIVER_PENALTY = 50 -- percentage
CULTURE_CROSS_DESERT_PENALTY = 55 -- percentage
CULTURE_CROSS_SNOW_PENALTY = 55 -- percentage
CULTURE_CROSS_MARSH_PENALTY = 65 -- percentage
CULTURE_MOUNTAIN_PENALTY = 75 -- percentage
--
-- Bonus, 100 = double the diffusion rate
CULTURE_FOLLOW_RIVER_BONUS = 65 -- percentage
CULTURE_FOLLOW_ROAD_BONUS = 100 -- percentage

------------------------------------------------------------------------------------------------------------------------
--
-- Culture on tile conquest (military unit entering a plot belonging to a civ it's at war with)
--
ALLOW_CULTURE_CONQUEST = false -- allow the use of military culture conquest
MINIMAL_CULTURE_FOR_CONQUEST = 150 -- minimum value of the unit culture on the plot to allow flipping. Overriden by CULTURE_CONQUEST_EVEN_NONE = true
CULTURE_CONQUEST_EVEN_LOWER = false -- conquest tile even without having more culture on it than it's current owner
CULTURE_CONQUEST_EVEN_NONE = false -- conquest tile even without having any culture on it. CULTURE_CONQUEST_EVEN_LOWER must be set to true if you want to activate this one
LOCKED_TURN_ON_CONQUEST = 5 -- number of turns the tile is locked when conquered

------------------------------------------------------------------------------------------------------------------------
--
-- Revolution Mod
--
if bRevolution then
	THRESHOLD_JOYFUL		= GameDefines.THRESHOLD_JOYFUL
	THRESHOLD_HAPPY			= GameDefines.THRESHOLD_HAPPY
	THRESHOLD_CONTENT		= GameDefines.THRESHOLD_CONTENT
	THRESHOLD_UNHAPPY		= GameDefines.THRESHOLD_UNHAPPY
	THRESHOLD_WOEFUL		= GameDefines.THRESHOLD_WOEFUL
	THRESHOLD_EXASPERATED	= GameDefines.THRESHOLD_EXASPERATED
end
