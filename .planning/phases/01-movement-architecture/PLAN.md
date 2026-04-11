# Phase 1: Movement & Architecture - Plan Summary

**Phase:** 01-movement-architecture
**Status:** Ready for Execution
**Created:** 2026/04/11

---

## Overview

Phase 1 establishes core player movement (already implemented: MOVE-01, MOVE-02) and extends with new states (Hurt, Die, Interact) to support future combat and loot phases.

---

## Plan Files

| Plan | Wave | Depends On | Description |
|------|------|------------|-------------|
| `PLAN.foundation.md` | 1 | None | Player.gd invincibility/knockback, player.tscn InteractArea/HurtBox |
| `PLAN.hurt.md` | 2 | PLAN.foundation.md | player_hurt.gd state with knockback + invincibility |
| `PLAN.die.md` | 2 | PLAN.foundation.md | player_die.gd state + game_over.tscn UI |
| `PLAN.interact.md` | 2 | PLAN.foundation.md | player_interact.gd state with E key + auto-face |
| `PLAN.state-transitions.md` | 3 | All Wave 2 plans | State node registration + transition updates |

---

## Execution Order

### Wave 1 (Parallel-Ready Foundation)
Execute `PLAN.foundation.md` first - all other plans depend on it.

### Wave 2 (New States - Parallel)
After Wave 1 completes, execute these in parallel:
- `PLAN.hurt.md`
- `PLAN.die.md`
- `PLAN.interact.md`

These are independent of each other and can run in parallel.

### Wave 3 (Integration)
After Wave 2 completes, execute `PLAN.state-transitions.md`.

---

## Requirements Coverage

### MOVE-01: Player moves with WASD keyboard input
- **Status:** Already implemented (per D-11)
- **Files:** Script/player.gd, Script/StateMachine/playerstates/player_run.gd

### MOVE-02: Player sprite faces movement direction
- **Status:** Already implemented (per D-12)
- **Files:** Script/StateMachine/playerstates/player_run.gd (facing_dir tracking), Script/basic_character.gd

### New in Phase 1:
- **Hurt state:** 0.5s invincibility, knockback, blink/flash visual
- **Die state:** Game over screen (black + "Game Over" + restart)
- **Interact state:** E key trigger, auto-face, 32-48px range, facing direction filter

---

## Key Decisions

| Decision | Value |
|----------|-------|
| D-01 Phase Priority | Extend with Hurt + Die + Interact |
| D-02 Invincibility Duration | 0.5 seconds |
| D-03 Knockback | Away from damage source, normalized |
| D-04 Visual Feedback | Blink/sprite flash during invincibility |
| D-05 Death | Show game over screen |
| D-06 No death animation | Immediate game over on HP depletion |
| D-07 Interact Trigger | E key (same as attack action) |
| D-08 Auto-face | Player faces interactable before interacting |
| D-09 Interaction Range | 32-48 pixels (use 40px radius CircleShape2D) |
| D-10 Facing Filter | Dot product > 0.3 (~70 degree cone) |

---

## Files Modified Summary

| File | Operation |
|------|-----------|
| Script/player.gd | Modify - add invincibility, knockback, damage system |
| Scene/player.tscn | Modify - add InteractArea, HurtBox, new state nodes |
| Script/StateMachine/playerstates/player_hurt.gd | New - hurt state |
| Script/StateMachine/playerstates/player_die.gd | New - die state |
| Script/StateMachine/playerstates/player_interact.gd | New - interact state |
| Scene/game_over.tscn | New - game over UI scene |
| Script/StateMachine/playerstates/player_idle.gd | Modify - add attack/interact transition |
| Script/StateMachine/playerstates/player_run.gd | Modify - add attack/interact transition |
| Script/StateMachine/playerstates/player_attack.gd | Modify - block attack during invincibility |

---

## Verification Gates

All plans include grep-verifiable acceptance criteria. Final verification:

1. All new .gd files exist in Script/StateMachine/playerstates/
2. game_over.tscn exists in Scene/
3. player.tscn contains InteractArea, HurtBox, and new state nodes
4. Grep-verifiable conditions pass for each task
5. Phase goal: Player can move (done), take damage (new), die (new), interact (new)