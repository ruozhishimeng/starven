extends State
## 敌人追击状态
##
## 行为：
## - 朝玩家方向移动
## - 玩家超出 lose_radius → stop_chase() + 切换回 Idle
## - 记录朝向，播放移动动画

func PhysicsProcess(delta: float) -> void:
	var target: Node2D = character.find_target()

	# 丢失目标 → 停止追击
	if target == null:
		character.stop_chase()
		state_machine.change_state("idle")
		return

	var dist := character.global_position.distance_to(target.global_position)

	# 玩家超出 lose_radius → 停止追击
	if dist > character.lose_radius:
		character.stop_chase()
		state_machine.change_state("idle")
		return

	var direction := character.global_position.direction_to(target.global_position)

	# 记录朝向（cardinal 4向）
	character.facing_dir = character.to_cardinal(direction)

	# 播放移动动画
	character.play_animation(character.facing_dir, "move")

	# 如果已贴近目标，停止推进让物理引擎自然分离
	if dist < character.SPEED * 0.5:
		character.velocity = character.velocity.move_toward(
			Vector2.ZERO,
			character.FRICTION * delta
		)
	else:
		# 正常朝目标加速
		character.velocity = character.velocity.move_toward(
			direction * character.SPEED,
			character.ACCELERATION * delta
		)

	character.move_and_slide()
