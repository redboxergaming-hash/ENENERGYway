# ENERGY INC. — roadmap

Every milestone must remain runnable. Inspect and reuse existing systems, run regressions, verify the actual render and document state/ownership changes.

## 01 — Mixing lab (complete)

Godot project, original room, one worker, scoped keyboard/gamepad inputs, physics pickup/carry/throw, ingredient/recipe Resources and five-second mixer. Original regression suite retained.

## 02 — Playable production shift and visual pass (complete, v0.2.0)

- Original rounded Blender-generated 3D models, animated worker, remodeled mixer, filler, dispenser and delivery counter.
- Factory art, lighting/camera pass, original icon, target outlines, small-item assistance, readable order/recipe HUD and world order display.
- Physical batch transfer, empty-can supply, six-can filler with bounded inputs/outputs and quantity accounting.
- Six-can order, 180-second deadline, atomic delivery, $420 reward / $100 timeout penalty, subsequent orders and money balance.
- Original synthesized audio, pause/restart/fullscreen/quit.
- Mac universal `.app` ZIP, export presets, structural signature checks and download instructions.
- Automated complete production loop and failure-path tests.

Acceptance exercised in simulation: mixer → batch → filler + six empties → six physical cans → delivery → money → new order. Mac packaging is verified; actual macOS/physical controller playtesting remains open.

## 02.1 — Hardware and feel validation (next)

- Launch the downloaded app on Apple Silicon and Intel Macs; check Gatekeeper and controllers.
- Tune camera distance, can targeting, walking/jumping and grab stability from human feedback.
- Profile representative integrated GPUs; confirm 16:9, 16:10 and ultrawide layouts.
- Add volume/sensitivity/rebinding/accessibility settings and versioned preference storage.
- Move downloadable binaries from development Git history to a repeatable release pipeline; add Apple Developer ID signing/notarization when credentials are available.

## 03 — Local co-op, 2–4 players

Player/session registry; explicit join/leave/device assignment; per-player cameras and HUD; split screen; shared pause policy. Test simultaneous claims, loading races, disconnect/reconnect and complete repeated shifts with four players. No networking until this loop is fun and reliable.

## 04 — Production depth and recoverable chaos

Separate CanSealer, LabelMachine and PackagingMachine; boxes, packing and more recipes. Turn ingredient properties into actual batch quality with explicit excess-input rules. Add a seeded event director, intensity limits and recovery tools: spills/slips, overheating, pressure, reversible conveyors, power failures and readable physical chains. Expand the original map gradually with warehouse/control/loading areas.

Acceptance: players can understand causes and recover; production stays enjoyable under pressure.

## 05 — Online co-op

Host-authoritative commands, stable IDs, replication/interpolation, ownership conflict handling and session abstraction. Test latency, packet loss, host departure and reconnect policy across whole shifts before integrating Steam.

## 06 — Progression and Steam release preparation

Versioned saves, upgrades, cosmetic-only unlocks, achievements/presence/cloud save policy, Steam matchmaking/invites, polished animation/audio, localization, accessibility, QA and performance budgets. Estimate release scope after full local co-op playtests; no release date is implied.
