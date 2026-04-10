extends Node
class_name StateMachine
## 状态机管理器
##
## 【小白理解】
## 状态机就像一个"主持人"，管理所有状态：
## - 记录当前是哪个状态在执行
## - 负责切换状态（从待机→移动）
## - 把玩家的按键、每帧更新分发给当前状态
##
## 【工作流程】
## 1. 游戏启动，_ready() 自动找出所有子状态
## 2. 默认进入第一个子状态
## 3. 每帧把 process/physics_process/输入 转发给当前状态
## 4. 当某个状态想切换时，调用 change_state()

## 当前正在执行的状态
var currentState: State

## 所有状态的字典 {状态名字: 状态节点}
var states: Dictionary = {}

## 玩家专用可选节点引用；敌人场景没有这些节点时保持 null 即可
var anim: AnimatedSprite2D = null
var attack_hitbox: Area2D = null
var attack_up: CollisionShape2D = null
var attack_down: CollisionShape2D = null
var attack_left: CollisionShape2D = null
var attack_right: CollisionShape2D = null

## 初始化状态机（由角色根节点在 _ready() 中调用）
func init() -> void:
	_resolve_optional_nodes()
	_register_states()
	if not states.is_empty():
		currentState = get_child(0)
		currentState.Enter()

## 注册所有子状态
func _register_states() -> void:
	## 【重点】自动收集所有子节点中继承自 State 的节点
	## get_children() 获取所有子节点
	## 遍历每个子节点，如果它是 State 类型，就加入 states 字典
	for child in get_children():
		## as 是类型转换，把 child 当作 State 看
		var childState = child as State
		if childState != null:
			## 【关键！】把状态注册到字典，key 是节点名字
			## 这样 change_state("Run") 才能找到 Run 状态节点
			states[child.name] = childState
			## 告诉这个状态，它属于哪个状态机
			childState.state_machine = self
			## 调用状态的 Ready() 做初始化
			childState.Ready()

## ============================================
## 状态切换 - 最重要的方法！
## ============================================

## 切换到指定名字的状态
## 【小白的重点】状态内部调用这个来切换到另一个状态
## 例如：player_idle 发现玩家按了方向键，就调用
##       state_machine.change_state("Run") 切换到移动状态
func change_state(state_name: String) -> void:
	## 1. 先退出当前状态（清理工作）
	if currentState != null:
		currentState.Exit()

	## 2. 从字典中找到新的状态
	currentState = states.get(state_name)

	## 3. 进入新状态（初始化工作）
	if currentState != null:
		currentState.Enter()

## ============================================
## 内部注册方法 - 给子状态用的
## ============================================

## 子状态调用这个把自己注册到字典
## 【注意】这个方法子类不需要调用，是给 add_child 后的树结构用的
func register_state(state_name: String, state: State) -> void:
	states[state_name] = state

## ============================================
## 消息转发 - 状态机的核心职责
## ============================================
## 状态机自己不干活，它把任务分发给当前状态

## 每帧更新（视觉逻辑）
## _process 是 Godot 内置方法，每帧自动调用
func _process(delta: float) -> void:
	if currentState != null:
		currentState.Process(delta)

## 每物理帧更新（物理逻辑）
## _physics_process 是 Godot 内置方法，每物理帧自动调用
func _physics_process(delta: float) -> void:
	if currentState != null:
		currentState.PhysicsProcess(delta)

## 处理输入
## _input 是 Godot 内置方法，当有输入事件时自动调用
func _input(event: InputEvent) -> void:
	if currentState != null:
		currentState.HandleInput(event)

## ============================================
## 快捷方法 - 简化状态内部的代码
## ============================================

## 检查是否可以切换到某个状态
## 状态内部可以用这个来判断能不能切换
func can_change_to(state_name: String) -> bool:
	return states.has(state_name)

## 获取当前状态的名字
## 调试时很有用
func get_current_state_name() -> String:
	if currentState != null:
		return currentState.name
	return ""


## ============================================
## 玩家节点辅助方法
## ============================================

func has_attack_nodes() -> bool:
	return (
		attack_hitbox != null
		and attack_up != null
		and attack_down != null
		and attack_left != null
		and attack_right != null
	)


func play_directional_animation(direction: Vector2, prefix: String) -> void:
	if anim == null:
		return

	anim.play(prefix + "_" + _direction_to_suffix(direction))


func disable_all_attack_hitboxes() -> void:
	if attack_hitbox != null:
		attack_hitbox.monitoring = false

	_set_collision_shape_enabled(attack_up, false)
	_set_collision_shape_enabled(attack_down, false)
	_set_collision_shape_enabled(attack_left, false)
	_set_collision_shape_enabled(attack_right, false)


func set_attack_hitbox_for_direction(direction: Vector2, enabled: bool) -> void:
	disable_all_attack_hitboxes()
	if not enabled:
		return

	var shape := _get_attack_shape_for_direction(direction)
	if shape == null:
		return

	if attack_hitbox != null:
		attack_hitbox.monitoring = true
	_set_collision_shape_enabled(shape, true)


func _resolve_optional_nodes() -> void:
	var host := get_parent()
	if host == null:
		return

	anim = host.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	attack_hitbox = host.get_node_or_null("AttackHitBox") as Area2D
	attack_up = host.get_node_or_null("AttackHitBox/CollisionShape2Dup") as CollisionShape2D
	attack_down = host.get_node_or_null("AttackHitBox/CollisionShape2Ddown") as CollisionShape2D
	attack_left = host.get_node_or_null("AttackHitBox/CollisionShape2Dleft") as CollisionShape2D
	attack_right = host.get_node_or_null("AttackHitBox/CollisionShape2Dright") as CollisionShape2D

	disable_all_attack_hitboxes()


func _get_attack_shape_for_direction(direction: Vector2) -> CollisionShape2D:
	var suffix := _direction_to_suffix(direction)
	match suffix:
		"up":
			return attack_up
		"down":
			return attack_down
		"left":
			return attack_left
		"right":
			return attack_right
		_:
			return attack_down


func _set_collision_shape_enabled(shape: CollisionShape2D, enabled: bool) -> void:
	if shape == null:
		return
	shape.disabled = not enabled


func _direction_to_suffix(direction: Vector2) -> String:
	if direction.y > 0:
		return "down"
	elif direction.y < 0:
		return "up"
	elif direction.x > 0:
		return "right"
	elif direction.x < 0:
		return "left"
	else:
		return "down"
