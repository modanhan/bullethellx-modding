
# Ad-hoc Structs

## Trail

Most bullets benefit from a trail visual component, to create this component manually,
use the `Engine.createTrail` function:

``` lua  hl_lines="7"
-- Create a trail visual
--- @param eid integer
--- @param detail integer
--- @param opacity number
--- @param widthScale number | nil if nil, default to 1
--- @param cd number | nil if nil, use Engine.dt
Engine.createTrail = function(eid, detail, opacity, widthScale, cd)
```

<div class="result" markdown>

``` lua title="Sample Usage in Helper.fireStandardBulletBoss" hl_lines="13"
local bulletEid = Engine.createEntity()
Engine.createComponent(bulletEid, "Color", ... )
Engine.createComponent(bulletEid, "Position", ... )
Engine.createComponent(bulletEid, "Radius", ... )
Engine.createComponent(bulletEid, "Velocity", ... )
Engine.createComponent(bulletEid, "Graphic", ... )
Engine.createComponent(bulletEid, "Circle", {})
Engine.createComponent(bulletEid, "Bullet", {
    damage = fp(1),
    firedBy = config.firedBy,
})
Engine.createComponent(bulletEid, "FactionEnemy", {})
Engine.createTrail(bulletEid, 8, 0.5, 1, Engine.dt * 2)
return bulletEid
```

</div>

!!! important
    `detail` is at most `8` and at least `1`!

!!! info
    Trail has no accessible/modifiable data! It is merely a visual effect.
