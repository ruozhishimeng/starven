# AGENTS.md

项目专用指南。适用于 `F:\starven` 仓库。

---

## 项目意图

- 清晰的角色状态机架构（玩家/敌人共用 Base + 独立状态）
- 迟滞式 AI 追击逻辑（detect_radius / lose_radius）
- 最小改动优先、回滚友好
- 中文注释保留（有益教学的内容不删除）

---

## 目录结构

```
f:\Starven\
├── Scene\                    # .tscn 场景文件
│   ├── player.tscn
│   ├── enemy1.tscn
│   ├── initial_map.tscn
│   ├── grass.tscn
│   ├── maze.tscn
│   └── Tree.tscn
├── Script\                   # 游戏逻辑脚本
│   ├── player.gd            # 玩家角色（继承 BasicCharacter）
│   ├── enemy_1.gd            # 敌人角色（继承 BasicCharacter）
│   ├── basic_character.gd    # 角色基座（通用移动参数+状态机）
│   ├── grass.gd              # 草
│   ├── grass_generator.gd
│   ├── grass_random.gd
│   ├── foliage_spawner.gd
│   ├── tile_map_layer_grass.gd
│   ├── random_tree.gd
│   └── StateMachine\
│       ├── StateMachine.gd   # 状态机管理器
│       ├── State.gd          # 状态基类
│       ├── basic_states\     # 通用状态
│       │   ├── idle.gd
│       │   └── move.gd
│       ├── playerstates\     # 玩家特有状态
│       │   ├── player_idle.gd
│       │   └── player_run.gd
│       └── enemystates\     # 敌人特有状态
│           ├── enemy_idle.gd
│           ├── enemy_move.gd
│           └── enemy_chase.gd
├── Asset\                    # 美术资源
├── addons\                   # 编辑器插件（禁止随意修改）
└── project.godot
```

---

## 命名规范

### 脚本文件

- `PascalCase.gd` — 类名式命名（`BasicCharacter`, `StateMachine`）
- `snake_case.gd` — 普通脚本（`grass_generator`, `foliage_spawner`）

### 节点命名

| 节点类型 | 规范 | 示例 |
|---------|------|------|
| 状态节点 | 全小写 | `idle`, `move`, `chase` |
| 角色节点 | PascalCase | `Player`, `Enemy` |
| 管理器节点 | PascalCase | `StateMachine`, `FoliageSpawner` |

**状态切换严格匹配节点名**：

```gdscript
state_machine.change_state("idle")   # ✅ 节点叫 "idle"
state_machine.change_state("Idle")   # ❌ 找不到
```

### 动画命名

**格式**：`{前缀}_{方向}`

| 动画族 | 命名 | 示例 |
|-------|------|------|
| 待机 | `idle_{方向}` | `idle_down`, `idle_left`, `idle_right`, `idle_up` |
| 移动 | `move_{方向}` | `move_down`, `move_left`, `move_right`, `move_up` |
| 追击 | `chase_{方向}` | `chase_down`, `chase_left`... |
| 受伤 | `hurt_{方向}` | `hurt_down`, `hurt_left`... |

**方向优先级**：`y > 0` → down | `y < 0` → up | `x > 0` → right | `x < 0` → left

---

## 分层架构

```
┌─────────────────────────────────────┐
│           Scene (tscn)              │  场景实例
├─────────────────────────────────────┤
│  Character (BasicCharacter / 子类)   │  角色层：移动参数、动画播放、状态机引用
├─────────────────────────────────────┤
│  StateMachine                        │  状态机层：注册状态、路由调用、切换状态
├─────────────────────────────────────┤
│  State (idle / move / chase / ...)   │  状态层：具体行为逻辑
└─────────────────────────────────────┘
```

### BasicCharacter — 角色基座

职责：
- 定义移动参数（`SPEED`, `ACCELERATION`, `FRICTION`）
- 管理 `facing_dir`（朝向）
- 提供工具方法（`to_cardinal()`）
- 持有状态机引用

子类实现：
- `get_input_direction()` — 获取输入/AI 方向
- `play_animation()` — 播放动画
- 可选：`find_target()`、`start_chase()` 等敌人特有方法

### 状态层规则

| 方法 | 调用时机 | 用途 |
|------|---------|------|
| `Enter()` | 进入状态时 | 播放动画、初始化 |
| `Exit()` | 退出状态时 | 清理临时状态 |
| `Process(delta)` | 每帧 | 视觉逻辑 |
| `PhysicsProcess(delta)` | 每物理帧 | 移动、物理 |
| `HandleInput(event)` | 输入事件时 | 响应输入 |

---

## 状态机规范

### 当前状态流

**玩家**：`idle` ↔ `move`

**敌人**：`idle` → `chase` → `idle`（迟滞追击）

### 敌人 AI 迟滞逻辑

```gdscript
# enemy_1.gd
@export var detect_radius := 300.0   # 进入追击范围
@export var lose_radius := 1000.0   # 脱离追击范围（需 >= detect_radius）
var is_chasing := false             # 当前是否追击中
```

**触发条件**：

| 状态 | 触发条件 |
|------|---------|
| `idle` → `chase` | 玩家进入 `detect_radius` 且 `is_chasing == false` |
| `chase` → `idle` | 玩家超出 `lose_radius` 或目标消失 |

### 状态节点添加流程

新增状态（如 `attack`）需要：

1. 在 `Script/StateMachine/enemystates/` 创建 `enemy_attack.gd`
2. 在 `enemy1.tscn` 的 `StateMachine` 下添加节点，名字为 `attack`
3. 在 Inspector 给节点挂载脚本

---

## 工作流程

### 改代码前

- [ ] 确认目标文件和当前命名规范
- [ ] 检查状态节点名字是否与 `change_state()` 调用一致
- [ ] 检查动画名字是否与 `play_animation()` 调用一致
- [ ] 优先最小改动，不做 speculative refactor

### 改代码后

- [ ] 确认修改路径逻辑完整
- [ ] 说明无法验证的假设
- [ ] 说明哪些需要编辑器内确认

---

## 不能随意修改的文件

| 文件 | 原因 |
|------|------|
| `project.godot` | 项目配置，可能破坏输入映射/导出设置 |
| `addons/` | 编辑器插件，非任务需求不修改 |
| `.github/ARCHITECTURE.md` | 设计参考文档（非项目架构） |
| `STATE_MACHINE.md` | 教程文档，修改需确认必要性 |

---

## 测试方式

Godot 内运行测试：

1. **场景启动测试** — 运行游戏，确认无 null 引用报错
2. **移动测试** — 按方向键，观察 `idle` ↔ `move` 切换
3. **敌人 AI 测试** — 远离敌人，确认 `idle`；接近 `detect_radius`，确认切换 `chase`；超出 `lose_radius`，确认回到 `idle`
4. **动画方向测试** — 上下左右移动，确认四个方向动画正确播放

无运行时，通过代码审查验证：
- `find_target()` 返回值处理
- `change_state()` 节点名匹配
- `play_animation()` 动画名存在

---

## GDScript 约定

- 显式类型声明（尤其返回值可能为 null 时）
- `@export var` 用于需要在编辑器配置的参数
- `@onready var` 用于延迟初始化的子节点引用
- `super._ready()` 调用父类初始化
- `move_and_slide()` 用于 CharacterBody2D 移动
- `move_toward(current, target, delta)` 用于平滑加减速

---

## 回滚友好

- 优先单文件修改，不做跨文件大规模重构
- 新增变量加 `@export` 或默认值，不改变已有字段语义
- 保持旧逻辑可用直到新逻辑验证通过
- 不重命名已有节点/动画/变量

---

## 调试技巧

问题排查顺序：

1. **名称匹配** — 状态节点名、动画名是否一致
2. **初始化顺序** — `@onready` vs `state_machine.init()` 调用时机
3. **运行时引用** — `character` / `state_machine` 是否正确指向
4. **最后** — 深层逻辑问题
