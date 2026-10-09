# Iron Rain 3D

A first-person, real-time take on [Iron Rain](https://buckbiggles.github.io/iron-rain/). You ride in the turret of a WWII tank: drive, lay the gun by eye or through the gunsight, set your powder charge and lob shells at the other tanks before they reload.

**Play:** https://buckbiggles.github.io/iron-rain-3d/

## How it plays
- Free-for-all against 1–3 CPU tanks, or online with friends (2–4 tanks; empty seats become CPUs).
- Real time: drive and fire whenever your gun is loaded. Each shell has a reload time, and heavier guns load slower.
- Every hit on an enemy spins the supply wheel for a special shell: Mini Nuke, MIRV, Lucky 7, Bouncer, Dig Bomb, Orbital Strike or Teleport.
- Five battlefields with craters you can blow into the ground: Rolling Hills, Mountain Pass, The Gorge, Steppe and Badlands.
- Ten real tanks: Sherman, T-34, Tiger I, Panther, Churchill, Cromwell, IS-2, Hellcat, StuG III and Stuart.
- Store: camo, emblems, flags, shell trails and death effects, paid for with money from hits ($20), kills ($30) and wins ($100). The wallet is shared with 2D Iron Rain.

## Controls
| Key | Action |
| --- | --- |
| Mouse / arrow keys | Aim (no button needed). The gun follows the crosshair, zeroed for the range shown beside it |
| W A S D | Drive |
| Wheel · R · X | Set the sight zero · lase the target to set it · high lob |
| Right mouse · Z | Gunsight with rangefinder |
| Click · Space | Fire |
| 1–4 · Q | Shell type · arm a supply special |
| V · C | Hold to ride with your shell · always follow (a shell cam inset shows every shot) |
| T · Esc | Chat (online) · menu |
| [ · ] | Mouse sensitivity down · up (full settings: Esc menu or the SETTINGS tab) |

## Online
Host a room and share the 5-letter code or invite link. Play is peer-to-peer over WebRTC (PeerJS's public broker only introduces players), with the host's browser running the battle. A dropped player gets their seat back by rejoining with the same code; a CPU drives their tank in the meantime.

Single file: `index.html` (Three.js r128 and PeerJS from CDNs).
