local skilltree = require("bx.scripts.players.skilltree").create()

local root = skilltree.skills[0]

local function bind(func, ...)
    local boundArgs = { ... }
    return function(...)
        local newArgs = { ... }
        return func(table.unpack(newArgs), table.unpack(boundArgs))
    end
end

local bcRadius = function(eid, amount, cost)
    if eid == nil then
        return {
            name = "Bullet Clear Radius",
            icon = {
                spriteSheet = "bx/data/rpg_magic_icons/potions.png",
                columns = 10,
                rows = 10,
                frame = 88,
            },
            desc = "Increase Bullet Clear radius by " .. (amount * 100) .. "%",
            weight = 1,
            cost = cost,
        }
    end
    local meta = Engine.metadata(eid)
    meta.bc.radiusMult = meta.bc.radiusMult + amount
    Engine.updateMetadata(eid, meta)
end

local bcRadius0 = skilltree.skill(bind(bcRadius, 1, 5))
root.unlocks(bcRadius0)
local bcRadius1 = skilltree.skill(bind(bcRadius, 1, 15))
bcRadius0.unlocks(bcRadius1)
local bcRadius2 = skilltree.skill(bind(bcRadius, 1, 30))
bcRadius1.unlocks(bcRadius2)
local bcRadius3 = skilltree.skill(bind(bcRadius, 1, 50))
bcRadius2.unlocks(bcRadius3)

local baseEnergyRegen = function(eid, amount, cost)
    if eid == nil then
        local amtStr = (amount * 100)
        return {
            name = "Base Energy Regen",
            icon = {
                spriteSheet = "bx/data/rpg_magic_icons/potions.png",
                columns = 10,
                rows = 10,
                frame = 89,
            },
            desc = "+ " .. amtStr .. "% to base energy regeneration",
            weight = 1,
            cost = cost,
        }
    end
    local meta = Engine.metadata(eid)
    meta.energyRegenBase = meta.energyRegenBase + amount
    Engine.updateMetadata(eid, meta)
end
local baseEnergyRegen0 = skilltree.skill(bind(baseEnergyRegen, 1 / 60 - 1 / 90, 10))
bcRadius0.unlocks(baseEnergyRegen0)
local baseEnergyRegen1 = skilltree.skill(bind(baseEnergyRegen, 1 / 45 - 1 / 60, 20))
baseEnergyRegen0.unlocks(baseEnergyRegen1)
local baseEnergyRegen2 = skilltree.skill(bind(baseEnergyRegen, 1 / 36 - 1 / 45, 30))
baseEnergyRegen1.unlocks(baseEnergyRegen2)

local autoFire = function(eid, uses, cooldown, cost)
    if eid == nil then
        return {
            name = "Bullet Clear Auto Fire",
            icon = {
                spriteSheet = "bx/data/rpg_magic_icons/potions.png",
                columns = 10,
                rows = 10,
                frame = 90,
            },
            desc = "Automatically fire Bullet Clear every " .. (cooldown) .. " seconds, " .. uses .. " uses per stage",
            weight = 1,
            cost = cost,
        }
    end
    local meta = Engine.metadata(eid)
    meta.autoBc.maxUses = uses
    meta.autoBc.cooldown = cooldown
    Engine.updateMetadata(eid, meta)
end
local autoFire0 = skilltree.skill(bind(autoFire, 1, 40, 10))
bcRadius0.unlocks(autoFire0)
local autoFire1 = skilltree.skill(bind(autoFire, 2, 30, 15))
autoFire0.unlocks(autoFire1)
local autoFire2 = skilltree.skill(bind(autoFire, 3, 24, 25))
autoFire1.unlocks(autoFire2)
local autoFire3 = skilltree.skill(bind(autoFire, 5, 18, 50))
autoFire2.unlocks(autoFire3)

local levelUp1 = function(eid)
    if eid == nil then
        return {
            name = "Bullet Reversal",
            icon = {
                spriteSheet = "bx/data/rpg_magic_icons/potions.png",
                columns = 10,
                rows = 10,
                frame = 39,
            },
            desc =
            "Bullet Clear now reverses enemy bullets instead of destroying them, but Bullet Clear has 10% less radius",
            weight = 1,
            cost = 25,
        }
    end
    local meta = Engine.metadata(eid)
    meta.bc.level = 1
    meta.bc.radiusMore = meta.bc.radiusMore - 0.1
    Engine.updateMetadata(eid, meta)
end
local levelUp1Skill = skilltree.skill(levelUp1)
bcRadius0.unlocks(levelUp1Skill)
levelUp1Skill.unlocks(bcRadius1)

local levelUp2 = function(eid)
    if eid == nil then
        return {
            name = "Return to Sender",
            icon = {
                spriteSheet = "bx/data/rpg_magic_icons/potions.png",
                columns = 10,
                rows = 10,
                frame = 39,
            },
            desc =
            "Reversed bullets now home back towards the enemies that fired them, but Bullet Clear has 20% less radius",
            weight = 1,
            cost = 50,
        }
    end
    local meta = Engine.metadata(eid)
    meta.bc.level = 2
    meta.bc.radiusMore = meta.bc.radiusMore - 0.2
    Engine.updateMetadata(eid, meta)
end
local levelUp2Skill = skilltree.skill(levelUp2)
levelUp1Skill.unlocks(levelUp2Skill)
levelUp2Skill.unlocks(bcRadius2)

local levelUp3 = function(eid)
    if eid == nil then
        return {
            name = "Destructive Return",
            icon = {
                spriteSheet = "bx/data/rpg_magic_icons/potions.png",
                columns = 10,
                rows = 10,
                frame = 39,
            },
            desc = "Reversed bullets now deal your bullets damage, but has 30% less radius",
            weight = 1,
            cost = 75,
        }
    end
    local meta = Engine.metadata(eid)
    meta.bc.level = 3
    meta.bc.radiusMore = meta.bc.radiusMore - 0.3
    Engine.updateMetadata(eid, meta)
end
local levelUp3Skill = skilltree.skill(levelUp3)
levelUp2Skill.unlocks(levelUp3Skill)
levelUp3Skill.unlocks(bcRadius3)

local function costReduction(eid, amount, cost)
    if eid == nil then
        return {
            name = "Bullet Clear Cost",
            icon = {
                spriteSheet = "bx/data/rpg_magic_icons/potions.png",
                columns = 10,
                rows = 10,
                frame = 37,
            },
            desc = "-" .. (amount * 100) .. "% energy cost for Bullet Clear",
            weight = 1,
            cost = cost,
        }
    end
    local meta = Engine.metadata(eid)
    meta.energyCost = meta.energyCost - amount
    Engine.updateMetadata(eid, meta)
end
local costReduction0 = skilltree.skill(bind(costReduction, 0.1, 10))
bcRadius0.unlocks(costReduction0)
local costReduction1 = skilltree.skill(bind(costReduction, 0.1, 25))
costReduction0.unlocks(costReduction1)
local costReduction2 = skilltree.skill(bind(costReduction, 0.1, 50))
costReduction1.unlocks(costReduction2)

local function abilityUse(eid, amount, cost)
    if eid == nil then
        return {
            name = "Bullet Clear Uses",
            icon = {
                spriteSheet = "bx/data/rpg_magic_icons/potions.png",
                columns = 10,
                rows = 10,
                frame = 38,
            },
            desc = "Increase max bullet clear ability uses by " .. amount .. ".",
            weight = 1,
            cost = cost,
        }
    end
    local meta = Engine.metadata(eid)
    meta.abilityMaxUse = meta.abilityMaxUse + amount
    Engine.updateMetadata(eid, meta)
end
local abilityUse0 = skilltree.skill(bind(abilityUse, 1, 50))
costReduction1.unlocks(abilityUse0)
local abilityUse1 = skilltree.skill(bind(abilityUse, 1, 50))
abilityUse0.unlocks(abilityUse1)
costReduction2.unlocks(abilityUse1)
local abilityUse2 = skilltree.skill(bind(abilityUse, 1, 50))
abilityUse1.unlocks(abilityUse2)


return skilltree
