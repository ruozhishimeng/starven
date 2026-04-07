# External Integrations

**Analysis Date:** 2026/04/06

## APIs & External Services

**AI/Code Assistant Integration:**
- **Godot MCP Pro** - Model Context Protocol server for AI-assisted development
  - Type: Streamable HTTP
  - URL: `http://127.0.0.1:3000/mcp`
  - Version: 1.6.0
  - Purpose: Enables AI code assistants to interact with the Godot editor
  - Implementation: `addons/godot_mcp/plugin.gd`

**npm MCP Tooling:**
- `@coding-solo/godot-mcp` - npx package for MCP server
  - Configured in `.mcp.json`
  - Environment variable: `GODOT_PATH` pointing to Godot executable

## Data Storage

**Databases:**
- None detected - This is a standalone game project

**File Storage:**
- Local filesystem only
- Game data stored in:
  - `.tres` Resource files (configuration/data)
  - `.tscn` scene files (game objects)
  - `project.godot` for project settings

**Persistence:**
- User data via `OS.get_user_data_dir()` (standard Godot location)
- MCP temp files stored in user data directory:
  - `mcp_game_request`
  - `mcp_game_response`
  - `mcp_input_commands`
  - `mcp_screenshot_request`
  - `mcp_screenshot.png`

## Authentication & Identity

**Auth Provider:**
- None - Single-player game without authentication

## Monitoring & Observability

**Error Tracking:**
- Godot's built-in `push_error()` and `push_warning()` functions
- No external error tracking service (e.g., Sentry, Bugsnag)

**Logs:**
- Godot print statements via `print()`
- MCP server logs via `print("[MCP] ...")`
- Debugger integration via Godot editor

**Editor Integration:**
- MCP plugin creates status panel in Godot editor bottom panel
- WebSocket-based communication between AI tools and editor

## CI/CD & Deployment

**Hosting:**
- Not applicable - Desktop game (no web hosting)

**CI Pipeline:**
- None detected

## Environment Configuration

**Required env vars:**
- `GODOT_PATH` - Path to Godot 4.6 Mono executable (for MCP tooling)

**Secrets location:**
- None - Game does not use external APIs requiring secrets

## Webhooks & Callbacks

**Incoming:**
- None - Standalone desktop game

**Outgoing:**
- None detected

## Hardware/Platform

**Target Platform:**
- Windows 10/11 with DirectX 12 support

**Input Systems:**
- Keyboard (WASD + Arrow keys)
- Mouse (for editor interaction)
- Gamepad support potentially available via Godot input system

## Build System

**Engine:**
- Godot 4.6 (Mono variant for C# support)

**Build Output:**
- Windows executable (.exe) via Godot export
- No CI/CD pipeline currently configured

## Asset Pipeline

**Art Assets Location:**
- `Asset/` directory contains:
  - Animations (player, enemies)
  - Level tilesets
  - VFX sprites
  - Character sprites (various NPC types)

**Asset Format:**
- PNG images for sprites
- No external asset CDN or delivery system

---

*Integration audit: 2026/04/06*
