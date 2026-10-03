# Verification — v0.2.0

Run `./tests/run_checks.sh` after installing Godot 4.6.3. It imports the project, runs both suites and starts the main scene, failing on engine/script errors as well as failed assertions.

- `run_tests.gd`: **69 checks** covering the original mixing loop, movement/jump/floor collision, real camera rays and player actions, dynamic holding, exclusive claims, duplicate ingredient rejection, timing, pause, output blocking/reset, replenishment, throwing/recovery, two batches, scoped gamepad mappings and scene restart.
- `production_tests.gd`: **83 checks** for the complete six-can order: real batch transfer and player interaction with dispenser/filler/delivery, input rejection, six-output accounting, tray stability and selectable outputs, repeated-start protection, deadline freeze on pause, correct product validation, exactly-once reward, next-order reset, exactly-once timeout penalty and restart cleanup. A watchdog prevents silent script failures from hanging the suite.
- `capture_preview.gd`: captures the actual rendered game to `docs/milestone-02.png`. A local Xorg display and Mesa llvmpipe were used. The virtual driver reports unsupported VSync; this is not a game script error.
- `tools/verify_macos_export.py`: checks ZIP CRCs, executable bits, universal Mach-O x86_64/arm64 slices, ad-hoc code-page hashes and signed bundle resource hashes. Also extracts the shipped PCK to `/tmp/energy-macos.pck` for an independent startup check.

The Mac application's exported PCK is launched under Godot 4.6.3 on Linux. The native Mach-O executable **cannot be run on this Linux environment**. There is no claim that native macOS startup, Gatekeeper, physical Xbox/PlayStation controllers or shipping GPU performance were tested.

The suites exercise real physics and commands, but reposition the actor to focus on interactions instead of pretending to be human navigation tests. Only human playtesting can judge game feel and co-op readability.

Manual release checklist:

1. Download the Mac ZIP, unpack, approve the individual app if requested, launch without Godot installed.
2. Walk, orbit camera, jump, grab/drop/throw, bump into carried items and walls.
3. Complete water/caffeine/mango → mix → batch transfer → six empties → fill → six deliveries.
4. Verify $420 and the next order; allow another order to time out once.
5. Pause during processing, resume, toggle fullscreen, restart and quit.
6. Repeat using only each supported controller; verify UI prompts, menu focus and reconnect behavior.
