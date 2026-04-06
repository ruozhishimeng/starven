# Feature Research

**Domain:** 2D Survival Roguelite Games
**Researched:** 2026/04/06
**Confidence:** MEDIUM

*Note: WebSearch access denied. Findings based on training data (Vampire Survivors, Don't Starve, Soulstone Survivors, Brotato ecosystem analysis). Recommend verification via playability testing and competitor analysis when possible.*

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Survival Stats (HP)** | Core to any survival game; death when depleted is fundamental | LOW | Simple float 0-100, damage sources, healing sources |
| **Survival Stats (Hunger)** | Don't Starve established this as genre convention; creates time pressure | MEDIUM | Decay rate tied to activity, food pickups restore it |
| **Survival Stats (Sanity)** | Differentiates survival from generic action; adds psychological pressure | MEDIUM | Night/darkness/fighting monsters triggers decay; affects visuals or enemy spawns |
| **Day/Night Cycle** | Survival genre rhythm; day = safe exploration, night = danger | MEDIUM | Configurable durations; affects enemy spawn rates, visibility |
| **WASD Movement** | PC survival game convention; muscle memory expectation | LOW | Deadzone already implemented per ARCHITECTURE.md |
| **Weapon System** | Combat is the response to survival pressure | MEDIUM | Extensible architecture needed; categories = melee/remote/magic |
| **Random Map Generation** | Roguelite expectation of replayability; no two runs identical | HIGH | Chunk-based streaming already in ARCHITECTURE.md |
| **Enemy Spawning** | Without enemies, survival has no tension | MEDIUM | Escalating frequency/count/strength over time |
| **Treasure Chests** | Loot expectation from roguelite genre; risk/reward for exploration | LOW | Random contents: food, weapons, resources |
| **XP / Level Up** | Roguelite progression hook; reward for surviving | LOW | XP on enemy kill, level up triggers |
| **Skill Points on Level Up** | Spend progression choices; core roguelite moment | LOW | Points at fixed level thresholds |
| **Skill Tree / Abilities** | Active choices that shape each run; replayability driver | MEDIUM | Unlock/upgrade abilities with skill points |

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **Sanity Visual Effects** | Distorted screen at low sanity, hallucinations; emotional investment | MEDIUM | Screen shake, color desaturation, phantom enemies |
| **Dynamic Weather** | Environmental pressure variation; surprises after memorized patterns | MEDIUM | Rain increases hunger decay, fog reduces visibility |
| **Weapon Evolution/Upgrades** | Finding weapon versions that change playstyle; Vampire Survivors magnet/weapon rank system | MEDIUM | Per-weapon level progression beyond raw stat boosts |
| **Passive Items / Accessories** | Equipment slots beyond weapons; build diversity | MEDIUM | Rings, amulets, boots that modify survival stats |
| **Enemy Variety Escalation** | Different enemy types at different survival durations; keeps pressure fresh | HIGH | Wave-based type introduction over time |
| **Procedural POIs** | Interesting locations beyond chests; caves, shrines, ruins | MEDIUM | Rewards exploration with guaranteed loot or events |
| **Survival Milestones** | Achievements for reaching time thresholds; personal goals | LOW | "Survive 10 minutes", "Reach Day 5", etc. |
| **Combo / Kill Streak System** | Score multiplier for rapid kills; skill expression | LOW | Encourages aggressive play, rewards mastery |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| **Multiple Playable Characters** | Character variety, replayability | Splits player base, doubles content requirements, complicates balance | One fixed hero with deep build diversity via skills |
| **Meta Progression / Permanent Unlocks** | "Progress between runs" feels good | Breaks roguelite purity, creates power creep, complicates demo scope | No meta progression; skill choices within run are the hook |
| **Multiplayer** | Co-op is popular, request every game | Network sync, balance, hosting complexity for demo | Ship single-player first; co-op is a future phase |
| **Mobile / Controller Support** | Broader audience reach | Input mapping differences, UI scaling, playtesting burden | Keyboard only for demo; preserve scope |
| **Large Content Library at Launch** | "Other games have X enemies" | Content debt is endless; better to polish core loop | Launch with fewer enemies, polish behaviors |
| **Real-Time Crafting UI** | Inventory management depth | Menus break action flow in survival game | Chest loot is immediate pickup; no inventory management |
| **Permadeath with Run History** | "My deaths matter" | Adds development complexity, may discourage casual players | Simple "you died, restart" loop is sufficient for demo |

## Feature Dependencies

```
[Day/Night Cycle]
    └──requires──> [Enemy Spawn Escalation]
                          └──requires──> [Survival Stats]

[Random Map Generation]
    └──requires──> [Treasure Chests]
                          └──requires──> [Loot System]

[XP System]
    └──requires──> [Level Up]
                        └──requires──> [Skill Points]
                                          └──requires──> [Skill Tree]

[Survival Stats]
    └──enhances──> [Sanity System] (if implemented)

[Weapon System]
    └──enhances──> [Weapon Categories (melee/remote/magic)]

[Skill Tree]
    └──conflicts──> [Meta Progression] (choose one progression model)
```

### Dependency Notes

- **Day/Night Cycle requires Enemy Spawn Escalation:** Night is meaningless without danger to contrast day safety
- **XP System requires Level Up requires Skill Points requires Skill Tree:** Linear dependency chain for progression
- **Random Map Generation requires Treasure Chests:** Without rewards, exploration has no point
- **Skill Tree conflicts with Meta Progression:** Roguelite purity vs persistent progress; Starven chose roguelite (correct for demo scope)
- **Survival Stats is foundational:** Everything else exists to pressure or respond to survival needs

## MVP Definition

### Launch With (v1)

Minimum viable product - what is needed to validate the concept.

- [ ] **HP + Hunger survival stats** - Core loop pressure and response; death when either depletes
- [ ] **WASD Movement** - Already implemented per ARCHITECTURE.md
- [ ] **Single weapon (knife)** - Combat exists, player can attack
- [ ] **Day/Night Cycle (10min/5min)** - Genre rhythm; darkness increases enemy spawns
- [ ] **Random Map Generation** - Exploration space exists
- [ ] **Treasure Chests** - Loot drops for reward; at minimum food to address hunger
- [ ] **XP + Level Up** - Progression exists
- [ ] **3-5 basic skills** - Enough to demonstrate build diversity
- [ ] **1-2 enemy types** - Enough to show escalation, not content debt
- [ ] **Basic enemy AI (chase)** - Already implemented per ARCHITECTURE.md

### Add After Validation (v1.x)

Features to add once core is working.

- [ ] **Sanity stat** - Adds third survival dimension; emotional pressure
- [ ] **More weapon categories** - Remote (ranged), Magic (elemental)
- [ ] **More enemy types** - Introduced at time thresholds
- [ ] **Visual sanity effects** - Screen distortion, hallucinations
- [ ] **Survival milestones** - UI badges, time achievements
- [ ] **Passive items** - Equipment beyond weapons

### Future Consideration (v2+)

Features to defer until product-market fit is established.

- [ ] **Multiple playable characters** - After single hero is validated
- [ ] **Meta progression** - Permanent unlocks between runs
- [ ] **Dynamic weather** - After core survival loop is solid
- [ ] **Procedural POIs** - Interesting exploration rewards
- [ ] **Weapon evolution system** - Upgraded weapon versions

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| HP + Hunger | HIGH | LOW | P1 |
| Day/Night Cycle | HIGH | MEDIUM | P1 |
| WASD Movement | HIGH | LOW | P1 |
| Random Map | HIGH | HIGH | P1 |
| Enemy Spawning | HIGH | MEDIUM | P1 |
| Treasure Chests | HIGH | LOW | P1 |
| XP + Level Up | HIGH | LOW | P1 |
| Skill Points | HIGH | LOW | P1 |
| Basic Skills (3-5) | HIGH | MEDIUM | P1 |
| Weapon (knife) | HIGH | LOW | P1 |
| Enemy AI (chase) | HIGH | MEDIUM | P1 |
| Sanity | MEDIUM | MEDIUM | P2 |
| More Weapon Categories | MEDIUM | MEDIUM | P2 |
| More Enemy Types | MEDIUM | MEDIUM | P2 |
| Visual Sanity Effects | MEDIUM | MEDIUM | P2 |
| Survival Milestones | MEDIUM | LOW | P2 |
| Passive Items | MEDIUM | MEDIUM | P2 |
| Dynamic Weather | LOW | HIGH | P3 |
| Procedural POIs | LOW | HIGH | P3 |
| Weapon Evolution | LOW | MEDIUM | P3 |
| Multiple Characters | LOW | HIGH | P3 |
| Meta Progression | LOW | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | Vampire Survivors | Don't Starve | Soulstone Survivors | Our Approach |
|---------|-------------------|---------------|---------------------|--------------|
| Survival Stats | HP only (no hunger/sanity) | HP + Hunger + Sanity | HP only | HP + Hunger + Sanity |
| Day/Night Cycle | No (endless day) | Yes | No | Yes (10min/5min) |
| Weapon Progression | Auto-fire, evolve at thresholds | Crafted weapons | Active abilities | Manual attack + skills |
| Map Generation | Single screen scrolling | Infinite procedural | Arena-based | Large random maps |
| Meta Progression | Unlock characters, achievements | N/A | Unlock modifiers | None (roguelite purity) |
| Skill System | Passive pickups | Sanity-based insanity skills | Active ability slots | Skill points + skill tree |
| Enemy Escalation | Intensity increases | More dangerous types at night | Wave-based | Time-based frequency + count + strength |

**Analysis Summary:**
- Vampire Survivors: Stripped-down survival (HP only), auto-combat, screen-scrolling arena. Suits casual play.
- Don't Starve: Deep survival (3 stats), crafted weapons, complex. Suits hardcore survival fans.
- Soulstone Survivors: Active ability focus, arena waves, moderate depth.
- **Starven position:** Don't Starve survival depth (3 stats, day/night) with Vampire Survivors progression model (XP/skill tree) and roguelite purity (no meta progression). This combination is underserved.

## Sources

- Vampire Survivors - Steam, gameplay analysis
- Don't Starve - Klei documentation, gameplay analysis
- Soulstone Survivors - Steam, gameplay analysis
- Brotato - Steam, gameplay analysis
- Hell Dogs - Steam, gameplay analysis
- Godot 4.x documentation - engine capabilities
- Starven ARCHITECTURE.md - existing implementation state
- Starven STACK.md - technology decisions

---
*Feature research for: 2D Survival Roguelite Games*
*Researched: 2026/04/06*
