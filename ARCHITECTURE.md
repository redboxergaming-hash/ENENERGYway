# ENERGY INC. — architecture

## Scope and engine

Milestone 01 is a single-player **mixing training room**, built in Godot 4.x with typed GDScript, tested on **4.6.3**. Compatibility rendering supports modest PC hardware and requires no plugins, imported models, network services, or external assets. Open `project.godot` and press F5.

This milestone deliberately ends at a physical Tropical Shock batch. Filling, cans, delivery, order deadlines, and money are Milestone 02. Training materials replenish after collecting a batch; this is tutorial supply behavior, not an implemented factory economy.

## Ownership and responsibilities

```text
GameSession (scene composition, supply lifecycle, pause/restart)
├── FactoryRoom (graybox geometry, environment, lighting)
├── FactoryPlayer : CharacterBody3D
│   ├── PlayerInput (device-scoped actions → commands)
│   ├── PhysicsGrabber (exclusive claim, dynamic hold, release/throw)
│   ├── PlayerInteraction (camera ray + reach → machine/item commands)
│   ├── CameraPivot / SpringArm3D / Camera3D
│   └── WorkerVisual (placeholder worker and walking animation)
├── MixerMachine : MachineBase : StaticBody3D
│   ├── RecipeData → IngredientData resources
│   ├── output marker → CarryableItem(batch_recipe)
│   └── MixerView (signal-driven display and visual wobble)
├── CarryableItem : RigidBody3D (ingredient OR batch identity)
└── FactoryHUD (observes state, emits resume/restart intent)
```

- `systems/input_bindings.gd` is the only autoload. It registers baseline keyboard, mouse, and standardized gamepad actions. It holds no gameplay state.
- `PlayerInput` clones actions into `p{player_id}_...`, assigns gamepad device IDs and optionally keyboard/mouse. This prevents every future local player responding to every controller. Only player one and one viewport are currently instantiated.
- `FactoryPlayer` owns locomotion, gravity, jump buffering/coyote time, and capped object shoves. Input, grabbing, interaction, and visuals are separate components.
- `MachineBase` owns the state enum, elapsed processing time, and state/progress/content/feedback signals. It exposes `interact`, `try_start`, and `interaction_text`; the player depends on this common interface, not on mixer internals.
- `MixerMachine` validates quantities, consumes accepted items, starts processing only with the exact recipe, and emits a single physical output. Wrong or duplicate inputs do not consume an item. Repeated start cannot duplicate production. The output slot remains occupied until the batch is claimed.
- `RecipeData` and `IngredientData` are immutable shared `.tres` definitions. Runtime quantities live in `MixerMachine.contents`; item ownership lives on the body. Never mutate shared resources to represent one machine or one can.
- The HUD observes game state and signals. HUD labels are never the source of truth. Environment labels and worker/machine animation do not drive simulation.

## Machine lifecycle

```text
IDLE → LOADING → PROCESSING (5s) → FINISHED → IDLE
         ↑          exact recipe      │       ↑
  accepted inputs                physical output
                                 claimed by player
```

`BROKEN` and `OVERHEATED`, plus power usage, temperature, damage, slot counts and jam probability, are explicit extension points. Breakdowns, power simulation, overheating, generic slot inventories and random jams are **not active** in this milestone. Ingredient instability/stickiness are data hooks only. The training mixer rejects extra caffeine instead of silently starting a chaos simulation.

Signals include `state_changed`, `progress_changed`, `contents_changed`, `feedback`, `batch_created`, `batch_collected`, `held_changed`, `claimed`, and `released`.

## Physics and interaction decisions

- 60 Hz physics; layers: 1 factory, 2 workers, 3 carryable objects, 4 interactable machines. Machines occupy factory + interaction layers.
- The camera ray respects walls, excludes the worker/held item, and requires a hit within 3.4 meters of the worker's chest. Looking at a distant machine is insufficient.
- Holding never reparents, freezes, or teleports a rigid body. A bounded velocity servo tracks a hand anchor; a chest-to-anchor wall ray retracts the target. Object dimensions, continuous collision detection, and solid colliders provide the remaining collision response.
- Held items temporarily ignore their holder and gravity, retaining world/other-item collisions. Releasing restores gravity and holder collisions. Hold Q/B/Circle to charge a throw; a quick release drops gently.
- Items can only have one holder. Mixer acceptance and consumption occur synchronously on the simulation thread. Items below the room recover at their spawn point; the worker recovers at spawn. Pause → Restart training is a complete reset.
- This is controllable stylized physics, not ragdoll locomotion. Wall pressure, stacking and controller feel need human playtesting before tuning for multiplayer.

## Co-op migration boundaries

Phase 1 is single-player. Phase 2 should introduce a local player/session registry, explicit join/leave, device assignment, per-player HUD and SubViewport split screen. Player-scoped input already exists; global pause and mouse capture are intentionally single-session concerns today.

Phase 3 should route pickup/load/start/drop commands through a host authority. Give players, items and machines stable network IDs; validate distance, state, ownership and capacity on the host. Replicate accepted state changes and snapshots, and interpolate item transforms on clients. Do not transmit keyboard events or attempt deterministic lockstep across rigid-body physics. Current direct node references and local synchronous claims are seams to replace, **not an implemented networking layer**. No RPCs or online promises are hidden in this slice.

Steam belongs behind a future platform-services adapter (session discovery, invites, achievements, presence, cloud saves). Production logic must remain runnable without Steam. No Steam API, SDK or account dependency is included.

## Map and content authoring

`factory/factory.tscn` composes reusable player and mixer scenes. `FactoryRoom` and `Graybox` construct original primitive geometry at runtime, so open the main scene and **run** it to see the room; the editor preview intentionally shows only scene roots. Gameplay components are replaceable independently of their placeholder visuals. Replace procedural room dressing with authored scenes as map production begins.

One enclosed room currently contains ingredient storage, mixing, a blocked future filling station, signs, and a small break bench. The rest of the factory districts belong to later milestones.

## Validation

See `README.md` for commands and `tests/README.md` for scope. Automated integration tests execute real scenes, physics ticks, device-scoped action commands, resource validation, mixer transactions, two production cycles, pause and recovery. Rendered smoke testing captures the real viewport; headless testing cannot establish visual correctness or controller feel.
