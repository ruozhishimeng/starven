extends State
## 敌人移动状态
##
## 行为：
## - 未索敌时朝随机目标点移动
## - 检测到玩家 → 切换到 chase
## - 到达随机目标点 → 切换回 idle

func Enter() -> void:
	if character.has_method("start_wander"):
		character.start_wander()

func PhysicsProcess(delta: float) -> void:
	var target: Node2D = character.find_target(true)

	if target != null:
		character.start_chase()
		state_machine.change_state("chase")
		return

	var direction := Vector2.ZERO
	if character.has_method("get_wander_direction"):
		direction = character.get_wander_direction()

	if direction.length() < 0.1:
		state_machine.change_state("idle")
		return

	character.facing_dir = character.to_cardinal(direction)
	character.play_animation(character.facing_dir, "move")

	character.velocity = character.velocity.move_toward(
		direction * character.SPEED,
		character.ACCELERATION * delta
	)

	character.move_and_slide()

	if character.has_method("has_reached_wander_target") and character.has_reached_wander_target():
		state_machine.change_state("idle")
