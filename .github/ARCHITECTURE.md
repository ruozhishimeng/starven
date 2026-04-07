---
name: Starven Architecture Patterns
description: "Use for technical decisions about scene design, component architecture, Resource patterns, and system-level implementations in Starven."
---

# Starven - Technical Architecture Reference

## 🎯 Design Philosophy

**Starven** implements three core architectural patterns to support rapid iteration and scalable game development:

1. **Data-Driven Design** - Configuration lives in Resource files
2. **Component Pattern** - Reusable, composable behavioral components
3. **Signal-Based Communication** - Decoupled event-driven systems

---

## 📐 Component Architecture

### Player Architecture
```
Player (Node2D)
├── Sprite2D (visual)
├── CollisionShape2D (physics)
├── AnimationPlayer (animations)
├── StateMachine (Node) - manages state transitions
│   ├── State nodes (IdleState, MoveState, ActionState, DeadState)
└── Components
    ├── StatsComponent (health, hunger, stamina)
    ├── InventoryComponent (item management)
    ├── CombatComponent (attack logic)
    └── InputController (player input handling)
```

### Component Pattern Example

Each component is an **autoload or child node** that encapsulates behavior:

```gdscript
# Scripts/Systems/StatsComponent.gd
extends Node
class_name StatsComponent

@export var max_health: int = 100
@export var max_hunger: int = 100

var current_health: int
var current_hunger: int

signal health_changed(new_value: int)
signal hunger_changed(new_value: int)
signal player_died

func _ready() -> void:
    current_health = max_health
    current_hunger = max_hunger

func take_damage(amount: int) -> void:
    current_health = maxi(0, current_health - amount)
    health_changed.emit(current_health)
    if current_health == 0:
        player_died.emit()

func add_hunger(amount: int) -> void:
    current_hunger = mini(max_hunger, current_hunger + amount)
    hunger_changed.emit(current_hunger)
```

**Benefits:**
- Testable in isolation
- Reusable across enemies, NPCs, food sources
- Signals decouple health UI from player logic

---

## 🗂️ Resource File Patterns

### Item Resource
```gdscript
# Scripts/Resources/ItemData.gd
extends Resource
class_name ItemData

@export var item_id: String
@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: String = "common"  # common, uncommon, rare, epic
@export var stackable: bool = true
@export var max_stack: int = 64
```

**Usage:** Create `res://Resources/Items/IronAxe.tres`
```
[ItemData]
item_id = "iron_axe"
display_name = "Iron Axe"
description = "A sturdy tool for cutting trees"
icon = res://Asset/Items/iron_axe.png
rarity = "uncommon"
stackable = false
```

### Recipe Resource
```gdscript
# Scripts/Resources/RecipeData.gd
extends Resource
class_name RecipeData

@export var recipe_id: String
@export var result_item: ItemData
@export var result_quantity: int = 1
@export var ingredients: Array[ItemData]
@export var ingredient_quantities: Array[int]
@export var crafting_time: float = 2.0
```

### Enemy Stats Resource
```gdscript
# Scripts/Resources/EnemyData.gd
extends Resource
class_name EnemyData

@export var enemy_id: String
@export var display_name: String
@export var max_health: int = 25
@export var attack_damage: int = 5
@export var attack_speed: float = 1.0
@export var movement_speed: float = 100.0
@export var drop_items: Array[ItemData]
@export var drop_rates: Array[float]  # 0.0 to 1.0
```

### Biome Configuration
```gdscript
# Scripts/Resources/BiomeData.gd
extends Resource
class_name BiomeData

@export var biome_id: String
@export var display_name: String
@export var tilesets: Array[TileSet]
@export var resource_spawn_rules: Array[BiomeSpawnRule]
@export var noise_threshold_min: float = 0.0
@export var noise_threshold_max: float = 0.33
```

---

## 🎭 State Machine Pattern

Use a **hierarchical state machine** for player and enemy behavior:

```gdscript
# Scripts/Systems/StateMachine.gd
extends Node
class_name StateMachine

var current_state: State
var states: Dictionary[String, State] = {}

func _ready() -> void:
    for child in get_children():
        if child is State:
            states[child.name] = child
            child.state_machine = self

    change_state("Idle")

func change_state(state_name: String) -> void:
    if current_state:
        current_state.exit()
    
    current_state = states.get(state_name)
    if current_state:
        current_state.enter()

func _input(event: InputEvent) -> void:
    if current_state:
        current_state.handle_input(event)

func _process(delta: float) -> void:
    if current_state:
        current_state.process(delta)
```

```gdscript
# Scripts/Player/States/IdleState.gd
extends State
class_name IdleState

func enter() -> void:
    owner.get_node("AnimationPlayer").play("idle")

func handle_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left") \
           or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
            state_machine.change_state("Move")

func process(delta: float) -> void:
    pass
```

---

## 🔄 Signal Communication Pattern

**Never do this:**
```gdscript
# ❌ BAD: Direct coupling
health_bar.health = stats_component.current_health
```

**Do this instead:**
```gdscript
# ✅ GOOD: Signal-driven
stats_component.health_changed.connect(health_bar.set_health)
```

**Example in a scene:**
```gdscript
# In MainLevel.gd setup
func _ready() -> void:
    var player: Player = get_node("Player")
    var ui_manager: UIManager = get_node("UI/UIManager")
    
    # Connect signals - UI updates when player stats change
    player.stats.health_changed.connect(ui_manager.update_health_bar)
    player.stats.hunger_changed.connect(ui_manager.update_hunger_bar)
    player.stats.player_died.connect(show_game_over)
```

---

## 🌍 World Generation Flow

```
FastNoiseLite.get_noise_2d(x, y)
        ↓
[0.0 - 1.0] noise value
        ↓
Map to biome threshold ranges:
  - 0.0-0.33  → Grassland
  - 0.33-0.66 → Forest
  - 0.66-1.0  → Wasteland
        ↓
Instantiate resources based on biome:
  - Forest: Trees (high density)
  - Grassland: Berries (medium density)
  - Wasteland: Enemies (low density)
        ↓
Place in TileMapLayer
```

---

## 📦 Dependency Injection Pattern

For manageable systems, use scene structure or explicit injection:

```gdscript
# BAD: Hard dependency
var inventory = InventoryManager.new()

# GOOD: Injected or referenced via scene
@onready var inventory: InventoryComponent = get_node("InventoryComponent")
```

---

## 🧪 Testing Strategy

For component testing, create **isolated scenes**:

```
Tests/
├── StatsComponentTest.tscn        # Tests StatsComponent in isolation
├── InventoryComponentTest.tscn    # Tests InventoryComponent
└── WorldGeneratorTest.tscn        # Tests world generation
```

Example test:
```gdscript
# In your testing framework
func test_stats_component_damage() -> void:
    var stats = StatsComponent.new()
    stats.current_health = 100
    stats.take_damage(30)
    assert_equal(stats.current_health, 70)
```

---

## 🎨 Scene Organization Best Practice

**Flatten unnecessary hierarchy:**
```gdscript
# ✅ GOOD: Minimal nesting
Player (Node2D)
├── Sprite2D
├── CollisionShape2D
└── StateMachine

# ❌ AVOID: Over-nesting
Player
├── VisualContainer
│   ├── Sprite2D
│   └── Effects
├── PhysicsContainer
│   └── CollisionShape2D
└── LogicContainer
    ├── StateMachine
    └── Components
```

---

## 🔗 Inter-System Communication Example

```gdscript
# Player takes damage from enemy attack
# Enemy.gd
func attack_player(player: Player) -> void:
    player.stats.take_damage(attack_damage)  # Emits health_changed signal

# Player.gd receives signal and updates game state
# Elsewhere: MainLevel.gd
func _ready() -> void:
    player.stats.player_died.connect(_on_player_died)

func _on_player_died() -> void:
    ui_manager.show_game_over()
    game_state = GameState.PAUSED
```

---

## ✅ Checklist for New Systems

- [ ] Create Resource class if data-heavy
- [ ] Use signals for state changes
- [ ] Make components reusable
- [ ] Avoid circular dependencies
- [ ] Write scene structure docs
- [ ] Test components in isolation
- [ ] Reference PRD for feature requirements
- [ ] Update this architecture doc if adding major patterns

---

For implementation examples, refer to specific system files in `Scripts/` folder.
