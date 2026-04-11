# Plan: Phase 1 - State Machine Integration

**Wave:** 3
**Depends On:** PLAN.hurt.md, PLAN.die.md, PLAN.interact.md, PLAN.foundation.md (Task 1.4)
**Files Modified:**
- Script/StateMachine/playerstates/player_idle.gd (input handling for attack/interact)
- Script/StateMachine/playerstates/player_run.gd (input handling for attack/interact)
- Script/StateMachine/playerstates/player_attack.gd (blocking attack during hurt)

## Overview

Integrates new states (hurt, die, interact) into the existing state machine. Updates idle/run/attack states to handle new transitions. State nodes (hurt, die, interact) were added in Wave 1 foundation (PLAN.foundation.md Task 1.4).

---

## Tasks

### Task 5.2: Update player_idle.gd for attack/interact transitions

**read_first:**
- F:\starven\Script\StateMachine\playerstates\player_idle.gd
- F:\starven\Script\StateMachine\playerstates\player_attack.gd (for attack trigger reference)

**acceptance_criteria:**
- `PhysicsProcess()` checks `Input.is_action_just_pressed("attack")` for E key (D-07)
- Attack transition blocked if `character.is_invincible == true`
- Interact transition when interactable in range (calls same query as player_interact.gd)
- Transition: `state_machine.change_state("attack")` or `state_machine.change_state("interact")`

### Task 5.3: Update player_run.gd for attack/interact transitions

**read_first:**
- F:\starven\Script\StateMachine\playerstates\player_run.gd
- F:\starven\Script\StateMachine\playerstates\player_idle.gd (from Task 5.2)

**acceptance_criteria:**
- `PhysicsProcess()` checks `Input.is_action_just_pressed("attack")` for E key
- Attack transition blocked if `character.is_invincible == true`
- Same interact transition logic as idle

### Task 5.4: Update player_attack.gd to block attack during hurt/invincible

**read_first:**
- F:\starven\Script\StateMachine\playerstates\player_attack.gd
- F:\starven\Script\player.gd (for is_invincible reference)

**acceptance_criteria:**
- Attack cannot be triggered while `character.is_invincible == true`
- When attacked during invincibility, attack input is ignored (no transition)

---

## Verification

1. Grep for `hurt` in Scene/player.tscn - hurt state node present
2. Grep for `die` in Scene/player.tscn - die state node present
3. Grep for `interact` in Scene/player.tscn - interact state node present
4. Grep for `is_invincible` in player_idle.gd - invincibility check present
5. Grep for `is_invincible` in player_run.gd - invincibility check present
6. Grep for `is_action_just_pressed.*attack` in player_idle.gd - E key check present

---

## Must-Haves (Goal-Backward)

- [x] All new states (hurt, die, interact) registered in player scene
- [x] Player can transition from idle/run to attack with E key
- [x] Player cannot attack while invincible (hurt state)
- [x] Player can transition from idle/run to interact with E key
- [x] State machine properly initialized with all 6 states