extends Sprite2D

@export var randomRegions: Array[Rect2] = []

func _ready() -> void:
	update_random_region()


## 随机选择一个 region
func update_random_region() -> void:
	if randomRegions.is_empty():
		return
	var selected = randomRegions[randi() % randomRegions.size()]
	region_enabled = true
	region_rect = selected


## 设置指定 variant（用于确定性生成）
func set_variant(variant: int) -> void:
	if randomRegions.is_empty() or variant < 0 or variant >= randomRegions.size():
		return
	region_enabled = true
	region_rect = randomRegions[variant]
