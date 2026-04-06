# Requirements: Starven

**Defined:** 2026/04/06
**Core Value:** Survive as long as possible — everything else can fail, this cannot.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Survival

- [ ] **SURV-01**: Player has HP stat (0-100), dies when depleted
- [ ] **SURV-02**: Player has Hunger stat (0-100), decays over time, eating food restores it
- [ ] **SURV-03**: Hunger at 0 causes HP to drain over time (starvation damage)
- [ ] **SURV-04**: Player has Sanity stat (planned for v1.x, not in v1 demo)

### Movement

- [ ] **MOVE-01**: Player moves with WASD keyboard input
- [ ] **MOVE-02**: Player sprite faces movement direction

### Combat

- [ ] **FIGHT-01**: Player attacks with equipped weapon using action key (default: knife)
- [ ] **FIGHT-02**: Weapon system supports melee/remote/magic categories
- [ ] **FIGHT-03**: Weapons have cooldown between attacks
- [ ] **FIGHT-04**: Player takes damage from enemy contact (hurtbox)
- [ ] **FIGHT-05**: Player invincibility frames after taking damage

### Enemies

- [ ] **ENEMY-01**: Enemies chase player (basic chase AI)
- [ ] **ENEMY-02**: Enemy spawn system with escalating frequency over time
- [ ] **ENEMY-03**: Enemy spawn system with escalating count over time
- [ ] **ENEMY-04**: Enemy spawn system with escalating strength over time
- [ ] **ENEMY-05**: Daytime has sparse enemy spawns
- [ ] **ENEMY-06**: Nighttime has increased enemy spawns

### World

- [ ] **WORLD-01**: Large random map is procedurally generated
- [ ] **WORLD-02**: Map has explorable area with terrain variety
- [ ] **WORLD-03**: Treasure chests spawn randomly in the world
- [ ] **WORLD-04**: Treasure chest loot is random (food, weapons, resources, special items)
- [ ] **WORLD-05**: Player can open treasure chests

### Day/Night Cycle

- [ ] **CYCLE-01**: Day lasts 10 minutes (configurable)
- [ ] **CYCLE-02**: Night lasts 5 minutes (configurable)
- [ ] **CYCLE-03**: Visual indicator of day/night transition
- [ ] **CYCLE-04**: Day/night cycle is always running (continuous)

### Progression

- [ ] **PROG-01**: Enemies drop XP on death
- [ ] **PROG-02**: Player gains XP from killing enemies
- [ ] **PROG-03**: Player levels up when XP threshold reached
- [ ] **PROG-04**: Level up grants skill points at fixed thresholds
- [ ] **PROG-05**: Player can spend skill points on abilities
- [ ] **PROG-06**: Skill system supports 3-5 basic skills
- [ ] **PROG-07**: Player stats (damage, speed, max HP) improve on level up

### Items & Loot

- [ ] **LOOT-01**: Food items restore hunger
- [ ] **LOOT-02**: Weapons can be found as chest loot
- [ ] **LOOT-03**: Special items provide passive effects
- [ ] **LOOT-04**: Resources are collected (future crafting use)

### UI

- [ ] **UI-01**: HUD displays HP bar
- [ ] **UI-02**: HUD displays Hunger bar
- [ ] **UI-03**: HUD displays current day/time
- [ ] **UI-04**: Level up notification displayed
- [ ] **UI-05**: Skill menu accessible (key to open)

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Survival

- **SURV-05**: Sanity stat — decreases at night and in darkness, affects visuals

### Combat

- **FIGHT-06**: Remote/ranged weapon category
- **FIGHT-07**: Magic weapon category

### Enemies

- **ENEMY-07**: Multiple enemy types introduced at time thresholds

### Progression

- **PROG-08**: Visual sanity effects at low sanity (screen distortion, hallucinations)

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Multiple playable characters | Demo phase fixed to one hero |
| Meta progression / permanent unlocks | Keep demo scope focused on core loop |
| Multiplayer | Ship single-player first |
| Mobile / controller support | Keyboard only for demo |
| Real-time crafting UI | Chest loot is immediate pickup |
| Permadeath with run history | Simple restart loop sufficient |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| SURV-01 | Phase 3 | Pending |
| SURV-02 | Phase 3 | Pending |
| SURV-03 | Phase 3 | Pending |
| MOVE-01 | Phase 1 | Pending |
| MOVE-02 | Phase 1 | Pending |
| FIGHT-01 | Phase 4 | Pending |
| FIGHT-02 | Phase 4 | Pending |
| FIGHT-03 | Phase 4 | Pending |
| FIGHT-04 | Phase 4 | Pending |
| FIGHT-05 | Phase 4 | Pending |
| ENEMY-01 | Phase 4 | Pending |
| ENEMY-02 | Phase 4 | Pending |
| ENEMY-03 | Phase 4 | Pending |
| ENEMY-04 | Phase 4 | Pending |
| ENEMY-05 | Phase 5 | Pending |
| ENEMY-06 | Phase 5 | Pending |
| WORLD-01 | Phase 2 | Pending |
| WORLD-02 | Phase 2 | Pending |
| WORLD-03 | Phase 2 | Pending |
| WORLD-04 | Phase 2 | Pending |
| WORLD-05 | Phase 2 | Pending |
| CYCLE-01 | Phase 5 | Pending |
| CYCLE-02 | Phase 5 | Pending |
| CYCLE-03 | Phase 5 | Pending |
| CYCLE-04 | Phase 5 | Pending |
| PROG-01 | Phase 4 | Pending |
| PROG-02 | Phase 4 | Pending |
| PROG-03 | Phase 4 | Pending |
| PROG-04 | Phase 4 | Pending |
| PROG-05 | Phase 4 | Pending |
| PROG-06 | Phase 4 | Pending |
| PROG-07 | Phase 4 | Pending |
| LOOT-01 | Phase 2 | Pending |
| LOOT-02 | Phase 2 | Pending |
| LOOT-03 | Phase 2 | Pending |
| LOOT-04 | Phase 2 | Pending |
| UI-01 | Phase 3 | Pending |
| UI-02 | Phase 3 | Pending |
| UI-03 | Phase 3 | Pending |
| UI-04 | Phase 3 | Pending |
| UI-05 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 37 total
- Mapped to phases: 37
- Unmapped: 0 ✓

---
*Requirements defined: 2026/04/06*
*Last updated: 2026/04/06 after initial definition*
