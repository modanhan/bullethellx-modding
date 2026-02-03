# Customizing the Boss

Experiment with a few more tweaks to see how they change the gameplay! Here are some ideas to get you started...

## Randomize Radius

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="35 35" }
-       fire(eid, pos, v * speed, fp(0.02))
+       local radius = Mix(fp(0.02), fp(0.08), meta.rng:nextFP())
+       fire(eid, pos, v * speed, radius)
```

## Next Steps

!!! hint "Challenge"
    Can you make more changes to create a truly unique attack pattern?

Once you're happy with your customization of the first boss,
let's go upload this mod onto Steam as a Workshop Item!

*You can choose to to keep it private!*
