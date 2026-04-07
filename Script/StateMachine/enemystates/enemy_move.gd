extends State
## 敌人移动状态
##
## 行为：
## - 朝玩家方向移动
## - 丢失目标 → 切换到 Idle
## - 记录朝向，播放移动动画

func PhysicsProcess(delta: float) -> void:
	var target: Node2D = character.find_target()

	if target == null:
		state_machine.change_state("idle")
		return

	var direction := character.global_position.direction_to(target.global_position)

	# 丢失目标（距离太远）→ 回到待机
	if direction.length() < 0.1:
		state_machine.change_state("idle")
		return

	# 记录朝向（cardinal 4向）
	character.facing_dir = character.to_cardinal(direction)

	# 播放移动动画
	character.play_animation(character.facing_dir, "move")

	# 加速移动
	character.velocity = character.velocity.move_toward(
		direction * character.SPEED,
		character.ACCELERATION * delta
	)

	character.move_and_slide()
