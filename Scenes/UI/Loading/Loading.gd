extends Control

@onready var fade = $ColorRect
@onready var label = $Label

# Frases de horror para imersão


func _ready():
	fade.color = Color(0, 0, 0, 1)
	
	await fade_in()
	await simulate_loading(4.0)
	await fade_out()
	load_scene()

func fade_in():
	var tween = create_tween()
	tween.tween_property(fade, "color", Color(0, 0, 0, 0), 0.6)
	await tween.finished

func fade_out():
	var tween = create_tween()
	tween.tween_property(fade, "color", Color(0, 0, 0, 1), 0.6)
	await tween.finished

func simulate_loading(total_time: float):
	var time := 0.0
	var dot_time := 0.0
	var dot_count := 0

	# Fixa "Carregando cena..." no início
	label.text = "Loading..."
	await get_tree().create_timer(1.0).timeout

	while time < total_time:
		var delta = get_process_delta_time()
		time += delta
		dot_time += delta

		# Troca a frase de horror a cada 1.2s

		# Animação de "..."
		if dot_time >= 0.3:
			dot_time = 0.0
			dot_count = (dot_count + 1) % 4
			var base = label.text.rstrip(".")
			label.text = base + ".".repeat(dot_count)

		await get_tree().process_frame

	# Fixa "Cena carregada." no final
	label.text = "Loaded."
	await get_tree().create_timer(0.8).timeout

func load_scene():
	var scene = GameManage.scenes.get(GameManage.target_scene, null)
	if scene == null:
		push_error("[LoadingScreen] Cena não encontrada: %s" % str(GameManage.target_scene))
		# Fallback seguro pro menu principal
		GameManage.target_scene = GameManage.NameScenes.UI_MAINMENU
		scene = GameManage.scenes.get(GameManage.target_scene, null)
		if scene == null:
			push_error("[LoadingScreen] Menu também não encontrado! Abortando.")
			return
	get_tree().change_scene_to_packed(scene)
	
