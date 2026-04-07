extends BasicCharacter
## 玩家角色
##
## 继承自 BasicCharacter，使用通用状态机
## 只需实现 get_input_direction() 和 play_animation()

const INPUT_DEADZONE := 0.2

## 动画节点引用
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


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
	if anim == null:
		push_error("anim is null")
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
## 其他
## ============================================
