# Pitfalls Research

**Domain:** 2D Godot Survival Roguelite Game
**Researched:** 2026/04/06
**Confidence:** MEDIUM (training knowledge, no web search access)

## Critical Pitfalls

### Pitfall 1: Over-Engineered Stat Systems

**What goes wrong:**
Game becomes a spreadsheet simulator. Players spend more time reading stat tooltips than playing. Code accumulates layers of abstraction for stats that could be simple floats.

**Why it happens:**
Developers anticipate "future requirements" and build generic stat frameworks with modifiers, buffs, stacking rules, damage calculations. The roguelite progression hook demands complex scaling, and it's easy to keep adding layers.

**How to avoid:**
Start with plain float values. Add complexity only when a specific gameplay requirement demands it. For Starven: hunger = float that decreases, not a "HungerSystem" with decay rates and saturation modifiers. Only abstract when you need the same pattern in 3+ places.

**Warning signs:**
- Designing stat classes before designing gameplay
- Creating "BaseStat" parent classes with no immediate concrete subclass
- More than 3 layers of stat modification indirection in Phase 1

**Phase to address:**
Phase 1 (Foundation) - Design stat storage as simple data, not systems

---

### Pitfall 2: Premature Procedural Generation Optimization

**What goes wrong:**
World generator is heavily optimized for map sizes you'll never reach in demo phase. Time spent on chunking, LOD, streaming when simple TileMap works fine.

**Why it happens:**
"Don't Starve has huge maps" creates implicit pressure. Developers read about FastNoiseLite optimizations and implement hierarchical tiling before verifying the naive approach is too slow.

**How to avoid:**
Generate the full map once at game start using simple TileMap. Only add chunking/streaming when profiling shows actual performance issues at target map size. For demo: maps of 100x100 tiles render instantly without optimization.

**Warning signs:**
- Implementing tile chunking before the map is too slow
- Writing custom threading for generation before measuring main thread time
- Designing "infinite world" architecture for a demo with fixed maps

**Phase to address:**
Phase 2 (World Generation) - Verify naive approach is insufficient before optimizing

---

### Pitfall 3: Collision Detection Mismanagement

**What goes wrong:**
Player walks through enemies, enemies stack on each other, interaction detection fails unpredictably. Collision bugs become heisenbugs - they appear and disappear with code changes.

**Why it happens:**
Using wrong CollisionLayer2D/CollisionMask combinations, mixing Area2D and StaticBody2D incorrectly, or setting layer priorities incorrectly in Godot 4's collision system.

**How to avoid:**
Explicitly document collision roles:
- Player: Layer 1 (Body), Mask 2 (enemies) + 4 (interactables)
- Enemies: Layer 2, Mask 1 (player) + 2 (other enemies)
- Interactables: Layer 4, Mask 0 (passive)
Use RayCast2D for targeted interactions, not Area2D proximity. Test collision pairs manually before assuming they work.

**Warning signs:**
- "Sometimes the hit doesn't register" bug reports
- Enemies clustering into single tile
- Player can walk partially through solid objects

**Phase to address:**
Phase 1 (Foundation) - Define collision layers before movement implementation

---

### Pitfall 4: Inconsistent World Coordinates

**What goes wrong:**
Entities spawned in code appear at wrong positions. Tile-to-world coordinate conversion fails. Camera doesn't follow player correctly after map generation.

**Why it happens:**
Mixing `global_position`, `position`, `modulate`, and coordinate spaces (TileMap grid vs. pixel world). Failing to account for TileMap's origin setting (TopLeft vs. Center vs. BottomLeft).

**How to avoid:**
Establish a single coordinate convention:
- World positions always in pixels (Vector2)
- TileMap grid positions always converted via `map_to_local()` / `local_to_map()`
- Document origin policy: TileMaps use TopLeft origin
- Centralize all spawn position calculations in one `WorldUtils` autoload

**Warning signs:**
- Entities spawning one tile off
- Camera jitter at map edges
- "Works in editor, wrong in game" position bugs

**Phase to address:**
Phase 2 (World Generation) - Establish coordinate utilities before placing any entity

---

### Pitfall 5: Memory Leaks from Scene Instancing

**What goes wrong:**
Game runs fine for 5 minutes, then framerate drops. Memory usage climbs monotonically. Exit returns to desktop slowly or hangs.

**Why it happens:**
Enemy deaths spawn loot scenes but never free them. Signal connections accumulate when scenes are re-instanced. `queue_free()` called but references still held in arrays/dictionaries.

**How to avoid:**
- Always `queue_free()` on exiting tree, not just `free()`
- Disconnect signals before `queue_free()` when dynamically created
- Use `WeakRef` for caches that hold scene instances
- Implement object pooling for frequently spawned entities (enemies, loot) after profiling shows allocation pressure
- Verify memory returns to baseline after each game session in test harness

**Warning signs:**
- Memory monitor climbing during extended play
- "Objects remaining after free" in debugger
- Longer exit times after longer play sessions

**Phase to address:**
Phase 1 (Foundation) - Establish memory management patterns before spawning anything

---

### Pitfall 6: Difficulty Scaling Imbalance

**What goes wrong:**
Early game is too hard (player dies before getting any items) or late game is trivial (infinite food, no threat). The escalation curve feels wrong.

**Why it happens:**
Difficulty parameters tuned in isolation. Enemy spawn rate, damage, and player stats scaled independently without holistic testing across the full progression curve.

**How to avoid:**
Design difficulty as a curve, not linear scaling:
- Base difficulty = D0 at game start
- Multiplicative scaling: `enemy_count = base_count * (1.15 ^ wave_number)`
- Cap difficulty scaling at reasonable bounds (enemies can't exceed 50 per screen)
- Test at: 0min, 5min (night), 15min, 30min marks
- Create "kill streak" metric - player should die once before reaching level 5 if playing normally

**Warning signs:**
- Playtesters dying in first 2 minutes consistently
- No deaths after 10 minutes
- Single strategy dominates all phases (no adaptation required)

**Phase to address:**
Phase 5 (Combat) - Test difficulty curve across full session length

---

### Pitfall 7: Scope Creep in Demo Phase

**What goes wrong:**
Demo never ships because features keep getting added. "Just one more system" becomes perpetual. The demo scope balloons beyond a reasonable prototype.

**Why it happens:**
No strict feature boundary. "It would be cool if" replaces "does this serve the demo goal?". Roguelite genre invites meta-progression ideas that are explicitly out of scope but tempting.

**How to avoid:**
Hard freeze on scope at phase start:
- PRD "Out of Scope" is inviolable during demo
- Any new feature request: "Can this wait for post-demo?"
- Demo success criteria: "Player survives 15 minutes with full loop"
- Weekly scope review with explicit "cut" list if behind

**Warning signs:**
- Phase estimates consistently exceeded
- "This small feature" being added weekly
- Demo still not playable after 2 months

**Phase to address:**
All phases - Review scope adherence at each phase transition

---

### Pitfall 8: Poor State Machine Architecture

**What goes wrong:**
State machine becomes a mess of boolean flags. "CanAttack" and "IsAttacking" contradict. Transitions fire at wrong times. New states require modifying every existing state.

**Why it happens:**
Using individual boolean properties instead of a proper state pattern. Adding `can_do_X` flags as new features emerge instead of redesigning the state model.

**How to avoid:**
Use Godot's built-in StateMachine node or a simple state pattern:
- Each state is its own scene/node
- Valid transitions defined explicitly per state
- No boolean flags for mutually exclusive conditions
- States handle their own exit conditions
- See existing STATE_MACHINE.md in project root for the established pattern

**Warning signs:**
- Code with 5+ boolean properties on player (can_attack, is_attacking, can_move, is_damaged...)
- "Wait, which state is the player in?" confusion
- New feature requires modifying 4+ unrelated files

**Phase to address:**
Phase 1 (Foundation) - Implement proper state machine before implementing actions

---

### Pitfall 9: Skill Point Economy Miscalculation

**What goes wrong:**
Players are overwhelmed with skill points (trivial progression) or cannot access skills until too late (frustrating progression). Skills feel meaningless either way.

**Why it happens:**
XP gain rates and skill costs not playtested together. Curve assumptions made without actual numbers. Skill points too abundant or too scarce relative to content depth.

**How to avoid:**
Design the economy first:
- XP needed per level: explicit formula (e.g., `level * 100`)
- Skill point gain: one per level
- First skill should cost 1 point, be accessible within 3 minutes
- Final skill should cost all remaining points at level 10+
- Test the full unlock sequence from fresh save

**Warning signs:**
- Player has 5 unspent points at level 8
- Player levels up twice before spending first point
- No skills available in first 5 minutes

**Phase to address:**
Phase 5 (Combat & Progression) - Tune economy with actual playtest data

---

### Pitfall 10: Night Cycle Neglect

**What goes wrong:**
Day/night cycle exists but night is just "darker" without meaningful gameplay change. Or night is impossibly hard without preparation. The cycle becomes cosmetic.

**Why it happens:**
Night spawning rates not tuned separately from day. No unique night threats. "Make it darker" implemented without "make it different."

**How to avoid:**
Night should change rules, not just visuals:
- Enemy spawn rate: 2-3x day rate
- Enemy aggression: 150% of daytime
- Add visual distinction: not just darker, but "fog of war" or limited visibility
- Force engagement: player cannot simply hide until dawn
- Create night-specific items (torch, night vision)

**Warning signs:**
- Playtesters say "I just wait out night"
- No difference in behavior between day and night
- Death at night feels random, not strategic

**Phase to address:**
Phase 5 (Combat & Progression) - Night should feel dangerous, not just dark

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoded enemy stats | Fast iteration | Balancing nightmare | MVP only, must be data-driven post-demo |
| Single global autoload for all managers | Simple code sharing | God object antipattern | MVP only, split after 3+ managers emerge |
| `print()` debugging instead of proper logging | No setup needed | Debug spam, performance cost | Temporary, replace with proper Logger |
| Scene-based level design (not procedural) | Visual editor workflow | Can't generate infinite content | Demo phase only |
| 1-second Timer polling instead of signals | Easier to write | Performance waste | Never acceptable, use signals |
| Global references via `get_node("/root/...")` | Quick access | Brittle, breaks with node moves | Never, use proper dependency injection |

---

## Integration Gotchas

This section is less applicable for a standalone game project. Key gotchas:

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Save System | Not saving mid-run state | Save on explicit events + periodic auto-save |
| Input System | Hardcoding input actions in multiple places | Use Godot's Input Map, reference via `InputMap.action_get_events()` |
| Audio | Placing AudioStreamPlayer nodes in scenes manually | Use a dedicated AudioManager autoload, pool audio players |

---

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| TileMap with 50+ layers | Editor lag, slow generation | Use 3-5 layers max, combine visuals | Maps larger than 200x200 |
| 100+ simultaneous Area2D checks | CPU spikes during combat | Use spatial partitioning, cap active enemies | More than 30 enemies visible |
| Particle effects on many entities | GPU bottleneck | Pool particles, limit concurrent | More than 10 entities with particles |
| `_process()` running when paused | Wasted CPU | Check `get_tree().paused` or use NOTIFICATION_PROCESS_STOP | Always -养成习惯 |

---

## Security Mistakes

For a standalone game, traditional security concerns are minimal. Key domain-specific issues:

| Mistake | Risk | Prevention |
|---------|------|------------|
| Save file manipulation | Players edit .sav to give themselves infinite items | Validate save data on load, checksums or schema validation |
| Deterministic RNG exploit | Speedrunners predict next RNG for "perfect" runs | Seed RNG with timestamp + session salt |
| Resource exhaustion via item duplication | Economy broken by duping items | Validate item count changes, server-authoritative if networked |

---

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No death screen/restart | Player confused after death | Clear "You Died - Press R to Restart" overlay |
| Controls never explained | New players lost | First 30 seconds: show control hints, allow skip |
| Hunger depleting while reading UI | Frustration | Hunger decreases slower during menu/pause states |
| Night too dark to see | Player frustration, not difficulty | Minimum ambient light, not pure black |
| No way to see current stats | Trial and error | Accessible stats menu (Tab or pause) |

---

## "Looks Done But Isn't" Checklist

- [ ] **Survival Loop:** Player CAN die from hunger - verify starvation deals damage
- [ ] **Combat:** Enemy death actually removes enemy from tree - verify no orphan nodes
- [ ] **Level Up:** XP bar visually fills - verify stat actually increases on level up
- [ ] **Day/Night:** Visual change occurs - verify enemy spawn rates actually change
- [ ] **Inventory:** Item appears when picked up - verify item disappears from world
- [ ] **Skill System:** Skill appears unlocked - verify it actually modifies behavior
- [ ] **World Generation:** Map is random each run - verify seed produces different layout
- [ ] **Save/Load:** Game saves - verify it loads to exact same state

---

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Over-engineered stats | HIGH | Refactor to simple floats, accept lost abstraction time |
| Collision bugs | MEDIUM | Re-audit all layer/mask assignments, test each entity pair |
| Memory leaks | MEDIUM | Profile with debugger, identify unreleased instances, add cleanup |
| Difficulty imbalance | LOW-MEDIUM | Tune numbers in data files, no code changes needed |
| Scope creep | LOW | Cut features ruthlessly, maintain demo boundary |

---

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Over-engineered stat systems | Phase 1 - Foundation | Code review: no class inheritance for stats beyond 1 level |
| Premature procedural optimization | Phase 2 - World Generation | Measure generation time, optimize only if >2 seconds |
| Collision detection issues | Phase 1 - Foundation | Manual test: all entity pairs can interact correctly |
| Coordinate inconsistency | Phase 2 - World Generation | Spawn test: entities appear at expected positions |
| Memory leaks | Phase 1 - Foundation | Memory profiler: stable usage after 10 minute run |
| Difficulty imbalance | Phase 5 - Combat | Playtest: death occurs between 3-15 minutes for new player |
| Scope creep | All phases | Phase review: no features outside demo scope |
| State machine issues | Phase 1 - Foundation | Code review: no boolean flags for state representation |
| Skill economy miscalc | Phase 5 - Combat | Playtest: skill unlocks feel appropriately paced |
| Night cycle neglect | Phase 5 - Combat | Playtest: night feels meaningfully different |

---

## Sources

- Godot 4.x documentation: Collision layers and masks
- Godot Best Practices: State machine patterns
- Game development community: "Survival games - common pitfalls" discussions
- Training knowledge: GDScript memory management quirks
- Project context: PRD, AGENTS.md, existing STATE_MACHINE.md

---
*Pitfalls research for: Starven 2D Survival Roguelite*
*Researched: 2026/04/06*
