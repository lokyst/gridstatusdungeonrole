-- Libraries
local L = LibStub("AceLocale-3.0"):GetLocale("GridStatusDungeonRole", true)

-- Grid Initialization
local GridStatus = Grid:GetModule("GridStatus")
local GridRoster = Grid:GetModule("GridRoster")

local GridStatusDungeonRole = GridStatus:NewModule("DungeonRole")
GridStatusDungeonRole.menuName = L["Dungeon Role"]

local rolestatus = {
    healer = {
                text = L["Healer"],
                icon = [[Interface\AddOns\GridStatusDungeonRole\icons\healer.tga]],
        },
    DPS = {
                text = L["DPS"],
                icon = [[Interface\AddOns\GridStatusDungeonRole\icons\damager.tga]],
        },
    tank = {
                text = L["Tank"],
                icon = [[Interface\AddOns\GridStatusDungeonRole\icons\tank.tga]],
        },
}



-- Grid config defaults
GridStatusDungeonRole.defaultDB = {
    debug = false,
    dungeonRole = {
        text = L["Dungeon Role"],
        enable = true,
        color = { r = 1, g = 1, b = 1, a = 1 },
        priority = 10,
        range = false,
        hideInCombat = false,
        colors = {
            DPS = { r = 0.75, g = 0, b = 0, a = 1 },
            healer = { r = 0, g = 0.75, b = 0, a = 1 },
            tank = { r = 0, g = 0, b = 0.75, a = 1 },
        },
        filter = {
            DPS = true,
            healer = true,
            tank = true,
        },
    },
}

GridStatusDungeonRole.options = false

local function getrolecolor(role)
    local color = GridStatusDungeonRole.db.profile.dungeonRole.colors[role]
    return color.r, color.g, color.b, color.a
end

local function setrolecolor(role, r, g, b, a)
    local color = GridStatusDungeonRole.db.profile.dungeonRole.colors[role]
    color.r = r
    color.g = g
    color.b = b
    color.a = a or 1
    GridStatus:TriggerEvent("Grid_ColorsChanged")
end

local function getrolefilter(role)
    return GridStatusDungeonRole.db.profile.dungeonRole.filter[role] ~= false
end

local function setrolefilter(role, v)
    GridStatusDungeonRole.db.profile.dungeonRole.filter[role] = v
    GridStatusDungeonRole:RoleCheckAll()
end



-- Grid configration options
local roleOptions = {
    ["healer"] = {
        type = "color",
        name = L["Healer color"],
        desc = L["Color for Healers."],
        order = 87,
        hasAlpha = true,
        get = function () return getrolecolor("healer") end,
        set = function (r, g, b, a) setrolecolor("healer", r, g, b, a) end,
    },
    ["DPS"] = {
        type = "color",
        name = L["DPS color"],
        desc = L["Color for DPS."],
        order = 88,
        hasAlpha = true,
        get = function () return getrolecolor("DPS") end,
        set = function (r, g, b, a) setrolecolor("DPS", r, g, b, a) end,
    },
    ["tank"] = {
        type = "color",
        name = L["Tank color"],
        desc = L["Color for Tanks."],
        order = 89,
        hasAlpha = true,
        get = function () return getrolecolor("tank") end,
        set = function (r, g, b, a) setrolecolor("tank", r, g, b, a) end,
    },
    ["filter"] = {
        type = "group",
        name = L["Role filter"],
        desc = L["Show status for the selected roles."],
        order = 90,
        args = {
            ["healer"] = {
                type = "toggle",
                name = L["Healer"],
                desc = L["Show on Healer."],
                get = function () return getrolefilter("healer") end,
                set = function (v) setrolefilter("healer", v) end,
            },
            ["DPS"] = {
                type = "toggle",
                name = L["DPS"],
                desc = L["Show on DPS."],
                get = function () return getrolefilter("DPS") end,
                set = function (v) setrolefilter("DPS", v) end,
            },
            ["tank"] = {
                type = "toggle",
                name = L["Tank"],
                desc = L["Show on Tank."],
                get = function () return getrolefilter("tank") end,
                set = function (v) setrolefilter("tank", v) end,
            },
        },
    },
    ["hideInCombat"] = {
        type = "toggle",
        name = L["Hide in combat"],
        desc = L["Hide roles while in combat."],
        order = 91,
        get = function() return GridStatusDungeonRole.db.profile.dungeonRole.hideInCombat end,
        set = function()
            local settings = GridStatusDungeonRole.db.profile.dungeonRole
            settings.hideInCombat = not settings.hideInCombat
            if settings.enable then
                if settings.hideInCombat then
                    GridStatusDungeonRole:RegisterEvent("Grid_EnteringCombat")
                    GridStatusDungeonRole:RegisterEvent("Grid_LeavingCombat")
                else
                    GridStatusDungeonRole:UnregisterEvent("Grid_EnteringCombat")
                    GridStatusDungeonRole:UnregisterEvent("Grid_LeavingCombat")
                end
                GridStatusDungeonRole:RoleCheckAll()
            end
        end,
    },

    ["color"] = false,
}



-- Status handling
function GridStatusDungeonRole:OnInitialize()
    self.super.OnInitialize(self)
    self:RegisterStatus("dungeonRole", L["Dungeon Role"], roleOptions, true)
end

function GridStatusDungeonRole:OnStatusEnable(status)
    if status == "dungeonRole" then
        if self.db.profile.dungeonRole.hideInCombat then
            self:RegisterEvent("Grid_EnteringCombat")
            self:RegisterEvent("Grid_LeavingCombat")
        end
        self:RegisterEvent("PLAYER_ROLES_ASSIGNED", "RoleCheckAll")
        self:RegisterEvent("PARTY_MEMBERS_CHANGED", "RoleCheckAll")
        self:RoleCheckAll()
    end
end

function GridStatusDungeonRole:OnStatusDisable(status)
    if status == "dungeonRole" then
        if self.db.profile.dungeonRole.hideInCombat then
            self:UnregisterEvent("Grid_EnteringCombat")
            self:UnregisterEvent("Grid_LeavingCombat")
        end
        self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
        self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
        self.core:SendStatusLostAllUnits("dungeonRole")
    end
end

function GridStatusDungeonRole:Reset()
    self.super.Reset(self)
    self:RoleCheckAll()
    if self.db.profile.dungeonRole.hideInCombat then
        GridStatusDungeonRole:RegisterEvent("Grid_EnteringCombat")
        GridStatusDungeonRole:RegisterEvent("Grid_LeavingCombat")
    else
        GridStatusDungeonRole:UnregisterEvent("Grid_EnteringCombat")
        GridStatusDungeonRole:UnregisterEvent("Grid_LeavingCombat")
    end
end

function GridStatusDungeonRole:Grid_EnteringCombat()
    local settings = self.db.profile.dungeonRole
    if settings.enable and settings.hideInCombat then
        self.core:SendStatusLostAllUnits("dungeonRole")
    end
end

function GridStatusDungeonRole:Grid_LeavingCombat()
    local settings = self.db.profile.dungeonRole
    if settings.enable and settings.hideInCombat then
        self:RoleCheckAll()
    end
end



-- Role check functions
function GridStatusDungeonRole:RoleCheckAll()
    local settings = self.db.profile.dungeonRole
    if settings.enable and ( not settings.hideInCombat or not Grid.inCombat ) then
        for guid in GridRoster:IterateRoster() do
            self:RoleCheck(guid)
        end
    else
        self.core:SendStatusLostAllUnits("dungeonRole")
    end
end

function GridStatusDungeonRole:RoleCheck(guid)
    local gained
    local settings = self.db.profile.dungeonRole
    if settings.enable and ( not settings.hideInCombat or not Grid.inCombat ) then
        local isTank, isHeal, isDPS = UnitGroupRolesAssigned(GridRoster:GetUnitidByGUID(guid))
        if isTank then
            role = "tank"
        elseif isHeal then
            role = "healer"
        elseif isDPS then
            role = "DPS"
        else
            role = false
            gained = false
        end
        if role and settings.filter[role] then
            local status = rolestatus[role]
            self.core:SendStatusGained(
                guid,
                "dungeonRole",
                settings.priority,
                (settings.range and 40),
                settings.colors[role],
                status.text,
                nil,
                nil,
                status.icon
            )
            gained = true
        end
    end
    if not gained then
        self.core:SendStatusLost(guid, "dungeonRole")
    end
end
