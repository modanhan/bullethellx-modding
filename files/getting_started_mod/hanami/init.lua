require("bx.scripts.engine")

---@diagnostic disable: need-check-nil, inject-field, undefined-field

local function stat(meta, s)
    return meta[s .. "Base"] * meta[s .. "Mult"] * meta[s .. "More"]
end

local function create(eid)
    local player = Engine.component(eid, "Player")
    player.mainColor = Colors.scale(Vec4.new(0.26, 0.12, 0.38, 1), 3.5, 1)
    player.altColor = Colors.scale(Vec4.new(0.005, 0.034, 0.145, 1), 3, 1)
    Engine.update(eid, "Player", player)
    Engine.createComponent(eid, "GraphicFunction", { name = "hanami.graphics:render", layer = GraphicLayer.player })
    Engine.createComponent(eid, "Unit", {})

    local meta = Engine.metadata(eid)

    -- Customize base stats
    meta.maxHPBase = 5
    meta.attackSpeedBase = meta.attackSpeedBase * 0.8
    meta.energyRegenBase = 1 / 90
    meta.energyCost = 1
    meta.attackDamageBase = 1
    -- Ability related stats
    meta.bc = {
        radius = 0.75,
        radiusMult = 1,
        radiusMore = 1,
        level = 0,
    }
    meta.autoBc = {
        uses = 0,
        maxUses = 0,
        cooldown = 0,
        timer = 0,
    }
    Engine.updateMetadata(eid, meta)

    local maxHP = stat(meta, "maxHP")
    Engine.createComponent(eid, "Health", {
        hp = maxHP,
        maxHp = maxHP,
        _s = maxHP,
    })
    Engine.createComponent(eid, "Radius", { r = stat(meta, "radius") })
    Engine.createComponent(eid, "Graphic", Component.Graphic(GraphicLayer.player))
    Engine.createComponent(eid, "FactionPlayer", {})
    return eid
end

local function reverseBullet(eid)
    local meta = Engine.metadata(eid)
    local vel = Engine.component(eid, "Velocity")
    vel.v = Damp(vel.v, meta.reversedVel, 1.5, Engine.dt(eid))
    Engine.update(eid, "Velocity", vel)
end

local function bulletClear(eid)
    local radius = Engine.component(eid, "Radius")
    local timer = Engine.component(eid, "Timer")
    local meta = Engine.metadata(eid)
    radius.r = timer.t * meta.radius + 0.05
    Engine.update(eid, "Radius", radius)

    local es = {}
    if timer.t < 0.8 then
        es = Engine.entities("Bullet", "Position", "Radius", "FactionEnemy")
    end
    for i = 1, #es do
        local beid = es[i]
        local bpos = Engine.component(beid, "Position").position
        local bradius = Engine.component(beid, "Radius")
        local epos = Engine.component(eid, "Position").position
        local dist = Length(bpos - epos)
        if dist <= radius.r + bradius.r then
            if meta.level == 0 then
                Engine.destroyComponent(beid, "Bullet")
                Engine.createComponent(beid, "DeathAnimation", { tbegin = 0, tend = 0.5, t = 0 })
            else
                Engine.destroyComponent(beid, "Function")
                Engine.destroyComponent(beid, "AsyncFunction")
                Engine.destroyComponent(beid, "FactionEnemy")
                Engine.createComponent(beid, "FactionPlayer", {})
                local color = Engine.component(beid, "Color")
                if not color then color = {} end
                color.color = meta.color
                Engine.update(beid, "Color", color)

                Engine.destroyMetadata(beid)
                Engine.destroyComponent(beid, "Target")

                local bullet = Engine.component(beid, "Bullet")
                bullet.damage = meta.damage
                Engine.update(beid, "Bullet", bullet)

                if meta.level == 1 then
                    local vel = Engine.component(beid, "Velocity")
                    local reversedVel = bpos - Helper.stdBossPos
                    if vel then
                        reversedVel = -vel.v
                    else
                        Engine.createComponent(beid, "Velocity", { v = Vec2.new(0) })
                    end
                    Engine.createMetadata(beid, {
                        reversedVel = reversedVel,
                    })
                    Engine.createComponent(beid, "AsyncFunction", { name = "hanami:reverseBullet" })
                else
                    Engine.createComponent(beid, "Target", {
                        target = bullet.firedBy,
                        lambda = 1.25,
                        maxSpeed = 2.5,
                    })
                end
            end
        end
    end
    if timer.t >= 1 then
        Engine.destroyEntity(eid)
    end
end

local function fireBulletClear(position, color, meta)
    local bcEid = Engine.createEntity()
    Engine.createComponent(bcEid, "Position", position)
    Engine.createComponent(bcEid, "Radius", { r = 0.0 })
    Engine.createComponent(bcEid, "FactionPlayer", {})
    Engine.createComponent(bcEid, "Function", { name = "hanami:bulletClear" })
    Engine.createComponent(bcEid, "GraphicFunction", { name = "hanami.graphics:bulletClear", layer = 1000 })
    Engine.createComponent(bcEid, "Color", { color = color })
    Engine.createComponent(bcEid, "Timer", { t = 0 })
    local damage = 1
    if meta.bc.level == 3 then
        damage = stat(meta, "attackDamage")
    end
    Engine.createMetadata(bcEid, {
        radius = meta.bc.radius * meta.bc.radiusMult * meta.bc.radiusMore,
        level = meta.bc.level,
        color = color,
        damage = damage,
    })
end

local function bulletClearAbility(eid)
    local dt = Engine.dt(eid)
    local meta = Engine.metadata(eid)
    local player = Engine.component(eid, "Player")
    local playerInput = Engine.component(eid, "PlayerInput")
    local position = Engine.component(eid, "Position")

    -- Ability: Bullet Clear
    local cheat = false
    -- cheat = true
    if playerInput.ability0 ~= 0 and ((meta.energy >= meta.energyCost and meta.abilityUse > 0) or cheat) then
        meta.energy = meta.energy - meta.energyCost
        meta.abilityUse = meta.abilityUse - 1
        fireBulletClear(position, player.mainColor, meta)
    end

    -- Auto fire
    meta.autoBc.timer = meta.autoBc.timer - dt
    if meta.autoBc.timer <= 0 then
        if meta.autoBc.uses > 0 then
            Log.d("Auto firing Bullet Clear")
            fireBulletClear(position, player.mainColor, meta)
            meta.autoBc.timer = meta.autoBc.cooldown
            meta.autoBc.uses = meta.autoBc.uses - 1
        end
    end
    -- Log.d(meta.autoBc.uses, meta.autoBc.timer, meta.autoBc.maxUses)

    if not meta.animationLoop then meta.animationLoop = 0 end
    meta.animationLoop = meta.animationLoop + dt * 0.3
    if meta.animationLoop >= 1 then
        meta.animationLoop = meta.animationLoop - 1
    end

    Engine.update(eid, "Player", player)
    Engine.updateMetadata(eid, meta)
end

local function update(eid)
    require("general").update(eid)
    bulletClearAbility(eid)
end

local function refill(eid)
    local meta = Engine.metadata(eid)
    meta.autoBc.uses = meta.autoBc.maxUses
    meta.autoBc.timer = meta.autoBc.cooldown
    Log.d("Refilled auto Bullet Clear uses to " .. meta.autoBc.uses)
    Engine.updateMetadata(eid, meta)
end

local skilltree = require("hanami.skilltree")

return {
    player = {
        name = "Hanami",
        displayName = "Hanami Dango",
        role = "Defender",
        desc =
        [[Hanami is a wandering protector of the worlds.
        She uses her signature ability to defend herself and allies from overwhelming odds.]],
        passives = {
            "5 base max HP",
            "Slightly reduced attack speed",
            "Very slow base energy regeneration: full regeneration every 90s",
        },
        ability = {
            name = "Bullet Clear",
            icon = {
                spriteSheet = "bx/data/icons/icons.png",
                rows = 9,
                columns = 10,
                frame = 31,
            },
            desc = {
                "Activate to fire a wave that clears nearby enemy bullets.",
                "Can be upgraded to convert enemy bullets into allied bullets and fire them back.",
            },
        },
        image = {
            filename = "bx/data/ac2d/08/Armature_Talk_2_10.png",
            uvOffset = Vec2.new(-0.0, -0.0),
            uvScale = Vec2.new(1) * 0.5,
        },
        create = create,
        update = update,
        skilltree = skilltree,
        refill = refill,
    },
    bulletClear = bulletClear,
    reverseBullet = reverseBullet,
}
