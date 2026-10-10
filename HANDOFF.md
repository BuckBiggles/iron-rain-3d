# Handoff: real models, eras, textures (branch `real-models`)

This branch holds the downloaded and processed assets for the next big Iron Rain 3D update, plus the plan. **The game code on this branch is still the same as `main` (build 2026-10-10.7); none of the steps below are wired in yet.** Work on this branch and merge to `main` when it plays well.

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
