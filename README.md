# Starven 🎮

**Starven** is a 2D top-down pixel art survival crafting game built in **Godot 4.6**, inspired by *Don't Starve*. The project is currently in **early development**, with art assets ready and core game systems being implemented.

---

## 🎯 Quick Start

### Prerequisites
- **Godot 4.6** (Forward Plus rendering)
- Windows with DirectX 12 support
- Git (for version control)

### Launch the Game

1. **Open Godot 4.6** editor
2. **Import project** from `f:\Starven`
3. **Set Main Scene** (if not already set):
   - Project → Project Settings → Application → Run → Main Scene
   - Set to `res://Scenes/MainLevel.tscn` (once created)
4. **Press F5** or click **Run** to start

---

## 📁 Project Structure

```
Starven/
├── Scripts/              # GDScript implementations
├── Scenes/               # Scene files (.tscn)
├── Resources/            # Data-driven config files (.tres)
├── Asset/                # Sprites, animations, tilesets
├── .github/              # Documentation & conventions
├── project.godot         # Engine configuration
├── PRD                   # Game design doc (Chinese)
└── CONTRIBUTING.md       # Developer guide
```

**Key Principle:** All game data lives in Resource files (`.tres`), not hardcoded in scripts.

---

## 🏗️ Architecture

Starven uses three core patterns:

1. **Data-Driven Design** - Configuration lives in `.tres` Resource files
2. **Component Pattern** - Reusable, composable behavioral units
3. **Signal-Based Communication** - Event-driven, decoupled systems

Learn more in [.github/ARCHITECTURE.md](.github/ARCHITECTURE.md).

---

## 🎮 Core Game Systems

| System | Description | Location |
|--------|-------------|----------|
| **Player & Stats** | Health, hunger, stamina tracking | `Scripts/Systems/StatsComponent.gd` |
| **World Generation** | Procedural map generation with biomes | `Scripts/World/WorldGenerator.gd` |
| **Inventory** | Item management and storage | `Scripts/Systems/InventoryManager.gd` |
| **Crafting** | Recipe system and crafting logic | `Scripts/Systems/CraftingManager.gd` |
| **Enemy AI** | Pathfinding, combat behavior | `Scripts/Enemy/Enemy.gd` |
| **UI** | Menus, HUD, panels | `Scripts/UI/UIManager.gd` |

---

## 📝 Available Assets

All art assets are ready in `Asset/`:

```
Asset/
├── Animations/
│   ├── Player_Idle.png
│   ├── Player_Run.png
│   ├── Player_Attack.png
│   ├── Enemy_Idle_Move_Hurt.png
│   └── ... (+ more)
├── Level/
│   ├── Tilemap_Platform.png
│   ├── Background_Grass.png
│   └── TreeAndGrass.png
└── VFX/
    ├── SwordSlash.png
    ├── Grass_Cut_Animation.png
    └── ... (+ more)
```

---

## 🧑‍💻 Development Guide

### New to Godot?
- Read [copilot-instructions.md](.github/copilot-instructions.md) for project conventions
- Check [ARCHITECTURE.md](.github/ARCHITECTURE.md) for design patterns
- See [GDScript guidelines](.github/instructions/gdscript.instructions.md)

### Contributing?
- Follow [CONTRIBUTING.md](./CONTRIBUTING.md) for workflow
- Use PR templates and check naming conventions
- Ensure all code follows style guidelines

### Starting Development?
1. **First:** Create `Player.gd` and `Scenes/Player.tscn`
2. **Then:** Implement `StatsComponent.gd` for health/hunger
3. **Next:** Build `WorldGenerator.gd` for map generation
4. **Finally:** Add enemies, crafting, and UI systems

See [First Steps for Contributors](./CONTRIBUTING.md#-first-steps-for-new-contributors).

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| [PRD](./PRD) | Full game design specification (Chinese) |
| [copilot-instructions.md](.github/copilot-instructions.md) | Project structure & conventions |
| [ARCHITECTURE.md](.github/ARCHITECTURE.md) | System design patterns & examples |
| [gdscript.instructions.md](.github/instructions/gdscript.instructions.md) | Code style & best practices |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Contributor workflow & checklist |

---

## 🎨 Key Features (MVP v0.1)

- **2D Top-Down Exploration** - Navigate a procedurally generated world
- **Resource Gathering** - Chop trees, pick berries, harvest materials
- **Hunger System** - Manage hunger to survive
- **Crafting** - Combine resources to create tools and food
- **Combat** - Simple enemy encounters and combat
- **Biomes** - Multiple environment types (Grassland, Forest, Wasteland)

---

## 🔧 Naming Conventions

| Element | Pattern | Example |
|---------|---------|---------|
| **Scripts** | PascalCase.gd | `Player.gd`, `StatsComponent.gd` |
| **Classes** | `class_name PascalCase` | `class_name Player` |
| **Functions** | snake_case | `take_damage()`, `_setup_signals()` |
| **Variables** | snake_case | `current_health`, `is_dead` |
| **Signals** | snake_case | `health_changed`, `item_added` |
| **Scenes** | PascalCase.tscn | `Player.tscn`, `MainLevel.tscn` |
| **Resources** | PascalCase.tres | `IronAxe.tres`, `ForestBiome.tres` |

---

## 🚀 Development Roadmap

### Phase 1: Core Player System ⏳
- [ ] Player movement and input
- [ ] Stats component (health, hunger, stamina)
- [ ] Inventory system
- [ ] Basic animation

### Phase 2: World & Environment ⏳
- [ ] Procedural map generation
- [ ] Biome system
- [ ] Gatherables (trees, berries, grass)
- [ ] Tilemap rendering

### Phase 3: Enemies & Combat ⏳
- [ ] Enemy AI and pathfinding
- [ ] Combat system
- [ ] Enemy types and stats
- [ ] Loot drops

### Phase 4: Crafting & Progression ⏳
- [ ] Crafting system
- [ ] Recipe database
- [ ] Item rarity system
- [ ] Experience & leveling

### Phase 5: UI & Polish 🔄
- [ ] HUD (health, hunger bars)
- [ ] Main menu
- [ ] Inventory UI
- [ ] Game over screen

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Read [CONTRIBUTING.md](./CONTRIBUTING.md)
2. Follow the [naming conventions](#-naming-conventions)
3. Reference [ARCHITECTURE.md](.github/ARCHITECTURE.md) for design patterns
4. Submit clear PRs with descriptive messages

---

## 📄 License

*License information to be added*

---

## 🎓 Learning Resources

- **Godot Engine**: https://docs.godotengine.org/
- **GDScript**: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/
- **2D Games**: https://docs.godotengine.org/en/stable/community/tutorials.html

---

Made with ❤️ using **Godot 4.6**
