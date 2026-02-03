require("bx.scripts.engine")

table.insert(Engine.stages, 1, "example_boss.stage")

return {
    stage = {
        name = "Orb of Chaos",
        boss = require("example_boss.boss").boss,
    }
}
