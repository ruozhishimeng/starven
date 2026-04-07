# Architecture

**Analysis Date:** 2026-04-06

## Pattern Overview

**Overall:** State Machine Pattern with Component-based Characters

**Key Characteristics:**
- Godot 4.6 2D game with CharacterBody2D physics
- Hierarchical State Machine (HSM) for character behavior
- Character inheritance hierarchy: StateMachine -> State -> BasicCharacter -> Player/Enemy
- Data-driven world generation with deterministic chunk-based spawning
- Visual variant system using sprite region selection

## Layers

**Game Objects (CharacterBody2D layer):**
- Purpose: Player and enemy entities with physics movement
- Location: `Script/player.gd`, `Script/enemy_1.gd`
- Contains: Character movement, animation control, AI behavior
- Depends on: StateMachine, State hierarchy
- Used by: Scene files (player.tscn, enemy1.tscn)

**State Machine (Node layer):**
- Purpose: Manages state transitions and dispatches lifecycle to active state
- Location: `Script/StateMachine/state_machine.gd`
- Contains: State registry, current state tracking, message forwarding
- Depends on: State hierarchy
- Used by: All characters via $StateMachine node

**States (Node layer):**
- Purpose: Individual behavior states (idle, move, chase)
- Location: `Script/StateMachine/`
  - Base: `Script/StateMachine/State.gd`
  - Player: `Script/StateMachine/playerstates/player_idle.gd`, `player_run.gd` (implied player_run would extend move)
  - Enemy: `Script/StateMachine/enemystates/enemy_idle.gd`, `enemy_move.gd`, `enemy_chase.gd`
  - Shared: `Script/StateMachine/basic_states/idle.gd`, `move.gd`
- Contains: Enter/Exit/Process/PhysicsProcess/HandleInput lifecycle
- Depends on: Character via `character` property
- Used by: StateMachine

**World Generation (Node2D layer):**
- Purpose: Procedural infinite terrain generation
- Location: `Script/foliage_spawner.gd`
- Contains: Chunk management, deterministic RNG, tree/grass placement
- Depends on: Player (via group lookup)
- Used by: Scene/initial_map.tscn

**Visual Effects (Node layer):**
- Purpose: Interactive grass sway animation
- Location: `Script/grass.gd`
- Contains: Tween-based sway, player proximity detection
- Depends on: Sprite2D children for skew/scale animation
- Used by: Scene/grass.tscn

## Data Flow

**Character Movement Flow:**
1. Input captured via `Input.get_vector("left", "right", "up", "down")`
2. Direction passed to current state's `PhysicsProcess(delta)`
3. State calls `character.velocity.move_toward()` with ACCELERATION
4. `character.move_and_slide()` executes physics
5. `character.play_animation()` updates sprite animation

**State Transition Flow:**
1. State detects condition (e.g., direction.length() > 0.1)
2. State calls `state_machine.change_state("NewState")`
3. StateMachine calls `currentState.Exit()`
4. StateMachine updates `currentState` reference
5. StateMachine calls `currentState.Enter()`

**World Generation Flow:**
1. Player moves, `FoliageSpawner._process()` detects chunk change
2. `_update_chunks_around_player()` calculates target chunks
3. For new chunks: `_generate_chunk_data()` creates deterministic positions
4. `_spawn_chunk()` instantiates scene nodes
5. For distant chunks: `_despawn_chunk()` queues nodes for removal

## Key Abstractions

**BasicCharacter (extends CharacterBody2D):**
- Purpose: Shared movement physics for all characters
- Examples: `Script/basic_character.gd`
- Pattern: Abstract base class with virtual methods `get_input_direction()` and `play_animation()`

**State (extends Node):**
- Purpose: Encapsulated behavior for a single state
- Examples: `Script/StateMachine/basic_states/idle.gd`, `move.gd`
- Pattern: Lifecycle methods (Enter, Exit, Process, PhysicsProcess, HandleInput)

**StateMachine (extends Node):**
- Purpose: State registry and transition manager
- Examples: `Script/StateMachine/state_machine.gd`
- Pattern: Message broker forwarding lifecycle calls to active state

**FoliageSpawner (extends Node2D):**
- Purpose: Chunk-based world streaming
- Examples: `Script/foliage_spawner.gd`
- Pattern: Object pool with deterministic regeneration

## Entry Points

**Main Scene:**
- Location: `uid://b8xn0kdu8wrv1` (referenced in project.godot as run/main_scene)
- Triggers: Game launch
- Responsibilities: Initialize world, spawn initial chunk, player spawn

**Player Scene:**
- Location: `Scene/player.tscn`
- Triggers: Scene instancing
- Responsibilities: Player input handling, camera, state machine initialization

**FoliageSpawner (in initial_map.tscn):**
- Location: `Scene/initial_map.tscn` (contains FoliageSpawner node)
- Triggers: Map load, player movement
- Responsibilities: World generation, chunk streaming

## Error Handling

**Strategy:** Push error/warning with context

**Patterns:**
- `push_error("BasicCharacter: 子类必须实现 get_input_direction()")` - Abstract method enforcement
- `push_warning("grass_scene is null: " + grass_scene_path)` - Optional component warnings
- Null checks via `get_node_or_null()` before access

## Cross-Cutting Concerns

**Logging:** Print statements for debugging (`print("Generating chunk ", chunk_coord)`)

**Validation:** 
- `is_instance_valid(node)` before queue_free
- `@export_range` for clamped values
- Deadzone (0.2) on input binding

**Animation:** Direction suffix system (down/up/left/right) + prefix (idle/move)

**Physics:** 
- 2D physics with collision layers (static=1, player=2, enemy=4, grass=8)
- Y-sort enabled for depth
- CharacterBody2D with move_and_slide()

---

*Architecture analysis: 2026-04-06*
