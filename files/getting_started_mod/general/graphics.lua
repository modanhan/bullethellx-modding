require("bx.scripts.graphics.common")
require("bx.scripts.graphics.helper")

---@diagnostic disable: need-check-nil, inject-field, undefined-field

local function render(eid)
    -- Hint to the renderer to load all textures
    for i = 1, 16 do
        local imageFilename = string.format("bx/data/ac2d/05/Armature_Jump_%02d.png", i)
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
    local imageFilename = string.format("bx/data/ac2d/05/Armature_Jump_%02d.png", imageIdx + 1, { dLayer = _dLayer })
    local color = Colors.scale(Vec4.new(1), 1.8, alpha)
    Render.texture(pos + Vec2.new(-0.018, math.sin(animationLoop * math.pi * 2) * 0.01), Vec2.new(0.2), color,
        imageFilename, { levels = Vec2.new(0.0, 1) })

    -- Glowing circle
    local color = PlayerColor(player)
    local radius = Engine.component(eid, "Radius").r * 1.5
    Render.circle(pos, radius * alpha, Colors.scale(color, 25, alpha), { dLayer = _dLayer + 1 })

    -- Ability bar
    local length = 0.035
    local yOffset = 0.1725
    local height = 0.005
    local outline = 0.00375
    Render.roundedRect(pos - Vec2.new(0, yOffset), Vec2.new(length, height * 0.5) + Vec2.new(outline),
        Colors.scale(color, 0, alpha),
        { playArea = 0, hAlign = 0.5, rr = height * 0.5 + outline })

    local energy = meta.energy
    Render.roundedRect(pos - Vec2.new(0.0, yOffset), Vec2.new(length, height * 0.5), Colors.scale(color, 1, 0.2 * alpha),
        { dLayer = 0.001, rr = height * 0.5 })
    Render.roundedRect(pos - Vec2.new(length - length * energy, yOffset),
        Vec2.new(length * energy, height * 0.5),
        Colors.scale(color, 1, alpha),
        { dLayer = 0.002, rr = height * 0.5 })

    GraphicsHelper.stdHealthBar(eid, Vec2.new(0, -0.15), color, alpha)
end

return {
    render = render,
}
