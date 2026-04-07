extends BasicCharacter
## 敌人角色
##
## 继承自 BasicCharacter，使用通用状态机
## AI 驱动：自动追踪玩家

@export var detect_radius := 300.0   ## 索敌半径（触发追击）
@export var lose_radius := 1000.0     ## 丢失半径（停止追击），需 >= detect_radius

var is_chasing := false              ## 当前是否处于追击状态

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	SPEED = 75.0
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
