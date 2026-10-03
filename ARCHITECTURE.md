# ENERGY INC. — architecture, version 0.2.0

## Runtime and scope

Godot **4.6.3**, typed GDScript and Compatibility rendering. There are no runtime plugins or external services. Version 0.2 completes one single-player production loop: ingredient → mixer → physical six-serving batch → filler + empty cans → six physical filled cans → delivery → reward/new order. Sealing, labeling and packaging remain folded into the filler for this slice.

## Composition and state ownership

```text
GameSession (composition, material replenishment, pause/restart)
├── FactoryRoom / FactoryLighting (room, original art, static collision)
├── FactoryPlayer : CharacterBody3D
│   ├── PlayerInput (per-device actions)
│   ├── PlayerInteraction (visible/reachable target → commands)
│   ├── PhysicsGrabber (exclusive ownership, dynamic carry/drop/throw)
│   └── WorkerVisual (GLB mesh parts animated independently of collision)
├── MixerMachine : MachineBase (resource recipe, input quantities, one batch slot)
├── CanFiller : MachineBase (reservoir, queued empties, six output slots)
├── CanSupply : MachineBase (empty-can dispenser)
├── DeliveryStation : MachineBase (delivery command adapter)
├── OrderManager (deadline, delivered count, settlement, balance)
├── CarryableItem : RigidBody3D → ItemView
├── FactoryHUD / HudLayout / OrderBoard (read-only state presentation)
└── FactoryAudio (original synthesized feedback; signal observer)
```

`InputBindings` is the only autoload. It registers standardized base input actions, not game state. `PlayerInput` clones scoped actions (`p1_…`) for a chosen gamepad and optional keyboard/mouse, removing them on teardown. Single-player mouse capture and global pause remain session responsibilities.

`MachineBase` owns elapsed processing time and `IDLE`, `LOADING`, `PROCESSING`, `FINISHED`, `BROKEN`, `OVERHEATED` states. All stations expose `interact`, `try_start` and `interaction_text`; player code does not branch by individual machine type. State, progress, inventory and feedback signals connect presentation. Temperature, damage, power and jams remain inactive extension fields.

## Data and production invariants

- `IngredientData`, `RecipeData`, `ItemDefinition` and `OrderData` are shared immutable `.tres` configuration.
- `ItemDefinition.Kind` distinguishes ingredient, batch, empty can and filled can. It stores mass, collider dimensions and mesh scene. `IngredientData` supplies each ingredient's model. Runtime product identity and remaining batch servings live on physical item instances.
- `ItemCatalog` names resource archetypes. `CarryableItem` owns physics and claims; `ItemView` constructs only its appearance.
- Mixer quantities must exactly match the recipe. Accepted input is consumed once. Processing lasts five seconds. One batch with six servings is emitted; another cycle is blocked until that output is claimed.
- Filler accepts one six-serving batch when its reservoir is empty. Raw ingredients and extra batches are rejected without consuming them. Up to six empty cans can queue. Starting requires liquid, an empty can and room in the output tray.
- Every one-second fill creates one physical can, deducts one empty and one serving, and continues through the queue. Each output records a tray slot; claiming it frees that slot. A full tray blocks another start. Reservoir counters never mutate `RecipeData`.
- Delivery accepts only a held, unconsumed filled can matching the active order's product ID. Acceptance consumes the body, increments once and settles after six. A settled order cannot pay or charge again.
- Orders use 180 simulation seconds, a $420 reward and $100 timeout penalty. Settlement starts a three-second intermission, then a new order. Money may be negative after penalties. State is session-only; no save/progression system is implied.
- Pause freezes physics, order timers, transitions and machine audio. Restart reloads the complete scene, clearing inventory, orders and balance. Visual UI remains responsive during pause.

## Physics and targeting

60 Hz physics. Layers: 1 room, 2 workers, 3 items, 4 stations. Machines occupy room + station layers. Held objects remain dynamic rigid bodies, with gravity and holder collision temporarily disabled. A bounded velocity servo and wall ray steer toward the hand; release restores gravity/collision and adds a bounded throw impulse. Objects below the map recover at spawn. Locomotion uses a capsule, coyote time/jump buffering and capped object shoves.

The primary camera ray respects geometry and a 3.4 m chest-relative reach. Small-item assistance considers candidates within 28 screen pixels, validates range, and requires another unobstructed ray. It never selects through walls. A presentation-only hull outline marks the selected object. The same commands support keyboard and standardized gamepad controls.

## Art and presentation decisions

The original block-only milestone is replaced by a generated Blender mesh kit with bevels, weighted normals, rounded worker proportions, machine fittings, six distinct carryable models, delivery desk, dispenser and environmental props. `tools/build_art.py` explicitly converts palette sRGB values to linear material inputs. Committed GLBs mean Blender is optional for contributors and absent from the game runtime.

The procedural room still uses modular pieces and simple solid colliders. It has a warm/cool palette, floor markings, windows, ceiling/trusses, signs, an animated mixer, visible queued cans, contact shadows and directional lighting. Labels do not cast tiny physical shadows. Compatibility rendering plus MSAA keeps the Mac target broad; there is no claim of a measured shipping performance budget.

HUD layout is separate from runtime updates; neither it nor the world order board owns authoritative counters. Open Sans is bundled with its license. Original short synthesized sounds are committed WAVs. All generated and third-party asset provenance is documented in `THIRD_PARTY_NOTICES.md`.

## Future co-op / platform boundaries

Only one player and viewport exist. Local co-op next needs a player registry, join/leave/device assignment, split-screen viewports and separate HUDs. Scoped input is groundwork, not a completed multiplayer feature.

Online play should route interaction commands through a host, introduce stable entity IDs, validate range/state/ownership/capacity server-side and replicate accepted state changes plus interpolated body snapshots. Current direct node references and synchronous transactions are migration seams. Do not attempt deterministic lockstep for these rigid bodies.

Steam belongs behind a later platform-services adapter. There are no Steam APIs, matchmaking, saves or accounts in this build.

## Mac distribution

The committed export preset creates `downloads/ENERGY-INC-macOS.zip`, containing an executable universal `.app` for x86_64 and arm64. It uses Godot's built-in ad-hoc signer. Apple Developer ID and notarization are not configured; users may need the documented per-app macOS approval.

`tools/verify_macos_export.py` verifies ZIP integrity, executable permission, both Mach-O slices, ad-hoc code-page hashes and resource hashes. The actual exported PCK is also launched on Linux. These checks do not replace native macOS execution, Gatekeeper validation, hardware controller testing or GPU profiling. The binary is deliberately stored in `downloads/` for this development delivery; move future release history to a release pipeline.
