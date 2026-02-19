require("bx.scripts.graphics.common")
require("bx.scripts.graphics.helper")

---@diagnostic disable: need-check-nil, inject-field, undefined-field

local function render(eid)
    local imageFilename = "bx/data/ac2d/08/Armature_Jump_%02d.png"
    -- Hint to the renderer to load all textures
    for i = 1, 16 do
        local imageFilename = string.format(imageFilename, i)
        Render.texture(Vec2.new(0), Vec2.new(0), Vec4.new(0), imageFilename)
    end

    local systemMeta = Engine.metadata(Engine.entities("System")[1])
    local player = Engine.component(eid, "Player")

    local alpha = 1
    local spawnAnimation = Engine.component(eid, "SpawnAnimation")
    if spawnAnimation then
        alpha = Smoothstep(spawnAnimation.tbegin, spawnAnimation.tend, spawnAnimation.t)
    end
    local deathAnimation = Engine.component(eid, "DeathAnimation")
    if deathAnimation then
        alpha = 1 - Smoothstep(deathAnimation.tbegin, deathAnimation.tend, deathAnimation.t)
    end

    local meta = Engine.metadata(eid)
    local animationLoop = meta.animationLoop

    local pos = Engine.component(eid, "Position").position

    local _dLayer = player.idx
    if Render.selfPlayerIndex == player.idx then _dLayer = _dLayer + systemMeta.initPlayerCount end

    local imageIdx = math.floor(animationLoop * 16) % 16
    local _imageFilename = string.format(imageFilename, imageIdx + 1, { dLayer = _dLayer })
    local color = Colors.scale(Vec4.new(1), 1.5, alpha)
    Render.texture(pos + Vec2.new(-0.018, math.sin(animationLoop * math.pi * 2) * 0.008 + 0.01), Vec2.new(0.2), color,
        _imageFilename, { levels = Vec2.new(0, 1) })

    -- Glowing circle
    local color = PlayerColor(player)
    local radius = Engine.component(eid, "Radius").r * 1.5
    Render.circle(pos, radius * alpha, Colors.scale(color, 25, alpha), { dLayer = _dLayer + 1 })

    GraphicsHelper.stdHealthBar(eid, Vec2.new(0, -0.15), color, alpha)

    GraphicsHelper.stdAbilityBar(eid, Vec2.new(0, -0.225),
        {
            spriteSheet = "bx/data/icons/icons.png",
            rows = 9,
            columns = 10,
            frame = 31,
        },
        color, alpha, _dLayer + 0.2)
end


local function bulletClear(eid)
    local pos = Engine.component(eid, "Position").position
    local size = Engine.component(eid, "Radius").r
    local timer = Engine.component(eid, "Timer")
    local color = Engine.component(eid, "Color").color

    local a = Smoothstep(0, 1, timer.t ^ (1 / 3))
    local distortAmount = math.min(1 - a, 0.3)
    Render.distort(pos, Vec2.new(size * 1.25), Vec4.new(distortAmount), "bx/data/distortions/explosion.png",
        { theta = timer.t * -4 })
    Render.circle(pos, size * a, Colors.scale(color, 1, 1 - a), { dLayer = 1000 })
end


return {
    render = render,
    bulletClear = bulletClear,
}
