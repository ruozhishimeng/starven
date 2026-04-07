extends Area2D

@export var sway_target: NodePath = ^"grass_1" # legacy fallback
@export var front_targets: Array[NodePath] = [^"grass_1"]
@export var back_targets: Array[NodePath] = []
@export var player_group := "player"

@export_range(0.01, 0.5, 0.01) var sway_angle := 0.08
@export_range(0.2, 4.0, 0.05) var sway_duration := 1.4
@export_range(0.0, 0.5, 0.01) var sway_randomness := 0.2

@export_range(0.0, 0.6, 0.01) var step_push_angle := 0.18
@export_range(0.0, 0.8, 0.01) var step_wind_damp := 0.35
@export_range(0.0, 0.5, 0.01) var step_squash := 0.08
@export_range(0.05, 1.5, 0.01) var step_in_duration := 0.14
@export_range(0.05, 2.0, 0.01) var step_out_duration := 0.28

var _sway_tween: Tween
var _step_tween: Tween
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _front_sprites: Array[Node2D] = []
var _back_sprites: Array[Node2D] = []
var _base_skews: Dictionary = {}
var _base_scales: Dictionary = {}

var _wind_value: float = 0.0
var _step_blend: float = 0.0
var _step_sign: float = 1.0
var _step_body_count: int = 0


func _ready() -> void:
	monitoring = true
	monitorable = true
	_connect_signals()

	_collect_targets()
	if _front_sprites.is_empty() and _back_sprites.is_empty():
		push_warning("No grass targets found for sway animation.")
		return

	_rng.randomize()
	_apply_pose()
	_start_skew_tween()


func _exit_tree() -> void:
	if _sway_tween and _sway_tween.is_valid():
		_sway_tween.kill()
	if _step_tween and _step_tween.is_valid():
		_step_tween.kill()


func _connect_signals() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)


func _collect_targets() -> void:
	_front_sprites.clear()
	_back_sprites.clear()
	_base_skews.clear()
	_base_scales.clear()

	_append_targets_from_paths(front_targets, _front_sprites)
	_append_targets_from_paths(back_targets, _back_sprites)

	if _front_sprites.is_empty():
		var fallback: Node2D = get_node_or_null(sway_target) as Node2D
		if fallback != null:
			_front_sprites.append(fallback)

	if _back_sprites.is_empty():
		for child in get_children():
			if child is Node2D:
				var node: Node2D = child as Node2D
				var lowered: String = node.name.to_lower()
				if lowered.contains("back") and not _front_sprites.has(node):
					_back_sprites.append(node)

	for sprite in _front_sprites:
		_base_skews[sprite] = sprite.skew
		_base_scales[sprite] = sprite.scale
	for sprite in _back_sprites:
		if not _base_skews.has(sprite):
			_base_skews[sprite] = sprite.skew
		if not _base_scales.has(sprite):
			_base_scales[sprite] = sprite.scale


func _append_targets_from_paths(paths: Array[NodePath], target_list: Array[Node2D]) -> void:
	for target_path in paths:
		var node: Node2D = get_node_or_null(target_path) as Node2D
		if node != null and not target_list.has(node):
			target_list.append(node)


func _start_skew_tween() -> void:
	if _front_sprites.is_empty() and _back_sprites.is_empty():
		return

	if _sway_tween and _sway_tween.is_valid():
		_sway_tween.kill()

	var amp_scale: float = _rng.randf_range(1.0 - sway_randomness, 1.0 + sway_randomness)
	var duration_scale: float = _rng.randf_range(1.0 - sway_randomness * 0.5, 1.0 + sway_randomness * 0.5)
	var amp: float = sway_angle * amp_scale
	var step: float = maxf(0.05, sway_duration * duration_scale * 0.5)

	_sway_tween = create_tween()
	_sway_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_sway_tween.tween_method(_set_wind_value, _wind_value, amp, step)
	_sway_tween.tween_method(_set_wind_value, amp, -amp, step * 2.0)
	_sway_tween.tween_method(_set_wind_value, -amp, 0.0, step)
	_sway_tween.finished.connect(_start_skew_tween)


func _set_wind_value(value: float) -> void:
	_wind_value = value
	_apply_pose()


func _set_step_blend(value: float) -> void:
	_step_blend = clampf(value, 0.0, 1.0)
	_apply_pose()


func _apply_pose() -> void:
	var wind_factor: float = lerpf(1.0, step_wind_damp, _step_blend)
	var step_offset: float = _step_sign * step_push_angle * _step_blend
	var squash_factor: float = 1.0 - step_squash * _step_blend

	for sprite in _front_sprites:
		var base_skew_front: float = float(_base_skews.get(sprite, sprite.skew))
		var base_scale_front: Vector2 = _base_scales.get(sprite, sprite.scale)
		sprite.skew = base_skew_front + (_wind_value * wind_factor) + step_offset
		sprite.scale = Vector2(base_scale_front.x, base_scale_front.y * squash_factor)

	for sprite in _back_sprites:
		var base_skew_back: float = float(_base_skews.get(sprite, sprite.skew))
		var base_scale_back: Vector2 = _base_scales.get(sprite, sprite.scale)
		sprite.skew = base_skew_back - (_wind_value * wind_factor) + step_offset
		sprite.scale = Vector2(base_scale_back.x, base_scale_back.y * squash_factor)


func _on_body_entered(body: Node) -> void:
	if not _is_player_body(body):
		return

	_step_body_count += 1
	if body is Node2D:
		var body_node: Node2D = body as Node2D
		_step_sign = -1.0 if body_node.global_position.x > global_position.x else 1.0

	_play_step_on_animation()


func _on_body_exited(body: Node) -> void:
	if not _is_player_body(body):
		return

	_step_body_count = maxi(0, _step_body_count - 1)
	if _step_body_count == 0:
		_play_step_off_animation()


func _is_player_body(body: Node) -> bool:
	if body == null:
		return false
	if not player_group.is_empty() and body.is_in_group(player_group):
		return true
	return body.name.to_lower().contains("player")


func _play_step_on_animation() -> void:
	if _step_tween and _step_tween.is_valid():
		_step_tween.kill()

	_step_tween = create_tween()
	_step_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_step_tween.tween_method(_set_step_blend, _step_blend, 1.0, step_in_duration)


func _play_step_off_animation() -> void:
	if _step_tween and _step_tween.is_valid():
		_step_tween.kill()

	_step_tween = create_tween()
	_step_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_step_tween.tween_method(_set_step_blend, _step_blend, 0.0, step_out_duration)
