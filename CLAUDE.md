<!-- GSD:project-start source:PROJECT.md -->
## Project

**Starven**

A 2D survival game built in Godot/GDScript with pixel art. Player survives indefinitely in a randomly generated world, managing hunger, health, and sanity through day/night cycles while fighting escalating waves of enemies. Combines Don't Starve-style survival pressure with Vampire Survivors-style skill progression.

**Core Value:** Survive as long as possible — everything else can fail, this cannot.

### Constraints

- **Tech stack**: Godot 4.x, GDScript only
- **Art**: Pixel art, user produces all美术 resources
- **Controls**: Keyboard only (WASD + action keys)
- **Platform**: PC desktop
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Engine
- **Godot** 4.6 - Game engine (not Godot 5)
## Languages
- **GDScript** - Main scripting language (.gd files)
- **C#** (.NET/Mono) - Configured and available
## Runtime
- Windows 10/11 with DirectX 12 support
- Godot 4.6 editor (Mono variant for C# support)
## Project Configuration
- Main scene: `uid://b8xn0kdu8wrv1` (internal map scene)
- Viewport: 1920x1080
- `up` - W key or Arrow Up
- `down` - S key or Arrow Down
- `left` - A key or Arrow Left
- `right` - D key or Arrow Right
- Deadzone: 0.2
## Key Dependencies
- FastNoiseLite - Procedural noise generation for world generation
- Godot的内置系统 - Scene system, Physics, Input, Audio
- `godot_mcp` - Model Context Protocol server addon
## File Structure
## Development Tools
- Godot 4.6 editor (Mono variant)
- Path: `C:\Users\ruozh\Downloads\Godot_v4.6.2-stable_mono_win64\Godot_v4.6.2-stable_mono_win64.exe`
- Godot MCP Pro v1.6.0 addon
- Streamable HTTP MCP server at `http://127.0.0.1:3000/mcp`
- WebSocket server on ports 6505-6509
## Package Management
- `package-lock.json` present (empty dependencies, likely for MCP tooling only)
## Rendering
- DirectX 12 (d3d12) on Windows
- Forward Plus rendering
- Canvas texture filter: disabled (pixel art friendly)
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Language
- GDScript (Godot 4.6)
- Explicit type declarations required, especially for return values that may be null
- Use type hints on function parameters and return types
## Naming Conventions
### Files
- `BasicCharacter.gd`
- `StateMachine.gd`
- `State.gd`
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
| Animation | Format | Examples |
|-----------|--------|----------|
| Idle | `idle_{direction}` | `idle_down`, `idle_left`, `idle_right`, `idle_up` |
| Move | `move_{direction}` | `move_down`, `move_left`, `move_right`, `move_up` |
| Chase | `chase_{direction}` | `chase_down`, `chase_left`... |
| Hurt | `hurt_{direction}` | `hurt_down`, `hurt_left`... |
## Code Style
### Formatting
- `charset = utf-8` (from `.editorconfig`)
- Indentation: Standard Godot/GDScript formatting
- Chinese comments are preserved and encouraged for educational content
### Type Declarations
### Decorators
### Inheritance and super
### Error Handling
### State Machine Patterns
### Movement Patterns
## Import Organization
## Comments
## 状态基类
## 所有具体状态（如 player_idle, player_run）都应该继承这个类
## 检测是否停止移动
## Module Design
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern Overview
- Godot 4.6 2D game with CharacterBody2D physics
- Hierarchical State Machine (HSM) for character behavior
- Character inheritance hierarchy: StateMachine -> State -> BasicCharacter -> Player/Enemy
- Data-driven world generation with deterministic chunk-based spawning
- Visual variant system using sprite region selection
## Layers
- Purpose: Player and enemy entities with physics movement
- Location: `Script/player.gd`, `Script/enemy_1.gd`
- Contains: Character movement, animation control, AI behavior
- Depends on: StateMachine, State hierarchy
- Used by: Scene files (player.tscn, enemy1.tscn)
- Purpose: Manages state transitions and dispatches lifecycle to active state
- Location: `Script/StateMachine/state_machine.gd`
- Contains: State registry, current state tracking, message forwarding
- Depends on: State hierarchy
- Used by: All characters via $StateMachine node
- Purpose: Individual behavior states (idle, move, chase)
- Location: `Script/StateMachine/`
- Contains: Enter/Exit/Process/PhysicsProcess/HandleInput lifecycle
- Depends on: Character via `character` property
- Used by: StateMachine
- Purpose: Procedural infinite terrain generation
- Location: `Script/foliage_spawner.gd`
- Contains: Chunk management, deterministic RNG, tree/grass placement
- Depends on: Player (via group lookup)
- Used by: Scene/initial_map.tscn
- Purpose: Interactive grass sway animation
- Location: `Script/grass.gd`
- Contains: Tween-based sway, player proximity detection
- Depends on: Sprite2D children for skew/scale animation
- Used by: Scene/grass.tscn
## Data Flow
## Key Abstractions
- Purpose: Shared movement physics for all characters
- Examples: `Script/basic_character.gd`
- Pattern: Abstract base class with virtual methods `get_input_direction()` and `play_animation()`
- Purpose: Encapsulated behavior for a single state
- Examples: `Script/StateMachine/basic_states/idle.gd`, `move.gd`
- Pattern: Lifecycle methods (Enter, Exit, Process, PhysicsProcess, HandleInput)
- Purpose: State registry and transition manager
- Examples: `Script/StateMachine/state_machine.gd`
- Pattern: Message broker forwarding lifecycle calls to active state
- Purpose: Chunk-based world streaming
- Examples: `Script/foliage_spawner.gd`
- Pattern: Object pool with deterministic regeneration
## Entry Points
- Location: `uid://b8xn0kdu8wrv1` (referenced in project.godot as run/main_scene)
- Triggers: Game launch
- Responsibilities: Initialize world, spawn initial chunk, player spawn
- Location: `Scene/player.tscn`
- Triggers: Scene instancing
- Responsibilities: Player input handling, camera, state machine initialization
- Location: `Scene/initial_map.tscn` (contains FoliageSpawner node)
- Triggers: Map load, player movement
- Responsibilities: World generation, chunk streaming
## Error Handling
- `push_error("BasicCharacter: 子类必须实现 get_input_direction()")` - Abstract method enforcement
- `push_warning("grass_scene is null: " + grass_scene_path)` - Optional component warnings
- Null checks via `get_node_or_null()` before access
## Cross-Cutting Concerns
- `is_instance_valid(node)` before queue_free
- `@export_range` for clamped values
- Deadzone (0.2) on input binding
- 2D physics with collision layers (static=1, player=2, enemy=4, grass=8)
- Y-sort enabled for depth
- CharacterBody2D with move_and_slide()
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, or `.github/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
