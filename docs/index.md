# Bullethell X Modding and Scripting Guide

Welcome to modding in Bullethell X!

This guide will walk you through creating mods, using the scripting interface, and exploring a few advanced techniques.

<iframe src="https://store.steampowered.com/widget/764420/"
frameborder="0" width="646" height="190" style="color-scheme:asdf"
></iframe>

## Modding Workflow

Bullethell X loads mods from two sources:

1. Steam Workshop – for published mods.
2. Local Mods – located in `bx/mods`. This is where you’ll be working during development.

To get started, place your mod files in the `bx/mods` folder, and the game will automatically detect them.

## Enabling Local Mods

- Open the in-game Settings menu.

- Ensure Local Mods are enabled.

- (Optional) Disable Steam Workshop mods while developing, so they don’t interfere with your work.

!!! tip

    Press F5 at any time (even during gameplay) to instantly reload your mods!

## Publishing Your Mod

Once your mod is ready:

- Use `steamcmd` to upload your mod. (In-game uploading is currently in development.)

- After publishing, players can subscribe to your mod on the Steam Workshop and enjoy it directly in their game.
