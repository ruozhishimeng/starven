# Testing Patterns

**Analysis Date:** 2026/04/06

## Test Framework

**Framework:** Godot MCP Test Commands (custom framework via `addons/godot_mcp/commands/test_commands.gd`)

**Note:** This is not a traditional unit testing framework. Godot does not have a built-in GDScript test runner. Testing is performed via:

1. **Manual play testing** in Godot editor
2. **Automated testing** via MCP commands that simulate gameplay

**Test Commands Location:** `addons/godot_mcp/commands/test_commands.gd`

## Test File Organization

**Location:** No dedicated `test/` directory exists

**Test Files:** None detected (`.gd` files with `test_` or `_test` naming pattern not found)

**MCP Test Framework:** `addons/godot_mcp/commands/test_commands.gd` provides:
- `run_test_scenario` - Execute scripted test scenarios
- `assert_node_state` - Assert node property values
- `assert_screen_text` - Assert UI text visibility
- `run_stress_test` - Rapid random input testing
- `get_test_report` - Retrieve accumulated test results

## Manual Testing Procedures

### Scene Launch Testing
1. Run game in Godot editor
2. Verify no null reference errors on startup

### Movement Testing
1. Press direction keys
2. Observe `idle` ↔ `move` state transitions

### Enemy AI Testing
1. Move away from enemy - confirm `idle` state
2. Approach within `detect_radius` - confirm `chase` state
3. Move beyond `lose_radius` - confirm return to `idle`

### Animation Direction Testing
1. Move in four directions (up/down/left/right)
2. Confirm correct directional animation plays

## Automated Testing (MCP Framework)

### Test Scenario Format

```gdscript
{
    "scene_path": "res://Scene/player.tscn",  # or "main", "current"
    "steps": [
        {"type": "input", "action": "up", "pressed": true},
        {"type": "wait", "seconds": 1.0},
        {"type": "assert", "node_path": "Player", "property": "velocity", "expected": Vector2(0, -1), "operator": "neq"},
        {"type": "screenshot"}
    ]
}
```

### Step Types

| Type | Parameters | Description |
|------|------------|-------------|
| `input` | `action` or `keycode`, `pressed` | Simulate input |
| `wait` | `seconds` or `node_path` | Wait for duration or node |
| `assert` | `node_path`, `property`, `expected`, `operator` | Assert node state |
| `screenshot` | `half_resolution` (optional) | Capture frame |

### Assertion Operators

- `eq` - Equal
- `neq` - Not equal
- `gt`, `lt`, `gte`, `lte` - Comparison
- `contains` - String/array contains
- `type_is` - Type check

### IPC Mechanism

Tests use file-based IPC between editor plugin and running game:

1. Write request to `user://mcp_game_request`
2. Poll for response in `user://mcp_game_response`
3. Parse JSON response

```gdscript
# Request format
{"command": "assert_node_state", "params": {...}}

# Response format
{"result": {"passed": true, "actual": Vector2(0, -1)}}
```

## Mocking

**No formal mocking framework detected.**

For testing node references, use `@onready` pattern with null checks:
```gdscript
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func play_animation(direction: Vector2, prefix: String) -> void:
    if anim == null:
        push_error("anim is null")
        return
```

## Code Review Checklist

For code that cannot be runtime-tested:

- [ ] `find_target()` returns null handling
- [ ] `change_state()` node name matches exactly (lowercase)
- [ ] `play_animation()` animation names exist in sprite sheet
- [ ] All `@onready` nodes exist in scene tree
- [ ] State transitions follow defined state flow

## Stress Testing

**Command:** `_run_stress_test`
```gdscript
{
    "duration": 5.0,  # seconds (max 60)
    "actions": ["up", "down", "left", "right"]
}
```

Returns:
- `events_sent` - Number of inputs
- `new_errors` - Errors in log after test
- `game_still_running` - Boolean

## Test Report

**Command:** `_get_test_report`
```gdscript
{
    "clear": true  # Clear accumulated results after report
}
```

Returns:
```gdscript
{
    "total": 10,
    "passed": 8,
    "failed": 2,
    "pass_rate": "80.0%",
    "all_passed": false,
    "details": [...]
}
```

## Debugging Techniques

1. **Name Matching** - Verify state node names match `change_state()` calls exactly
2. **Initialization Order** - `@onready` vs `state_machine.init()` timing
3. **Runtime References** - `character` and `state_machine` properly linked
4. **Screenshots** - Capture frames for visual inspection

---

*Testing analysis: 2026/04/06*
