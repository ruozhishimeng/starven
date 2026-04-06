# Starven - Project State

**Last updated:** 2026/04/06

## Project Reference

**Project:** Starven
**Type:** 2D survival game (Godot/GDScript)
**Core Value:** Survive as long as possible — everything else can fail, this cannot.
**Granularity:** Standard
**Current Milestone:** v1 Demo

## Current Position

**Phase:** Not started
**Current focus:** Awaiting roadmap approval

### Phase Progress

| Phase | Goal | Status | Completion |
|-------|------|--------|------------|
| 1 | Movement & Architecture | Not started | 0% |
| 2 | World Generation & Loot | Not started | 0% |
| 3 | Survival Systems & HUD | Not started | 0% |
| 4 | Combat & Progression | Not started | 0% |
| 5 | Day/Night Cycle | Not started | 0% |

## Performance Metrics

**Requirements coverage:** 37/37 v1 requirements mapped
**Phase count:** 5 phases
**First phase:** Phase 1 - Movement & Architecture

## Accumulated Context

### Key Decisions
- Infinite survival: simplest demo goal
- No meta progression: keep demo scope focused
- Day/Night 10min/5min: standard survival rhythm
- Large random maps: exploration is core

### Research Flags
- Phase 1: Verify Godot 4.4+ vs 4.3+ API differences
- Phase 5: Difficulty tuning requires playtesting

### Blockers
- None

### Notes
- SURV-04 (Sanity) deferred to v2
- FIGHT-06 (ranged), FIGHT-07 (magic) deferred to v2
- ENEMY-07 (multiple enemy types) deferred to v2
- PROG-08 (sanity visual effects) deferred to v2

## Session Continuity

**Context file:** `.planning/STATE.md`
**Roadmap file:** `.planning/ROADMAP.md`
**Requirements file:** `.planning/REQUIREMENTS.md`
**Project file:** `.planning/PROJECT.md`
**Research file:** `.planning/research/SUMMARY.md`

## Next Action

Await user approval of roadmap. Once approved:
1. Begin Phase 1 planning via `/gsd-plan-phase 1`
