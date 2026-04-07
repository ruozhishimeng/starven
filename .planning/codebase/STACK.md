# Technology Stack

**Analysis Date:** 2026/04/06

## Engine

**Primary:**
- **Godot** 4.6 - Game engine (not Godot 5)
  - Forward Plus rendering backend
  - DirectX 12 (d3d12) on Windows
  - Jolt Physics for 3D physics (used for 2D game)

## Languages

**Primary:**
- **GDScript** - Main scripting language (.gd files)
  - Used for all game logic, AI, state machines, world generation
  - Type hints required (Godot 4.6 feature)

**Secondary:**
- **C#** (.NET/Mono) - Configured and available
  - Project has `[dotnet]` section in `project.godot`
  - Assembly name: "Starven"
  - Not actively used in current codebase (no .cs files found)

## Runtime

**Environment:**
- Windows 10/11 with DirectX 12 support
- Godot 4.6 editor (Mono variant for C# support)

## Project Configuration

**Entry Point:**
- Main scene: `uid://b8xn0kdu8wrv1` (internal map scene)
- Viewport: 1920x1080

**Physics Layers:**
```
Layer 1: "stastic" (static geometry)
Layer 2: "player"
Layer 3: "enemy"
Layer 4: "grass"
```

**Input Bindings:**
- `up` - W key or Arrow Up
- `down` - S key or Arrow Down
- `left` - A key or Arrow Left
- `right` - D key or Arrow Right
- Deadzone: 0.2

## Key Dependencies

**Core (Bundled with Godot):**
- FastNoiseLite - Procedural noise generation for world generation
- Godot的内置系统 - Scene system, Physics, Input, Audio

**Addons:**
- `godot_mcp` - Model Context Protocol server addon
  - Provides WebSocket server for AI/code assistant integration
  - Location: `addons/godot_mcp/`

## File Structure

**Project Root:**
```
F:/Starven/
├── project.godot          # Engine configuration
├── Script/                # GDScript source files
│   ├── StateMachine/      # State machine framework
│   │   ├── state_machine.gd
│   │   ├── State.gd
│   │   ├── basic_states/
│   │   │   ├── idle.gd
│   │   │   └── move.gd
│   │   ├── playerstates/
│   │   │   ├── player_idle.gd
│   │   │   └── player_run.gd
│   │   └── enemystates/
│   │       ├── enemy_idle.gd
│   │       ├── enemy_move.gd
│   │       └── enemy_chase.gd
│   ├── player.gd
│   ├── basic_character.gd
│   ├── enemy_1.gd
│   ├── foliage_spawner.gd
│   ├── grass.gd
│   ├── grass_random.gd
│   ├── grass_generator.gd
│   ├── random_tree.gd
│   └── tile_map_layer_grass.gd
├── Scene/                # Godot scene files (.tscn)
│   ├── player.tscn
│   ├── enemy1.tscn
│   ├── enemy_axeman.tscn
│   ├── enemy_moth.tscn
│   ├── enemy_stoneman.tscn
│   ├── grass.tscn
│   ├── Tree.tscn
│   ├── initial_map.tscn
│   └── maze.tscn
├── Asset/                 # Sprites, animations, tilesets
├── addons/godot_mcp/      # MCP server addon
├── .godot/               # Godot engine-generated files
└── .github/              # Documentation
```

## Development Tools

**Editor:**
- Godot 4.6 editor (Mono variant)
- Path: `C:\Users\ruozh\Downloads\Godot_v4.6.2-stable_mono_win64\Godot_v4.6.2-stable_mono_win64.exe`

**MCP Integration:**
- Godot MCP Pro v1.6.0 addon
- Streamable HTTP MCP server at `http://127.0.0.1:3000/mcp`
- WebSocket server on ports 6505-6509

## Package Management

**npm packages:**
- `package-lock.json` present (empty dependencies, likely for MCP tooling only)

## Rendering

**Backend:**
- DirectX 12 (d3d12) on Windows
- Forward Plus rendering
- Canvas texture filter: disabled (pixel art friendly)

---

*Stack analysis: 2026/04/06*
