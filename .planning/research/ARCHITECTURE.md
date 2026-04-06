# Architecture Research

**Domain:** 2D Godot Survival Roguelite
**Researched:** 2026/04/06
**Confidence:** MEDIUM

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Autoload Layer                           │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │GameMaster│  │SignalBus │  │SaveSystem│  │AudioMgr  │     │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘     │
└───────┴────────────┴────────────┴─────────────┴────────────┘
                            ↓ signals
┌─────────────────────────────────────────────────────────────┐
│                    Scene Manager Layer                       │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────────┐   │
│  │                   [World Scene]                        │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │TileMap   │  │Player    │  │Enemies   │            │   │
│  │  │Generator │  │StateMach │  │Manager   │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                   [UI Scene]                           │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │HUD       │  │Inventory │  │ShopUI    │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓ resource references
┌─────────────────────────────────────────────────────────────┐
│                    Resource/Data Layer                       │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │ItemDB    │  │WeaponDB  │  │EnemyDB   │  │LootTable │    │
│  │(Resource)│  │(Resource)│  │(Resource)│  │(Resource)│    │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| GameMaster (Autoload) | Global game state, run progression, difficulty scaling | Singleton with `current_run` dictionary, handles run start/end |
| SignalBus (Autoload) | Decouple systems via signals | `Resource` subclass or static class with `signal` declarations |
| SaveSystem (Autoload) | Persist player progress, unlocks, settings | JSON file via `FileAccess`, triggered on run end |
| AudioManager (Autoload) | Pooled sound playback | Preload audio streams, `AudioStreamPlayer` pool |
| WorldManager | Scene transitions, procedural generation orchestration | Loads/unloads world scenes, owns map generator |
| TileMapGenerator | Procedural dungeon/overworld layout | `TileMap` + custom generation algorithm (WFC, BSP, cellular automata) |
| Player | Player entity with state machine | `CharacterBody2D` + `StateMachine` child node |
| EnemyManager | Spawning, pooling, AI coordination | Manages `EnemySpawner` nodes, object pool |
| Enemy (base) | Individual enemy AI and behavior | Extends base enemy class, uses state machine for AI |
| Item/Weapon (Resource) | Data containers for items, weapons, stats | `Resource` subclasses with exported properties |
| Inventory | Player item management | `Array[ItemResource]` with add/remove/swap logic |
| HUD | On-screen stats, health bars, minimap | `Control` nodes, subscribes to signals |
| ShopUI | Run-between shopping interface | `Control` scene, activated during interlude |

## Recommended Project Structure

```
res://
├── autoload/
│   ├── game_master.gd         # Global state, run management
│   ├── signal_bus.gd          # Centralized signal hub
│   ├── save_system.gd         # Persistence
│   └── audio_manager.gd       # Sound pooling
├── entities/
│   ├── player/
│   │   ├── player.tscn        # Player scene
│   │   ├── player.gd          # Controller
│   │   ├── player_states/     # State machine states
│   │   │   ├── idle.gd
│   │   │   ├── move.gd
│   │   │   ├── attack.gd
│   │   │   ├── hurt.gd
│   │   │   └── die.gd
│   │   └── state_machine.gd   # State machine logic
│   ├── enemies/
│   │   ├── base_enemy.tscn
│   │   ├── base_enemy.gd      # Shared enemy logic
│   │   └── enemy_types/       # Specific enemy variants
│   │       ├── slime.tscn
│   │       ├── slime.gd
│   │       └── skeleton.tscn
│   └── loot/
│       ├── item.gd            # Base item resource
│       ├── weapon.gd          # Weapon resource extends item
│       └── armor.gd
├── resources/
│   ├── items/
│   │   ├── item_db.tres       # Item registry
│   │   ├── weapon_db.tres
│   │   └── loot_tables/       # Drop table resources
│   ├── enemies/
│   │   └── enemy_db.tres      # Enemy registry
│   └── levels/
│       ├── room_templates/    # Predefined room scenes
│       └── level_gen_config.tres
├── world/
│   ├── world_manager.gd       # Scene loading orchestration
│   ├── map_generator.gd      # Procedural generation
│   ├── tile_map.tscn         # TileMap scene
│   └── tilemap_generator.gd  # TileMap population
├── ui/
│   ├── hud/
│   │   ├── hud.tscn
│   │   └── hud.gd
│   ├── inventory/
│   │   ├── inventory_ui.tscn
│   │   └── inventory_ui.gd
│   ├── shop/
│   │   ├── shop.tscn
│   │   └── shop.gd
│   └── menus/
│       ├── main_menu.tscn
│       └── pause_menu.tscn
├── systems/
│   ├── combat/
│   │   ├── hitbox_component.gd    # Damage delivery
│   │   ├── hurtbox_component.gd  # Damage reception
│   │   └── damage_calculator.gd  # Stat-based damage
│   ├── inventory/
│   │   └── inventory_system.gd
│   └── spawner/
│       └── enemy_spawner.gd
├── scenes/
│   ├── levels/
│   │   ├── level_01.tscn       # Test/debug level
│   │   └── level_template.tscn
│   └── menus/
│       └── title_screen.tscn
└── project.godot
```

### Structure Rationale

- **autoload/:** Game-wide singletons that persist across scenes. Only place truly global state here.
- **entities/:** All game entities organized by type. Player and enemies are leaf nodes that extend base classes.
- **resources/:** `Resource` subclass data files (`.tres`). These are loadable data containers for items, enemies, loot tables. Keeps data separate from logic.
- **world/:** Map generation and world management. Depends on entity resources but not on entities themselves.
- **ui/:** All interface components. Should subscribe to SignalBus, never directly call entity logic.
- **systems/:** Reusable components that attach to entities (Hitbox, Hurtbox). Promotes composition over inheritance.
- **scenes/:** Packed scenes for levels and menus. Minimal logic, mostly scene composition.

## Architectural Patterns

### Pattern 1: Autoload Singleton (GameMaster)

**What:** Global game state accessible from any script via `get_tree().root.get_node("/root/GameMaster")` or shorthand.

**When to use:** Managing run state, score, difficulty progression, player unlocks across scenes.

**Trade-offs:** Convenient access but creates implicit coupling. Any script can reach it. Avoid putting game logic here — only state storage and scene tree navigation.

```gdscript
# Autoload: game_master.gd
extends Node

var current_run: Dictionary = {}
var player_stats: Dictionary = {}
var unlocked_items: Array[String] = []
var run_score: int = 0

func start_new_run():
    current_run = {
        "level": 1,
        "enemies_killed": 0,
        "items_collected": [],
        "gold": 0
    }
    run_score = 0

func end_run():
    SaveSystem.save_progress(self)
    current_run.clear()
```

### Pattern 2: Signal Bus (Decoupling)

**What:** Centralized signal hub that decouples emitters from listeners.

**When to use:** UI needs to react to player damage, audio needs to react to events, any many-to-one communication.

**Trade-offs:** Prevents tight coupling but can become an unmaintainable grab-bag. Use namespaced signal names and document signal contracts.

```gdscript
# Autoload: signal_bus.gd
extends Node

# Player events
signal player_damaged(amount: int, source: Node)
signal player_died
signal player_healed(amount: int)

# Combat events
signal enemy_killed(enemy: Node, loot: Array)
signal item_pickup(item_resource: Resource)

# Run events
signal level_completed
signal run_started
signal run_ended(final_score: int)

# UI events
signal inventory_updated
signal gold_changed(new_total: int)
```

### Pattern 3: State Machine (Player/Enemies)

**What:** Behavior split into discrete states with transitions.

**When to use:** Player input response, enemy AI behavior, any entity with distinct modes that affect available actions.

**Trade-offs:** More boilerplate than simple match statements but scales better, easier to debug, and allows states to own their own enter/exit logic.

```gdscript
# state_machine.gd
extends Node
class_name StateMachine

var current_state: State
var states: Dictionary = {}

func _ready():
    for child in get_children():
        if child is State:
            states[child.name] = child
            child.state_machine = self
    if states.size() > 0:
        current_state = states.values()[0]
        current_state.enter()

func _process(delta):
    current_state.update(delta)

func _physics_process(delta):
    current_state.physics_update(delta)

func transition_to(state_name: String):
    if states.has(state_name):
        current_state.exit()
        current_state = states[state_name]
        current_state.enter()

# state.gd (base class)
class_name State
var state_machine: StateMachine

func enter(): pass
func exit(): pass
func update(_delta): pass
func physics_update(_delta): pass
```

```gdscript
# Example: player attack state
extends State

func enter():
    player.animation_player.play("attack")
    player.velocity = Vector2.ZERO

func physics_update(delta):
    # Attack logic, hitbox activation
    if player.animation_player.is_playing() == false:
        state_machine.transition_to("idle")
```

### Pattern 4: Resource-Based Item/Weapon Design

**What:** Items and weapons are `Resource` subclasses loaded from `.tres` files, not instanced scenes.

**When to use:** Items, weapons, armor, enemy stats, loot tables. Data that defines "what something is" rather than "how something behaves."

**Trade-offs:** Clean separation of data from logic. Allows hot-reloading of balance data. But `Resource` subclasses require `.tres` file creation per item — can be verbose for many items.

```gdscript
# weapon.gd
class_name Weapon
extends Resource

@export var name: String = "Sword"
@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var knockback: float = 50.0
@export var sprite: Texture2D
@export var projectile_scene: PackedScene  # For ranged weapons
```

```gdscript
# In player script
@export var starting_weapon: Weapon

func attack():
    var damage_dealt = weapon.damage * attack_multiplier
    # Apply damage via hitbox component
    hitboxComponent.apply_damage(damage_dealt, weapon.knockback)
```

### Pattern 5: Component Pattern (Hitbox/Hurtbox)

**What:** Small reusable components attached to entities that handle specific concerns.

**When to use:** Damage systems, inventory attachments, effect applicators. Any feature that needs to be added to multiple entity types.

**Trade-offs:** Promotes reuse and composition. But Godot's scene instance system means components can't be freely mixed like ECS — you add them as child nodes.

```gdscript
# hitbox_component.gd
class_name HitboxComponent
extends Area2D

@export var damage: int = 10
@export var knockback_force: float = 50.0
@export var knockback_direction: Vector2 = Vector2.RIGHT

signal hit_landed(hurtbox: HurtboxComponent)

func _ready():
    area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
    if area is HurtboxComponent:
        area.receive_hit(self)
        hit_landed.emit(area)
```

### Pattern 6: TileMap-Based World with Procedural Generation

**What:** Use Godot's `TileMap` node for world rendering, populated by a procedural generation algorithm.

**When to use:** Dungeon crawlers, top-down survival games with tile-based movement.

**Trade-offs:** `TileMap` is efficient for rendering but adds complexity for arbitrary collision shapes. Consider using `TileSet` with physics layers rather than separate collision nodes.

```gdscript
# tilemap_generator.gd
extends TileMap

@export var width: int = 50
@export var height: int = 50
@export var room_min_size: int = 5
@export var room_max_size: int = 15
@export var room_count: int = 20

func generate():
    clear()
    var rooms = generate_rooms()
    connect_rooms(rooms)
    place_tiles()

func generate_rooms() -> Array:
    # BSP or random room placement
    pass

func connect_rooms(rooms: Array):
    # L-shaped corridor carving between rooms
    pass
```

### Pattern 7: Object Pooling (Enemies/Projectiles)

**What:** Pre-instantiate and reuse entity instances rather than create/destroy.

**When to use:** Enemies, projectiles, particles, loot drops. Anything spawned frequently that causes GC pressure.

**Trade-offs:** Memory trade-off for frame stability. More complex setup than raw `instance()`.

```gdscript
# enemy_pool.gd
extends Node

@export var enemy_scene: PackedScene
@export var pool_size: int = 20

var pool: Array[Node] = []

func _ready():
    for i in pool_size:
        var enemy = enemy_scene.instantiate()
        enemy.set_process(false)
        enemy.visible = false
        pool.append(enemy)
        add_child(enemy)

func get_enemy() -> Node:
    for enemy in pool:
        if not enemy.visible:
            enemy.visible = true
            enemy.set_process(true)
            return enemy
    # Overflow: instantiate new
    var new_enemy = enemy_scene.instantiate()
    pool.append(new_enemy)
    add_child(new_enemy)
    return new_enemy

func return_enemy(enemy: Node):
    enemy.visible = false
    enemy.set_process(false)
    enemy.global_position = Vector2.ZERO
```

## Data Flow

### Player Attack Flow

```
[Player Input: Space/Click]
    ↓
[Player._unhandled_input()] → [StateMachine.transition_to("attack")]
    ↓
[AttackState.enter()] → [enable hitbox, play animation]
    ↓
[Enemy Hitbox overlaps Hurtbox] → [Hurtbox.receive_hit()]
    ↓
[Enemy.take_damage(damage)] → [Enemy HP reduced, play hurt animation]
    ↓
[Enemy HP <= 0] → [enemy.die()] → [SignalBus.enemy_killed.emit()]
    ↓
[SignalBus listener: GameMaster] → [increment kill count]
[SignalBus listener: LootSystem] → [roll loot, spawn drops]
[SignalBus listener: AudioManager] → [play death sound]
```

### Item Pickup Flow

```
[Player Body overlaps Item]
    ↓
[Player._on_item_area_entered()] → [Inventory.add_item(item_resource)]
    ↓
[SignalBus.item_pickup.emit(item_resource)]
    ↓
[SignalBus listener: HUD] → [update UI indicators]
[SignalBus listener: AudioManager] → [play pickup sound]
[SignalBus listener: AchievementSystem] → [check unlocks]
```

### Run Progression Flow

```
[GameMaster.start_new_run()]
    ↓
[WorldManager.load_level(1)] → [MapGenerator.generate()]
    ↓
[Spawner.spawn_waves()] → [EnemyPool.get_enemy()]
    ↓
[All enemies dead] → [SignalBus.level_completed.emit()]
    ↓
[GameMaster.level_cleared()] → [increment level, scale difficulty]
    ↓
[WorldManager.load_next_level() or load_shop()]
```

### State Management

```
[GameMaster (Autoload)]
    ↑
    │  Signals (reactive)
    │
[Player] ←→ [State Machine] → [SignalBus] ←→ [UI/HUD]
                                    ↓
[WorldManager] ←→ [EnemyManager] → [LootSystem]
```

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| Single room, <20 entities | Single scene, simple node hierarchy, no pooling needed |
| Procedural levels, <50 active entities | TileMap generation, basic object pooling, signal decoupling |
| Multi-floor roguelite, <200 active entities | Scene-based level loading, proper enemy pooling, data-driven spawner |
| Full roguelite with leaderboards, <1000 concurrent | Database-backed save system, server-side run tracking, performance profiling critical |

### Scaling Priorities

1. **First bottleneck: Scene switching** — If loading between levels causes hitches, implement async scene loading with loading screen.
2. **Second bottleneck: Entity count** — Godot's `Area2D` and `RayCast2D` can lag with many entities. Use spatial partitioning (GridMap) for broad-phase collision.
3. **Third bottleneck: Signal bus spam** — Too many signals per frame causes overhead. Batch events or use `_process` polling for high-frequency events.

## Anti-Patterns

### Anti-Pattern 1: Godot Node Tree as Data Store

**What people do:** Store game state scattered across arbitrary nodes in the scene tree (e.g., `get_node("/root/Main/Level/Player/Stats/HP")`).

**Why it's wrong:** Ties logic to scene structure. Refactoring scene breaks all hardcoded paths. No single source of truth.

**Do this instead:** Use Autoload singletons for global state. Use `Resource` files for data definitions. Pass references via `export` variables or dependency injection.

### Anti-Pattern 2: Monolithic Player Script

**What people do:** Put all player logic (movement, combat, inventory, quests) in one `player.gd` file with thousands of lines.

**Why it's wrong:** Unmaintainable. Bug hunting requires reading unrelated code. State machine transitions become convoluted.

**Do this instead:** Use state machine for behavior, component pattern for features (separate `inventory_component.gd`), resource references for item data.

### Anti-Pattern 3: Scene Instancing for Every Item

**What people do:** Creating a `.tscn` scene for each weapon/item variant and instantiating them at runtime.

**Why it's wrong:** Wastes memory and load time. Makes data-driven balance changes require scene edits.

**Do this instead:** Use `Resource` subclasses for item data. Instantiate visual representation programmatically from resource data.

### Anti-Pattern 4: Direct Node References for Cross-System Communication

**What people do:** `player.get_node("HealthBar").value = player.health` in enemy attack code.

**Why it's wrong:** Tight coupling. Enemy code depends on UI existing. Impossible to test without UI.

**Do this instead:** Emit signals (`SignalBus.player_damaged`). UI subscribes to signals. Entities never reference UI directly.

### Anti-Pattern 5: Ignoring `locked` Physics Process

**What people do:** Putting game logic in `_physics_process` for entities that don't need physics, or putting physics in `_process`.

**Why it's wrong:** `_physics_process` runs at fixed timestep (good for physics). `_process` runs per-frame (variable, bad for physics). Mixing causes inconsistent behavior.

**Do this instead:** Physics-related movement in `_physics_process`. Pure visual updates (animation, particles) in `_process`.

## Integration Points

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| Player ↔ Enemy | Hitbox/Hurtbox collision, SignalBus events | Never directly reference each other |
| Player ↔ UI | SignalBus signals (player_damaged, gold_changed) | UI subscribes, player emits |
| WorldManager ↔ Entities | Dependency injection via `spawn_enemy(spawn_point, enemy_resource)` | Entities receive data, not scene references |
| MapGenerator ↔ WorldManager | Returns TileMap data structure or spawns rooms as scenes | WorldManager handles camera, lighting setup |
| Inventory ↔ Items | Item resource references, SignalBus.item_pickup | Visual inventory is UI layer, data is separate |

## Sources

- [Godot 4 Documentation: Autoloads](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)
- [Godot 4 Documentation: State Machine](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#class-name-vs-script-name)
- [Godot 4 Documentation: Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html)
- [Godot 4 Documentation: TileMap](https://docs.godotengine.org/en/stable/classes/class_tilemap.html)
- [GameDev.tv: Godot 4 Roguelike Course](https://www.gamedev.tv/p/godot-4-roguelike)
- [Heartbeast: Godot 4 Roguelike Tutorial](https://www.youtube.com/watch?v=JC-9h6lLLNN)

---
*Architecture research for: 2D Godot Survival Roguelite*
*Researched: 2026/04/06*
