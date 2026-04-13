extends CharacterBody2D
class_name BasicCharacter
## 通用角色基座
##
## 所有玩家、敌人都继承此类
## 子类只需实现 get_input_direction() 和 play_animation()
##
## 【移动参数】（子类可通过 @export 覆盖）
@export var SPEED := 200.0
@export var ACCELERATION := 800.0
@export var FRICTION := 800.0
@export var max_hp: int = 5
@export var attack_power: int = 1
@export var hit_knockback_speed := 180.0

signal health_changed(current_hp: int, max_hp: int)
signal health_depleted(source: Node)

## 状态机
@onready var state_machine: StateMachine = $StateMachine

## 面朝方向（移动时更新，Idle 时读取）
var facing_dir := Vector2(0, 1)
var current_hp: int = 0
var is_dead := false
var knockback_direction := Vector2.ZERO


func _ready() -> void:
	current_hp = maxi(max_hp, 0)
	is_dead = false
	state_machine.init()


## ============================================
## 子类必须实现
## ============================================

## 获取输入方向（玩家=输入，敌人=AI）
func get_input_direction() -> Vector2:
	push_error("BasicCharacter: 子类必须实现 get_input_direction()")
	return Vector2.ZERO


## 播放动画（子类根据动画系统实现）
func play_animation(direction: Vector2, prefix: String) -> void:
	push_error("BasicCharacter: 子类必须实现 play_animation()")


func get_attack_power() -> int:
	return attack_power


func set_current_health(value: int, source: Node = null) -> void:
	var previous_hp := current_hp
	var clamped_max_hp := maxi(max_hp, 0)
	current_hp = clampi(value, 0, clamped_max_hp)

	if current_hp > 0:
		is_dead = false

	if previous_hp != current_hp:
		health_changed.emit(current_hp, max_hp)

	if current_hp > 0:
		return
	if is_dead:
		return

	is_dead = true
	health_depleted.emit(source)
	if state_machine != null and state_machine.can_change_to("die"):
		state_machine.change_state("die")
	else:
		handle_death_finished()


func gethit(direction: Vector2) -> void:
	if direction.length() < 0.001:
		knockback_direction = Vector2.ZERO
		return

	knockback_direction = direction.normalized()
	velocity = knockback_direction * hit_knockback_speed


func receive_attack(incoming_attack_power: int, source: Node = null) -> int:
	if is_dead:
		return 0
	if source == self:
		return 0

	var damage := resolve_incoming_damage(incoming_attack_power, source)
	if damage <= 0:
		return 0

	var source_node := source as Node2D
	if source_node != null:
		gethit(global_position - source_node.global_position)

	set_current_health(current_hp - damage, source)
	return damage


func resolve_incoming_damage(incoming_attack_power: int, source: Node = null) -> int:
	if source == self:
		return 0

	return maxi(1, incoming_attack_power)


func handle_death_finished() -> void:
	pass


## ============================================
## 工具方法
## ============================================

## 方向转主方向（斜方向转成最近的主方向）
func to_cardinal(direction: Vector2) -> Vector2:
	if absf(direction.y) >= absf(direction.x):
		return Vector2(0, 1 if direction.y > 0 else -1)
	else:
		return Vector2(1 if direction.x > 0 else -1, 0)
