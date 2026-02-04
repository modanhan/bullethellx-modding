# Creating a Boss

In this section, we’ll create a simple boss, load it into the game,
make a small change, and then hot-reload it to see the results.

## Step 1: Download the example

Click here to download
[getting_started_mod.zip](getting_started_mod.zip){:download},
extract the zip and move the `getting_started_mod` folder under `bx/mods`.

## Step 2: Inspect Boss Script

You should now have `bx/mods/getting_started_mod/example_boss/boss.lua`,
this is where most of the logic lives!

Note the modding/scripting system (and game logic) of Bullethell is written in [Lua](https://www.lua.org/)!
No programming experience is necessary and this is a good place to start!

## Step 3: Load Your Mod In-Game

1. Launch the game.
2. Press *Backspace* to toggle mod settings and make sure:
    - **Local Mods** are *ENABLED*.
    - **Steam Workshop Mods** are *DISABLED*.
    - You can see these settings on the top left corner.
3. Start a singleplayer game. You should see your new boss (Orb of Chaos) performing its basic attack pattern.

## Step 4: Make a Live Change

Open `boss.lua` (you can do this while the game is running!) and edit line 44:

```diff  { title="bx/mods/my_mod/new_boss.lua" linenums="44 44" }
-     meta.t = meta.t + dt * fp(0.7)
+     meta.t = meta.t + dt * fp(1.4)
```

## Step 5: Hot Reload Your Mod

Switch back to the game and press **F5** - this hot reloads the scripts.
Your boss should now have a much higher attack speed.

!!! success
    **Congratulations!** You’ve just completed the basic Bullethell X modding workflow.
