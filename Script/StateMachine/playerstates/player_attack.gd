extends State
## 玩家攻击状态
##
## 行为：
## - 进入时锁定移动并播放攻击动画
## - 在固定帧窗口启用当前朝向的 AttackHitBox
## - 动画结束后按当前输入返回 idle / move

const HITBOX_ENABLE_FRAME := 2
const HITBOX_DISABLE_FRAME := 5

var _attack_dir: Vector2 = Vector2.DOWN
var _attack_animation: StringName = &""
var _hitbox_active: bool = false
var _anim_finished_callable: Callable
var _frame_changed_callable: Callable


func Ready() -> void:
	_anim_finished_callable = Callable(self, "_on_attack_animation_finished")
	_frame_changed_callable = Callable(self, "_on_attack_frame_changed")


func Enter() -> void:
	_attack_dir = character.facing_dir
	_attack_animation = &""
	_hitbox_active = false
	character.velocity = Vector2.ZERO

	state_machine.disable_all_attack_hitboxes()

	if state_machine.anim == null:
		_finish_attack()
		return

	state_machine.play_directional_animation(_attack_dir, "attack")
	_attack_animation = state_machine.anim.animation

	if not state_machine.anim.animation_finished.is_connected(_anim_finished_callable):
		state_machine.anim.animation_finished.connect(_anim_finished_callable)
	if not state_machine.anim.frame_changed.is_connected(_frame_changed_callable):
		state_machine.anim.frame_changed.connect(_frame_changed_callable)

	_sync_hitbox_for_current_frame()


func Exit() -> void:
	state_machine.disable_all_attack_hitboxes()

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


func _finish_attack() -> void:
	state_machine.disable_all_attack_hitboxes()

	var direction: Vector2 = character.get_input_direction()
	if direction.length() > 0.1:
		state_machine.change_state("move")
	else:
		state_machine.change_state("idle")


func _on_attack_frame_changed() -> void:
	_sync_hitbox_for_current_frame()


func _sync_hitbox_for_current_frame() -> void:
	if state_machine.anim == null:
		return
	if state_machine.anim.animation != _attack_animation:
		return

	var frame := state_machine.anim.frame
	var should_enable := frame >= HITBOX_ENABLE_FRAME and frame < HITBOX_DISABLE_FRAME

	if should_enable == _hitbox_active:
		return

	_hitbox_active = should_enable
	state_machine.set_attack_hitbox_for_direction(_attack_dir, _hitbox_active)
