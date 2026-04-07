extends State
## 通用待机状态
##
## 行为：
## - 进入时播放待机动画（使用 facing_dir）
## - 每帧检测是否有输入
## - 有输入 → 切换到 Move
## - 无输入 → 用 FRICTION 减速 + move_and_slide()

func Enter() -> void:
	character.play_animation(character.facing_dir, "idle")


func PhysicsProcess(delta: float) -> void:
	var direction: Vector2 = character.get_input_direction()

	## 检测是否有移动输入
	if direction.length() > 0.1:
		state_machine.change_state("move")
	else:
		## 【关键】用 FRICTION 减速（保留流畅减速效果）
		character.velocity = character.velocity.move_toward(
			Vector2.ZERO,
			character.FRICTION * delta
		)
		character.move_and_slide()
