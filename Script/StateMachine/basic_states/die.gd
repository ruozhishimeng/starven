extends State
## 通用死亡状态
##
## 行为：
## - 进入时立即停止移动
## - 禁用本体碰撞与受击 Area
## - 优先播放 die_{direction}，没有时回退到 die
## - 动画结束后调用角色自己的 handle_death_finished()

var _death_animation: StringName = &""
var _anim_finished_callable: Callable
var _anim_looped_callable: Callable
var _death_finished := false


func Ready() -> void:
	_anim_finished_callable = Callable(self, "_on_death_animation_finished")
	_anim_looped_callable = Callable(self, "_on_death_animation_looped")


func Enter() -> void:
	_death_animation = &""
	_death_finished = false
	character.velocity = Vector2.ZERO

	if character.has_method("stop_chase"):
		character.stop_chase()

	state_machine.disable_all_attack_hitboxes()
	state_machine.disable_character_collision()
	state_machine.disable_damage_receiver()

	if state_machine.anim == null:
		_finish_death()
		return

	if not state_machine.play_animation_with_fallback("die", character.facing_dir):
		_finish_death()
		return

	_death_animation = state_machine.anim.animation
	if not state_machine.anim.animation_finished.is_connected(_anim_finished_callable):
		state_machine.anim.animation_finished.connect(_anim_finished_callable)
	if not state_machine.anim.animation_looped.is_connected(_anim_looped_callable):
		state_machine.anim.animation_looped.connect(_anim_looped_callable)


func Exit() -> void:
	if state_machine.anim != null and state_machine.anim.animation_finished.is_connected(_anim_finished_callable):
		state_machine.anim.animation_finished.disconnect(_anim_finished_callable)
	if state_machine.anim != null and state_machine.anim.animation_looped.is_connected(_anim_looped_callable):
		state_machine.anim.animation_looped.disconnect(_anim_looped_callable)


func PhysicsProcess(_delta: float) -> void:
	character.velocity = Vector2.ZERO


func _on_death_animation_finished() -> void:
	if state_machine.anim == null:
		return
	if state_machine.anim.animation != _death_animation:
		return

	_finish_death()


func _on_death_animation_looped() -> void:
	if state_machine.anim == null:
		return
	if state_machine.anim.animation != _death_animation:
		return

	_finish_death()


func _finish_death() -> void:
	if _death_finished:
		return

	_death_finished = true
	if character.has_method("handle_death_finished"):
		character.handle_death_finished()
