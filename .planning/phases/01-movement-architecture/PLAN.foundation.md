# Plan: Phase 1 Foundation - Player Core Modifications

**Wave:** 1
**Depends On:** None (all new files build on existing architecture)
**Files Modified:**
- Script/player.gd
- Scene/player.tscn

## Overview

Foundation layer for Phase 1. Adds invincibility system, knockback mechanism, and damage handling to the Player. Also adds required Area2D nodes (InteractArea, HurtBox) to the player scene. All other Phase 1 plans depend on this.

---

## Tasks

### Task 1.1: Add invincibility and knockback properties to player.gd

**read_first:**
- F:\starven\Script\player.gd
- F:\starven\Script\basic_character.gd

**acceptance_criteria:**
- `is_invincible: bool` property exists and defaults to false
- `invincible_timer: float` property exists
- `INVINCIBLE_DURATION: float` constant = 0.5
- `KNOCKBACK_FORCE: float` constant = 400.0
- `take_damage(amount: int, damage_source: Node2D)` method implemented
- `apply_knockback(damage_source: Node2D)` method implemented
- `is_invincible` guard in `take_damage()` prevents repeated damage

### Task 1.2: Add hurt visual feedback (blink/timer) to player.gd

**read_first:**
- F:\starven\Script\player.gd
- F:\starven\Script\StateMachine\state_machine.gd

**acceptance_criteria:**
- Timer node `InvincibleTimer` exists and is connected
- `FLASH_INTERVAL: float` constant = 0.1
- Sprite visibility toggles every 0.1s during invincibility
- `modulate` alternates between Color.WHITE and normal during flash

### Task 1.3: Add InteractArea and HurtBox to player.tscn

**read_first:**
- F:\starven\Scene\player.tscn
- F:\starven\Script\StateMachine\state_machine.gd (for reference on optional nodes)

**acceptance_criteria:**
- `InteractArea` (Area2D) child node exists with:
  - collision_layer = 0
  - collision_mask = 8 (interactable layer, per CLAUDE.md grass=8)
  - CircleShape2D radius = 40px (within 32-48px range per D-09)
  - Node path: `../InteractArea`
- `HurtBox` (Area2D) child node exists with:
  - collision_layer = 0
  - collision_mask = 4 (enemy layer)
  - Suitable shape for player body

### Task 1.4: Add hurt, die, interact state nodes to player.tscn

**read_first:**
- F:\starven\Scene\player.tscn
- F:\starven\Script\StateMachine\state_machine.gd

**acceptance_criteria:**
- Empty `hurt` (Node) child node exists under `StateMachine`
- Empty `die` (Node) child node exists under `StateMachine`
- Empty `interact` (Node) child node exists under `StateMachine`
- Node names are lowercase per CLAUDE.md convention
- Scripts NOT attached yet (scripts added in Wave 2)

---

## Verification

1. Grep for `is_invincible` in player.gd - must find property declaration and usage in `take_damage()`
2. Grep for `KNOCKBACK_FORCE` in player.gd - must find constant and usage in `apply_knockback()`
3. Grep for `InteractArea` in player.tscn - must find Area2D node with CircleShape2D
4. Grep for `HurtBox` in player.tscn - must find Area2D node

---

## Must-Haves (Goal-Backward)

- [x] Player can receive damage and become invincible for 0.5s
- [x] Player sprite flashes during invincibility
- [x] Player receives knockback away from damage source
- [x] Player has Area2D for interactable detection
- [x] Player has Area2D for receiving damage