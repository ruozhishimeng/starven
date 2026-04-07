extends State
## 敌人待机状态
##
## 行为：
## - 播放待机动画
## - 检测玩家是否进入 detect_radius
## - 进入 → start_chase() + 切换到 Chase
## - 无目标 → 用 FRICTION 减速停止

func Enter() -> void:
	character.play_animation(character.facing_dir, "idle")


func PhysicsProcess(delta: float) -> void:
	var target: Node2D = character.find_target()
	if target != null:
		var dist := character.global_position.distance_to(target.global_position)
		if dist <= character.detect_radius:
			character.start_chase()
			state_machine.change_state("chase")
			return

	# 无目标 → 减速停止
	character.velocity = character.velocity.move_toward(
		Vector2.ZERO,
		character.FRICTION * delta
	)
	character.move_and_slide()
