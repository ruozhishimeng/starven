# Plan: Phase 1 - Player Hurt State

**Wave:** 2
**Depends On:** PLAN.foundation.md
**Files Modified:**
- Script/StateMachine/playerstates/player_hurt.gd (NEW)

## Overview

Implements player_hurt.gd state. When player takes damage (from enemy, hazard, etc.), transitions to this state. State applies knockback, enables invincibility, plays hurt animation, and returns to idle/move when knockback completes.

---

## Tasks

### Task 2.1: Create player_hurt.gd state file

**read_first:**
- F:\starven\Script\StateMachine\State.gd
- F:\starven\Script\StateMachine\playerstates\player_attack.gd (reference for state structure)
- F:\starven\Script\player.gd (for is_invincible, apply_knockback)

**acceptance_criteria:**
- File exists at `Script/StateMachine/playerstates/player_hurt.gd`
- Extends `State` class
- Implements `Enter()`, `Exit()`, `PhysicsProcess()` methods
- `Enter()` calls `character.apply_knockback()` with stored damage_source
- `Enter()` sets `character.is_invincible = true` and starts timer
- `Enter()` plays `hurt_{direction}` animation using `state_machine.play_directional_animation()`
- `PhysicsProcess()` applies friction deceleration to velocity
- `PhysicsProcess()` calls `character.move_and_slide()`
- `PhysicsProcess()` checks if knockback velocity < 10.0 to transition back to idle/move
- `Exit()` resets any temporary state

### Task 2.2: Connect invincibility timer and flash in player_hurt.gd

**read_first:**
- F:\starven\Script\player.gd
- F:\starven\Script\StateMachine\playerstates\player_hurt.gd (from Task 2.1)

**acceptance_criteria:**
- Timer callable `_on_invincible_timeout` exists
- `_on_invincible_timeout()` sets `character.is_invincible = false`
- `_on_invincible_timeout()` stops sprite flashing
- Flash mechanism uses Timer with 0.1s interval (per research: FLASH_INTERVAL = 0.1)

---

## State Transition Logic

```
Any state --[take damage via HurtBox, HP > 0]--> hurt
hurt --[timer finished + velocity.length() < 10]--> idle (if no input) or move (if moving)
```

---

## Verification

1. Grep for `player_hurt.gd` in Script/StateMachine/playerstates/ - file must exist
2. Grep for `apply_knockback` in player_hurt.gd - must be called in Enter()
3. Grep for `is_invincible = true` in player_hurt.gd - must be set in Enter()
4. Grep for `hurt_` animation play in player_hurt.gd - must call play_directional_animation with "hurt" prefix
5. Grep for `move_and_slide()` in player_hurt.gd - physics movement present

---

## Must-Haves (Goal-Backward)

- [x] Player enters hurt state when taking damage
- [x] Player knocked back away from damage source
- [x] Player invincible for 0.5s after damage
- [x] Player sprite flashes during invincibility
- [x] Player returns to idle/move when knockback completes