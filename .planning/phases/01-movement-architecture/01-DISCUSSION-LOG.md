# Phase 1: Movement & Architecture - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026/04/11
**Phase:** 01-movement-architecture
**Areas discussed:** Phase Priority, New States, Hurt, Die, Interact

---

## Phase Priority

| Option | Description | Selected |
|--------|-------------|----------|
| Verify & tune existing work | Test built features, tune values, document layers | |
| Extend with new states | Add Hurt, Die, Interact before next phase | ✓ |
| Formalize architecture only | Focus on docs, no gameplay changes | |

**User's choice:** Extend with new states

---

## New States

| Option | Description | Selected |
|--------|-------------|----------|
| Hurt + Die | Hurt (knockback + i-frames) + Die (game over). For Phase 4 combat. | |
| Interact | Interact with objects (chests). For Phase 2 loot. | |
| Hurt + Die + Interact all three | All three. Comprehensive coverage. | ✓ |

**User's choice:** Hurt + Die + Interact 全部

---

## Hurt - Invincibility Duration

| Option | Description | Selected |
|--------|-------------|----------|
| 0.5秒 | Short i-frames, fast combat rhythm | ✓ |
| 1.0秒 | Medium, enough to retreat and re-engage | |
| 1.5秒 | Longer, safer buffer | |

**User's choice:** 0.5秒

---

## Hurt - Knockback Effect

| Option | Description | Selected |
|--------|-------------|----------|
| Knockback away from source | Push player away from damage origin | ✓ |
| Fixed direction knockback | Fixed direction or reverse of facing | |
| No knockback | I-frames + flash only, no displacement | |

**User's choice:** 击退远离伤害源

---

## Die - Death Behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Show game over screen | Black screen + Game Over text + restart button | ✓ |
| Immediate restart | No screen, reset map and player state | |
| Death animation then reset | Play death animation (1-2s), then reset | |

**User's choice:** 显示游戏结束画面

---

## Interact - Trigger Method

| Option | Description | Selected |
|--------|-------------|----------|
| Key trigger (E) | Player presses E when in range | |
| Auto trigger on approach | Auto-enter interact state when near object | |
| Key trigger + auto-face | Press E, player auto-faces object | ✓ |

**User's choice:** 按键触发 + 自动面朝

---

## Interact - Range

| Option | Description | Selected |
|--------|-------------|----------|
| Close range (32-48px) | Must be near object, tight feel | ✓ |
| Medium range (64-96px) | Standard interaction, convenient | |
| Far range (96+px) | Loose interaction, less positioning | |

**User's choice:** 近距离（32-48像素）

---

## Interact - Detection Method

| Option | Description | Selected |
|--------|-------------|----------|
| Area2D detection | Circular area around player | |
| Raycast | Ray from player in facing direction | |
| Area2D + facing direction filter | Area detection, only objects in front count | ✓ |

**User's choice:** Area2D + 面朝方向过滤

---

## Claude's Discretion

No areas deferred to Claude — all decisions made by user.

## Deferred Ideas

None — discussion stayed within Phase 1 scope

