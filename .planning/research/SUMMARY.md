# Project Research Summary

**Project:** Starven
**Domain:** 2D Godot Survival Roguelite
**Researched:** 2026/04/06
**Confidence:** MEDIUM

## Executive Summary

Starven is a 2D top-down survival roguelite built with Godot 4.3+ and GDScript, drawing design inspiration from Don't Starve (3-survival-stats, day/night cycle) combined with Vampire Survivors' progression model (XP, skill tree, roguelite purity with no meta-progression). The recommended approach is to start with a minimal viable loop: HP+Hunger survival pressure, WASD movement, knife attack, random map generation, enemy spawning with chase AI, treasure chests, XP/level-up, and 3-5 basic skills. The architecture follows Godot best practices with autoload singletons for global state, signal-based decoupled communication, state machine patterns for player/enemy behavior, and resource-based item definitions. Key risks include scope creep (the roguelite genre invites feature bloat), premature procedural generation optimization (simple TileMap suffices for demo), and collision layer misconfiguration (must be explicitly documented per entity type). The demo success criteria should be: "Player can survive 15 minutes with full survival loop functional."

## Key Findings

### Recommended Stack

**Domain:** 2D Godot Survival Roguelite

Godot 4.3+ with GDScript is the standard for 2D indie games, offering native 2D rendering, scene system, tilemap support, and physics. The ecosystem favors built-in solutions over external dependencies.

**Core technologies:**
- **Godot 4.3+:** Game engine — native 2D rendering, scene system, TileMap, physics built-in
- **GDScript:** Primary language — first-class citizen, tight engine integration, signal system
- **Godot TileMap:** 2D world layout — grid-based maps, autotiling, collision layers
- **AStar2D / Navigation2D:** Pathfinding — grid-based roguelite navigation
- **Resource (.tres):** Data storage — items, weapons, stats, RNG seeds
- **SignalBus pattern:** Decoupled events — survival stat changes, inventory updates, time events

**Note:** Stack confidence is LOW — research conducted with training data only, unable to verify against current Godot documentation. Godot 4.4+ may be current; verify before implementation.

### Expected Features

**Must have (table stakes):**
- HP + Hunger survival stats — core loop pressure; death when either depletes
- WASD Movement — PC survival convention (deadzone already implemented per ARCHITECTURE.md)
- Day/Night Cycle (10min/5min) — genre rhythm; night increases enemy spawns
- Random Map Generation — roguelite replayability expectation
- Enemy Spawning with chase AI — survival tension; escalating frequency/strength over time
- Treasure Chests — loot drops for risk/reward exploration
- XP + Level Up + Skill Points + Skill Tree — roguelite progression hook
- Weapon System (knife as MVP) — combat response to survival pressure

**Should have (competitive differentiators):**
- Sanity stat — third survival dimension; emotional/psychological pressure
- Visual sanity effects (screen distortion at low sanity) — deepens immersion
- Weapon categories beyond knife (ranged, magic) — build diversity
- Passive items/equipment slots — equipment beyond weapons

**Defer (v2+):**
- Multiple playable characters — splits content, complicates balance
- Meta progression — breaks roguelite purity
- Dynamic weather — complexity after core loop solid
- Procedural POIs — caves, shrines, ruins
- Weapon evolution/upgrade system

### Architecture Approach

The architecture follows standard Godot patterns organized into layers: Autoload singletons (GameMaster, SignalBus, SaveSystem, AudioManager) for global state and decoupled communication; Scene-based entities (Player with state machine, Enemies with AI) for game objects; Resource-based data (ItemDB, WeaponDB, EnemyDB, LootTable) for balance data; and UI scenes (HUD, Inventory, Shop) subscribing to signals.

Key architectural patterns:
1. **Autoload Singleton (GameMaster):** Global run state, difficulty scaling, accessible via shorthand
2. **Signal Bus:** Centralized event hub decoupling emitters from listeners (player_damaged, enemy_killed, item_pickup)
3. **State Machine:** Player/enemy behavior split into discrete states with explicit transitions
4. **Resource-Based Items:** Weapon/item data as .tres files, not instanced scenes
5. **Component Pattern (Hitbox/Hurtbox):** Reusable damage delivery/reception attached to entities
6. **Object Pooling:** Enemy/projectile reuse to avoid GC pressure

Project structure: `autoload/`, `entities/player/`, `entities/enemies/`, `entities/loot/`, `resources/`, `world/`, `ui/`, `systems/combat/`.

### Critical Pitfalls

1. **Over-Engineered Stat Systems** — Plain floats suffice; abstraction layers waste time. Hunger = float that decreases, not a "HungerSystem." Only abstract when 3+ places need the same pattern.

2. **Premature Procedural Generation Optimization** — Simple TileMap works for 100x100 demo maps. Chunking/streaming only after profiling shows actual slowdown.

3. **Collision Detection Mismanagement** — Explicitly document collision roles: Player (Layer 1, Mask 2+4), Enemies (Layer 2, Mask 1+2), Interactables (Layer 4). Use RayCast2D for targeted interactions, Area2D proximity only when necessary.

4. **Inconsistent World Coordinates** — Establish convention: world positions always pixels (Vector2), TileMap grid via `map_to_local()`/`local_to_map()`. Centralize spawn calculations in WorldUtils autoload.

5. **Memory Leaks from Scene Instancing** — Always `queue_free()` on exiting tree, disconnect signals before freeing, use WeakRef for caches, implement object pooling after profiling.

6. **Scope Creep** — Hard freeze on scope. Demo success criteria: "Player survives 15 minutes with full loop." Any "can this wait for post-demo?" is automatically yes.

7. **Poor State Machine Architecture** — No boolean flags (can_attack, is_attacking). Each state is its own node/scene. Explicit transitions per state.

8. **Night Cycle Neglect** — Night must change rules, not just visuals. Enemy spawn rate 2-3x, aggression 150%, minimum ambient light (not pure black), force engagement.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundation
**Rationale:** Core architecture must exist before any gameplay. Establishes patterns that all subsequent phases depend on.
**Delivers:** Project structure, state machine, collision layers, memory management, autoload singletons (GameMaster, SignalBus), coordinate conventions, basic player scene with idle/move states.
**Implements:** State machine pattern, collision layer documentation, Resource-based data structure skeleton
**Avoids:** Over-engineered stats (keep simple), poor state machine (use proper pattern), memory leaks (establish cleanup patterns)
**Research Flag:** Verify Godot 4.4+ vs 4.3+ API differences before implementation

### Phase 2: World Generation
**Rationale:** Map is the play space; must exist before combat or survival systems can be tested meaningfully.
**Delivers:** TileMap-based procedural generation, room/corridoor algorithm, world-to-grid coordinate utilities, WorldUtils autoload, basic treasure chest spawning
**Implements:** TileMap system, procedural generation algorithm, coordinate conversion utilities
**Avoids:** Premature optimization (generate full map at start, simple approach first), coordinate inconsistency (establish conventions)
**Research Flag:** None — standard TileMap patterns, well-documented

### Phase 3: Survival Core Loop
**Rationale:** HP+Hunger are the primary pressure sources. Must be playable before enemies or progression.
**Delivers:** HP stat (damage on depletion = death), Hunger stat (decay over time, food pickups restore), Hunger damage implementation, basic HUD showing both stats
**Implements:** Survival stat signals, food pickup items, stat decay system
**Avoids:** Over-engineered stat system (plain floats)
**Research Flag:** None — straightforward implementation

### Phase 4: Combat & Enemies
**Rationale:** Enemies provide survival pressure; must exist to test difficulty scaling.
**Delivers:** Enemy base class, 1-2 enemy types with chase AI, hitbox/hurtbox combat system, knife weapon (single attack), enemy spawning with escalating frequency/strength, object pooling
**Implements:** Component pattern (Hitbox/Hurtbox), enemy AI state machine, spawner system
**Avoids:** Collision mismanagement (explicit layer documentation), memory leaks (pooling from start)
**Research Flag:** None — standard patterns

### Phase 5: Progression & Content
**Rationale:** Progression hooks player attention; skill tree provides replayability.
**Delivers:** XP system (enemy kills), level-up UI, skill points (1 per level), 3-5 basic skills, skill tree UI, treasure chest loot (food, maybe weapons)
**Implements:** XP/skill Resource data, skill point allocation UI
**Avoids:** Skill economy miscalculation (design formula first, test full unlock sequence), scope creep (no meta-progression)

### Phase 6: Day/Night Cycle & Polish
**Rationale:** Day/night is genre rhythm; needs tuning once base systems exist.
**Delivers:** Day/night cycle (10min/5min), night spawn rate 2-3x, night visual (darkness), night enemy aggression increase, basic enemy AI improvement, HUD polish, audio setup
**Implements:** WorldEnvironment for lighting, spawn rate multipliers
**Avoids:** Night cycle neglect (make it dangerous, not just dark), difficulty imbalance (tune across full curve: 0min, 5min night, 15min, 30min)
**Research Flag:** Playtest required — difficulty tuning is empirical

### Phase Ordering Rationale

1. **Foundation before World:** State machine and collision patterns needed to test entity placement
2. **World before Combat:** Map must exist before spawning enemies; coordinate system needed for spawn points
3. **Combat before Progression:** Enemies are the source of XP; must exist to tune economy
4. **Progression before Day/Night:** Skills affect survivability; night tuning requires knowing base difficulty
5. **Day/Night last:** Visual/balance tuning phase after all systems interact

### Research Flags

**Phases needing deeper research during planning:**
- **Phase 1:** Godot 4.4+ API verification — current docs reference 4.3, 4.4 may have differences
- **Phase 6 (Difficulty Tuning):** Requires extensive playtesting — empirical, not researchable

**Phases with standard patterns (skip research-phase):**
- **Phase 2 (World Generation):** Godot TileMap is well-documented
- **Phase 3 (Survival Core):** Plain float stats, simple decay formula
- **Phase 4 (Combat):** State machine, hitbox/hurtbox, object pooling — all standard Godot patterns

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | LOW | Training data only. Unable to verify Godot 4.3 vs 4.4. Recommend checking official docs before implementation. |
| Features | MEDIUM | Training data + project context. MVP definition aligns with competitor analysis. Anti-features list credible. |
| Architecture | MEDIUM | Standard Godot patterns. SignalBus, state machine, resources — all well-established. |
| Pitfalls | MEDIUM | Training data + project context. Pitfall-to-phase mapping is actionable. |

**Overall confidence:** MEDIUM

### Gaps to Address

- **Godot Version:** Research used Godot 4.3; current stable may be 4.4+. Verify before Phase 1.
- **Procedural Generation Algorithm:** Research recommends BSP, WFC, or cellular automata but did not specify which for Starven's map style. Decision needed during Phase 2 planning.
- **Enemy AI Depth:** Research covers chase AI only. Whether more complex AI (patrol, flee, ranged) belongs in demo is undecided.
- **Sanity Implementation:** Sanity is marked P2 (should-have) but spec says "HP + Hunger + Sanity" in competitor analysis. Clarify if Sanity is in demo scope.

## Sources

### Primary (HIGH confidence)
- None — web search access denied during research

### Secondary (MEDIUM confidence)
- Godot 4.3 documentation (training data) — engine capabilities, patterns
- Vampire Survivors, Don't Starve, Soulstone Survivors, Brotato — feature ecosystem analysis
- Starven existing implementation (ARCHITECTURE.md) — current state, deadzone, state machine docs

### Tertiary (LOW confidence)
- Godot 4.4 release notes — not verified, training data may be outdated
- Community Godot patterns — inferred from training data, not verified

---
*Research completed: 2026/04/06*
*Ready for roadmap: yes*
