# Plan: Phase 1 - Player Interact State

**Wave:** 2
**Depends On:** PLAN.foundation.md
**Files Modified:**
- Script/StateMachine/playerstates/player_interact.gd (NEW)

## Overview

Implements player_interact.gd state. Player presses E key near an interactable object, automatically faces it, and triggers interaction. Detection uses Area2D with facing direction filter (dot product threshold 0.3).

---

## Tasks

### Task 4.1: Create player_interact.gd state file

**read_first:**
- F:\starven\Script\StateMachine\State.gd
- F:\starven\Script\StateMachine\playerstates\player_attack.gd (reference for state structure)
- F:\starven\Script\player.gd (for InteractArea reference via $InteractArea)

**acceptance_criteria:**
- File exists at `Script/StateMachine/playerstates/player_interact.gd`
- Extends `State` class
- Implements `Enter()`, `Exit()`, `HandleInput()` methods

### Task 4.2: Implement E key detection and interactable query

**read_first:**
- F:\starven\Script\StateMachine\playerstates\player_interact.gd (from Task 4.1)
- F:\starven\.planning\phases\01-movement-architecture\01-RESEARCH.md (for Area2D facing filter math)

**acceptance_criteria:**
- `HandleInput()` checks `Input.is_action_just_pressed("attack")` for E key (per D-07)
- `_get_nearest_interactable_in_facing_direction()` method implemented
- Uses `InteractArea` (Area2D) to get overlapping bodies
- Filters by group "interactable": `body.is_in_group("interactable")`
- Filters by facing direction: `to_body.normalized().dot(facing) > 0.3` (per research: ~70 degree cone)
- Range check: `dist <= 48.0` (per D-09: 32-48px range)

### Task 4.3: Implement auto-face and interaction trigger

**read_first:**
- F:\starven\Script\StateMachine\playerstates\player_interact.gd (from Task 4.2)
- F:\starven\Script\basic_character.gd (for to_cardinal method)

**acceptance_criteria:**
- `Enter()` calls `_get_nearest_interactable_in_facing_direction()`
- If no interactable found, immediately transitions to idle
- If interactable found:
  - Calculates direction to target: `target.global_position - character.global_position`
  - Sets `character.facing_dir = character.to_cardinal(dir_to_target)` (auto-face, per D-08)
  - Calls `target.interact()` on the interactable object
- After interaction, transitions to idle

---

## State Transition Logic

```
idle --[E key + interactable in range]--> interact
move --[E key + interactable in range]--> interact
interact --[interaction complete]--> idle (if no input) or move (if moving)
```

---

## Verification

1. Grep for `player_interact.gd` in Script/StateMachine/playerstates/ - file must exist
2. Grep for `InteractArea` in player_interact.gd - must reference player's InteractArea node
3. Grep for `is_in_group("interactable")` in player_interact.gd - group check present
4. Grep for `dot` in player_interact.gd - facing direction filter present
5. Grep for `to_cardinal` in player_interact.gd - auto-face implementation present
6. Grep for `interact()` in player_interact.gd - trigger method called

---

## Must-Haves (Goal-Backward)

- [x] Player can trigger interact with E key
- [x] Only interactables in front of player (within ~70 degree cone) are detected
- [x] Player automatically faces interactable before triggering
- [x] Interaction only works at close range (32-48px)
- [x] State transitions to idle after interaction completes