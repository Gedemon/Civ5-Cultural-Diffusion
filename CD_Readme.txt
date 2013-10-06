Cultural Diffusion
for Civilization 5
v.19

	-- Presentation --

Culture spread from cities, each tile can host culture from multiple civilizations. You can still buy tiles, but they can flip to another Civilization if it has more culture than you on it, and units can capture tiles (both optional). Culture diffusion is slowed by crossing rivers, desert, snow, swamp or mountain and accelerated following rivers, roads or rails.


	-- Installation --

- download the civ5mod file to your mod folder (..\My Documents\My Games\Sid Meier's Civilization 5\MODS).
- launch civ5, go to the mod browser and click "install mod"
- find the "Cultural Diffusion" line and activate the mod.
- from the mod section, go to single player and set up a game


	-- Credits & thanx --

Whys (SaveUtils), Onni (ContextPtr tutorial), and a lot of people on civfanatics

	-- To do --

- Reflect Great Artist culture bombing on culture map

	-- version history --
	
v.18 (Aug 06, 2013)
- Bugfix: "Tile Flipping" and "Tile Acquisition" options descriptions were inverted.
	
v.17 (July 09, 2013)
- Optimization: Use MapModData for data sharing
- Optimization: Save tables only when needed
- Culture conversion rate in city is affected by some of Brave New World policies (Media Culture, Socialist Realism, Nationalism) or G+K/Vanilla (Communism, Democracy, Populism)
	
v.16 (May 23, 2013)
- Bugfix: Culture Relation table was not shared properly with the Revolution mod
- Balance: Lock tile flipping from culture after conquest for 15 turns (was 5)

v.15 (May 17, 2013)
- Change the save slot for the locked plots table, speed up late game by a factor 5 on large maps...
	
v.14 (May 12, 2013)
- Turn OFF debug output.
	
v.13 (Oct 21, 2012)
- Add penalty values for jungle, hill, forest.
- scale Culture diffusion rate with gamespeed and map size.
- Tweak diffusion rate and culture change on city capture (to prevent plots from switching back immediately).
- Add influence from buildings on foreign culture conversion: Library (0.25%/turn), University (0.5%), Public School (1%)
- Update influence from Policies on foreign culture conversion: Tradition (opener = 0.5%, finisher = 0.5%), Communism (1%)
- Bugfix : some plots were not receiving culture at all if the gained culture value was superior to the max culture calculated for the plots. Now the plots are reaching max value in such cases.

v.12 (Jun 06, 2012)
- Updated : use steam workshop
- Gameplay : Separatist are not created, only converted (in Revolutions mod).

v.11 (Apr 22, 2012)
- Feature : options added to the advanced setup screen to set Culture Flipping and Culture Conquest ON/OFF.
- Added : Policies can influence culture diffusion (and corresponding ON/OFF option to setup screen)

v.10 (Apr 18, 2012)
- Bugfix : culture value were not displayed on mouse over hexes if the Revolution mod was not activated.

v.9 (Apr 11, 2012)
- Small grammar correction

v.8 (Apr 11, 2012)
- Bugfix : no visual spamming of culture in plot help text when scrolling the map during AI turn.
- Bugfix : the player get notifications for tile flipping only if he is concerned (aquired or lost tiles for his empire)
- Changed : list culture on plot in decreasing order
- Config : default value for tile conquest is "false" (can be set ON by changing the ALLOW_CULTURE_CONQUEST value to "true" in CultureDefines.lua)
- Config : default value for tile flipping is "false" (can be set ON by changing the ALLOW_TILE_FLIPPING value to "true" in CultureDefines.lua)

v.7 (Mar 12, 2012)
- rebuild Mod project after HDD crash.
- added : military conquest (capture tile with military units)
- added : maximum distance from city a plot may flip.
- feature : an owned plot should alway show the owner culture
- changed : replace the showed culture value by a comment on culture strength

v.6 (May 02, 2011)
- tweak : malus is now only applied according to destination tile, not diffusing tile.
- bugfix : CULTURE_FLIPPING_RATIO is now applied to the total culture of a plot, not just the highest single value
- bugfix : a city build on a tile with another(s) existing civ culture but no culture from the city owner wasn't producing culture for him. 

v.5 (Apr 13, 2011)
- bug fix : tile flipping from one civ to another was occurring too early in some cases

v.4 (Apr 09, 2011)
- clean diffusion formulas
- handle culture change on city conquest
- city culture capped

v.3 (Fev 07, 2011)
- add culture info on Plot Over UI
- add defines option to allow civ4 spreading & culture flipping

v0.2 (Fev 06, 2011) :
- remove ownership of dead civ
- slower culture spreading
- add penalty values for desert, snow, march, tundra

v0.1 (Fev 06, 2011) :
- initial beta release

================================================================================

Culture spread from cities, each tile can host culture from multiple civilizations. You can still buy tiles, but they can flip to another Civilization if it has more culture than you on it, and units can capture tiles (both optional). Culture diffusion is slowed by crossing rivers, desert, snow, swamp or mountain and accelerated following rivers, roads or rails.

Installation
=========

1/ Click the "subscribe" button and go back in game, in the mod section, it will be downloaded automatically.
2/ Once downloaded, click the checkbox on the right of the mod line to enabled it.
3/ After you've enabled all the mods you want to play with, click "next"


Troubleshooting
=============

With the number of comments saying that the mods does not download automatically even after unsubscribing/restarting, here's detailled instruction to reset the download and try again.

- first, check your game files integrity, instruction to do so are here :

https://support.steampowered.com/kb_article.php?ref=2037-QEUH-3335


- then follow these instructions closely:

1/ unsubscribe to the mod
2/ close steam (not just the windows, the compete program, in doubt restart your computer)
3/ delete all the content (files and folders) of the civ5 cache folder ("\My Documents\My Games\Sid Meier's Civilization 5\cache")
4/ go into your civ5 mods folder ("\My Documents\My Games\Sid Meier's Civilization 5\MODS") and delete any file or folder named "Cultural Diffusion".
5/ launch steam then civ5 and subscribe again from ingame.
