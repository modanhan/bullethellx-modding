# Customizing Bullets

We’ve already customized the boss’s attack behavior
—but there’s much more we can do! What if we want each bullet to move differently?

Right now, bullets travel at a constant velocity set when they are fired.
Let’s add a function that periodically speeds up and slows down a bullet.

```diff  { title="getting_started_mod/example_boss/boss.lua" linenums="10 10" }
+local function bulletMovement(eid)
+    local _freq = 1.65
+    local _amp = 0.05
+    local velocity = Engine.component(eid, "Velocity")
+    local meta = Engine.metadata(eid)
+    meta.t = meta.t + Engine.dt(eid) * 2 * _freq
+    velocity.v = Normalize(velocity.v) * Mix(0.1, 2.4, fpmath.sin(meta.t) * _amp + _amp)
+    Engine.updateMetadata(eid, "t", meta.t)
+    Engine.update(eid, "Velocity", velocity)
+end
```

Next, attach this function to every bullet we spawn,
along with metadata to store the time variable `t`.

```diff  { title="getting_started_mod/example_boss/boss.lua" linenums="33 33" }
    Engine.createComponent(bulletEid, "FactionEnemy", {})
    Engine.createTrail(bulletEid, 5, 0.5, 1.05, 0.06)

+    Engine.createComponent(bulletEid, "AsyncFunction", { name = "example_boss.boss:bullet" })
+    local meta = { t = k }
+    Engine.createMetadata(bulletEid, meta)
end
```

Finally, expose the function so it can be referenced by name.

```diff  { title="getting_started_mod/example_boss/boss.lua" linenums="128 5" }
        themeColor = themeColor,
        bulletColor = bulletColor,
-    }
+    },
+    bullet = bulletMovement,
}
```

Press `F5` to refresh (or start a new game),
and you should now see a much funkier attack pattern.

Designing bullet trajectories is trickier than shaping attack patterns—
but it’s also far more expressive. Experiment and see what you can come up with.

`Function` and `Metadata` are foundational tools that
every serious modder should understand. For more details, read up on
[Scripting Basics](scripting_basics.md).

Next, we’ll look at another useful tool for rapidly iterating on your designs.
