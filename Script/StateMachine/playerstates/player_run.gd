extends State
## 玩家移动状态

## ============================================
## 进入状态 - 初始化
## ============================================

func Enter() -> void:
	pass

## ============================================
## 每物理帧更新 - 移动 + 检测停止
## ============================================

func PhysicsProcess(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	## 检测是否停止移动
	if direction.length() < 0.1:
		state_machine.change_state("Idle")
		return

	## 记录朝向（切换到 Idle 时需要知道面朝哪个方向）
	character._facing_dir = _to_cardinal(direction)

	## 播放对应方向的动画
	var anim = character.get_node("AnimatedSprite2D")
	anim.play("Run_" + _dir_to_suffix(direction))

	## 加速移动
	character.velocity = character.velocity.move_toward(
		direction * character.SPEED,
		character.ACCELERATION * delta
	)

	## 执行移动
	character.move_and_slide()

## ============================================
## 公共方法
## ============================================

## 方向转主方向（斜方向转成最近的主方向）
static func _to_cardinal(direction: Vector2) -> Vector2:
	if absf(direction.y) >= absf(direction.x):
		return Vector2(0, 1 if direction.y > 0 else -1)
	else:
		return Vector2(1 if direction.x > 0 else -1, 0)

## 方向转动画后缀
static func _dir_to_suffix(direction: Vector2) -> String:
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
