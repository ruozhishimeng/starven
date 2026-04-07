---
name: Starven GDScript Development
description: "Use when creating or editing .gd GDScript files in the Starven project. Applies conventions, patterns, and architectural guidelines specific to Godot 4.6 code."
applyTo: "**/*.gd"
---

# GDScript Code Guidelines for Starven

## 🎯 When This Applies

This instruction applies automatically to all `.gd` (GDScript) files in Starven. Use guidance from [ARCHITECTURE.md](./../ARCHITECTURE.md) for system design patterns.

---

## 📝 File Structure Template

Every GDScript file should follow this structure:

```gdscript
extends [ParentClass]
class_name [ClassName]

# ============================================================
# Signals (top, grouped)
# ============================================================
signal stat_changed(new_value: int)
signal action_completed

# ============================================================
# Exports (properties exposed in editor)
# ============================================================
@export var max_value: int = 100
@export var update_speed: float = 1.0

# ============================================================
# Onready references (to other nodes in scene)
# ============================================================
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# ============================================================
# Private variables
# ============================================================
var current_value: int
var is_active: bool = false
var _internal_cache: Dictionary = {}

# ============================================================
# Lifecycle Methods
# ============================================================
func _ready() -> void:
    """Called when node enters scene tree."""
    current_value = max_value
    _setup_signals()

func _process(delta: float) -> void:
    """Called every frame."""
    pass

func _physics_process(delta: float) -> void:
    """Called every physics frame."""
    pass

# ============================================================
# Public Methods
# ============================================================
func reset_value() -> void:
    """Public-facing method to reset state."""
    current_value = max_value
    stat_changed.emit(current_value)

# ============================================================
# Private Methods
# ============================================================
func _setup_signals() -> void:
    """Internal initialization of signal connections."""
    pass

func _update_internal_state() -> void:
    """Private helper for internal logic."""
    pass
```

---

## 📋 Naming Conventions

| Element | Pattern | Example |
|---------|---------|---------|
| Class name | `PascalCase` | `class_name PlayerController` |
| Files | `PascalCase.gd` | `Player.gd`, `StatsComponent.gd` |
| Functions | `snake_case` | `take_damage()`, `_setup_signals()` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_HEALTH = 100` |
| Public variables | `snake_case` | `current_health` |
| Private variables | `_snake_case` | `_internal_state`, `_cache` |
| Signals | `snake_case` | `health_changed`, `item_added` |
| Enums | `PascalCase` | `enum State { IDLE, MOVING, ATTACKING }` |

---

## 🎯 Coding Standards

### Type Hints (Required in Godot 4.6)
```gdscript
# ✅ DO: Always use type hints
func take_damage(amount: int) -> void:
    current_health -= amount

func get_item_name() -> String:
    return current_item.name

# ❌ DON'T: Omit types
func take_damage(amount):
    current_health -= amount
```

### Use Signals for Communication
```gdscript
# ✅ GOOD: Signal-based
signal player_died
signal health_changed(new_health: int)

func die() -> void:
    player_died.emit()

# ❌ BAD: Direct coupling
# game_manager.end_game()  # Direct reference dependency
```

### Component Reusability
```gdscript
# ✅ GOOD: Generic, reusable component
extends Node
class_name StatsComponent

var health: int
func take_damage(amount: int) -> void:
    health -= amount

# Can be attached to Player, Enemy, Boss, NPC, etc.

# ❌ BAD: Hardcoded to Player
extends Node
class_name PlayerStatsComponent

func player_take_damage(amount: int) -> void:
    player.health -= amount
```

### Constants and Enums
```gdscript
# ✅ GOOD: Clear state management
enum State { IDLE, MOVING, ATTACKING, DEAD }
const DEFAULT_HEALTH: int = 100
const MOVE_SPEED: float = 150.0

var current_state: State = State.IDLE

# ❌ BAD: Magic numbers scattered in code
if state == 0:
    move_speed = 150.0
```

### Error Handling
```gdscript
# ✅ GOOD: Validate inputs
func set_health(new_health: int) -> bool:
    if new_health < 0:
        push_error("Health cannot be negative: %d" % new_health)
        return false
    health = new_health
    return true

# ❌ BAD: Silently fail
func set_health(new_health: int) -> void:
    health = new_health
```

---

## 🔌 Signal Pattern

Every component that changes state should emit signals:

```gdscript
extends Node
class_name ExampleComponent

signal value_changed(new_value: int)

var _value: int = 0

func set_value(new_value: int) -> void:
    if _value != new_value:
        _value = new_value
        value_changed.emit(_value)

func get_value() -> int:
    return _value
```

**Connect in parent scenes:**
```gdscript
# In MainLevel.gd or Player.gd
func _ready() -> void:
    component.value_changed.connect(_on_component_value_changed)

func _on_component_value_changed(new_value: int) -> void:
    print("Component changed to: %d" % new_value)
```

---

## 📦 Resource-Based Configuration

Never hardcode configuration:

```gdscript
# ✅ GOOD: Load from Resource
extends Node
class_name Enemy

@export var enemy_data: EnemyData  # Assign .tres file in editor

func _ready() -> void:
    health = enemy_data.max_health
    attack_damage = enemy_data.attack_damage

# ❌ BAD: Hardcoded values
var health: int = 25
var attack_damage: int = 5
var name: String = "Goblin"
```

---

## 🧹 Code Organization Tips

### Group Related Methods
```gdscript
# Group by responsibility
# ============================================================
# Input Handling
# ============================================================
func handle_input(event: InputEvent) -> void:
    pass

# ============================================================
# Physics/Movement
# ============================================================
func move(velocity: Vector2) -> void:
    pass

# ============================================================
# State Management
# ============================================================
func change_state(new_state: State) -> void:
    pass
```

### Avoid Deep Nesting
```gdscript
# ✅ GOOD: Early exit reduces indentation
func process_item(item: ItemData) -> void:
    if not item:
        return
    
    if not inventory.has_space():
        return
    
    inventory.add_item(item)

# ❌ BAD: Deep nesting
func process_item(item: ItemData) -> void:
    if item:
        if inventory.has_space():
            inventory.add_item(item)
```

---

## 🔗 Common Patterns in Starven

### StatsComponent Pattern
All stat-tracking components should follow this:
```gdscript
extends Node
class_name StatsComponent

@export var max_health: int = 100

signal health_changed(new_value: int)
signal stat_depleted  # When a vital stat reaches 0

var current_health: int

func _ready() -> void:
    current_health = max_health

func take_damage(amount: int) -> void:
    current_health = maxi(0, current_health - amount)
    health_changed.emit(current_health)
    
    if current_health == 0:
        stat_depleted.emit()
```

### State Machine Pattern
Use State base class:
```gdscript
extends Node
class_name State

var state_machine: StateMachine

func enter() -> void:
    """Called when entering this state."""
    pass

func exit() -> void:
    """Called when leaving this state."""
    pass

func handle_input(event: InputEvent) -> void:
    """Handle input in this state."""
    pass

func process(delta: float) -> void:
    """Update logic for this state."""
    pass
```

---

## ✅ Pre-Commit Checklist

Before committing your .gd file:

- [ ] Does it have a clear class name? `class_name MyClass`
- [ ] Are all functions typed? `func example() -> void:`
- [ ] Are private variables prefixed with underscore? `_private_var`
- [ ] Are signals defined at the top?
- [ ] Does it use signals for state changes instead of direct references?
- [ ] Are exports (`@export`) used for editor configuration?
- [ ] Is there a docstring on complex functions?
- [ ] Does it follow the file structure template?
- [ ] Is there hardcoded data that should be Resource files?

---

## 🚫 Anti-Patterns to Avoid

| Anti-Pattern | Why Bad | Fix |
|---|---|---|
| Circular dependencies | Causes infinite loops, hard to debug | Use signals |
| Global state (not Autoload) | Untrackable, conflicts | Use dependency injection |
| Deep nesting (>3 levels) | Hard to read | Early exit/extract functions |
| Magic numbers | Unclear intent | Use named constants |
| Direct references to sibling nodes | Tight coupling | Use signals |
| Ignoring type hints | Runtime errors | Always use types |
| Duplicate code | Hard to maintain | Extract to shared function |
| Mixing logic and presentation | Can't reuse logic | Separate concerns |

---

For architecture patterns, see [ARCHITECTURE.md](./../ARCHITECTURE.md).
For project structure, see [copilot-instructions.md](./../copilot-instructions.md).
