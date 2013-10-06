-- Culture Defines
-- Author: Gedemon
-- DateCreated: 1/29/2011 4:22:38 PM
--------------------------------------------------------------

print("Loading Culture Defines...")
print("-------------------------------------")


GODS_AND_KINGS_ACTIVE = ContentManager.IsActive("0E3751A1-F840-4e1b-9706-519BF484E59D", ContentType.GAMEPLAY);
BRAVE_NEW_WORLD_ACTIVE = ContentManager.IsActive("6DA07636-4123-4018-B643-6575B4EC336B", ContentType.GAMEPLAY);

-- Save/Load
PLAYER_SAVE_SLOT = 0 -- Player slot used by saveutils
DEFAULT_SAVE_KEY = "0,1" -- "0,0" used by HSD -- "1,1" used by Revolution
REVOLUTION_SAVE_KEY = "1,1" -- Things are getting complicated here, time to use our own save tool ?
TABLE_SAVED = false

-- Debug settings
OVERRIDE_OPTION_MENU = false -- if true, the values from the option panel will be overriden by the values of the define file. Used to debug savegame only.
DEBUG_CULTURE = false -- if true will output debug text in the lua.log / firetuner console.
DEBUG_SHOW_PLOT_CULTURE = false -- if true will show the culture value and coordinate of a plot
DEBUG_PERFORMANCE = false -- if true will outpout time taken by some functions to the lua.log / firetuner console.

-- General settings
ALLOW_CIV4_SPREADING = true--false -- if true, allow civilizations to gain unowned tiles via culture
ALLOW_TILE_FLIPPING = true -- if true, allow flipping of tiles from one civ to another (check CULTURE_FLIPPING_RATIO)
USE_POLICIES = true  -- if true, policies will affect culture diffusion
CULTURE_MAX_LINE_UI = 5  -- Maximum culture entries shown on tooltip

BARBARIAN_PLAYER = GameDefines.MAX_CIV_PLAYERS

--------------------------------------------------------------
-- Shared tables
--------------------------------------------------------------

MapModData.AH = MapModData.AH or {}
MapModData.AH.CultureRelations = MapModData.AH.CultureRelations or {}
MapModData.AH.CultureMap = MapModData.AH.CultureMap or {}

--------------------------------------------------------------
-- Culture Map
--------------------------------------------------------------
-- CultureMap ["x,y"] = { { ID = CIVILIZATION_TYPE, Value = culturesum }, ... }
-- x,y converted to a string "x,y" used as a key
--
-- Initial culture value in cities
CULTURE_CITY_BASE_PRODUCTION = 10 -- default = 10
-- Base culture production factor in cities
CULTURE_CITY_FACTOR = 10000 -- culture value fator used for logarithmic progression (log10)
CULTURE_CITY_RATIO = 15 -- percent of culture value used for sqrt progression
CULTURE_OUTPUT_USE_LOG = false -- if true use logarithmic progression (slower), else use sqrt (faster)
------------------------------------------------------------------------------------------------------------------------
--
CULTURE_CITY_CAPED_FACTOR = 2000 -- maxCulture on a city plot = (population + cityCultureProduction) * CULTURE_CITY_CAPED_FACTOR
CULTURE_CITY_CONVERSION_RATE = 0.5 -- percentage of foreign culture groups converted in your cities each turn
CULTURE_LOST_CONQUEST = 55--50 -- percentage of culture lost by each civs on a city plot on conquest
CULTURE_GAIN_CONQUEST = 75--60 -- percentage of the total lost culture gained by the conqueror
------------------------------------------------------------------------------------------------------------------------
--
-- Minimum culture value before a plot can have ownership, ratio applied to change ownership and max distance from city
CULTURE_MINIMUM_OWNER = 300 -- higher value means more stability (less tile flipping)
CULTURE_FLIPPING_RATIO = 0.65 -- that ratio of the most important culture group value must be superior of the 2nd CG value for a tile to flip. 0.5 means the first CG must have at least twice the value of the second CG. 1 means the first CG get the tile immediatly. [old usage: 0.5 means a civ culture must be at least at 50% of the total plot culture to get it.]
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
-- (percentage of CULTURE_THRESHOLD)
CULTURE_MOUNTAIN_THRESHOLD = 750
CULTURE_CROSS_MARSH_THRESHOLD = 500
CULTURE_CROSS_JUNGLE_THRESHOLD = 450
CULTURE_CROSS_SNOW_THRESHOLD = 400
CULTURE_CROSS_DESERT_THRESHOLD = 300
CULTURE_CROSS_TUNDRA_THRESHOLD = 250
CULTURE_CROSS_RIVER_THRESHOLD = 200
CULTURE_CROSS_HILLS_THRESHOLD = 150
CULTURE_CROSS_FOREST_THRESHOLD = 125
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
-- so bonus tile must be > 100 to act as bonus should, the total will always be capped by (CULTURE_MAX_PERCENT/100)
--
CULTURE_MAX_PERCENT = 75 -- percent
--
CULTURE_NORMAL_MAX = 40 -- base percentage, always used
--
CULTURE_FOLLOW_RIVER_MAX = 180
CULTURE_FOLLOW_ROAD_MAX = 250
--
CULTURE_CROSS_FOREST_MAX = 80
CULTURE_CROSS_HILLS_MAX = 60
CULTURE_CROSS_TUNDRA_MAX = 40
CULTURE_CROSS_RIVER_MAX = 35
CULTURE_CROSS_DESERT_MAX = 30
CULTURE_CROSS_SNOW_MAX = 25
CULTURE_CROSS_JUNGLE_MAX = 20
CULTURE_CROSS_MARSH_MAX = 20
CULTURE_MOUNTAIN_MAX = 10
------------------------------------------------------------------------------------------------------------------------
--
-- Rate of diffusion modifiers
-- Malus, 100 = halve the diffusion rate
CULTURE_CROSS_FOREST_PENALTY = 10 -- percentage
CULTURE_CROSS_HILLS_PENALTY = 15 -- percentage
CULTURE_CROSS_TUNDRA_PENALTY = 25 -- percentage
CULTURE_CROSS_RIVER_PENALTY = 50 -- percentage
CULTURE_CROSS_DESERT_PENALTY = 55 -- percentage
CULTURE_CROSS_SNOW_PENALTY = 55 -- percentage
CULTURE_CROSS_JUNGLE_PENALTY = 60 -- percentage
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
CULTURE_CONQUEST_EVEN_LOWER = true -- conquest tile even without having more culture on it than it's current owner
CULTURE_CONQUEST_EVEN_NONE = true -- conquest tile even without having any culture on it. CULTURE_CONQUEST_EVEN_LOWER must be set to true if you want to activate this one
LOCKED_TURN_ON_CONQUEST = 15 -- number of turns the tile is locked when conquered
CULTURE_CONQUEST_ONLY_ADJACENT = true -- conquest tile only if adjacent to an already owned tile

------------------------------------------------------------------------------------------------------------------------
--
-- Policies modifier
CULTURE_TRADITION_OPENER_CONVERTION_RATE = 0.5 -- percentage of culture converted to plot owner each turn for tradition opener
CULTURE_TRADITION_FINISHER_CONVERTION_RATE = 0.5 -- percentage of culture converted to plot owner each turn for tradition finisher
CULTURE_COMMUNISM_CONVERTION_RATE = 1.5 -- percentage of culture converted to plot owner each turn for communism (G+K & vanilla)
CULTURE_DEMOCRACY_CONVERTION_RATE = 1.5 -- percentage of culture converted to plot owner each turn for democracy (G+K & vanilla)
CULTURE_POPULISM_CONVERTION_RATE = 1.0 -- percentage of culture converted to plot owner each turn for populism (G+K & vanilla)
CULTURE_SOCIALIST_REALISM_CONVERTION_RATE = 1.5 -- percentage of culture converted to plot owner each turn for socialist realism (BNW)
CULTURE_MEDIA_CULTURE_CONVERTION_RATE = 1.75 -- percentage of culture converted to plot owner each turn for media culture (BNW)
CULTURE_NATIONALISM_CONVERTION_RATE = 1.25 -- percentage of culture converted to plot owner each turn for nationalism (BNW)

CULTURE_LIBRARY_CONVERTION_RATE = 0.25 -- percentage of culture converted to city owner each turn for library
CULTURE_UNIVERSITY_CONVERTION_RATE = 0.5 -- percentage of culture converted to city owner each turn for university
CULTURE_PUBLIC_SCHOOL_CONVERTION_RATE = 1 -- percentage of culture converted to city owner each turn for Public School

------------------------------------------------------------------------------------------------------------------------
--
-- Revolution Mod
--
SEPARATIST_TYPE = "SEPARATIST" -- culture type used for separatist

if bRevolution then
	THRESHOLD_JOYFUL		= GameDefines.THRESHOLD_JOYFUL
	THRESHOLD_HAPPY			= GameDefines.THRESHOLD_HAPPY
	THRESHOLD_CONTENT		= GameDefines.THRESHOLD_CONTENT
	THRESHOLD_UNHAPPY		= GameDefines.THRESHOLD_UNHAPPY
	THRESHOLD_WOEFUL		= GameDefines.THRESHOLD_WOEFUL
	THRESHOLD_EXASPERATED	= GameDefines.THRESHOLD_EXASPERATED
end