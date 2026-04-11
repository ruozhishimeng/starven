# Plan: Phase 1 - Player Die State and Game Over UI

**Wave:** 2
**Depends On:** PLAN.foundation.md
**Files Modified:**
- Script/StateMachine/playerstates/player_die.gd (NEW)
- Scene/game_over.tscn (NEW)

## Overview

Implements player_die.gd state and game_over.tscn scene. When player HP <= 0, transitions to die state which freezes player and shows game over UI. Game over screen has dark overlay, "Game Over" text, and restart button.

---

## Tasks

### Task 3.1: Create player_die.gd state file

**read_first:**
- F:\starven\Script\StateMachine\State.gd
- F:\starven\Script\StateMachine\playerstates\player_attack.gd (reference for state structure)

**acceptance_criteria:**
- File exists at `Script/StateMachine/playerstates/player_die.gd`
- Extends `State` class
- Implements `Enter()` method (die state has no exit - game ends)
- `Enter()` sets `character.velocity = Vector2.ZERO`
- `Enter()` triggers game over UI via `get_tree().get_first_node_in_group("game_over_ui")`
- `Enter()` optionally pauses game with `get_tree().paused = true`

### Task 3.2: Create game_over.tscn scene

**read_first:**
- F:\starven\Script\player.gd (reference for player structure)

**acceptance_criteria:**
- File exists at `Scene/game_over.tscn`
- Scene root is `CanvasLayer`
- Contains `ColorRect` (black, full screen, name="Background")
- Contains `Label` with text="Game Over" (name="Title", centered)
- Contains `Button` with text="Restart" (name="RestartButton", centered below label)
- All nodes added to group "game_over_ui"
- Background has modulate alpha = 0 initially (for fade-in later)
- `RestartButton` has signal `pressed` connected to `_on_restart_pressed`

### Task 3.3: Implement restart button functionality

**read_first:**
- F:\starven\Scene\game_over.tscn (from Task 3.2)

**acceptance_criteria:**
- `_on_restart_pressed()` method unpauses tree: `get_tree().paused = false`
- `_on_restart_pressed()` reloads scene: `get_tree().reload_current_scene()`

---

## State Transition Logic

```
Any state --[HP <= 0]--> die
```

No transition out of die state - game over.

---

## Verification

1. Grep for `player_die.gd` in Script/StateMachine/playerstates/ - file must exist
2. Grep for `game_over` in Scene/game_over.tscn - scene must exist
3. Grep for `game_over_ui` in game_over.tscn - nodes must be in this group
4. Grep for `reload_current_scene` in game_over.tscn or player_die.gd - restart functionality present
5. Grep for `CanvasLayer` in game_over.tscn - root type correct

---

## Must-Haves (Goal-Backward)

- [x] Player enters die state when HP reaches 0
- [x] Game over screen shows black overlay
- [x] "Game Over" text displayed
- [x] Restart button present
- [x] Clicking restart reloads the current scene