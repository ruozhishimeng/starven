# Phase 1 Research: Movement & Architecture

**Research Date:** 2026/04/11
**Phase:** 01-movement-architecture
**Status:** Ready for planning

---

## Executive Summary

Phase 1 extends existing Move-01/Move-02 work with three new states: Hurt (0.5s invincibility + knockback), Die (game over screen), and Interact (E key + auto-face + Area2D detection). The existing state machine architecture (StateMachine -> State -> BasicCharacter -> Player/Enemy) is well-suited for these additions. No structural changes to existing architecture required.

---

## 1. Godot 4.6 CharacterBody2D Hurt/Invincibility Patterns

### Existing Foundation

- `BasicCharacter.gd` already provides movement physics (SPEED=200, ACCELERATION=800, FRICTION=800)
- `CharacterBody2D` is the base class — supports `move_and_slide()` for physics-based movement
- Player collision layer = 2, Enemy collision layer = 4

### Invincibility Implementation Options

**Option A: Boolean flag with timer (Recommended)**
```gdscript
var is_invincible := false
var invincible_timer := 0.0
const INVINCIBLE_DURATION := 0.5

func take_damage(amount: int, damage_source: Node2D) -> void:
    if is_invincible:
        return
    # Apply damage, start invincibility
    is_invincible = true
    invincible_timer = INVINCIBLE_DURATION
```

**Option B: Modulate collision shape**
```gdscript
# Disable collision during invincibility
$CollisionShape2D.disabled = true
```

### Visual Feedback (Blink/Flash)

Godot 4.6 provides `modulate` property on all CanvasItem-based nodes:

```gdscript
# Flash white during invincibility
const FLASH_COLOR := Color(1.0, 0.3, 0.3)  # Red tint
const FLASH_INTERVAL := 0.1  # 10 flashing per second

# In _process or via Timer
sprite.modulate = Color.WHITE if flash_on else Color(1.0, 1.0, 1.0)

# Alternative: modulate alpha
sprite.modulate.a = 0.5  # Semi-transparent
```

**Recommended approach:** Use a `Timer` node with `timeout` signal for 100ms interval, toggle sprite visibility on each timeout. This is simpler and more performant than `_process` toggling.

---

## 2. Knockback Implementation in Godot 4.6

### Pattern Overview

Knockback is an impulse applied to `velocity` that decays over time via friction. Since `BasicCharacter` uses `CharacterBody2D.move_and_slide()`, knockback is natural.

### Implementation

```gdscript
## In BasicCharacter or Player
const KNOCKBACK_FORCE := 400.0

func apply_knockback(damage_source: Node2D) -> void:
    # Direction: from damage source TO player
    var knockback_dir := global_position - damage_source.global_position
    knockback_dir = knockback_dir.normalized()

    # Apply as immediate velocity impulse
    velocity = knockback_dir * KNOCKBACK_FORCE
    # move_and_slide() will handle deceleration via FRICTION
```

### Integration with Hurt State

The `Hurt` state should:
1. Lock player input during knockback
2. Apply knockback velocity
3. Let physics handle deceleration
4. Transition back to `idle`/`move` once velocity is near zero or timer expires

```gdscript
# In player_hurt.gd
func PhysicsProcess(delta: float) -> void:
    character.velocity = character.velocity.move_toward(
        Vector2.ZERO,
        character.FRICTION * delta
    )
    character.move_and_slide()

    # Check if knockback finished
    if character.velocity.length() < 10.0:
        state_machine.change_state("idle")
```

---

## 3. Area2D Detection with Facing Direction Filtering

### Existing Pattern

The `AttackHitBox` on the player already uses `Area2D` for attack detection. A similar pattern applies for interactables.

### Interact Area2D Design

```gdscript
# Node structure on Player:
# InteractArea (Area2D)
#   - collision_layer = 0 (doesn't block)
#   - collision_mask = [interactable layer]
#   - shape: CircleShape2D, radius = 40px (within 32-48px range)

# In player or interact state:
func _get_nearest_interactable_in_facing_direction() -> Node2D:
    var interact_area = $InteractArea
    if interact_area == null:
        return null

    var bodies := interact_area.get_overlapping_bodies()
    var facing := character.facing_dir  # Vector2

    var nearest: Node2D = null
    var nearest_dist := INF

    for body in bodies:
        if not body.is_in_group("interactable"):
            continue

        var to_body := body.global_position - character.global_position
        var dist := to_body.length()

        # Filter: must be in front (dot product > 0)
        if to_body.normalized().dot(facing) <= 0.3:  # ~70 degree cone
            continue

        if dist < nearest_dist and dist <= 48.0:
            nearest = body
            nearest_dist = dist

    return nearest
```

### Facing Direction Filter Math

Dot product between facing direction and direction-to-object determines if object is "in front":
- `dot > 0`: Object is in front hemisphere
- `dot > 0.5`: ~60 degree cone
- `dot > 0.7`: ~45 degree cone

Using `0.3` gives ~70 degree cone, which is reasonable for "in front of player."

---

## 4. Game Over Screen / Scene Transition Approaches

### Option A: CanvasLayer Overlay (Recommended for v1)

Simplest approach — add a full-screen UI layer when player dies.

```gdscript
# In player_die.gd or via signal
func Enter() -> void:
    character.velocity = Vector2.ZERO
    # Freeze player (optional, can leave visible underneath)

    # Show game over UI via signal or direct node access
    var game_over_ui = get_tree().get_first_node_in_group("game_over_ui")
    if game_over_ui:
        game_over_ui.show()

    # Pause game if desired
    # get_tree().paused = true
```

Game Over UI scene structure:
```
game_over_ui (CanvasLayer)
  - ColorRect (black, full screen, modulate for fade-in)
  - Label ("Game Over", centered, large font)
  - Button ("Restart", centered below label)
```

**Restart behavior:**
```gdscript
func _on_restart_pressed() -> void:
    get_tree().paused = false
    get_tree().reload_current_scene()
```

### Option B: Separate Game Over Scene

```gdscript
# In player_die.gd
func Enter() -> void:
    get_tree().change_scene_to_file("res://Scene/game_over.tscn")
```

More disruptive to game flow but cleaner separation.

### Recommendation

**Option A** (CanvasLayer overlay) is recommended:
- Simpler to implement and test
- Player remains visible under darkened overlay
- No scene transition delay
- Easier to add fade-in animation later

---

## 5. Interact System Patterns (Auto-Face + Proximity)

### Auto-Face Implementation

When interact is triggered, player should face the interactable before interacting:

```gdscript
# In player_interact.gd
func Enter() -> void:
    var target := _get_nearest_interactable_in_facing_direction()
    if target == null:
        state_machine.change_state("idle")
        return

    # Auto-face the interactable
    var dir_to_target := target.global_position - character.global_position
    character.facing_dir = character.to_cardinal(dir_to_target)

    # Play interact animation (optional)
    # Play interact sound (optional)

    # Trigger interact after brief delay (optional, for animation)
    await get_tree().create_timer(0.2).timeout
    _do_interact(target)

    state_machine.change_state("idle")
```

### Interactable Interface

Objects that can be interacted with should implement a common pattern:

```gdscript
# Interactable.gd (optional base class or interface)
class_name Interactable
extends Area2D

func interact() -> void:
    pass  # Override in subclasses
```

### Trigger Conditions

Per D-07 through D-10:
- **Trigger:** E key press
- **Range:** 32-48 pixels (use CircleShape2D radius ~40)
- **Detection:** Area2D around player, filtered by facing direction
- **Auto-face:** Player rotates to face interactable before interaction

---

## 6. State Machine Integration Points

### New States Needed

1. `player_hurt.gd` — extends `State`
2. `player_die.gd` — extends `State`
3. `player_interact.gd` — extends `State`

### State Transitions

```
idle --[direction > deadzone]--> move
idle --[E key + interactable]--> interact
move --[direction < deadzone]--> idle
move --[E key + interactable]--> interact
attack --[animation finished]--> idle/move

Any state --[take damage, HP > 0]--> hurt
Any state --[HP <= 0]--> die
hurt --[timer finished + velocity ~0]--> idle/move
```

### Blocking Attack During Hurt

Attack state should check invincibility before allowing transition:
```gdscript
# In player_idle.gd HandleInput or PhysicsProcess
if Input.is_action_pressed("attack"):
    if not character.is_invincible:  # Can't attack while invincible
        state_machine.change_state("attack")
```

---

## 7. Key Files to Modify

| File | Changes |
|------|---------|
| `Script/player.gd` | Add `is_invincible`, `invincible_timer`, `take_damage()`, `apply_knockback()`, HP management |
| `Scene/player.tscn` | Add `InteractArea` (Area2D child), add `HurtBox` for receiving damage |
| `Script/StateMachine/state_machine.gd` | Likely no changes (existing patterns sufficient) |
| `Script/StateMachine/playerstates/player_hurt.gd` | **New file** — 0.5s invincibility, knockback physics |
| `Script/StateMachine/playerstates/player_die.gd` | **New file** — game over screen trigger |
| `Script/StateMachine/playerstates/player_interact.gd` | **New file** — E key + auto-face + Area2D query |
| `Scene/game_over.tscn` | **New file** — CanvasLayer with dark overlay, "Game Over" label, Restart button |

---

## 8. Implementation Notes from Codebase

### Reusable Patterns Already Established

1. **Direction suffix mapping:** `_dir_to_suffix()` in `player_idle.gd`/`player_run.gd` — reuse this
2. **Animation naming:** `idle_down`, `run_left`, `attack_right` — new states follow same convention
3. **Facing direction:** `character.facing_dir` tracked in Run, read in Idle
4. **State transition pattern:** `state_machine.change_state("state_name")`
5. **Physics movement:** `character.velocity.move_toward()` + `character.move_and_slide()`

### Collision Layers

Per CLAUDE.md and existing code:
- Layer 1: Static (world)
- Layer 2: Player
- Layer 4: Enemy

For interactables: Use layer 8 (per CLAUDE.md `grass=8`), or create new layer 16 for interactables.

### Input Deadzone

Already implemented: `INPUT_DEADZONE := 0.2` in `player.gd`

---

## 9. Open Questions

1. **Hurt animation:** Should there be a `hurt_down/left/right/up` animation, or just use existing sprites with flash effect?
2. **Interact prompt:** Should UI show "Press E to interact" when near interactable? (Recommended for UX)
3. **Game over fade:** Should game over screen fade in over 0.5-1s, or appear immediately?
4. **Interactables in Phase 1:** Will there be actual interactable objects (chests), or is this infrastructure-only?

---

## 10. References

### Godot 4.6 Documentation (to verify)
- CharacterBody2D: https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html
- Area2D: https://docs.godotengine.org/en/stable/classes/class_area2d.html
- CanvasLayer: https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html

### Patterns from Existing Codebase
- `Script/StateMachine/playerstates/player_attack.gd` — frame-based hitbox timing (model for invincibility timer)
- `Script/StateMachine/state_machine.gd` — `play_directional_animation()` helper
- `Script/basic_character.gd` — movement physics foundation

---

*Research completed: 2026/04/11*
*Ready for planning: yes*
