extends State
## 玩家待机状态

## ============================================
## 进入状态 - 读取朝向播放待机动画
## ============================================

func Enter() -> void:
	var anim = character.get_node("AnimatedSprite2D")
	## 播放朝向对应的待机动画
	## _facing_dir 是在 Run 状态中记录的最后移动方向
	anim.play("Idle_" + _dir_to_suffix(character._facing_dir))

## ============================================
## 每物理帧更新 - 检测是否要切换状态
## ============================================

func PhysicsProcess(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction.length() > 0.1:
		## 切换到 Run 状态
		state_machine.change_state("Run")
	else:
		## 减速
		character.velocity = character.velocity.move_toward(
			Vector2.ZERO,
			character.FRICTION * delta
		)
		character.move_and_slide()

## ============================================
## 公共方法：方向转动画后缀（静态方法，Idle 和 Run 都能用）
## ============================================

static func _dir_to_suffix(direction: Vector2) -> String:
	## 斜方向时优先 y 轴
	if direction.y > 0:
		return "down"
	elif direction.y < 0:
		return "up"
	elif direction.x > 0:
		return "right"
	elif direction.x < 0:
		return "left"
	else:
		return "down"  ## 默认向下
