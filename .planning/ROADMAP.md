# Starven Roadmap

## Project
Starven - 2D survival game (Godot/GDScript)

## Core Value
Survive as long as possible — everything else can fail, this cannot.

## Phases

- [ ] **Phase 1: Movement & Architecture** - Player WASD movement, sprite direction, project foundation
- [ ] **Phase 2: World Generation & Loot** - Procedural map, treasure chests, random loot, food items
- [ ] **Phase 3: Survival Systems & HUD** - HP/Hunger stats, stat decay, HUD bars and day display
- [ ] **Phase 4: Combat & Progression** - Enemies, XP/leveling, skill system, weapon combat
- [ ] **Phase 5: Day/Night Cycle** - Day/night timing, enemy spawn modifiers by time of day

## Phase Details

### Phase 1: Movement & Architecture
**Goal**: Player can move freely in an empty world; core architecture patterns established
**Depends on**: Nothing (first phase)
**Requirements**: MOVE-01, MOVE-02
**Success Criteria** (what must be TRUE):
  1. Player sprite moves in response to WASD keys without input lag
  2. Player sprite visually faces the direction of last movement
  3. Project structure follows Godot best practices (autoloads, signal bus, state machines)
  4. Collision layers documented and applied to player entity
  5. Basic player scene with idle/move states functional
**Plans**: TBD
**UI hint**: yes

### Phase 2: World Generation & Loot
**Goal**: Player exists in a large procedurally generated world with explorable terrain and collectible loot
**Depends on**: Phase 1
**Requirements**: WORLD-01, WORLD-02, WORLD-03, WORLD-04, WORLD-05, LOOT-01, LOOT-02, LOOT-03, LOOT-04
**Success Criteria** (what must be TRUE):
  1. New game generates a unique large map each time (procedurally varied)
  2. Map contains terrain variety (at least two visual tile types)
  3. Player can walk/move across the entire map without getting stuck
  4. Treasure chests spawn randomly throughout the world
  5. Player can approach and open a treasure chest to receive loot
  6. Chest loot is randomized (food, weapons, resources, special items appear)
  7. Food items consumed by player restore hunger stat
  8. Weapons found in chests can be equipped and used by player
  9. Special items provide observable passive effects when collected
**Plans**: TBD

### Phase 3: Survival Systems & HUD
**Goal**: Player experiences HP and Hunger as survival pressure; UI displays critical stats
**Depends on**: Phase 2
**Requirements**: SURV-01, SURV-02, SURV-03, UI-01, UI-02, UI-03, UI-04
**Success Criteria** (what must be TRUE):
  1. Player has 100 HP at spawn; HP bar visible in HUD
  2. Player has 100 Hunger at spawn; Hunger bar visible in HUD
  3. Hunger decreases gradually over time during gameplay
  4. Eating food (from chests or pickups) restores Hunger
  5. When Hunger reaches 0, Player HP begins draining continuously
  6. HUD displays current day number and time of day
  7. "Level Up" notification appears when player levels up
**Plans**: TBD
**UI hint**: yes

### Phase 4: Combat & Progression
**Goal**: Player fights enemies to gain XP, level up, and spend skill points on abilities
**Depends on**: Phase 3
**Requirements**: FIGHT-01, FIGHT-02, FIGHT-03, FIGHT-04, FIGHT-05, ENEMY-01, ENEMY-02, ENEMY-03, ENEMY-04, PROG-01, PROG-02, PROG-03, PROG-04, PROG-05, PROG-06, PROG-07, UI-05
**Success Criteria** (what must be TRUE):
  1. Player can attack with equipped weapon using action key (default knife)
  2. Weapon attacks have cooldown between uses
  3. Enemies chase the player when within detection range
  4. Enemy contact damages player (HP decreases, hurtbox triggers)
  5. Player has brief invincibility after taking damage (visible feedback)
  6. Killing enemies causes XP orbs/items to drop
  7. Player collects XP orbs by moving near them
  8. Player reaches XP threshold and levels up
  9. Level up grants skill points to the player
  10. Player can open skill menu and spend points to unlock/upgrade abilities
  11. Skill menu displays 3-5 available skills
  12. Player stats (damage, speed, max HP) visibly improve upon leveling
  13. Enemy spawn rate increases over time (escalating frequency)
  14. Enemy spawn count increases over time (escalating count)
  15. Enemy strength/power increases over time (escalating difficulty)
**Plans**: TBD
**UI hint**: yes

### Phase 5: Day/Night Cycle
**Goal**: Day/night cycle creates genre-appropriate rhythm with increased danger at night
**Depends on**: Phase 4
**Requirements**: ENEMY-05, ENEMY-06, CYCLE-01, CYCLE-02, CYCLE-03, CYCLE-04
**Success Criteria** (what must be TRUE):
  1. Day lasts exactly 10 minutes before transitioning to night (configurable)
  2. Night lasts exactly 5 minutes before transitioning to day (configurable)
  3. Visual indicator clearly shows day/night transition (screen tint, icon, etc.)
  4. Day/night cycle runs continuously from game start (no pausing)
  5. Daytime enemy spawns are sparse (few enemies visible during day)
  6. Nighttime enemy spawns are significantly increased (noticeably more enemies at night)
**Plans**: TBD

## Progress Table

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Movement & Architecture | 0/5 | Not started | - |
| 2. World Generation & Loot | 0/9 | Not started | - |
| 3. Survival Systems & HUD | 0/7 | Not started | - |
| 4. Combat & Progression | 0/15 | Not started | - |
| 5. Day/Night Cycle | 0/6 | Not started | - |

## Coverage

All 37 v1 requirements mapped to phases.

## Awaiting

Approve roadmap or provide feedback for revision.
