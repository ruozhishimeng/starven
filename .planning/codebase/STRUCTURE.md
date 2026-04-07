# Codebase Structure

**Analysis Date:** 2026-04-06

## Directory Layout

```
/f/Starven/
├── Script/                    # GDScript source files
├── Scene/                     # Godot scene files (.tscn)
├── Asset/                     # Game assets (sprites, animations)
├── addons/                    # Godot plugins (godot_mcp)
├── .godot/                    # Godot engine files (generated)
├── .github/                   # GitHub configuration
├── .claude/                   # Claude IDE settings
├── project.godot              # Godot project configuration
└── .planning/codebase/        # Architecture documentation
```

## Directory Purposes

**Script/**
- Purpose: All GDScript code files
- Contains: State machine, characters, world generation, VFX
- Key files:
  - `Script/player.gd` - Player character
  - `Script/enemy_1.gd` - Enemy character
  - `Script/basic_character.gd` - Character base class
  - `Script/foliage_spawner.gd` - World generator
  - `Script/grass.gd` - Grass interaction VFX

**Scene/**
- Purpose: Godot scene files defining node trees
- Contains: Player, enemies, grass, trees, map
- Key files:
  - `Scene/player.tscn` - Player scene
  - `Scene/enemy1.tscn` - Enemy scene
  - `Scene/initial_map.tscn` - Main map with FoliageSpawner
  - `Scene/grass.tscn` - Grass clump scene
  - `Scene/Tree.tscn` - Tree scene

**Asset/**
- Purpose: Game assets (sprites, textures)
- Subdirectories:
  - `Asset/Animations/` - Sprite sheets for characters
  - `Asset/Level/` - Environment sprites (trees, grass)
  - `Asset/VFX/` - Visual effect assets
  - `Asset/角色行走/` - Player walk cycle assets

**addons/godot_mcp/**
- Purpose: Godot MCP plugin for Claude integration
- Contains: Command implementations, UI, websocket server

## Key File Locations

**Entry Points:**
- `project.godot` - Godot project config, defines main_scene
- `Scene/initial_map.tscn` - Main scene (contains FoliageSpawner)

**Configuration:**
- `project.godot` - Engine config, input mappings, physics layers

**Core Logic:**
- `Script/basic_character.gd` - 1405 bytes - Character movement base
- `Script/player.gd` - 1122 bytes - Player-specific input/animation
- `Script/enemy_1.gd` - 1883 bytes - Enemy AI (chase behavior)
- `Script/foliage_spawner.gd` - 13928 bytes - World chunk generation

**State Machine:**
- `Script/StateMachine/state_machine.gd` - State coordinator
- `Script/StateMachine/State.gd` - Base state class
- `Script/StateMachine/basic_states/idle.gd` - Shared idle
- `Script/StateMachine/basic_states/move.gd` - Shared movement
- `Script/StateMachine/playerstates/player_idle.gd` - Player idle
- `Script/StateMachine/enemystates/enemy_idle.gd` - Enemy idle
- `Script/StateMachine/enemystates/enemy_move.gd` - Enemy wander
- `Script/StateMachine/enemystates/enemy_chase.gd` - Enemy pursuit

**Visual Effects:**
- `Script/grass.gd` - 6060 bytes - Grass sway animation
- `Script/grass_random.gd` - Sprite variant selector
- `Script/random_tree.gd` - Tree variant selector

## Naming Conventions

**Files:**
- GDScript: `snake_case.gd` (e.g., `player.gd`, `enemy_1.gd`)
- Scenes: `snake_case.tscn` (e.g., `player.tscn`, `enemy1.tscn`)
- State folders: `PascalCase/` (e.g., `StateMachine/`, `playerstates/`)

**Classes:**
- Class names: `PascalCase` (e.g., `BasicCharacter`, `StateMachine`)
- `class_name` declarations in files match filename conventions

**Variables:**
- Local variables: `snake_case` (e.g., `player_chunk`, `detect_radius`)
- Constants: `SCREAMING_SNAKE_CASE` (e.g., `INPUT_DEADZONE`)
- Node references: `snake_case` with `_node` suffix when ambiguous

**Node Paths in Scenes:**
- Physical nodes: `PascalCase` (e.g., `AnimatedSprite2D`, `CollisionShape2D`)
- State nodes: `snake_case` matching script name (e.g., `idle`, `move`, `chase`)

## Where to Add New Code

**New Character Type:**
1. Create script: `Script/new_character.gd` extending `BasicCharacter`
2. Implement `get_input_direction()` and `play_animation()`
3. Create scene: `Scene/new_character.tscn` with CharacterBody2D root
4. Add StateMachine node with child states
5. Connect to world via group ("player") or direct reference

**New State:**
1. Create script: `Script/StateMachine/[category]/[state_name].gd`
2. Extend `State` class
3. Implement lifecycle methods (Enter, Exit, PhysicsProcess, etc.)
4. Add as child node in character scene

**New Enemy Type:**
1. Duplicate `Script/enemy_1.gd` and modify AI logic
2. Create scene: `Scene/enemy_[type].tscn`
3. Configure `detect_radius`, `lose_radius`, `SPEED` exports
4. Add to map via instancing or spawner

**New World Element:**
1. Create scene: `Scene/[element].tscn`
2. Add to `FoliageSpawner` exports in `initial_map.tscn`
3. Configure generation parameters (count, spacing, variants)

**Utilities/Helpers:**
- Sprite variants: Extend `grass_random.gd` pattern with `randomRegions` array
- Position helpers: Add to `BasicCharacter` if shared, or character-specific

## Special Directories

**.godot/**
- Purpose: Godot engine-generated files (imported assets, shader cache, mono metadata)
- Generated: Yes
- Committed: Yes (required for project)

**addons/godot_mcp/**
- Purpose: Claude integration plugin
- Contains: MCP server implementation, UI panels
- Generated: No (installed plugin)
- Committed: Yes (in repo)

**.claude/**
- Purpose: Claude IDE settings and plans
- Generated: Partially
- Committed: No (.gitignore)

**.planning/codebase/**
- Purpose: Architecture documentation (this analysis)
- Generated: Yes (by GSD mapper)
- Committed: No (.gitignore)

---

*Structure analysis: 2026-04-06*
