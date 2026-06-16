extends Control

var player: Player

@onready var overlay: ColorRect = $DarkOverlay


func _ready():
	hide()
	overlay.modulate.a = 0.0
	
func show_menu() -> void:
	show()

	overlay.show()
	overlay.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(
		overlay,
		"modulate:a",
		0.5,
		0.2
	)
func hide_menu() -> void:
	var tween = create_tween()

	tween.tween_property(
		overlay,
		"modulate:a",
		0.0,
		0.2
	)

	await tween.finished

	overlay.hide()
	hide()
