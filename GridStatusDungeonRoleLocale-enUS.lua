local L = AceLibrary("AceLocale-2.2"):new("GridStatusDungeonRole")

L:RegisterTranslations("enUS", function() return {
	["Dungeon Role"] = true,
	
	["Healer"] = true,
	["DPS"] = true,
	["Tank"] = true,
	
	["Healer color"] = true,
	["Color for Healers."] = true,
	
	["DPS color"] = true,
	["Color for DPS."] = true,
	
	["Tank color"] = true,
	["Color for Tanks."] = true,
	
	["Role filter"] = true,
	["Show status for the selected roles."] = true,
	
	["Show on Healer."] = true,
	["Show on DPS."] = true,
	["Show on Tank."] = true,
	
	["Hide in combat"] = true,
	["Hide roles while in combat."] = true,
} end)
