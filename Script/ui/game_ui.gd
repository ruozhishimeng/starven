extends CanvasLayer
@onready var progress_bar: ProgressBar = $control_HUD/ProgressBar
@onready var game_over: Control = $game_over

func _ready() -> void:
	game_over.visible = false
