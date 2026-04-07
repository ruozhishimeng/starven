extends State
## 通用移动状态
##
## 行为：
## - 每帧获取输入方向
## - 无输入 → 切换到 Idle
## - 有输入 → 记录朝向 + ACCELERATION 加速 + 播放动画 + move_and_slide()

func PhysicsProcess(delta: float) -> void:
	var direction: Vector2 = character.get_input_direction()

	## 检测是否停止移动
	if direction.length() < 0.1:
		state_machine.change_state("idle")
		return

	## 【关键】记录朝向（切换 Idle 时需要知道面朝哪个方向）
	character.facing_dir = character.to_cardinal(direction)

	## 播放移动动画
	character.play_animation(direction, "move")

	## 【关键】用 ACCELERATION 加速（保留流畅加速效果）
	character.velocity = character.velocity.move_toward(
		direction * character.SPEED,
		character.ACCELERATION * delta
	)

	## 执行移动
	character.move_and_slide()
