extends BasicCharacter
## 敌人角色
##
## 继承自 BasicCharacter，使用通用状态机
## AI 驱动：自动追踪玩家

@export var detect_radius := 300.0   ## 索敌半径（触发追击）
@export var lose_radius := 1000.0     ## 丢失半径（停止追击），需 >= detect_radius
@export var chase_contact_buffer := 4.0 ## 追击停距缓冲，避免贴着玩家持续顶住
@export var wander_radius := 64.0     ## 未索敌时的活动半径（围绕初始/刷新位置）
@export var idle_time_min := 0.8      ## 闲逛前最短待机时间
@export var idle_time_max := 1.8      ## 闲逛前最长待机时间
@export var wander_arrive_distance := 6.0 ## 到达随机目标点的判定距离

var is_chasing := false              ## 当前是否处于追击状态

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collision_shape: CollisionShape2D = $CollisionShape2D

var _body_collision_radius := 0.0
var _wander_origin := Vector2.ZERO
var _wander_target := Vector2.ZERO
var _idle_time_left := 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	SPEED = 75.0
	_rng.randomize()
	_wander_origin = global_position
	_wander_target = _wander_origin
	_body_collision_radius = _get_collision_radius_from_shape(body_collision_shape)
	super._ready()


## ============================================
## BasicCharacter 要求实现的方法
## ============================================

## 获取 AI 方向（朝向目标玩家）
func get_input_direction() -> Vector2:
	var target := find_target()
	if target == null:
		return Vector2.ZERO
	return global_position.direction_to(target.global_position)


## 播放动画
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


func set_current_health(value: int, source: Node = null) -> void:
	super.set_current_health(value, source)


## ============================================
## 敌人索敌逻辑
## ============================================

## 查找玩家目标（受 detection_range 限制，chasing 时用 lose_radius）
func find_target(in_range_only: bool = false) -> Node2D:
	var target := get_tree().get_first_node_in_group("player")
	if target == null:
		return null

	# 计算距离
	var dist := global_position.distance_to(target.global_position)
	var radius := detect_radius if not is_chasing else lose_radius

	if in_range_only and dist > radius:
		return null

	return target


## 开始追击
func start_chase() -> void:
	is_chasing = true


## 停止追击
func stop_chase() -> void:
	is_chasing = false


func handle_death_finished() -> void:
	stop_chase()
	queue_free()


## 获取追击停距（双方本体半径 + 额外缓冲）
func get_chase_stop_distance(target: Node2D) -> float:
	return _body_collision_radius + _get_target_collision_radius(target) + chase_contact_buffer


func enter_wander_idle() -> void:
	_idle_time_left = _rng.randf_range(idle_time_min, maxf(idle_time_min, idle_time_max))


func should_start_wander(delta: float) -> bool:
	_idle_time_left = maxf(_idle_time_left - delta, 0.0)
	return _idle_time_left <= 0.0


func start_wander() -> void:
	if wander_radius <= 0.0:
		_wander_target = _wander_origin
		return

	var angle := _rng.randf_range(0.0, TAU)
	var distance := _rng.randf_range(0.0, wander_radius)
	_wander_target = _wander_origin + Vector2.RIGHT.rotated(angle) * distance


func get_wander_direction() -> Vector2:
	var to_target := _wander_target - global_position
	if to_target.length() <= wander_arrive_distance:
		return Vector2.ZERO

	return to_target.normalized()


func has_reached_wander_target() -> bool:
	return global_position.distance_to(_wander_target) <= wander_arrive_distance


func _get_target_collision_radius(target: Node2D) -> float:
	if target == null:
		return 0.0

	var target_collision_shape := target.get_node_or_null("CollisionShape2D") as CollisionShape2D
	return _get_collision_radius_from_shape(target_collision_shape)


func _get_collision_radius_from_shape(collision_shape: CollisionShape2D) -> float:
	if collision_shape == null or collision_shape.shape == null:
		return 0.0

	var circle_shape := collision_shape.shape as CircleShape2D
	if circle_shape == null:
		return 0.0

	return circle_shape.radius
