# ENERGY INC. — delivery roadmap

Every milestone must import, launch and remain playable. Extend existing components, run regression tests, and document architecture changes before advancing.

## 01 — Foundation and mixing lab (implemented)

- Godot 4.x project, reusable scenes, recipe and ingredient Resources.
- One original graybox room, one stylized worker, mouse/keyboard + gamepad mappings.
- Camera-relative movement, jumping, collision, physical pickup, carrying, drop and charged throw.
- Water, caffeine and mango; exact-recipe mixer, five-second processing, physical six-serving batch.
- Training checklist, progress, contextual prompts, pause/restart, automatic material replenishment.
- Integration suite and rendered viewport smoke test.

Acceptance: collect all three ingredients, load/start mixer, take batch, repeat without restarting. See `tests/README.md` for verified coverage and hardware limitations.

## 02 — Complete the first production loop (next)

1. Introduce resource-backed item definitions / can state, then `CanFiller : MachineBase` using the existing interaction interface. Transfer the batch once; track six remaining servings without mutating the shared RecipeData.
2. Add six physical empty cans and filler input/output handling. One empty can + one serving produces one Tropical Shock can. Explicitly prevent duplicate consumption and output blockage loss.
3. Add resource-backed order specification and runtime order instance: Gym Bro GmbH, six Tropical Shock cans, 180 seconds, $420 reward, $100 timeout penalty.
4. Add loading/delivery area. Count only matching filled cans, consume each delivered can exactly once, pay once when all six arrive, and generate the next order.
5. Add authoritative deadline/economy state and factory display/HUD. Pause freezes the shift clock; restart restores starting money and materials. Define negative-balance handling before penalties ship.
6. Supply enough resources for successive orders. Test wrong products, duplicate delivery, timeouts, cancellation, occupied outputs and repeated shifts.

Acceptance: START → order → three ingredients → 5s mixing → batch transfer → six empty cans → six filled cans → delivery → reward → new order. A human can complete the whole loop using only a controller. This milestone is the first full vertical slice, not the full game.

## 03 — Local co-op, 2–4 players

- Player registry, join/leave, explicit device assignment, per-player cameras/HUD/split screen.
- Host-local shared machine transactions and exclusive object claims; no global movement input.
- Test disconnect/reconnect and two players grabbing/loading the same object.
- Tune room circulation and handoff distances through actual co-op playtests.

Acceptance: four players can complete repeatable shifts without duplication, lost ownership or cross-controller input.

## 04 — Production depth and controlled chaos

- Modular `CanSealer`, `LabelMachine`, `PackagingMachine`; boxes and order packing.
- Additional original resource recipes: Blue Panic, Nuclear Melon, Zero IQ Zero Sugar.
- Expand ingredient properties to actual batch composition/quality; bounded excess input rules.
- Event director with a seed and intensity budget: spills/slips, pressure, overheating, jams, power interruptions and reversible conveyors.
- Chain reactions through physics and signals, with cooldowns, recovery tools and readability. Do not spawn arbitrary disasters before basic production remains fun under pressure.
- Expand this factory with warehouse, loading bay and control room; environmental humor, sound and animation pass.

Acceptance: disasters create recoverable, legible co-op decisions; players can explain why an incident occurred.

## 05 — Online co-op

- Host-authoritative command validation, network IDs, replication/interpolation, lobby/session abstraction.
- Latency simulation; ownership races, disconnect policy and reconnect scope.
- Verify whole shifts under realistic latency/packet loss before integrating platform matchmaking.

## 06 — Progression and Steam readiness

- Shift economy, machine upgrades, versioned saves, accessibility and rebinding/settings UI.
- Cosmetic-only unlocks, original hats/outfits, character animation and UI/audio polish.
- Steam adapter: matchmaking/invites, achievements, presence, cloud save policy.
- Export presets and release build pipeline, Steam Deck/controller hardware matrix, performance budgets, localization, credits/licenses, QA and store deliverables.

Release scope and schedule should be estimated after the complete single-player loop and local co-op playtests establish production cost and fun. No release date is implied by this roadmap.
