require("bx.scripts.engine")
require("bx.scripts.utils")
require("bx.scripts.helpers")

---@diagnostic disable: need-check-nil, inject-field, undefined-field

local themeColor = Vec4.new(0.32, 0.38, 0.5, 1)
local bulletColor = themeColor * 1.5

local function fire(eid, pos, v, radius, k)
    local bulletEid = Engine.createEntity()
    Engine.createComponent(bulletEid, "Color", { color = bulletColor })
    Engine.createComponent(bulletEid, "Position", pos)
    Engine.createComponent(bulletEid, "Radius", { r = radius })
    Engine.createComponent(bulletEid, "Velocity", { v = v })
    Engine.createComponent(bulletEid, "Graphic", Graphic.stdPixelatedBullet())
    Engine.createComponent(bulletEid, "Circle", {})
    Engine.createComponent(bulletEid, "Bullet", {
        damage = 1,
        firedBy = eid,
    })
    Engine.createComponent(bulletEid, "FactionEnemy", {})
    Engine.createTrail(bulletEid, 5, 0.5, 1.05, 0.06)
end

local function attack(eid, meta, pos)
    local speed = 0.35
    local radialCount = 18
    local theta = fpmath.pi * 2 / radialCount
    local rot = Mat2.rotate(theta)
    local v = Vec2.new(0, 1)
    v = Mat2.rotate(fpmath.gr * meta.n) * v
    for _k = 1, radialCount do
        v = rot * v
        fire(eid, pos, v * speed, 0.02, _k + meta.n)
        meta.n = meta.n + 1
    end
end

local function updateAttack(eid, dt, meta)
    if not meta then
        return
    end
    meta.t = meta.t + dt * 0.6
    if meta.t >= 1 then
        meta.t = meta.t - 1
        attack(eid, meta, Engine.component(eid, "Position"))
    end
end

local function update(eid)
    local dt = Engine.dt(eid)

    local meta = Engine.metadata(eid)
    if not meta.animationLoop then meta.animationLoop = 0 end
    meta.animationLoop = meta.animationLoop + dt * 1.2
    if meta.animationLoop >= 1 then
        meta.animationLoop = meta.animationLoop - 1
    end

    if Engine.component(eid, "BossEntrance") then
        Engine.updateMetadata(eid, meta)
        return
    end
    local health = Engine.component(eid, "Health")
    if not health or health.hp <= 0 then
        return
    end

    Engine.updateMetadata(eid, "animationLoop", meta.animationLoop)

    updateAttack(eid, dt, meta.attack)
    Engine.updateMetadata(eid, "attack", meta.attack)
end

local function create()
    local difficulty = Helper.difficulty()

    local e = Engine.createEntity()
    Engine.createComponent(e, "Unit", {})
    Engine.createComponent(e, "FactionEnemy", {})
    Engine.createComponent(e, "Radius", { r = 0.16 })
    Engine.createComponent(e, "GraphicFunction", { name = "example_boss.graphics:boss", layer = GraphicLayer.enemy })
    Engine.createComponent(e, "Position", { position = Vec2.new(0) })
    Engine.createComponent(e, "Velocity", { v = Vec2.new(0) })
    Engine.createComponent(e, "BossEntrance", { duration = 4.5, t = 0 })
    Engine.createComponent(e, "IFrame", { duration = 4.5, t = 0 })

    local attack = {
        difficulty = difficulty,
        t = 0.8,
        n = 0,
        rng = Grng.new(difficulty),
    }
    local meta = {
        difficulty = difficulty,
        attack = attack,
    }
    Engine.createMetadata(e, meta)
    local hp = Helper.stdHP(difficulty)
    Engine.createComponent(e, "Health", { maxHp = hp, hp = hp, _s = hp })
    Engine.createComponent(e, "SpawnUpgrades",
        { count = Helper.stdUpgradeCount(difficulty), spawned = 0, rng = Grng.new(difficulty) })

    return e
end

return {
    boss = {
        name = "Orb of Chaos",
        create = create,
        update = update,
        themeColor = themeColor,
        bulletColor = bulletColor,
    }
}
