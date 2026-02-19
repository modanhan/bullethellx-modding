require("bx.scripts.engine")

---@diagnostic disable: need-check-nil, inject-field, undefined-field

local function stat(meta, s)
    return meta[s .. "Base"] * meta[s .. "Mult"] * meta[s .. "More"]
end

local function fire(eid, pos, v, radius, idx, config)
    local bulletEid = Engine.createEntity()
    Engine.createComponent(bulletEid, "PlayerIndex", { idx = idx })
    Engine.createComponent(bulletEid, "Position", { position = pos })
    Engine.createComponent(bulletEid, "Radius", { r = radius })
    Engine.createComponent(bulletEid, "Velocity", { v = v })
    Engine.createComponent(bulletEid, "Graphic", Component.Graphic(GraphicLayer.playerBullet))
    Engine.createComponent(bulletEid, "Circle", {})
    Engine.createComponent(bulletEid, "Bullet", {
        damage = config.damage,
        firedBy = eid,
    })
    Engine.createComponent(bulletEid, "FactionPlayer", {})
    Engine.createTrail(bulletEid, 8, 1, 1)
    Engine.createComponent(bulletEid, "SpawnAnimation", {
        tbegin = 0,
        tend = 0.1,
        t = 0,
    })
    if config.homing then
        local es = Engine.entities("FactionEnemy", "Unit", "Position")
        if #es > 0 then
            local closest = es[1]
            for i = 2, #es do
                local p1 = Engine.component(closest, "Position").position
                local p2 = Engine.component(es[i], "Position").position
                local d1 = Length(p1 - pos)
                local d2 = Length(p2 - pos)
                if d2 < d1 then
                    closest = es[i]
                end
            end
            Engine.createComponent(bulletEid, "Target", {
                target = closest,
                lambda = config.homingSpeed,
                maxSpeed = Length(v),
            })
        end
    end
    Engine.createComponent(bulletEid, "TimeScaleBlend", { t = 1, dt = -config.timeScaleDT })
    Engine.createComponent(bulletEid, "CullingThreshold", { m = 1.1 })
end


local function attack(eid, idx, meta, player)
    local position = Engine.component(eid, "Position")
    if not position then return end
    local direction = Vec2.new(1, 0)
    if meta.aim > 0 then
        local aimDirection = Vec2.new(1, 0)
        local es = Engine.entities("FactionEnemy", "Unit", "Position")
        if #es > 0 then
            local closest = es[1]
            for i = 2, #es do
                local p1 = Engine.component(closest, "Position").position
                local p2 = Engine.component(es[i], "Position").position
                local d1 = Length(p1 - position.position)
                local d2 = Length(p2 - position.position)
                if d2 < d1 then
                    closest = es[i]
                end
            end
            aimDirection = Normalize(Engine.component(closest, "Position").position - position.position)
        end
        direction = Normalize(Mix(direction, aimDirection, meta.aim))
    end
    local damage    = stat(meta, "attackDamage")
    local radius    = 0.0015
    local multishot = meta.multishot or 1
    if meta.fuse == 1 then
        damage = damage * multishot
        multishot = 1
        radius = radius * 3
    end
    local spray          = stat(meta, "spray")
    local theta          = (player.rng:nextFP() - 0.5) * spray
    local multishotAngle = math.min(meta.multishotAngle, math.pi * 2 / multishot)
    theta                = theta - ((multishot - 1) / 2) * multishotAngle
    direction            = Mat2.rotate(theta) * direction
    local rotate         = Mat2.rotate(multishotAngle)
    for i = 1, multishot do
        local crit = player.gr:nextFP() < stat(meta, "critChance")
        local _radius = radius
        if crit then
            damage = damage * stat(meta, "critDamage")
            _radius = _radius * 3
        end
        fire(eid, position.position,
            Normalize(direction) * meta.projectileSpeed, _radius, idx,
            {
                crit = crit,
                damage = damage,
                homing = meta.homing ~= 0,
                homingSpeed = meta.homingSpeed,
                timeScaleDT = meta.bulletTimeScaleDT + (player.rng:nextFP() - 0.5) * meta.bulletTimeScaleDTR,
            })
        direction = rotate * direction
    end
end


local function update(eid)
    local dt = Engine.dt(eid)
    local player = Engine.component(eid, "Player")
    local playerInput = Engine.component(eid, "PlayerInput")
    local meta = Engine.metadata(eid)

    if playerInput then
        local position = Engine.component(eid, "Position")
        position.position = position.position + playerInput.movement * dt * stat(meta, "movementSpeed")
        Engine.update(eid, "Position", position)
    end

    if not meta.attackTime then
        meta.attackTime = 0
    end
    if not meta.attackN then
        meta.attackN = 0
    end
    meta.attackTime = meta.attackTime + dt * stat(meta, "attackSpeed")

    local health = Engine.component(eid, "Health")
    if meta.attackTime >= 1 then
        meta.attackTime = meta.attackTime - 1
        if health.hp > 0 then
            meta.attackN = meta.attackN + 1
            attack(eid, Engine.component(eid, "PlayerIndex").idx, meta, player)
        end
    end

    meta.animationLoop = meta.animationLoop + dt * 0.3
    if meta.animationLoop >= 1 then
        meta.animationLoop = meta.animationLoop - 1
    end

    local energyRegen = stat(meta, "energyRegen")
    if meta.abilityOn == 0 then
        meta.energy = math.min(meta.energy + dt * energyRegen, 1)
    end

    Engine.update(eid, "Player", player)
    Engine.updateMetadata(eid, meta)
end

local function create(eid)
    local player = Engine.component(eid, "Player")
    player.mainColor = Colors.scale(Vec4.new(1.000, 0.359, 0.394, 1), 1.5, 1)
    player.altColor = Colors.scale(Vec4.new(0.005, 0.034, 0.145, 1), 3, 1)
    Engine.update(eid, "Player", player)
    Engine.createComponent(eid, "GraphicFunction", { name = "general.graphics:render", layer = GraphicLayer.player })
    Engine.createComponent(eid, "Unit", {})

    local meta = Engine.metadata(eid)
    -- Customize metadata here
    -- Engine.updateMetadata(eid, meta)

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

local desc =
[[General
]]

return {
    _player = {
        name = "General",
        displayName = "General",
        desc = desc,
        image = {
            filename = "bx/data/ac2d/05/Armature_Talk_2_01.png",
            uvOffset = Vec2.new(0.0, -0.0),
            uvScale = Vec2.new(1) * 0.5,
        },
        create = create,
        update = update,
        skilltree = require("bx.scripts.players.skilltree").create(),
    },
    update = update,
    attack = attack,
}
