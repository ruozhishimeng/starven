extends State
## 敌人攻击状态
##
## 行为：
## - 进入时朝向当前目标并播放攻击动画
## - 在固定帧窗口结算一次伤害
## - 动画播完后回到 chase / idle

const DAMAGE_ENABLE_FRAME := 2
const DAMAGE_DISABLE_FRAME := 5
const ATTACK_REACH_BUFFER := 8.0

var _attack_dir: Vector2 = Vector2.DOWN
var _attack_animation: StringName = &""
var _attack_applied := false
var _finished := false
var _last_frame := -1
var _anim_finished_callable: Callable
var _frame_changed_callable: Callable


func Ready() -> void:
	_anim_finished_callable = Callable(self, "_on_attack_animation_finished")
	_frame_changed_callable = Callable(self, "_on_attack_frame_changed")


func Enter() -> void:
	_attack_applied = false
	_finished = false
	_last_frame = -1
	character.velocity = Vector2.ZERO

	var target: Node2D = character.find_target()
	if target != null:
		var direction := character.global_position.direction_to(target.global_position)
		if direction.length() > 0.0:
			character.facing_dir = character.to_cardinal(direction)

	_attack_dir = character.facing_dir
	_attack_animation = &""

	if state_machine.anim == null:
		_finish_attack()
		return

	state_machine.play_directional_animation(_attack_dir, "attack")
	_attack_animation = state_machine.anim.animation
	_last_frame = state_machine.anim.frame

	if not state_machine.anim.animation_finished.is_connected(_anim_finished_callable):
		state_machine.anim.animation_finished.connect(_anim_finished_callable)
	if not state_machine.anim.frame_changed.is_connected(_frame_changed_callable):
		state_machine.anim.frame_changed.connect(_frame_changed_callable)

	_try_apply_attack_damage()


func Exit() -> void:
	if state_machine.anim != null and state_machine.anim.animation_finished.is_connected(_anim_finished_callable):
		state_machine.anim.animation_finished.disconnect(_anim_finished_callable)
	if state_machine.anim != null and state_machine.anim.frame_changed.is_connected(_frame_changed_callable):
		state_machine.anim.frame_changed.disconnect(_frame_changed_callable)


func PhysicsProcess(_delta: float) -> void:
	character.velocity = Vector2.ZERO


func _on_attack_animation_finished() -> void:
	if state_machine.anim == null:
		return
	if state_machine.anim.animation != _attack_animation:
		return

	_finish_attack()


func _on_attack_frame_changed() -> void:
	if state_machine.anim == null:
		return
	if state_machine.anim.animation != _attack_animation:
		return

	var current_frame := state_machine.anim.frame
	if _last_frame >= 0 and current_frame < _last_frame:
		_finish_attack()
		return

	_last_frame = current_frame
	_try_apply_attack_damage()


func _try_apply_attack_damage() -> void:
	if _attack_applied:
		return
	if state_machine.anim == null:
		return
	if state_machine.anim.animation != _attack_animation:
		return

	var frame := state_machine.anim.frame
	if frame < DAMAGE_ENABLE_FRAME or frame >= DAMAGE_DISABLE_FRAME:
		return

	var attacker := character as BasicCharacter
	if attacker == null:
		return

	var target: BasicCharacter = character.find_target() as BasicCharacter
	if target == null or target == attacker:
		return
	if not _is_target_in_attack_range(target):
		return

	_attack_applied = true
	target.receive_attack(attacker.get_attack_power(), attacker)


func _is_target_in_attack_range(target: Node2D) -> bool:
	if target == null:
		return false

	var attack_range := ATTACK_REACH_BUFFER
	if character.has_method("get_chase_stop_distance"):
		attack_range += character.get_chase_stop_distance(target)

	return character.global_position.distance_to(target.global_position) <= attack_range


func _finish_attack() -> void:
	if _finished:
		return
	_finished = true

	var target: Node2D = character.find_target()
	if target == null:
		if character.has_method("stop_chase"):
			character.stop_chase()
		state_machine.change_state("idle")
		return

	if state_machine.can_change_to("chase"):
		state_machine.change_state("chase")
	else:
		state_machine.change_state("idle")
