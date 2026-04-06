# Stack Research

**Domain:** 2D Godot Survival Game with Roguelite Elements
**Researched:** 2026/04/06
**Confidence:** LOW — Training data only. Unable to verify against current Godot docs or recent community sources.

## Recommended Stack

### Core Engine

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Godot Engine | 4.3+ (stable) | Game engine | Industry standard for 2D indie games. Native 2D rendering with scene system, excellent tilemap support, and built-in physics. |
| GDScript | Godot 4.x built-in | Primary language | First-class citizens in Godot. Native performance, tight engine integration, signal system. |

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| Godot Engine | 4.3+ | Game engine | Native 2D rendering, scene system, tilemaps, physics. Standard for 2D indie. |
| GDScript | Godot 4.x | Primary language | Native to Godot, tight integration with engine, signal-based patterns. |
| Godot TileMap | Built-in | 2D world layout | Grid-based maps, autotiling, collision layers. Core to dungeon generation. |
| Godot Navigation2D | Built-in | Pathfinding | AStar2D for roguelike pathfinding. Works with TileMap. |
| Resource | Built-in | Data storage | `.tres` files for items, stats, procedural generation seeds. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Godot Standard Library | 4.x built-in | Core utilities | Arrays, dictionaries, math functions — no external deps needed. |
| AStar2D | Built-in | Pathfinding | Grid-based pathfinding for roguelite navigation. |
| Tween | Built-in | Animations/transitions | Day/night cycle lighting, UI transitions, smooth movement. |
| SceneTree | Built-in | Scene management | instancing, changing scenes for roguelite runs. |
| SignalBus pattern | Custom singleton | Decoupled events | Survival stat changes, inventory updates, time events. |

**Note on external libraries:** The Godot ecosystem favors built-in solutions. Heavy external dependencies are uncommon. Use GDExtension (C++) only if performance demands it.

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Godot Editor | 4.3+ | Primary IDE. Use 64-bit. Enable "Create C# Solution" if using C#. |
| Godot Steam Template | Community | Reference for Steam integration (if needed later). |
| Aseprite | External | Pixel art creation. Export to `.png` or `.gd` sprite sheets. |
| Git | Version control | `.godot/` ignored, track `project.godot`, `scenes/`, `scripts/`. |
| LibreOffice Draw / Excalidraw | Diagrams | Planning dungeon layouts, UI mockups. |

## Installation

Godot is a standalone executable. No install needed.

```bash
# No npm/package manager needed for Godot projects
# Download Godot 4.3+ from https://godotengine.org
# Extract and run

# For version control, initialize git:
cd your_project
git init
# Add to .gitignore:
# .godot/
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| GDScript | C# (.NET) | Team already knows C#, needs Unity-level performance. More boilerplate. |
| Built-in TileMap | GridMap (3D) | If doing pseudo-3D (2.5D) with depth layers. |
| GDScript signals | Autoload/Singleton | Signals are preferred for decoupled game events. |
| Native Godot | Godot GDExtension (C++) | Only if Profiler shows GDScript bottleneck (rare for 2D). |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Godot 3.x | Outdated. 4.x has rebuilt 2D rendering, new tilemap system, GDExtension. | Godot 4.x |
| GDScript `tool` keyword abuse | Causes editor lag if overused. | `_get_property_list()` or `@export` patterns. |
| Global variables for game state | Makes testing hard, hidden dependencies. | Autoload singleton with clear interface. |
| Scene references via ` preload("...")` | Blocks loading, increases startup time. | `preload` for constants only, `load` for dynamic. |

## Stack Patterns by Variant

**If pixel-perfect rendering:**
- Enable **Import > Presets > Pixel Art** in project settings
- Use 2D pixel font rendering
- Because: Godot 4.x defaults to 3D pipeline with anti-aliasing. Pixel art needs nearest-neighbor scaling.

**If procedural generation with seeds:**
- Store RNG seed in `Resource` (`.tres`)
- Use `WorldEnvironment` for day/night lighting
- Because: Reproducible runs are core to roguelite design.

**If requiring save/load between runs:**
- Use `ConfigFile` for persistence, not `Resource.save()`
- Save to `user://` path (platform-aware)
- Because: `Resource.save()` to `.tres` is editor-centric.

## Version Compatibility

| Package A | Compatible With | Notes |
|-----------|-----------------|-------|
| Godot 4.3 | GDScript 2.0 | Major syntax changes from Godot 3.x. |
| Godot 4.x | TileMap (new system) | Not compatible with Godot 3.x TileSet format. |
| Godot 4.x | C# (.NET 6) | Requires Godot .NET build. Different install from standard. |
| Aseprite | Godot via `.tscn` export | Export layers as individual `.png` or use Aseprite importer plugin. |

## Sources

- **Context7:** Not verified — external search denied at runtime.
- **Official docs:** Unable to fetch — WebFetch denied at runtime.
- **Godot 4.3 release notes:** Training data from 2024. Current stable may be 4.4+.
- **Community patterns:** Known Godot patterns (signals, autoload, tilemap).

---

*Stack research for: 2D Godot Survival Roguelite*
*Researched: 2026/04/06*
*Confidence: LOW — Requires verification against current Godot documentation before use.*
