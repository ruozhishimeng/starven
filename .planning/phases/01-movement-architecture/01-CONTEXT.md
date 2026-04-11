# Phase 1: Movement & Architecture - Context

**Gathered:** 2026/04/11
**Status:** Ready for planning

<domain>
## Phase Boundary

Player can move freely in an empty world; core architecture patterns established. Includes Hurt, Die, and Interact states to support future combat and loot phases.

</domain>

<decisions>
## Implementation Decisions

### Phase Priority
- **D-01:** Extend with new states — add Hurt, Die, and Interact states to Phase 1 before moving to Phase 2

### Hurt State
- **D-02:** Invincibility frames: 0.5 seconds after taking damage
- **D-03:** Knockback: Away from damage source (direction calculated from damage origin to player)
- **D-04:** Visual feedback: Blink/sprite flash during invincibility frames

### Die State
- **D-05:** Death behavior: Show game over screen (black screen + "Game Over" text + restart button)
- **D-06:** No death animation in v1 — immediate game over screen on HP depletion

### Interact State
- **D-07:** Trigger: E key press (action key, same as attack)
- **D-08:** Auto-face: Player automatically faces the interactable object when interacting
- **D-09:** Interaction range: Close range (32-48 pixels) — player must be near object
- **D-10:** Detection: Area2D around player, filtered by facing direction — only objects in front register

### Existing Implementation (Confirm)
- **D-11:** WASD movement already implemented (MOVE-01 satisfied)
- **D-12:** Direction-facing sprite already implemented (MOVE-02 satisfied)
- **D-13:** State machine architecture already established
- **D-14:** Collision layers: static=1, player=2, enemy=4, grass=8 (from CLAUDE.md)

### Architecture Decisions
- **D-15:** Player extends BasicCharacter (not duplicated logic)
- **D-16:** States use StateMachine for transitions
- **D-17:** Animation naming: `Idle_down/left/right/up`, `Run_down/left/right/up`, `Attack_down/left/right/up`
- **D-18:** Input deadzone: 0.2 (already implemented)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project Requirements
- `CLAUDE.md` — Collision layers, naming conventions, tech stack (Godot 4.x, GDScript)
- `.planning/REQUIREMENTS.md` — MOVE-01, MOVE-02 requirements for Phase 1
- `.planning/ROADMAP.md` §Phase 1 — Success criteria for Movement & Architecture

### Existing Architecture
- `Script/basic_character.gd` — Base character class with movement physics
- `Script/StateMachine/state_machine.gd` — State machine manager
- `Script/StateMachine/State.gd` — Base state class
- `Script/StateMachine/basic_states/idle.gd` — Reference idle state pattern
- `Script/StateMachine/basic_states/move.gd` — Reference move state pattern
- `Script/player.gd` — Player implementation
- `Script/StateMachine/playerstates/player_idle.gd` — Player idle state
- `Script/StateMachine/playerstates/player_run.gd` — Player run state
- `Script/StateMachine/playerstates/player_attack.gd` — Player attack state (reference for state structure)

</canonical_refs>

<codebase_context>
## Existing Code Insights

### Reusable Assets
- `BasicCharacter.gd`: Movement physics (SPEED=200, ACCELERATION=800, FRICTION=800) — use for knockback
- `StateMachine.gd`: `play_directional_animation()`, `set_attack_hitbox_for_direction()` — reference patterns
- `player_attack.gd`: Frame-based hitbox enable/disable — model for hurt invincibility timing

### Established Patterns
- States: Enter() → PhysicsProcess() loop → Exit()
- Character facing: `character.facing_dir` set in Run state, read in Idle
- Animation: `play_directional_animation(direction, prefix)` with suffix mapping

### Integration Points
- Hurt state → Die state transition when HP <= 0
- Die state → Game over screen (separate UI scene)
- Interact state → needs interactable detection Area2D on player
- Attack state already exists — Hurt state should block attack during invincibility

</codebase_context>

<specifics>
## Specific Ideas

- Knockback direction: Calculate vector from damage_source.position to player.position, normalize, apply impulse
- Interact Area2D: Place on player node, ~48px radius, check objects in facing direction
- Game over screen: Simple dark overlay with centered text, "Restart" button triggers scene reload

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 1 scope

</deferred>

---

*Phase: 01-movement-architecture*
*Context gathered: 2026/04/11*
