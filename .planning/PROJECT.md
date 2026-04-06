# Starven

## What This Is

A 2D survival game built in Godot/GDScript with pixel art. Player survives indefinitely in a randomly generated world, managing hunger, health, and sanity through day/night cycles while fighting escalating waves of enemies. Combines Don't Starve-style survival pressure with Vampire Survivors-style skill progression.

## Core Value

Survive as long as possible — everything else can fail, this cannot.

## Requirements

### Active

- [ ] Survival systems: HP, hunger, sanity with day/night cycle
- [ ] Player character: single fixed hero, WASD movement, keyboard controls
- [ ] Weapons: melee/remote/magic categories, extensible architecture, starts with knife
- [ ] Random map generation (large explorable maps)
- [ ] Treasure chests with random loot (food, weapons, resources, special items)
- [ ] Day/night cycle (10min day / 5min night, adjustable)
- [ ] Enemies: sparse during day, increased danger at night
- [ ] Infinite survival with escalating difficulty (enemy frequency, count, strength all increase over time)
- [ ] Level up system — gain XP, level up stats, earn skill points at fixed level thresholds
- [ ] Skill system — spend skill points to unlock/upgrade abilities (roguelite progression per run)

### Out of Scope

- Multiple playable characters — demo phase fixed to one hero
- Meta progression / permanent unlocks between runs
- Multiplayer
- Mobile or controller support

## Context

- **Engine**: Godot + GDScript
- **Art style**: Pixel art — handled by user
- **Goal**: Playable demo proving core survival + progression loop
- **Starting resources**: Knife weapon only, no food

## Constraints

- **Tech stack**: Godot 4.x, GDScript only
- **Art**: Pixel art, user produces all美术 resources
- **Controls**: Keyboard only (WASD + action keys)
- **Platform**: PC desktop

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Infinite survival | Simplest demo goal — survives long enough = success | — Pending |
| No meta progression | Keep demo scope focused on core loop | — Pending |
| Day/Night 10min/5min | 10min active + 5min dangerous is standard survival rhythm | Adjustable |
| Large random maps | Exploration is core to survival genre | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026/04/06 after initialization*
