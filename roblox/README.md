# Bulut Adası (Roblox Studio)

A small, server-built Roblox obby with seven floating islands, six neon crystals, two checkpoints, a crystal-gated portal, and `Kristal` / `Dusus` leaderstats.

## Run it in Roblox Studio

1. Create a new **Baseplate** experience.
2. In **ServerScriptService**, add a regular **Script** named `BulutAdasi`.
3. Paste in [`BulutAdasi.server.lua`](BulutAdasi.server.lua).
4. Press **Play**. The script creates the complete map and game logic in Workspace.

The default Roblox character controls work: use **WASD** to move and **Space** to jump. Reach the portal after collecting all six crystals. The script can be rerun safely; it rebuilds only its own `BulutAdasi` map folder.

## Browser preview

The repository root also contains a standalone playable browser version (`index.html`), with Turkish UI, keyboard and touch controls, checkpoints, timer, saved best time, and restart flow. Run `./start.sh` or open `index.html` in a modern browser.
