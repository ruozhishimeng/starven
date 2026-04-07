---
name: Starven Game Development
description: "Use for game development, GDScript coding, scene setup, Resource configuration, and architecture decisions in the Starven Godot survival game project."
---

# Starven - Godot 4.6 Survival Game

## 🎮 Project Overview

**Starven** is a 2D top-down pixel art survival crafting game built in **Godot 4.6**, inspired by Don't Starve. The project follows a **data-driven, component-based architecture** documented in [PRD](../PRD).

- **Engine:** Godot 4.6 (Forward Plus, DirectX 12, Jolt Physics)
- **Development Stage:** Early Implementation (assets ready, core game code being built)
- **Core Design:** Architecture principles in [PRD](../PRD) - all game data must be configured through Resource files (.tres), not hardcoded

---

## 📁 Project Structure

```
Starven/
├── .github/
│   └── copilot-instructions.md        # This file
├── Asset/
│   ├── Animations/                    # Sprite sheets for Player, Enemy, VFX
│   ├── Level/                         # Tilemap and background assets
│   └── VFX/                           # Visual effects and UI icons
├── Scripts/                           # GDScript files (to be created)
│   ├── Player/
│   ├── Systems/
│   ├── World/
│   ├── Enemy/
│   └── UI/
├── Scenes/                            # Scene files (.tscn) (to be created)
│   ├── Player.tscn
│   ├── MainLevel.tscn
│   ├── Enemy.tscn
│   └── UI.tscn
├── Resources/                         # Data-driven configurations (.tres)
│   ├── Items/                         # Item definitions
│   ├── Recipes/                       # Crafting recipes
│   ├── Enemies/                       # Enemy stat templates
│   └── Biomes/                        # Biome definitions
└── project.godot
```

---

## 🏗️ Architecture & Design Principles

### 1. **Data-Driven Design**
- **All game data lives in Resource files** (`.tres`), not in code
- Items, recipes, enemy stats, biome rules → Define as `Resource` classes, then instantiate as `.tres` files
- This enables rapid iteration and AI-assisted batch content generation

### 2. **Component-Based Pattern**
- Player and enemies use composable component systems (Stats, Combat, AI, etc.)
- Example: `Player.gd` contains a `StatsComponent` for health/hunger/stamina
- Components should be reusable and independently testable

### 3. **Separation of Concerns**
- **Scenes** = Visual hierarchy and static structure
- **Scripts** = Game logic and dynamics
- **Resources** = Static configuration data
- Avoid mixing these layers

---

## 🎯 Core Systems (per PRD)

### Player & Stats System
- **Health:** Depletes to zero = death
- **Hunger:** Decreases over time; hunger = 0 starts draining health
- **Stamina/Sanity:** Optional in v0.1, for labor intensity or night penalties
- **State Machine:** Idle, Move, Action, Dead

**File:** `Scripts/Player/Player.gd` + `Scripts/Systems/StatsComponent.gd`

### World Generation
- **FastNoiseLite** for procedural generation
- **TileMapLayer** for world tilemap
- **Biomes:** 2-3 types (Grassland, Forest, Wasteland)
- **Resource spawning:** Based on biome thresholds

**File:** `Scripts/World/WorldGenerator.gd`

### Environment & Interaction
- Gatherables (trees, berries, grass)
- Player crafting/cooking
- Combat system
- Inventory management

**Files:** `Scripts/Environment/GatherableNode.gd`, `Scripts/Systems/InventoryManager.gd`

### Enemies & AI
- Base enemy behavior
- Different enemy types with stat templates
- Simple pathfinding and combat

**File:** `Scripts/Enemy/Enemy.gd`

---

## 🛠️ Development Workflow

### Running the Game
1. Open Godot 4.6 editor
2. Import project from `f:\Starven`
3. Set **Main Scene** (Project Settings → Application → Run → Main Scene) if not set
4. Press **F5** or click **Run** to launch

### Creating New Scripts
- Place in `/Scripts/` folder with appropriate subdirectory
- Use **PascalCase** for class names: `Player.gd`, `StatsComponent.gd`
- Use **snake_case** for variables and functions: `_process()`, `take_damage()`

### Creating Scenes
- Place in `/Scenes/` folder  
- Name scene to match its primary node: `Player.tscn`, `MainLevel.tscn`
- Attach scripts to root nodes

### Creating Resources
- Place in `/Resources/` folder with subdirectory (Items/, Recipes/, Enemies/)
- Inherit from appropriate Resource base class
- File naming: `PlayerStats.tres`, `IronSword.tres`

---

## 📝 Naming Conventions

| Element | Pattern | Example |
|---------|---------|---------|
| GDScript files | PascalCase.gd | `Player.gd`, `StatsComponent.gd` |
| Class names | PascalCase | `class_name Player` |
| Functions | snake_case | `_ready()`, `take_damage()` |
| Variables | snake_case | `health_points`, `is_dead` |
| Signals | snake_case | `health_changed`, `item_added` |
| Scene files | PascalCase.tscn | `Player.tscn`, `MainLevel.tscn` |
| Resource files | PascalCase.tres | `IronAxe.tres`, `ForestBiome.tres` |
| Folders | PascalCase | `Scripts`, `Scenes`, `Resources` |

---

## 🎨 Godot Best Practices for This Project

### Signals (Event System)
- Use signals for decoupled communication (UI updates, stat changes)
- Example: `signal health_changed(new_health)`
- Emit when stats change: `health_changed.emit(current_health)`

### Scene Structure
```
Player (Node2D)
├── Sprite2D
├── CollisionShape2D
├── AnimationPlayer
├── StateMachine (Node)
└── StatsComponent (Node) [attach Stats.gd]
```

### Resource Structure
```gdscript
extends Resource
class_name ItemData

@export var id: String
@export var name: String
@export var description: String
@export var rarity: String  # common, uncommon, rare, epic
```

### Script Template
```gdscript
extends Node

@export var stat_value: int = 10
var is_active: bool = false

func _ready() -> void:
    # Initialize when scene loads
    pass

func _process(delta: float) -> void:
    # Update logic here
    pass
```

---

## 📚 Reference Documents

- **[PRD](../PRD)** - Full game design specification (Chinese)
- **Asset Library:** `Asset/Animations/`, `Asset/Level/`, `Asset/VFX/`

### Building New Scenes
When creating a new scene (e.g., MainLevel):
1. Reference PRD for the feature requirements
2. Create `.tscn` file in `Scenes/` folder
3. Attach relevant `.gd` scripts
4. Create corresponding `.tres` Resource files for configuration
5. Connect signals for state changes

---

## 🚀 First Steps for New Contributors or AI Agents

1. Read this file and the [PRD](../PRD)
2. Explore the `Asset/` folder to understand available sprites
3. Start with **Player.gd** - create the main character controller
4. Create **StatsComponent.gd** - health, hunger, stamina tracking
5. Build **MainLevel.tscn** - the game world with tilemap
6. Implement **WorldGenerator.gd** - procedural biome generation

---

## ✅ Important Notes

- **No hardcoded data:** All item properties, recipes, enemy stats → Resource files
- **Reusable components:** Code should be modular and testable
- **Signals first:** Prefer event-driven communication over direct references
- **Version control:** Commit `.gd` scripts, `.tscn` scenes, and `.tres` resources
- **`.godot/` folder:** Auto-generated by Godot, ignore it (already in `.gitignore`)

---

## 📞 Common Tasks

| Task | Location | Example |
|------|----------|---------|
| Add player stat | `Scripts/Systems/StatsComponent.gd` | Add `@export var sanity: int = 100` |
| Add enemy type | `Resources/Enemies/NewEnemy.gd` + `Resources/Enemies/NewEnemy.tres` | Create new enemy stats resource |
| Add crafting recipe | `Scripts/Systems/CraftingManager.gd` + `Resources/Recipes/Recipe.tres` | Define recipe as Resource |
| Add UI panel | `Scenes/UI.tscn` + `Scripts/UI/UIManager.gd` | Add CanvasLayer and UI controls |
| Add animation | `Asset/Animations/` + attach to `AnimationPlayer` in scene | Reference sprite sheet in scene |

---

Generated with guidance from PRD and Starven project structure.
