
extends TileMapLayer
const GRASS = preload("uid://ddkh4xhv0c6n5")
const OFFSET = 10
func _ready() -> void:
	visible = false
	var cellArray = get_used_cells()
	for cellCoordinate in cellArray:
		var newGrass = GRASS.instantiate()
		newGrass.global_position = global_position + cellCoordinate * 32.0 + Vector2(16, 16)
		get_parent().add_child.call_deferred(newGrass)
		var randomOffset = Vector2(randf_range(-OFFSET, OFFSET), randf_range(-OFFSET, OFFSET))
		newGrass.global_position += randomOffset
		newGrass.get_node("grass_1").flip_h = randi_range(0, 1)
		(newGrass.get_node("grass_1_back") as Sprite2D).flip_h
