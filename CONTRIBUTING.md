# Contributing to Starven

Welcome to the Starven project! This guide will help you understand how to contribute effectively to our Godot 4.6 survival game.

---

## 📖 Quick Start

1. **Read the Documentation:**
   - [copilot-instructions.md](.github/copilot-instructions.md) - Project structure & conventions
   - [ARCHITECTURE.md](.github/ARCHITECTURE.md) - Design patterns & technical implementation
   - [PRD](./PRD) - Game design specification (Chinese)

2. **Set Up Development:**
   - Clone/open the project in Godot 4.6
   - Ensure DirectX 12 rendering driver is available
   - Launch the project (F5) to verify it opens

3. **Pick a Task:**
   - Review the [First Steps](#-first-steps-for-new-contributors) section below
   - Check issues or the PRD for features to implement

---

## 🏗️ Project Structure

```
Scripts/                 # GDScript implementations
Scenes/                  # Scene files (.tscn)
Resources/               # Data-driven configuration files (.tres)
Asset/                   # Art assets (sprites, animations, tilemap)
.github/                 # Workflow & documentation
```

**Key Principle:** All game data (items, recipes, enemy stats) lives in `.tres` Resource files, not in code.

---

## 🛠️ Development Workflow

### Before You Start

1. Create a **new branch** for your feature:
   ```bash
   git checkout -b feature/player-movement
   ```

2. Read the relevant architecture docs:
   - For **components:** See [ARCHITECTURE.md - Component Pattern](.github/ARCHITECTURE.md#-component-architecture)
   - For **Resources:** See [ARCHITECTURE.md - Resource Patterns](.github/ARCHITECTURE.md#-resource-file-patterns)
   - For **GDScript code:** See [gdscript.instructions.md](.github/instructions/gdscript.instructions.md)

### Creating a New Script

1. Create the `.gd` file in the appropriate folder under `Scripts/`
2. Use the template from [gdscript.instructions.md](.github/instructions/gdscript.instructions.md)
3. Follow naming conventions:
   - Files: `PascalCase.gd` (e.g., `Player.gd`, `StatsComponent.gd`)
   - Classes: `class_name PascalCase`
   - Functions: `snake_case`

### Creating a New Scene

1. Create the `.tscn` file in `Scenes/` with appropriate subfolder
2. Name it to match the root node: `Player.tscn`
3. Attach scripts to establish hierarchy
4. Connect signals between components

### Creating a New Resource

1. Define a Resource class in `Scripts/Resources/`:
   ```gdscript
   extends Resource
   class_name ItemData
   
   @export var item_id: String
   @export var name: String
   @export var description: String
   ```

2. Save an instance as `.tres` file in `Resources/`:
   ```
   Resources/Items/IronAxe.tres
   ```

---

## 📋 Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Script files | PascalCase.gd | `Player.gd`, `InventoryManager.gd` |
| Class names | PascalCase | `class_name Player` |
| Functions | snake_case | `take_damage()`, `_setup_signals()` |
| Variables | snake_case | `current_health`, `is_dead` |
| Private variables | _snake_case | `_internal_state`, `_cache` |
| Signals | snake_case | `health_changed`, `item_added` |
| Scene files | PascalCase.tscn | `Player.tscn`, `MainLevel.tscn` |
| Resource files | PascalCase.tres | `IronAxe.tres`, `ForestBiome.tres` |

---

## 🎯 Architecture Principles

### 1. **Data-Driven Design**
Never hardcode game data:

```gdscript
# ❌ WRONG
var max_health: int = 100
var weapon_damage: int = 15

# ✅ CORRECT
@export var player_stats: PlayerStatsData  # Assign .tres file in editor
```

### 2. **Component Pattern**
Build reusable components that can be attached to any entity:

```gdscript
# ✅ Good: Generic StatsComponent
extends Node
class_name StatsComponent

var health: int
signal health_changed(new_health: int)

func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)

# Can attach to Player, Enemy, Boss, NPC, etc.
```

### 3. **Event-Driven Communication**
Use signals instead of direct references:

```gdscript
# ✅ Good: Decoupled via signals
player.stats.health_changed.connect(ui_manager.update_health_bar)

# ❌ Bad: Direct coupling
ui_manager.health_bar.value = player.stats.health
```

### 4. **Scene Hierarchy**
Keep scene structure clean and flat where possible:

```
Player (Node2D)
├── Sprite2D
├── CollisionShape2D
├── AnimationPlayer
├── StateMachine
└── StatsComponent
```

---

## 🚀 First Steps for New Contributors

### Phase 1: Core Player System
1. **Create `Scripts/Player/Player.gd`** - Main player controller
   - Inherit from `Node2D`
   - Handle basic movement and input
   - Reference other components

2. **Create `Scripts/Systems/StatsComponent.gd`** - Health/Hunger/Stamina
   - Emit signals when stats change
   - Handle damage/healing

3. **Create `Scenes/Player.tscn`** - Player scene
   - Set up visual hierarchy
   - Attach scripts and components
   - Configure animations

### Phase 2: World Generation
4. **Create `Scripts/World/WorldGenerator.gd`** - Procedural generation
   - Use FastNoiseLite for biome generation
   - Spawn resources based on biome rules

5. **Create `Scenes/MainLevel.tscn`** - Game world
   - Add TileMapLayer
   - Instantiate player and enemies
   - Set up UI

### Phase 3: Enemy System
6. **Create `Scripts/Enemy/Enemy.gd`** - Base enemy class
   - AI state machine
   - Combat logic
   - Pathfinding

7. **Create `Resources/Enemies/` data** - Enemy configurations
   - Stat templates
   - Behavior rules

---

## 🔄 Review Checklist

Before submitting a pull request, ensure:

- [ ] Code follows [gdscript.instructions.md](.github/instructions/gdscript.instructions.md) conventions
- [ ] Type hints are present on all functions
- [ ] Signals are used for state changes
- [ ] No hardcoded game data (use Resources/.tres files)
- [ ] Scene hierarchy is clean and logical
- [ ] Components are reusable and testable
- [ ] Comments explain **why**, not **what** (code is self-documenting)
- [ ] Branch name is descriptive: `feature/x`, `fix/y`, `docs/z`
- [ ] Commit messages are clear and concise

---

## 🐛 Troubleshooting

### "Script not found" or "Class not found"
- Ensure `class_name ClassName` is at the top of the file
- Verify file naming matches class name (both PascalCase)
- Restart Godot editor

### Circular import errors
- Use signals instead of direct references
- Load Resources via `@export` fields, not hardcoded paths
- Break dependency cycles by injecting dependencies

### Performance issues
- Profile using Godot's built-in profiler
- Avoid instantiating Resources in `_process()`
- Cache OnReady references properly

---

## 📞 Common Questions

**Q: Where should I put new utility functions?**
A: Create a `Scripts/Utilities/` folder and group related functions:
   - `Scripts/Utilities/MathHelpers.gd`
   - `Scripts/Utilities/StringHelpers.gd`

**Q: How do I test my code?**
A: Create test scenes in `Tests/` folder with isolated components. Use Godot's built-in visual testing.

**Q: Should I commit `.godot/` folder changes?**
A: No, it's auto-generated. It's already in `.gitignore`.

**Q: How do I report a bug?**
A: Open an issue with clear reproduction steps and the Godot version.

---

## 📚 Additional Resources

- **Godot 4.6 Docs:** https://docs.godotengine.org/en/stable/
- **GDScript Reference:** https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html
- **Project PRD:** [PRD](./PRD) (Chinese, detailed game design)
- **Architecture:** [ARCHITECTURE.md](.github/ARCHITECTURE.md)

---

Thank you for contributing to Starven! 🎮
