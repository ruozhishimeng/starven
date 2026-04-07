# Codebase Concerns

**Analysis Date:** 2026-04-06

## Tech Debt

**Animation Naming Inconsistency:**
- Issue: `player_idle.gd` and `player_run.gd` use PascalCase animation names (`Idle_`, `Run_`) while `basic_states/idle.gd` and `basic_states/move.gd` use lowercase (`idle`, `move`)
- Files: `Script/StateMachine/playerstates/player_idle.gd` (line 12), `Script/StateMachine/playerstates/player_run.gd` (line 28), `Script/StateMachine/basic_states/idle.gd` (line 11), `Script/StateMachine/basic_states/move.gd` (line 21)
- Impact: Animation playback may fail silently if state machine switches between player-specific and basic states
- Fix approach: Standardize on lowercase naming across all state files

**Inconsistent Facing Direction Variable:**
- Issue: `basic_character.gd` defines `facing_dir` (public), but `player_idle.gd` and `player_run.gd` access `character._facing_dir` (private with underscore prefix)
- Files: `Script/basic_character.gd` (line 17), `Script/StateMachine/playerstates/player_idle.gd` (line 12), `Script/StateMachine/playerstates/player_run.gd` (line 24)
- Impact: Player states may not properly read/write facing direction, causing incorrect idle animations after running
- Fix approach: Use `character.facing_dir` consistently or add a getter/setter

**Duplicate Cardinal Direction Conversion:**
- Issue: `to_cardinal()` exists in both `basic_character.gd` and `_to_cardinal()` in `player_run.gd`
- Files: `Script/basic_character.gd` (lines 44-48), `Script/StateMachine/playerstates/player_run.gd` (lines 44-48)
- Impact: Code duplication, potential for divergence
- Fix approach: Use `character.to_cardinal()` in player_run.gd

**Incomplete Line in tile_map_layer_grass.gd:**
- Issue: Line 15 has a dangling expression with no assignment
- File: `Script/tile_map_layer_grass.gd` (line 15)
- Code: `(newGrass.get_node("grass_1_back") as Sprite2D).flip_h` - accesses property without assignment
- Impact: Unintended behavior - grass back sprite flip state is never set
- Fix approach: Add `= randi_range(0, 1)` or remove the line

**Hardcoded Scene UID:**
- Issue: `tile_map_layer_grass.gd` uses a hardcoded UID that may change on reimport
- File: `Script/tile_map_layer_grass.gd` (line 3)
- Code: `const GRASS = preload("uid://ddkh4xhv0c6n5")`
- Impact: Scene may fail to load if asset is reimported or project is moved
- Fix approach: Use scene path or load dynamically

**Debug Print Statements:**
- Issue: `grass_generator.gd` contains multiple print statements for debugging
- Files: `Script/grass_generator.gd` (lines 142, 144, 185, 192, 195, 313)
- Impact: Performance degradation, console spam
- Fix approach: Remove or replace with proper logging utility

**SPEED Override in enemy_1.gd:**
- Issue: Enemy SPEED is hardcoded after potential @export override
- File: `Script/enemy_1.gd` (line 15)
- Code: `SPEED = 75.0` in `_ready()` overrides any @export value
- Impact: Designer cannot adjust enemy speed via Inspector
- Fix approach: Remove line 15 or use `@export` properly

---

## Known Bugs

**Enemy Move State Detection Threshold:**
- Issue: `enemy_move.gd` checks `direction.length() < 0.1` to lose target, but direction is calculated from `global_position.direction_to(target)` which is always normalized (length = 1.0)
- File: `Script/StateMachine/enemystates/enemy_move.gd` (line 19)
- Trigger: Enemy enters move state but never transitions out via this check
- Workaround: Relies on `enemy_idle.gd` re-detecting player to continue chase

**Chase State Null Check Redundancy:**
- Issue: `enemy_chase.gd` checks for null target (lines 12-16) but this should never happen since transition only occurs from idle which already verified target exists
- File: `Script/StateMachine/enemystates/enemy_chase.gd` (lines 12-16)
- Impact: Extra function call to `find_target()` each physics frame
- Workaround: Not critical, but unnecessary computation

---

## Security Considerations

**No Security Concerns Identified:**
- This is a single-player game with no network code
- No user input validation issues in current code
- No sensitive data handling

---

## Performance Bottlenecks

**FoliageSpawner Chunk Generation:**
- Issue: Chunk generation happens synchronously in main thread
- Files: `Script/grass_generator.gd`
- Cause: `_generate_chunk_data()` and scene instantiation run on same thread
- Impact: Potential frame drops when crossing chunk boundaries
- Improvement path: Use worker thread for generation or async instantiation

**No Object Pooling for Foliage:**
- Issue: Trees and grass are instantiated/despawned as chunks load/unload
- Files: `Script/grass_generator.gd`
- Cause: No object reuse
- Impact: GC pressure and allocation spikes
- Improvement path: Implement object pooling for foliage nodes

**Grass Area2D Monitoring:**
- Issue: Every grass node has an Area2D with monitoring enabled
- File: `Script/grass.gd`
- Cause: Each grass monitors all body_entered/exited events
- Impact: Performance scales poorly with grass density
- Improvement path: Use spatial partitioning or central event system

---

## Fragile Areas

**State Machine Initialization Order:**
- Files: `Script/StateMachine/state_machine.gd`, `Script/basic_character.gd`
- Why fragile: `@onready` variables in character may not be initialized when `state_machine.init()` is called during `super._ready()`
- Safe modification: Always call `super._ready()` first in child classes
- Test coverage: Only verified through runtime testing

**Player vs Basic Character State Mixing:**
- Files: `Script/StateMachine/playerstates/`, `Script/StateMachine/basic_states/`
- Why fragile: Player uses player-specific states with different naming conventions than basic states
- Safe modification: Never mix states between character types without renaming
- Test coverage: Not explicitly tested

**Animation Name Convention Mismatch:**
- Files: `Script/StateMachine/playerstates/player_idle.gd`, `Script/StateMachine/basic_states/idle.gd`
- Why fragile: Basic states call `play_animation(character.facing_dir, "idle")` but player states call `anim.play("Idle_" + suffix)` directly
- Safe modification: Always use the character type's play_animation method consistently
- Test coverage: Runtime verification only

---

## Scaling Limits

**Chunk-based Foliage System:**
- Current capacity: ~5x5 active chunks (25 chunks) with ~120 trees + 480 grass per chunk = ~6000 foliage nodes max
- Limit: Exceeding ~100 active chunks causes memory/stuttering issues
- Scaling path: Implement LOD system for distant chunks, reduce active radius

**Enemy AI Detection:**
- Current capacity: Single player group lookup via `get_first_node_in_group("player")`
- Limit: Only works with single player, breaks in multiplayer
- Scaling path: Pass target reference explicitly to avoid group lookup

**State Machine Per-Character:**
- Current capacity: One state machine per character node
- Limit: Hundreds of characters may have state machine overhead
- Scaling path: Consider shared state logic or component-based approach for many entities

---

## Dependencies at Risk

**Godot 4.6 Specific Features:**
- Risk: Uses `FastNoiseLite` (Godot built-in), Jolt Physics, D3D12 rendering
- Impact: Code may not work on Godot 3.x or newer 5.x without modification
- Migration plan: Stay on Godot 4.x LTS branch

**PackedScene UID Dependencies:**
- Risk: `uid://` protocol references in `tile_map_layer_grass.gd`
- Impact: Project reimport may break scene references
- Migration plan: Convert to resource path loading

---

## Test Coverage Gaps

**Untested State Transitions:**
- What's not tested: All state transitions are runtime-only verified
- Files: All state files in `Script/StateMachine/`
- Risk: Silent failures on incorrect state names or missing states
- Priority: Medium

**Untested Enemy AI Logic:**
- What's not tested: `detect_radius`/`lose_radius` hysteresis behavior under edge cases
- Files: `Script/enemy_1.gd`, `Script/StateMachine/enemystates/`
- Risk: Enemy may behave incorrectly when player is exactly at radius boundary
- Priority: Medium

**Untested Foliage Spawning:**
- What's not tested: Chunk generation edge cases (boundary positions, terrain validation)
- Files: `Script/grass_generator.gd`
- Risk: Crash or incorrect placement at world edges
- Priority: Low

**Untested Null References:**
- What's not tested: What happens when player node is not in "player" group
- Files: `Script/enemy_1.gd` (line 57)
- Risk: Silent null returns causing enemy to stop chasing
- Priority: High

---

*Concerns audit: 2026-04-06*
