extends State
## 敌人待机状态
##
## 行为：
## - 进入时播放待机动画
## - 待机时检测玩家是否进入索敌范围
## - 检测到目标后进入 chase

func Enter() -> void:
	character.play_animation(character.facing_dir, "idle")
	if character.has_method("enter_wander_idle"):
		character.enter_wander_idle()


func PhysicsProcess(delta: float) -> void:
	var target: Node2D = character.find_target(true)

	if target != null:
		character.start_chase()
		state_machine.change_state("chase")
		return

	if state_machine.can_change_to("move") and character.has_method("should_start_wander"):
		if character.should_start_wander(delta):
			state_machine.change_state("move")
			return

	character.velocity = character.velocity.move_toward(
		Vector2.ZERO,
		character.FRICTION * delta
	)
	character.move_and_slide()
