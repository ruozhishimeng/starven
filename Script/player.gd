extends BasicCharacter
## 玩家角色
##
## 继承自 BasicCharacter，使用通用状态机
## 只需实现 get_input_direction() 和 play_animation()

const INPUT_DEADZONE := 0.2


func _ready() -> void:
	add_to_group("player")
	## 初始化状态机（必须调用父类）
	super._ready()


## ============================================
## BasicCharacter 要求实现的方法
## ============================================

## 获取玩家输入方向
func get_input_direction() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")


## 播放动画
func play_animation(direction: Vector2, prefix: String) -> void:
	if state_machine == null:
		push_error("state_machine is null")
		return

	state_machine.play_directional_animation(direction, prefix)


func set_current_health(value: int, source: Node = null) -> void:
	super.set_current_health(value, source)


## ============================================
## 其他
## ============================================
