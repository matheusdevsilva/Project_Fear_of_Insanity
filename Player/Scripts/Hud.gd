extends Control
class_name Hud

var player: Player
@onready var stamina_bar = $ProgressBar

var displayed_stamina := 100.0
var blink_time := 0.0
var target_alpha := 1.0

func _process(delta):

	displayed_stamina = lerp(displayed_stamina, player.stamina, 8.0 * delta)
	stamina_bar.value = displayed_stamina

	var t = player.stamina / player.stamina_max

	# --- COR ---
	var color = Color.GREEN.lerp(Color.YELLOW, 1.0 - t)

	if t < 0.3:
		color = Color.YELLOW.lerp(Color.RED, (0.3 - t) / 0.3)

	if player.exhausted:
		blink_time += delta
		var blink = sin(blink_time * 12.0) * 0.5 + 0.5
		color = Color.RED.lerp(Color.BLACK, blink)
	else:
		blink_time = 0.0

	# --- FADE (alpha separado, mas aplicado junto) ---
	if stamina_bar.value >= stamina_bar.max_value - 0.1:
		target_alpha = 0.0
	else:
		target_alpha = 1.0

	var final_color = color
	final_color.a = lerp(stamina_bar.modulate.a, target_alpha, 6.0 * delta)

	stamina_bar.modulate = final_color
