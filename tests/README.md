# Verification notes

Validation run on 2026-10-03: Godot 4.6.3 on Linux; **69 checks passed, zero failures**. Clean editor import, integration suite and main-scene startup completed without script or engine errors. The rendered smoke test also completed successfully; only the virtual graphics driver reported unsupported VSync. Run the commands in the root README after importing the project.

`run_tests.gd` instantiates the actual factory scene and runs the physics engine. It covers resource identity/quantities, floor collision, movement/jump input, camera-ray selection, physical pickup/ownership and following, loading/consumption, duplicate rejection, the five-second processing boundary, double-start protection, pause, output-slot blocking, batch pickup/reset, supply replenishment, throw/gravity, out-of-bounds recovery, a second production cycle, device-specific input mappings/teardown, HUD placement, pause-menu focus, and actual scene restart.

The first cycle uses player-scoped action presses and real interaction rays. The second cycle exercises machine transaction commands directly; it does not claim to simulate player navigation. No external test framework is needed.

`capture_preview.gd` starts the real scene on a graphical display and captures the viewport after rendering. The reference image was produced on an Xorg dummy display with Mesa llvmpipe. This verifies rendering and layout, not a target-PC performance budget. A virtual-driver VSync warning is expected in this setup.

Still requires manual validation: physical Xbox / PlayStation controllers, hot-unplug hardware behavior, rumble (not implemented), unusual aspect ratios, sustained play feel, shipping GPU performance, and accessibility/rebinding options. Local split screen and online multiplayer do not exist yet.

Manual smoke path:

1. Launch, move/look/jump, approach ingredient bench, aim/grab each ingredient.
2. Test gentle drop and charged throw against floor and walls; recover the object.
3. Load all three into the mixer. Try starting early and submitting a duplicate.
4. Start, pause midway, resume, take output after five simulation seconds.
5. Verify supply replenishes and a second batch works.
6. Open pause with Esc/Start, use menu focus to restart, and verify clean initial state.
