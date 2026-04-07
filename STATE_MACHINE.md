# 游戏状态机系统教程

> **学习路径**：本文分为两部分
> - 第一部分：GDScript 基础入门（写状态机必须掌握的知识）
> - 第二部分：一步步教你写状态机（从零开始实现）

---

# 第一部分：GDScript 基础入门

## 1.1 extends 继承

`extends` 声明当前类继承自哪个父类：

```gdscript
extends Node           # 继承 Godot 内置 Node
extends CharacterBody2D # 继承角色身体
extends State          # 继承自定义 State 类
```

继承后，子类自动拥有父类的所有属性和方法。

---

## 1.2 class_name 自定义类名

`class_name` 给脚本注册一个全局类名，其他脚本可以用 `is` 来检查类型：

```gdscript
extends Node
class_name StateMachine  # 注册为全局类 "StateMachine"

# 其他脚本可以这样用：
# if node is StateMachine:
#     node.init()
```

---

## 1.3 @onready 延迟初始化

`@onready` 告诉 Godot：等节点树完全构建好后再获取子节点：

```gdscript
extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
    # 此时 $AnimatedSprite2D 和 $StateMachine 一定已经存在
    anim.play("idle")
```

**为什么需要 @onready？**
Godot 的 `_ready()` 执行顺序是"从叶子到根"（子节点先于父节点）。如果不用 `@onready`，直接写 `var anim = $AnimatedSprite2D`，子节点可能还没被创建。

---

## 1.4 super._ready() 父类方法调用

`super` 关键字调用父类的方法：

```gdscript
extends BasicCharacter

func _ready() -> void:
    # 先执行父类的 _ready()
    super._ready()
    # 再执行子类自己的初始化
    setup_extra()
```

**常见错误**：忘记调用 `super._ready()`，导致父类的初始化逻辑被跳过。

---

## 1.5 move_and_slide() 移动方法

`move_and_slide()` 是 CharacterBody2D 的核心移动方法，它会自动：
- 根据 velocity 移动
- 检测碰撞
- 停止在障碍物上
- 处理斜面滑动

```gdscript
extends CharacterBody2D

const SPEED := 300.0

func _physics_process(delta: float) -> void:
    velocity = Vector2(1, 0) * SPEED
    move_and_slide()  # 执行移动
```

---

## 1.6 move_toward() 平滑加速/减速

`move_toward(current, target, delta)` 将 current 向 target 移动最多 delta 步：

```gdscript
# 加速：velocity 从 0 向 300 移动
velocity = velocity.move_toward(Vector2.RIGHT * SPEED, ACCELERATION * delta)

# 减速：velocity 从当前值向 0 移动
velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
```

**公式**：`move_toward(a, b, t)` = `a` 接近 `b`，每次最多走 `t` 距离

---

## 1.7 Input.get_vector() 获取方向输入

`Input.get_vector()` 从按键映射获取二维方向：

```gdscript
# 返回 Vector2 (x, y)
# "left" "right" "up" "down" 是项目设置的输入映射
var direction := Input.get_vector("left", "right", "up", "down")

# direction 的值：
# 完全停止 = (0, 0)
# 右下 = (0.7, 0.7)
# 左上 = (-0.7, -0.7)
```

---

## 1.8 Vector2 方向判断

判断 Vector2 是哪个方向：

```gdscript
var dir := Vector2(0, -1)  # 假设是向上

if dir.y < 0:      # 上
    suffix = "up"
elif dir.y > 0:    # 下
    suffix = "down"
elif dir.x > 0:    # 右
    suffix = "right"
elif dir.x < 0:    # 左
    suffix = "left"
```

**斜方向优先轴判断**：
```gdscript
func to_cardinal(direction: Vector2) -> Vector2:
    if absf(direction.y) >= absf(direction.x):
        # y 轴更重要（上下优先）
        return Vector2(0, 1 if direction.y > 0 else -1)
    else:
        # x 轴更重要（左右优先）
        return Vector2(1 if direction.x > 0 else -1, 0)
```

---

## 1.9 生命周期方法

Godot 内置的自动调用方法：

| 方法 | 调用时机 |
|------|---------|
| `_ready()` | 节点第一次进入场景树时（仅一次） |
| `_process(delta)` | 每帧（视觉更新） |
| `_physics_process(delta)` | 每物理帧（物理更新，通常 60fps） |
| `_input(event)` | 有输入事件时 |
| `_exit_tree()` | 节点离开场景树时 |

---

## 1.10 as 类型转换

`as` 尝试将一个对象转换为指定类型：

```gdscript
var child = get_child(0)
var state = child as State  # 尝试转为 State 类型

if state != null:  # 转换成功
    state.Enter()
else:               # 转换失败（不是 State 类型）
    pass
```

---

## 1.11 小结：第一部分核心知识点

| 知识点 | 用途 |
|--------|------|
| `extends` | 继承父类，复用代码 |
| `class_name` | 注册全局类型 |
| `@onready` | 确保子节点已创建 |
| `super._ready()` | 调用父类初始化 |
| `move_and_slide()` | CharacterBody2D 移动 |
| `move_toward()` | 平滑加速/减速 |
| `Input.get_vector()` | 获取方向输入 |
| `as` 类型转换 | 安全转换类型 |

---

# 第二部分：一步步教你写状态机

## 一、什么是状态机？

**有限状态机（Finite State Machine, FSM）** = 系统在某一时刻只能处于有限种状态之一。

### 游戏中的状态示例

| 角色 | 可能的状态 |
|------|-----------|
| 玩家 | 待机、移动、跳跃、攻击、受伤、死亡 |
| 敌人 | 巡逻、追击、攻击、逃跑、死亡 |
| 门 | 关闭、打开中、打开、关闭中 |

### 状态机解决什么问题？

**不用状态机的问题** — 所有逻辑混在一个文件：

```gdscript
# 屎山代码 - 1000 行难以维护
func _physics_process(delta):
    if state == "idle":
        # 待机逻辑 50 行...
        if 可移动: state = "run"
    elif state == "run":
        # 移动逻辑 80 行...
        if 停止: state = "idle"
    elif state == "jump":
        # 跳跃逻辑 60 行...
    # 状态越多，if/elif 爆炸
```

**状态机的优势**：
- 每个状态一个文件，职责清晰
- 状态转换逻辑集中
- 易于扩展和维护
- 可复用给不同角色

---

## 二、目标：实现待机/移动状态机

最终效果：
```
[待机] --按方向键--> [移动]
  ^                      |
  |                      v
  <-------松开方向键------
```

---

## 三、创建文件结构

```
Script/
├── BasicCharacter.gd      # 角色基类（父类）
├── player.gd              # 玩家脚本（子类）
└── StateMachine/
    ├── StateMachine.gd    # 状态机管理器
    ├── State.gd           # 状态基类
    └── basic_states/
        ├── idle.gd        # 待机状态
        └── move.gd        # 移动状态
```

---

## 四、第一步：State.gd 状态基类

状态基类定义所有状态的公共接口：

```gdscript
extends Node
class_name State

## 引用所属的状态机
var state_machine: StateMachine

## 引用所属的角色（通过 state_machine.character 访问）
var character: BasicCharacter:
    get:
        return state_machine.character

## 进入状态时调用
func Enter() -> void:
    pass

## 退出状态时调用
func Exit() -> void:
    pass

## 每帧更新（视觉）
func Process(delta: float) -> void:
    pass

## 每物理帧更新（物理/移动）
func PhysicsProcess(delta: float) -> void:
    pass

## 处理输入
func HandleInput(event: InputEvent) -> void:
    pass
```

---

## 五、第二步：StateMachine.gd 状态机管理器

状态机管理器负责：
- 注册所有子状态
- 追踪当前状态
- 路由调用到当前状态
- 执行状态切换

```gdscript
extends Node
class_name StateMachine

## 当前正在执行的状态
var current_state: State

## 所有状态的字典 {状态名字: 状态节点}
var states: Dictionary = {}

## 角色引用（由初始化者传入）
var character: BasicCharacter

## 初始化状态机
func init(character_ref: BasicCharacter) -> void:
    character = character_ref
    _register_states()
    if not states.is_empty():
        current_state = get_child(0)
        current_state.Enter()

## 注册所有子状态
func _register_states() -> void:
    for child in get_children():
        var child_state = child as State
        if child_state != null:
            states[child.name] = child_state
            child_state.state_machine = self

## 切换到指定状态
func change_state(state_name: String) -> void:
    if current_state != null:
        current_state.Exit()

    current_state = states.get(state_name)

    if current_state != null:
        current_state.Enter()

## 路由方法
func _process(delta: float) -> void:
    if current_state != null:
        current_state.Process(delta)

func _physics_process(delta: float) -> void:
    if current_state != null:
        current_state.PhysicsProcess(delta)

func _input(event: InputEvent) -> void:
    if current_state != null:
        current_state.HandleInput(event)
```

---

## 六、第三步：BasicCharacter.gd 角色基类

通用角色基类，定义所有角色共有的属性和方法：

```gdscript
extends CharacterBody2D
class_name BasicCharacter

## 移动参数
const SPEED := 200.0
const ACCELERATION := 800.0
const FRICTION := 800.0

## 面朝方向
var facing_dir := Vector2(0, 1)

## 状态机
@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
    state_machine.init(self)

## 子类必须实现
func get_input_direction() -> Vector2:
    push_error("BasicCharacter: 子类必须实现 get_input_direction()")
    return Vector2.ZERO

func play_animation(direction: Vector2, prefix: String) -> void:
    push_error("BasicCharacter: 子类必须实现 play_animation()")

## 工具方法：斜方向转主方向
func to_cardinal(direction: Vector2) -> Vector2:
    if absf(direction.y) >= absf(direction.x):
        return Vector2(0, 1 if direction.y > 0 else -1)
    else:
        return Vector2(1 if direction.x > 0 else -1, 0)
```

---

## 七、第四步：idle.gd 待机状态

待机状态检测输入，有输入时切换到移动，否则用摩擦力减速：

```gdscript
extends State

func Enter() -> void:
    character.play_animation(character.facing_dir, "idle")

func PhysicsProcess(delta: float) -> void:
    var direction := character.get_input_direction()

    if direction.length() > 0.1:
        # 有输入 → 切换到移动
        state_machine.change_state("Move")
    else:
        # 无输入 → 用摩擦力减速
        character.velocity = character.velocity.move_toward(
            Vector2.ZERO,
            character.FRICTION * delta
        )
        character.move_and_slide()
```

---

## 八、第五步：move.gd 移动状态

移动状态检测输入，无输入时切换到待机，有输入时加速移动：

```gdscript
extends State

func PhysicsProcess(delta: float) -> void:
    var direction := character.get_input_direction()

    if direction.length() < 0.1:
        # 无输入 → 切换到待机
        state_machine.change_state("Idle")
        return

    # 记录朝向（切换到待机时需要知道面朝哪）
    character.facing_dir = character.to_cardinal(direction)

    # 播放移动动画
    character.play_animation(direction, "move")

    # 加速移动
    character.velocity = character.velocity.move_toward(
        direction * character.SPEED,
        character.ACCELERATION * delta
    )

    character.move_and_slide()
```

---

## 九、第六步：player.gd 玩家脚本

玩家脚本只需要实现两个方法，状态机逻辑复用：

```gdscript
extends BasicCharacter

const INPUT_DEADZONE := 0.2

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    super._ready()

func get_input_direction() -> Vector2:
    return Input.get_vector("left", "right", "up", "down")

func play_animation(direction: Vector2, prefix: String) -> void:
    if anim == null:
        return

    var suffix: String
    if direction.y > 0:
        suffix = "down"
    elif direction.y < 0:
        suffix = "up"
    elif direction.x > 0:
        suffix = "right"
    elif direction.x < 0:
        suffix = "left"
    else:
        suffix = "down"

    anim.play(prefix + "_" + suffix)
```

---

## 十、节点树结构

```
Player (BasicCharacter)
├── CollisionShape2D
├── AnimatedSprite2D
└── StateMachine (Node)
    ├── Idle (idle.gd)
    └── Move (move.gd)
```

---

## 十一、运行流程解析

```
1. Player._ready()
   └── super._ready() → BasicCharacter._ready()
       └── state_machine.init(self)
           ├── _register_states() 收集所有子状态
           ├── states = {"Idle": <idle节点>, "Move": <move节点>}
           ├── current_state = Idle 节点
           └── Idle.Enter() 播放待机动画

2. 每帧 PhysicsProcess
   └── StateMachine._physics_process(delta)
       └── current_state.PhysicsProcess(delta)
           ├── Idle.PhysicsProcess() 检测输入
           │   └── 有输入 → change_state("Move")
           │       ├── Idle.Exit()
           │       ├── current_state = Move 节点
           │       └── Move.Enter()
           └── Move.PhysicsProcess() 移动逻辑
               └── 无输入 → change_state("Idle")
```

---

## 十二、常见问题

### Q: @onready 为什么会造成 anim == null？

**原因**：StateMachine 的 `_ready()` 比 character 的 `@onready` 先执行。

**解决**：不要在 StateMachine 写 `_ready()`，让 character 在自己的 `_ready()` 里调用 `state_machine.init()`。

### Q: owner vs character 有什么区别？

本项目统一用 `character` 指向角色节点（BasicCharacter 类型）。`owner` 是 Godot 内置属性，指向父节点，用 `as` 转换可能失败。

### Q: 状态名字大小写要注意什么？

状态字典的 key 是节点名字，切换时要用相同的名字：
```gdscript
# 节点叫 "Move"，切换时也要用 "Move"
state_machine.change_state("Move")  # ✅
state_machine.change_state("move")  # ❌ 找不到
```

---

## 十三、完整文件清单

| 文件路径 | 作用 |
|---------|------|
| `Script/BasicCharacter.gd` | 角色基类（定义移动参数、方向工具） |
| `Script/player.gd` | 玩家脚本（实现输入和动画） |
| `Script/StateMachine/StateMachine.gd` | 状态机管理器 |
| `Script/StateMachine/State.gd` | 状态基类 |
| `Script/StateMachine/basic_states/idle.gd` | 待机状态 |
| `Script/StateMachine/basic_states/move.gd` | 移动状态 |

---

## 十四、下一步扩展

学会了基础状态机后，可以扩展：

1. **添加新状态**：jump.gd、attack.gd、hurt.gd
2. **敌人 AI**：patrol.gd（巡逻）、chase.gd（追击）
3. **层次化状态机**：用超状态共享地面/空中行为的公共逻辑

---

## 参考资料

- Godot 文档: https://docs.godotengine.org/
- Game Programming Patterns: https://gameprogrammingpatterns.com/
