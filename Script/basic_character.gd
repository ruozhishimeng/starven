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

## 状态机
@onready var state_machine: StateMachine = $StateMachine

## 面朝方向（移动时更新，Idle 时读取）
var facing_dir := Vector2(0, 1)


func _ready() -> void:
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


## ============================================
## 工具方法
## ============================================

## 方向转主方向（斜方向转成最近的主方向）
func to_cardinal(direction: Vector2) -> Vector2:
	if absf(direction.y) >= absf(direction.x):
		return Vector2(0, 1 if direction.y > 0 else -1)
	else:
		return Vector2(1 if direction.x > 0 else -1, 0)
