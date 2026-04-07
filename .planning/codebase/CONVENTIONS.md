# Coding Conventions

**Analysis Date:** 2026/04/06

## Language

**Primary:**
- GDScript (Godot 4.6)

**Type System:**
- Explicit type declarations required, especially for return values that may be null
- Use type hints on function parameters and return types

## Naming Conventions

### Files

**Class Files (PascalCase):**
- `BasicCharacter.gd`
- `StateMachine.gd`
- `State.gd`

**Regular Scripts (snake_case):**
- `grass_generator.gd`
- `foliage_spawner.gd`
- `grass_random.gd`

### Nodes in Scene Tree

| Node Type | Convention | Example |
|-----------|------------|---------|
| State nodes | lowercase | `idle`, `move`, `chase` |
| Character nodes | PascalCase | `Player`, `Enemy` |
| Manager nodes | PascalCase | `StateMachine`, `FoliageSpawner` |

### Variables and Functions

- `camelCase` for variables: `facing_dir`, `detect_radius`, `lose_radius`
- `PascalCase` for functions: `get_input_direction()`, `play_animation()`, `find_target()`
- `SCREAMING_SNAKE_CASE` for constants: `INPUT_DEADZONE`, `_DIALOG_CHECK_INTERVAL`
- Leading underscore for private members: `_test_results`, `_MCP_AUTOLOADS`

### Animation Naming

Format: `{prefix}_{direction}`

| Animation | Format | Examples |
|-----------|--------|----------|
| Idle | `idle_{direction}` | `idle_down`, `idle_left`, `idle_right`, `idle_up` |
| Move | `move_{direction}` | `move_down`, `move_left`, `move_right`, `move_up` |
| Chase | `chase_{direction}` | `chase_down`, `chase_left`... |
| Hurt | `hurt_{direction}` | `hurt_down`, `hurt_left`... |

**Direction Priority:** `y > 0` → down | `y < 0` → up | `x > 0` → right | `x < 0` → left

## Code Style

### Formatting

- `charset = utf-8` (from `.editorconfig`)
- Indentation: Standard Godot/GDScript formatting
- Chinese comments are preserved and encouraged for educational content

### Type Declarations

**Function return types (required when nullable):**
```gdscript
func get_input_direction() -> Vector2:
    return Vector2.ZERO

func find_target(in_range_only: bool = false) -> Node2D:
    # ...
    return target  # May be null
```

**Variable declarations:**
```gdscript
var currentState: State
var states: Dictionary = {}
var facing_dir := Vector2(0, 1)
```

### Decorators

**`@export`** - Editor-configurable parameters:
```gdscript
@export var SPEED := 200.0
@export var ACCELERATION := 800.0
@export var detect_radius := 300.0
```

**`@onready`** - Delayed node reference initialization:
```gdscript
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine
```

**`@tool`** - Editor plugins only:
```gdscript
@tool
extends EditorPlugin
```

### Inheritance and super

**Calling parent initialization:**
```gdscript
func _ready() -> void:
    super._ready()  # Initialize state machine
```

### Error Handling

**`push_error()`** - For subclass contract violations:
```gdscript
func get_input_direction() -> Vector2:
    push_error("BasicCharacter: 子类必须实现 get_input_direction()")
    return Vector2.ZERO
```

**`push_warning()`** - For non-critical warnings:
```gdscript
push_warning("[MCP] Auto-pressed debugger Continue button")
```

### State Machine Patterns

**State transition (strictly uses lowercase node names):**
```gdscript
state_machine.change_state("idle")   # Correct
state_machine.change_state("Idle")   # Wrong - will not find state
```

**State lifecycle methods:**
```gdscript
func Enter() -> void:
    # Initialize state
    pass

func Exit() -> void:
    # Cleanup state
    pass

func Ready() -> void:
    # One-time setup (like _ready)
    pass
```

### Movement Patterns

**CharacterBody2D movement:**
```gdscript
# Acceleration-based movement
character.velocity = character.velocity.move_toward(
    direction * character.SPEED,
    character.ACCELERATION * delta
)
character.move_and_slide()

# Friction/deceleration
character.velocity = character.velocity.move_toward(
    Vector2.ZERO,
    character.FRICTION * delta
)
character.move_and_slide()
```

## Import Organization

GDScript uses `preload()` for compile-time imports:
```gdscript
const WebSocketServer = preload("res://addons/godot_mcp/websocket_server.gd")
```

Godot autoloads are accessed globally by their registered name:
```gdscript
ProjectSettings.set_setting(key, "*" + script)
```

## Comments

**Chinese comments are standard** - The project preserves Chinese comments for educational value.

**Doc comments use `##`:**
```gdscript
## 状态基类
## 所有具体状态（如 player_idle, player_run）都应该继承这个类
```

**Inline comments use `#`:**
```gdscript
## 检测是否停止移动
if direction.length() < 0.1:
```

## Module Design

**Exports:** Use `class_name` for globally accessible classes:
```gdscript
extends Node
class_name StateMachine
```

**State pattern:** Each state is a separate node/script file under StateMachine

---

*Convention analysis: 2026/04/06*
