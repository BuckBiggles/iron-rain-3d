# Handoff: real models, eras, textures (branch `real-models`)

This branch holds the downloaded and processed assets for the next big Iron Rain 3D update, plus the plan. Work on this branch and merge to `main` when it plays well. Merged to `main` (the live GitHub Pages site) at build 2026-10-11.1 for the user's playtest.

## PC session log (2026-10-10 evening, newest last)

**Cloud session: start with the Queue at the end of this section.** The original model downloads exist only on the PC
(`%TEMP%\ir3d\in\`), so any re-pack has to be done there.

Test harness on the PC: serve `repo/` and open **`/index.html`** (the bare `/` path served an empty page there). Debug helpers live in the
browser's localStorage (`__dbg`; `eval(localStorage.getItem('__dbg')); await __boot()`): `__rot(name, turretYaw, camYaw, camEl, dist, colours)`
renders a tank with hull grey / turret red / gun blue and the turret turned, `__top(name, y0, y1)` a top view coloured by height with a metre
grid, `__side(name)` a side view with a 10 cm height grid, `__raw(model, /regex/)` the raw .glb with matching node names in red. They are
not in the repo; recreate them if needed (each is ~10 lines of three.js render-to-target code).

Done and pushed:
- **Ashton** (all in `index.html`): Mixamo-rigged soldier + RPG-7 models with IK (`poseSoldier`, `reach2`, `aimBone`), run cycle, rocket in
  the tube, reload animation, first person shows his arms (his Head bone is shrunk). **Hands follow the real RPG-7 hold** (reference photos:
  Wikimedia Commons "RPG-7" firing/aiming shots, e.g. the ANA commando "tests the sight picture"): right hand on the trigger grip
  (`infTpl.rpg.grip`), left hand on the second (rear) pistol grip just behind it (`infTpl.rpg.fore`, found from the plastic grip mesh).
- **C4** is planted, not thrown: `fire()` for `kind 'c4'` emits a `fire` event with `pt` = the plant target from `c4Target(t)` (nearest
  tank plate within `PLANT_REACH` 2.2 m of his hands, else the ground 0.7 m ahead); every client plays the plant (`t.plantT`, `PLANT_T`
  2.1 s); the host calls `plantNow()` at `PLANT_AT` 1.05 s, which emits the usual `c4` event (`ry`, `sd` = side plate). **10 s timer**
  (`C4_FUSE`), no detonator; the light blinks and the beep speeds up in the last 3 s. **Two plant animations**: on a tank he stands and
  presses it onto the armour; on the ground he crouches (`m.crouch`, legs IK, spine lean, first-person eye drops). In both he **slings the
  RPG on his back** (`m.stowK`, diagonal across Spine2) and carries the charge in both hands (`m.c4h`). He can't move while planting.
- **C4 model**: `assets/infantry/c4.glb` = "Makeshift C-4 Explosive" by lion.gelders (CC BY; credited in CREDITS.md and the in-game
  credits). `prepC4()` lays it flat, 0.3 m long; its `Light` mesh is the blinking LED. A code-built charge (`c4Parts`) stands in until it
  loads. (The first C4 tried was a Counter-Strike rip, `w_eq_c4`; deleted, don't use it.)
- Tanks: with no flag equipped the mast is a 1.2 m radio whip instead of the 2.6 m flag pole.

In progress (tank models, user: "clean up the tank models, they are wrong", "broken under the turret"):
- New `prepTank` options: `names.within` (named turret meshes keep only triangles over the ring, above `T.y - tol`; named gun pieces low
  down go to the hull: hull MG), `names.grab` (unused now), and for merged models **`foot` + `cut` (+ `cuts`)**: a hand-drawn turret
  outline from above (`[[x, z], ...]` counter-clockwise, tank frame metres) and the ring height (`cuts: [[fromX, y], ...]` when the deck
  steps); triangles are clipped at the cut height and along every edge of the outline, so only what's over the turret turns.
- `makeModelTank` adds a dark **turret-ring disc** to the hull under every turret (the models have no roof there; a turned turret showed a hole).
- Checked with `__rot`: KV-2, KV-1, StuG IV, Leopard 2A6, Sherman fine. Fixed: **T-34** (names; fenders and rear plate were turning with
  the turret), **Panzer IV** (`DrawCall_1/8` turret, `_6/_7` barrel + mantlet), **Tiger** (`TigerTurret*`, `TigerCannon*`, hullOnly; tow
  cables and hull MG were in the turret), **Abrams** (`foot`/`cut` 1.72, verified). **Merkava** (`foot`, cut 1.62) mostly right.
  **Challenger 2** (cut 1.65) and **KF51** (`cuts` 2.05 / 1.68) still need tuning: use `__top` + `__side` to read the outline and the
  turret's underside height, then `__rot` to check. T-90M: a few hull bits still turn with its turret.

**All 13 tank models re-packed** (user, on seeing the result: "whatever you did to the abrams do that to every tank, the shape looks great"):
the old packs were simplified with gltfpack's aggressive mode, which tore the UV seams, so the camo was smeared into streaks and the
shapes were shard-like. They are now `gltfpack -si 0.5 -tw -tl 1024 -kn -noq -cc` from the original downloads (kept on the PC in
`%TEMP%\ir3d\in\`), no `-sa`. `assets/tanks` went from ~30 MB to 54 MB (Sherman 10.8 MB, Abrams 7.2 MB, T-34 7.6 MB; drop those to
`-tl 512` or `-si 0.35` if loading is slow). Checked after the re-pack: Abrams (crisp camo, correct split), T-34, Merkava, T-90M look right
with real materials. The splits use metres, so the configs still apply, but **re-check every tank with `__rot` after the re-pack**.
- T-34 now also has `names.grab: 1.0, grabMax: 3` (its mantlet is in `Body_Main`); one sloped plate by the turret's rear right still
  stays on the hull.

Queue (user requests not done yet, in order):
1. Finish the tank splits above (Challenger 2, KF51, T-90M; re-check all after the re-pack), then **"fix the camo"** (user's words, said
   right after the re-pack: confirm the smeared camo is gone on every tank with real textures, and look at the store camo cosmetics,
   which multiply a single tint over the whole textured model in `makeModelTank` (`tint`), probably the thing that looks wrong now).
2. Verify each tank's aiming numbers (`elev`, `trav`, `erate`, `arc`) against sources (user: "research how each tank aims and act accordingly").
3. Rider must sit **on** the deck, not above or inside it (`seatRider` / `tpl.deck`; check every tank).
4. RPG reload animation: base it on real RPG-7 reload footage, may be inspired by Call of Duty's but not a copy (user's words).
5. Rider voices (more female voices; item 4 of the cloud list below).
6. **Menu**: optimise it and make sure the tank panels/cards are aligned properly.
7. Later: merge to `main`, bump `BUILD`, upload `assets/` to the artifact. Don't do the final handoff until the user says so.

## Queue status (cloud session, build 2026-10-11.1, merged to `main` for a playtest)

All 6 queue items above are done:
1-2. Tank splits all checked (only the barrel elevates), store camo is tri-planar (`camoPaint`), aiming numbers checked against sources.
3. **Rider seats**: `riderSeat(tpl)` rasterises each model's hull (and turret) into a 5 cm height map and searches for a flat seat with
   nothing in her body or over her head, clear of the turret's swing, legs hanging into open air: left side of the rear deck, then the
   right, then facing the back (StuG IV: on the casemate roof's back edge, feet on the engine deck). `seat.ry` turns her. The radio mast
   moved to the right side. **Emblems** (`emblemSpots`): rays find a flat turret plate and the decal lies on it; no plate, no decal.
4. **RPG-7 reload** (`reloadDrill`, model soldier): launcher down, rocket from the left hip pack, nose cap off, tail first into the
   muzzle with a twist to seat the lug (click), hammer cocked with the right thumb (click), back on the shoulder. User: "that looks good".
5. **Voices**: Rosie af_bella, Betty af_nicole+af_bella, Scarlett bf_emma+bf_isabella, Vera af_kore+af_aoede, Dolores ef_dora+af_river,
   Lili Piper de-ramona, Katya Piper uk-lada (Cyrillic respelling). Generator scripts aren't in the repo (Kokoro voices can be blended
   by averaging their style vectors; Piper LibriTTS-high has 904 speakers, ~190 female by pitch). A voice audition artifact exists for
   the user to pick replacements. Don't use Piper "lessac" (research-only dataset licence).
6. **Menu**: tank cards use one silhouette scale per era on a common ground line, 4 columns when there are 7 tanks, spec line wraps.

Still open: artifact copy needs `assets/` uploaded; KV-2 mantlet doesn't tilt with the gun; heavy models (T-34, Sherman, Abrams, T-90M).

## Status (updated by the cloud session, build 2026-10-10.8)

The cloud session can't reach Sketchfab, Poly Haven, itch.io, jsDelivr or cdnjs (all blocked there), so **anything that needs a download has to be done on the PC**. It *can* fetch GitHub release files and npm packages.

**Done on this branch (steps 1, 2 and the credits):**
- `TANKS` is now 13 real tanks in two eras (`era: 'ww2' | 'modern'`), with the stats from the table below and the era scaling described there. `ERAS`, `eraTanks(era)`, `setEra()`; ERA picker on the VS CPU tab (`#eraRow`) and in the lobby (`#lobbyEra`, host only, `lobby.era`); CPU tanks come from the battle's era; stats bars compare within an era.
- **Models**: `loadTankModel(spec)` loads `assets/tanks/<model>.glb` (GLTFLoader + MeshoptDecoder from jsDelivr, already in the page), `prepTank()` orients, scales to the real hull length (`spec.L`) and cuts hull / turret / gun, and `makeModelTank()` builds each tank from the cached template (shared geometry, cloned materials). Battles wait for their models (`needModels()`, a LOADING card); the menu preloads the selected era, then the other. Tank cards show silhouettes rendered from the models.
- `prepTank` cutting, per tank in `spec.cfg`: `turret {x, y, rx, rz}` = footprint ellipse and ring height (metres, tank frame), `auto` = ring height from the hull roof, `names` = mesh-name rules, `pca` + `fwdFromGun` + `unshear` (Panzer IV: tilted and sheared node transform), `flip` (Sherman), `autoYaw` (Merkava: turret modelled turned ~20°), `casemate` (StuG IV), `clipAll` + `footprint` + `drop` (KF51, Abrams: hull and turret merged; cut along the ring plane under the turret roof's outline). Pieces are sorted as connected components; big merged pieces are clipped triangle by triangle.
- Material fixes in `loadTankModel`: metalness capped (exports were fully metallic = black), `vertexTangents = false` (tangents are dropped when cutting), textures set to linear encoding (the game renders in linear).
- **Real aiming** (user request): each tank has `elev: [min, max]` (real depression/elevation), `trav` (turret deg/s), `erate` (elevation deg/s), `arc` (StuG IV: ±10° casemate). `slewGun()` carries the turret with the hull and lays it at those rates; the view (`viewYaw`) is free and the gun follows; the gunsight is locked to the gun. CPU uses the same limits (and pivots the StuG's hull); the host clamps clients. `solve()` only searches the gun's real elevation range.
- CREDITS button in SETTINGS (`#credits`, built from `CREDITS.md`).

**Added by the PC session:**
- `assets/riders/base_female.glb`: Quaternius Universal Base Characters, female **Superhero** body (CC0), 15k triangles, rigged (69 nodes; UE-style bone names: `pelvis`, `spine_01..03`, `neck_01`, `Head`, `clavicle_l/r`, `upperarm_l`, `lowerarm_l`, `hand_l`, fingers, `thigh_l/r`, `calf_l/r`, `foot_l/r`, ...), meshes `Superhero_Female`, `Eyes`, `Eyebrows`. The free pack's skin texture is the darker tone only: tint or recolour the base colour per rider. No animation clip (pose the bones in code).
- `assets/riders/hair_long.glb`, `hair_buns.glb`, `hair_simpleparted.glb`, `eyebrows_female.glb`: hair rigged to the `Head` bone (bind them to the body's skeleton, or parent them to the Head bone).
- `assets/buildings/rural.glb`: the user's extra building pick, **Rural Buildings Set** by Daniel Zhabotinsky (CC BY): American countryside houses, a quonset hut, a trailer, a diner and more as separate meshes in one file (7.7k triangles). Split it into individual buildings by mesh/connected piece.
- `CREDITS.md` updated for both.

**Known issues / still to do (in this order):**
1. **Ashton has no running animation** (user just asked): `makeSoldierMesh()` legs are static, so other players see him slide. Step 3 below (soldier.glb with the Mixamo skeleton) should animate the run by swinging the UpLeg/Leg bones with his speed (`footMove` sets his movement); until then, swing the code-built legs.
2. Step 3 (Ashton models), step 4 (buildings), step 5 (terrain textures, sky), step 6 (new reticle): not started.
3. **Riders** (user request): they want sexier pin-up riders, curvier, in skimpier swimwear (keep it non-explicit: bikinis and swimsuits, no nudity), **one free default plus the rest for the store**. Plan: download Quaternius *Universal Base Characters* (CC0, https://quaternius.itch.io/universal-base-characters), export the female "Superhero" body to `assets/riders/base_female.glb` (+ CREDITS.md line), then build each of the 7 riders (`COSMETICS.rider`) on it with her own outfit, hair, colours, hat and accessories, seated on the rear deck (`seatRider`, `animateRider`).
4. **Rider voices** (user request: find more female voices): every line is pre-rendered per rider into `voices/<id>.mp3` (+ `VOICE_CLIPS` offsets in the page). The generator used Kokoro (`kokoro-onnx`, model files from github.com/thewh1teagle/kokoro-onnx releases) and Piper (voice files from github.com/rhasspy/piper releases v0.0.2). Other female voices available that way: Kokoro af_bella, af_sky, af_nova, af_river, af_jessica, af_aoede, af_kore, af_alloy, bf_isabella, bf_alice, bf_lily, ff_siwis, if_sara, pf_dora, and blends of two voices; Piper de-eva_k, de-ramona, uk-lada, en-us-amy, en-us-kathleen, en-gb-southern_english_female, fr-siwis. Next step was an audition page so the user can pick one per rider.
5. Tank models: a few small hull pieces on the KF51 may still sit inside the turret footprint; check in game.
6. Publishing: the claude.ai artifact copy is still the morning build; it needs `assets/` (~45 MB) uploaded as supporting files when this branch is merged.

Test harness used by the cloud session: serve the repo (`python -m http.server`), open the page; `window.__ir` exposes `step`, `frameMs`, `startOffline`, `setup`, `tanks`, `player`. `loadTankModel`, `modelTpl`, `prepTank`, `slewGun` are globals.

Everything in `assets/` is already slimmed for the web. Attribution for the CC BY models is in `CREDITS.md`, and the game must show credits (a CREDITS button on the menu that lists `CREDITS.md`'s content).

## What the user asked for

1. **Replace every tank** with real 3D models, split into **two separate eras** (user's choice: battles are WW2-only or modern-only; an ERA picker on the VS CPU tab and in the online lobby; CPU opponents come from the same era).
2. **Real-life stats** for every tank, the same way the current game derives them (armor → hull points, road speed → speed, muzzle velocity → shell speed and range, round energy → damage, rate of fire → reload).
3. **Ashton** uses the soldier model and the RPG-7 model (keep the current iron sights, 7.5 s RPG reload, first person only, no aim dots, body hidden in first person, own reload animation).
4. **Buildings** in the maps use the 8 building models.
5. **Terrain** uses the 10 Poly Haven textures (blend by slope), and the sky uses the Lilienstein panorama.
6. **A new tank gunsight reticle**, designed in-house and inspired by real sights (WW2: German TZF-style triangles and stadia; modern: digital fire-control sight with a laser range readout). Don't copy any game's graphics.
7. Ripped game assets are off limits (the user agreed): no models from War Thunder, World of Tanks, Battlefield, Call of Duty, etc. The original T-90 pick was a rip (its internal name was "Elements of War") and was replaced with Quasar's T-90M.

## Loading the models

- Add `https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/GLTFLoader.js` and `https://cdn.jsdelivr.net/npm/meshoptimizer@0.18.1/meshopt_decoder.js` after three r128; `loader.setMeshoptDecoder(MeshoptDecoder)`.
- The files use `EXT_meshopt_compression` and `EXT_texture_webp`, no quantization (`-noq`), so positions are plain floats and can be split in JS.
- Pack command (gltfpack 1.3, from the meshoptimizer GitHub releases): `gltfpack -i in.glb -o out.glb -si <ratio> -sa -tw -tl 1024 -kn -noq -cc` (512 px textures for buildings and infantry). gltfpack can't open paths longer than 260 characters on Windows, so work from a short folder.
- Load models once per battle and clone them per tank (`SkeletonUtils` is not needed for tanks; the soldier needs `SkeletonUtils.clone` from the same examples folder).

## Tanks: files, structure and what's left to do

Each tank needs, per model: an orientation fix (forward = +x, up = +y, as in `makeTankMesh`), a uniform scale to its real length, and **turret and gun parts** that can rotate. `tools/lab.html` (serve the folder and open it) shows a model from four sides and has `lab.paint(fn)` to colour triangles by a classifier, for calibrating splits.

| File | Tank | Turret/gun parts in the file |
|---|---|---|
| `tanks/kv2.glb` | KV-2 | One mesh: split by geometry (turret = the big box above the hull) |
| `tanks/pz4.glb` | Panzer IV | Meshes by material only: split by geometry |
| `tanks/kv1.glb` | KV-1 | One mesh: split by geometry |
| `tanks/t34.glb` | T-34/76 | Named: `Body_Body_Turret_Plate_low`, `Body_Body_Turret_Barrel_low`, `Details_Details_Turret_*`, `Body_Turret_Details_low_Body` |
| `tanks/tiger.glb` | Tiger I | Named: `TigerTurret_Low`, `TigerTurretHatch_Low`, `TigerCannonTurret_Low`, `TigerCannon_Low`, `TigerGun_Low` |
| `tanks/stug4.glb` | StuG IV | Casemate, no turret: traverse the gun only a few degrees (real: ±10°) or turn the whole vehicle |
| `tanks/sherman.glb` | M4A2 Sherman | Many unnamed parts: split by geometry |
| `tanks/leo2.glb` | Leopard 2A6 | Named: `turret`, `gun` |
| `tanks/chall2.glb` | Challenger 2 | Few meshes: split by geometry |
| `tanks/kf51.glb` | KF51 Panther | Named groups `KF51_Body_*`, `KF51_Parts_*`: check which are turret |
| `tanks/merkava.glb` | Merkava Mk4 | One main mesh: split by geometry |
| `tanks/abrams.glb` | M1A2 SEPv3 | One merged object: split by geometry |
| `tanks/t90m.glb` | T-90M | Has an interior (already simplified away, mostly): split by geometry |

Splitting by geometry: transform every triangle to the oriented frame, then turret = centroid above the turret-ring height and inside the turret's footprint ellipse; gun = centroid inside a thin box in front of the turret along the barrel. Build three meshes (hull, turret, gun) and keep the gun's pivot at the trunnion so `gun.rotation.z` elevates it, as `makeTankMesh` does now.

Keep the hitbox, rider seat, eye point, muzzle point and `top` fields that the rest of the game reads from `t.mesh` (see `makeTankMesh`'s return value).

## Real stats (fill `REAL` and `AMMO` with these)

Armor is effective frontal protection in mm (RHA equivalent against kinetic rounds for modern tanks). Modern figures are public estimates.

| Tank | Armor mm | Road km/h | Gun | Main AP round | m/s | kg in flight | Rounds/min | Weight t | Crew |
|---|---|---|---|---|---|---|---|---|---|
| KV-2 | 75 (110 with appliqué) | 34 | 152 mm M-10T | BR-540 | 432 | 40 | 2 | 52 | 6 |
| Panzer IV (Ausf. H) | 80 | 38 | 7.5 cm KwK 40 L/48 | PzGr. 39 | 790 | 6.8 | 8 | 25 | 5 |
| KV-1 (1941) | 75 (90 with appliqué) | 35 | 76.2 mm ZiS-5 | BR-350A | 662 | 6.3 | 6 | 45 | 5 |
| T-34/76 (1943) | 45 at 60° ≈ 90 | 53 | 76.2 mm F-34 | BR-350A | 662 | 6.3 | 6 | 30.9 | 4 |
| Tiger I | 100 (120 mantlet) | 45 | 8.8 cm KwK 36 | PzGr. 39 | 773 | 10.2 | 6 | 57 | 5 |
| StuG IV | 80 | 38 | 7.5 cm StuK 40 L/48 | PzGr. 39 | 790 | 6.8 | 8 | 23 | 4 |
| M4A2 Sherman | 51 at 56° ≈ 91 | 48 | 75 mm M3 | M61 APC | 619 | 6.79 | 8 | 31.3 | 5 |
| Leopard 2A6 | ~800 | 72 | 120 mm L/55 | DM53 | 1750 | 4.6 | 10 | 62.3 | 4 |
| Challenger 2 | ~850 | 59 | 120 mm L30A1 (rifled) | L27A1 | 1700 | 4.5 | 8 | 62.5 | 4 |
| KF51 Panther | ~750 | 70 | 130 mm Rh-130 L/52 | 130 mm APFSDS | 1650 | 6.5 | 10 | 59 | 3 |
| Merkava Mk4 | ~800 | 64 | 120 mm MG253 | M338 | 1700 | 4.6 | 10 | 65 | 4 |
| M1A2 SEPv3 | ~900 | 67 | 120 mm M256 | M829A4 | 1555 | 4.6 | 10 | 66.8 | 4 |
| T-90M | ~800 | 60 | 125 mm 2A46M-4 | 3BM60 | 1660 | 4.8 | 8 | 46.5 | 3 |

Game scaling per era, so each era plays like the current game:
- WW2 keeps today's formulas (`hp = 120 + sqrt(armor)*11`, `vk = mv/800`, energy relative to the Sherman's M61).
- Modern: scale armor by 0.11 before the hp formula (so ~800 mm plays like ~90 mm), shell speed `vk = mv/1650`, energy relative to the M1A2's M829A4. Range stays inside the map.

## Ashton files

- `infantry/soldier.glb`: Mixamo skeleton, bone prefix `mott_var01:` (Hips, Spine, Spine1, Spine2, Neck, Head, Left/RightShoulder, Arm, ForeArm, Hand, fingers, Left/RightUpLeg, Leg, Foot, ToeBase). Units are centimetres (1.86 m tall), T-pose, one Mixamo clip. Pose the arms onto the RPG and animate the run in code (rotate UpLeg/Leg bones).
- `infantry/rpg7.glb`: launcher meshes under `pCube12`; the **rocket is its own node `pCylinder8`** (use it for the reload: hide after firing, slide back into the muzzle). Odd scale: normalise by its bounding box to about 0.95 m long.

## Buildings

`buildings/*.glb`: autumn, forest, farmpoor, barn, medieval, village, log, farmwood. Map them onto the layout's building types (house, barn, shed, church, chapel, ruin): scale each to the footprint `w × d` the layout gives, keep the existing box solids for collisions and damage, and keep the collapse-to-rubble behaviour (swap to the rubble heap when destroyed). There's no church model yet: keep the code-built church and chapel, or find a CC BY one.

## Terrain and sky

`terrain/*_diff.jpg` (1024 px) and `*_nor.jpg` (512 px):
- Ground (flat): forrest_ground_01, leaves_forest_ground, brown_mud_leaves_01, forest_leaves_02, forest_leaves_03.
- Dirt (mid slopes, roads, craters): rocks_ground_02, dry_riverbed_rock.
- Rock (steep): coast_sand_rocks_02, rocky_terrain_02, aerial_rocks_04.

Blend by slope and height in a terrain shader (onBeforeCompile on the Lambert/Standard material), tinted per map theme (desert maps warmer). Keep the scorch and paint layers. `terrain/sky_lilienstein.jpg` is a 4096×2048 equirectangular panorama: use it as the sky sphere texture (and optionally as the environment light).

## Tools

- `tools/lab.html`: model viewer and turret/gun split tester (needs the `out/` folder path edited to `../assets/tanks/`).
- `tools/glbinfo.ps1`: prints a .glb's node tree, meshes and bounds.
