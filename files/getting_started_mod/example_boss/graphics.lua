require("bx.scripts.graphics.common")
require("bx.scripts.graphics.helper")

---@diagnostic disable: need-check-nil, inject-field, undefined-field

local themeColor = Vec4.new(0.32, 0.38, 0.5, 1)
local bulletColor = themeColor * fp(1.5)

local _ex_boss3_t = 0
local function boss(eid)
    local pos = Engine.component(eid, "Position").position
    local alpha = 1
    local deathAnimation = Engine.component(eid, "DeathAnimation")
    if deathAnimation then
        alpha = 1 - fpmath.smoothstep(deathAnimation.tbegin, deathAnimation.tend, deathAnimation.t)
    end
    local meta = Engine.metadata(eid)
    local animationLoop = meta.animationLoop

    local color = Colors.scale(Vec4.new(1), 3, alpha)
    Render.spriteSheet(pos + Vec2.new(0, math.cos(animationLoop * math.pi * 2) * 0.04), Vec2.new(0.2),
        color,
        "bx/data/black_bird_team/oneeye1_idle.png", {
            rows = 4,
            columns = 4,
            idx = _ex_boss3_t,
        })
    _ex_boss3_t = _ex_boss3_t + Render.dt * 30
    _ex_boss3_t = _ex_boss3_t % 16
end

return {
    boss = boss,
}
