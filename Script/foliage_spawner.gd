extends Node2D
## 无限地图生成器（Chunk 流式生成）
##
## 核心思路：
## - 世界划分为固定大小 chunk
## - 只生成玩家周围的 chunk（active_chunk_radius）
## - chunk 生成使用 world_seed + chunk_coord 确定性种子
## - 先生成数据，再实例化节点（数据与渲染分离）

## ============================================
## 世界参数
## ============================================

@export var world_seed: int = 1
@export var chunk_size: Vector2i = Vector2i(1024, 1024)  ## chunk 像素尺寸
@export var active_chunk_radius: int = 2                 ## 激活半径（2 = 5x5 chunk）

## ============================================
## 场景路径
## ============================================

@export var grass_scene_path := "res://Scene/grass.tscn"
@export var tree_scene_path := "res://Scene/Tree.tscn"

## ============================================
## 树生成规则
## ============================================

@export var tree_count_per_chunk: int = 24       ## 每 chunk 目标树数量
@export var tree_min_spacing: float = 80.0    ## 树之间最小间距
@export var tree_scale_range := Vector2(0.9, 1.25)
@export var tree_noise_threshold: float = -1.0  ## 树密度噪声阈值（-1=不过滤）

## ============================================
## 草生成规则
## ============================================

@export var grass_count_per_chunk: int = 96     ## 每 chunk 目标草数量
@export var grass_min_spacing: float = 20.0   ## 草之间最小间距
@export var grass_scale_range := Vector2(0.9, 1.2)
@export var grass_noise_threshold: float = -1.0 ## 草密度噪声阈值（-1=不过滤）

## ============================================
## 地形限制（可选）
## ============================================

@export var terrain_tile_map_path: NodePath       ## 用于检测合法地形的 TileMap（可选）
@export var require_terrain: bool = false         ## 是否要求物体必须放在合法地形上

## ============================================
## 内部状态
## ============================================

## 已生成的 chunk 数据 {chunk_coord: chunk_data}
var _spawned_chunks: Dictionary = {}

## 已实例化的 chunk 节点 {chunk_coord: [nodes]}
var _chunk_nodes: Dictionary = {}

## 随机数生成器
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

## 玩家上一个所在的 chunk
var _last_player_chunk: Vector2i = Vector2i(-99999, -99999)

## 噪声生成器（用于密度控制）
var _noise: FastNoiseLite = FastNoiseLite.new()


## ============================================
## 生命周期
## ============================================

func _ready() -> void:
	_noise.seed = world_seed
	_noise.frequency = 0.01
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	if not Engine.is_editor_hint():
		_initial_spawn()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var player := _get_player()
	if player == null:
		return

	var player_chunk := world_to_chunk(player.global_position)
	if player_chunk != _last_player_chunk:
		_last_player_chunk = player_chunk
		_update_chunks_around_player(player.global_position)


## ============================================
## 公开方法
## ============================================

## 重新生成世界（使用新种子）
func regenerate_with_new_seed() -> void:
	world_seed = randi()
	_rng.seed = world_seed
	_noise.seed = world_seed
	_clear_all_chunks()
	_initial_spawn()


## ============================================
## Chunk 坐标转换
## ============================================

## 世界坐标 -> chunk 坐标
func world_to_chunk(pos: Vector2) -> Vector2i:
	var x := int(floor(pos.x / chunk_size.x))
	var y := int(floor(pos.y / chunk_size.y))
	return Vector2i(x, y)


## 获取 chunk 的世界边界（左下角，右上角）
func get_chunk_bounds(chunk_coord: Vector2i) -> Rect2:
	var origin := Vector2(chunk_coord) * Vector2(chunk_size)
	return Rect2(origin, Vector2(chunk_size))


## 计算 chunk 的确定性种子
func _get_chunk_seed(chunk_coord: Vector2i) -> int:
	var hash_input := "%s:%s:%s" % [world_seed, chunk_coord.x, chunk_coord.y]
	return hash(hash_input)


## ============================================
## Chunk 管理
## ============================================

func _initial_spawn() -> void:
	var player := _get_player()
	if player == null:
		push_error("FoliageSpawner: player not found!")
		return
	print("FoliageSpawner: player found at ", player.global_position)
	_last_player_chunk = world_to_chunk(player.global_position)
	print("FoliageSpawner: initial chunk = ", _last_player_chunk)
	_update_chunks_around_player(player.global_position)


func _update_chunks_around_player(player_pos: Vector2) -> void:
	var center_chunk: Vector2i = world_to_chunk(player_pos)

	## 计算应激活的 chunk 范围（用 Dictionary 做快速查找）
	var target_chunks: Dictionary = {}
	for dx in range(-active_chunk_radius, active_chunk_radius + 1):
		for dy in range(-active_chunk_radius, active_chunk_radius + 1):
			var coord := Vector2i(center_chunk.x + dx, center_chunk.y + dy)
			target_chunks[coord] = true

	## 找出需要移除的 chunk（已存在但超出范围）
	var to_remove: Array[Vector2i] = []
	for existing in _chunk_nodes.keys():
		if not target_chunks.has(existing):
			to_remove.append(existing)

	## 移除远处 chunk
	for chunk_coord in to_remove:
		_despawn_chunk(chunk_coord)

	## 生成和激活新进 chunk
	for chunk_coord in target_chunks:
		if not _chunk_nodes.has(chunk_coord):
			var chunk_data := _generate_chunk_data(chunk_coord)
			_spawned_chunks[chunk_coord] = chunk_data
			_spawn_chunk(chunk_coord, chunk_data)


## ============================================
## 数据生成（确定性）
## ============================================

func _generate_chunk_data(chunk_coord: Vector2i) -> Dictionary:
	var chunk_rng := RandomNumberGenerator.new()
	chunk_rng.seed = _get_chunk_seed(chunk_coord)

	var bounds := get_chunk_bounds(chunk_coord)
	print("Generating chunk ", chunk_coord, " bounds=", bounds)

	var trees: Array[Dictionary] = []
	var grass: Array[Dictionary] = []

	## 生成树
	trees = _generate_trees_for_chunk(chunk_rng, bounds)
	print("  trees generated: ", trees.size())

	## 生成草
	grass = _generate_grass_for_chunk(chunk_rng, bounds)
	print("  grass generated: ", grass.size())

	return {
		"trees": trees,
		"grass": grass
	}


func _generate_trees_for_chunk(chunk_rng: RandomNumberGenerator, bounds: Rect2) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var placed: Array[Vector2] = []

	var jitter: float = chunk_size.x / 4.0  ## 网格抖动幅度

	for i in tree_count_per_chunk:
		var attempts := 30
		for _attempt in attempts:
			## 网格 + 抖动定位
			var grid_x := (i % 4) * (chunk_size.x / 4.0)
			var grid_y := (i / 4) * (chunk_size.y / 4.0)
			var jitter_x := chunk_rng.randf_range(-jitter, jitter)
			var jitter_y := chunk_rng.randf_range(-jitter, jitter)
			var candidate := Vector2(bounds.position.x + grid_x + jitter_x, bounds.position.y + grid_y + jitter_y)

			## 噪声阈值检测
			var noise_val := _noise.get_noise_2d(candidate.x * 0.005, candidate.y * 0.005)
			if noise_val < tree_noise_threshold:
				continue

			## 间距检测
			if _is_too_close(candidate, placed, tree_min_spacing):
				continue

			## 地形检测（可选）
			if require_terrain and not _is_valid_terrain(candidate):
				continue

			placed.append(candidate)
			result.append({
				"pos": candidate,
				"scale": chunk_rng.randf_range(tree_scale_range.x, tree_scale_range.y),
				"variant": chunk_rng.randi() % 4  ## 4 种树外观
			})
			break

	return result


func _generate_grass_for_chunk(chunk_rng: RandomNumberGenerator, bounds: Rect2) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var placed: Array[Vector2] = []

	## 先生成 patch 中心点（噪声驱动）
	var patch_centers: Array[Vector2] = []
	var patch_jitter := chunk_size.x / 2.0
	for i in 4:
		var cx := bounds.position.x + chunk_rng.randf_range(0, chunk_size.x)
		var cy := bounds.position.y + chunk_rng.randf_range(0, chunk_size.y)
		var noise_at := _noise.get_noise_2d(cx * 0.008, cy * 0.008)
		if noise_at > 0.3:  ## 只在一定密度区域生成 patch
			patch_centers.append(Vector2(cx, cy))

	var jitter: float = chunk_size.x / 8.0  ## 更密集的抖动

	for i in grass_count_per_chunk:
		var attempts := 20
		for _attempt in attempts:
			## 随机位置
			var candidate := Vector2(
				bounds.position.x + chunk_rng.randf_range(0, chunk_size.x),
				bounds.position.y + chunk_rng.randf_range(0, chunk_size.y)
			)

			## 噪声阈值检测
			var noise_val := _noise.get_noise_2d(candidate.x * 0.01, candidate.y * 0.01)
			if noise_val < grass_noise_threshold:
				continue

			## 检查是否在 patch 内（patch 内高密度，patch 外低密度）
			var in_patch := _is_in_any_patch(candidate, patch_centers, chunk_size.x / 3.0)
			if not in_patch and chunk_rng.randf() > 0.3:
				## patch 外只有 30% 概率生成
				continue

			## 间距检测（patch 内更密集）
			var spacing := grass_min_spacing if in_patch else grass_min_spacing * 1.5
			if _is_too_close(candidate, placed, spacing):
				continue

			## 地形检测（可选）
			if require_terrain and not _is_valid_terrain(candidate):
				continue

			placed.append(candidate)
			result.append({
				"pos": candidate,
				"scale": chunk_rng.randf_range(grass_scale_range.x, grass_scale_range.y),
				"variant": chunk_rng.randi() % 5  ## 5 种草外观
			})
			break

	return result


## ============================================
## 节点实例化
## ============================================

func _spawn_chunk(chunk_coord: Vector2i, chunk_data: Dictionary) -> void:
	var grass_scene: PackedScene = _load_scene(grass_scene_path)
	var tree_scene: PackedScene = _load_scene(tree_scene_path)

	if grass_scene == null:
		push_warning("grass_scene is null: " + grass_scene_path)
	if tree_scene == null:
		push_warning("tree_scene is null: " + tree_scene_path)

	print("Spawning chunk ", chunk_coord, " - trees: ", chunk_data["trees"].size(), " grass: ", chunk_data["grass"].size())

	var nodes: Array[Node2D] = []

	## 生成树节点
	if tree_scene != null:
		for tree_info in chunk_data["trees"]:
			var instance: Node2D = _instantiate_scene(tree_scene, tree_info["pos"], tree_info["scale"])
			if instance != null:
				## 设置随机外观（如果支持）
				_set_tree_variant(instance, tree_info["variant"])
				add_child(instance)
				nodes.append(instance)

	## 生成草节点
	if grass_scene != null:
		for grass_info in chunk_data["grass"]:
			var instance: Node2D = _instantiate_scene(grass_scene, grass_info["pos"], grass_info["scale"])
			if instance != null:
				_set_grass_variant(instance, grass_info["variant"])
				add_child(instance)
				nodes.append(instance)

	_chunk_nodes[chunk_coord] = nodes


func _instantiate_scene(scene: PackedScene, pos: Vector2, scale: float) -> Node2D:
	var instance: Node = scene.instantiate()
	if not (instance is Node2D):
		instance.queue_free()
		return null

	var node2d: Node2D = instance as Node2D
	node2d.position = pos
	node2d.scale = Vector2.ONE * scale
	return node2d


func _despawn_chunk(chunk_coord: Vector2i) -> void:
	if not _chunk_nodes.has(chunk_coord):
		return

	for node in _chunk_nodes[chunk_coord]:
		if is_instance_valid(node):
			node.queue_free()

	_chunk_nodes.erase(chunk_coord)
	_spawned_chunks.erase(chunk_coord)


func _clear_all_chunks() -> void:
	for chunk_coord in _chunk_nodes.keys():
		_despawn_chunk(chunk_coord)


## ============================================
## 工具方法
## ============================================

func _is_too_close(point: Vector2, positions: Array[Vector2], spacing: float) -> bool:
	var spacing_sq: float = spacing * spacing
	for p in positions:
		if point.distance_squared_to(p) < spacing_sq:
			return true
	return false


func _is_in_any_patch(point: Vector2, patch_centers: Array[Vector2], patch_radius: float) -> bool:
	var radius_sq: float = patch_radius * patch_radius
	for center in patch_centers:
		if point.distance_squared_to(center) < radius_sq:
			return true
	return false


func _get_player() -> Node2D:
	var tree := get_tree()
	if tree == null:
		return null
	var player := tree.get_first_node_in_group("player")
	if player is Node2D:
		return player as Node2D
	return null


func _load_scene(path: String) -> PackedScene:
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		push_warning("Scene not found: %s" % path)
		return null
	var res: Resource = load(path)
	if res is PackedScene:
		return res as PackedScene
	return null


## ============================================
## 地形验证（可选）
## ============================================

func _is_valid_terrain(pos: Vector2) -> bool:
	if not require_terrain:
		return true

	if terrain_tile_map_path.is_empty():
		return true

	var tilemap: TileMap = get_node_or_null(terrain_tile_map_path)
	if tilemap == null:
		return true

	## 检查该位置是否有瓦片
	var tile_pos := tilemap.local_to_map(pos)
	var source_id := tilemap.get_cell_source_id(0, tile_pos)
	return source_id >= 0


## ============================================
## 变体设置（依赖 randomRegions 数组）
## ============================================

func _set_tree_variant(node: Node2D, variant: int) -> void:
	## Tree.tscn 中 TreeAndGrass Sprite2D 挂载了 random_tree.gd
	var sprite: Sprite2D = node.get_node_or_null("TreeAndGrass")
	if sprite != null and sprite.has_method("set_variant"):
		sprite.set_variant(variant)


func _set_grass_variant(node: Node2D, variant: int) -> void:
	## grass.tscn 中 grass_1 Sprite2D 挂载了 grass_random.gd
	var sprite: Sprite2D = node.get_node_or_null("grass_1")
	if sprite != null and sprite.has_method("set_variant"):
		sprite.set_variant(variant)
