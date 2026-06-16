extends Node3D

@onready var midi_player: MidiPlayer = $MidiPlayer
@onready var marker_position:Marker3D = $Marker3D

var tocando_piano := false
var player_in_scene:Player
var oitava_offset := 0
var teclas := {
	# Graves (C2-B2)
	KEY_1: 36,
	KEY_2: 37,
	KEY_3: 38,
	KEY_4: 39,
	KEY_5: 40,
	KEY_6: 41,
	KEY_7: 42,
	KEY_8: 43,
	KEY_9: 44,
	KEY_0: 45,
	KEY_MINUS: 46,
	KEY_EQUAL: 47,

	# Médios (C3-B3)
	KEY_Q: 48,
	KEY_W: 49,
	KEY_E: 50,
	KEY_R: 51,
	KEY_T: 52,
	KEY_Y: 53,
	KEY_U: 54,
	KEY_I: 55,
	KEY_O: 56,
	KEY_P: 57,
	KEY_BRACKETLEFT: 58,
	KEY_BRACKETRIGHT: 59,

	# Dó Central e acima (C4-C5)
	KEY_A: 60,
	KEY_S: 61,
	KEY_D: 62,
	KEY_F: 63,
	KEY_G: 64,
	KEY_H: 65,
	KEY_J: 66,
	KEY_K: 67,
	KEY_L: 68,
	KEY_SEMICOLON: 69,
	KEY_APOSTROPHE: 70,

	# Agudos
	KEY_Z: 72,
	KEY_X: 74,
	KEY_C: 76,
	KEY_V: 77,
	KEY_B: 79,
	KEY_N: 81,
	KEY_M: 83
}

var teclas_pressionadas := {}

func _ready():
	midi_player.set_soundfont("res://Soundfont/Equinox_Grand_Pianos.sf2")
	print("Soundfont:", midi_player.soundfont)
	print("Bank:", midi_player.bank)

func _input(event):
	if !player_in_scene:
		return
	if event.is_action_pressed("ui_cancel"):
		sair_do_piano()
		return
	if event is InputEventKey and event.pressed and !event.echo:
			if event.keycode == KEY_PAGEUP:
				oitava_offset = clamp(oitava_offset + 12, -24, 24)
				print("Oitava:", oitava_offset / 12)
				return

			if event.keycode == KEY_PAGEDOWN:
				oitava_offset = clamp(oitava_offset - 12, -24, 24)
				print("Oitava:", oitava_offset / 12)
				return
	if event is InputEventKey and teclas.has(event.keycode):
		var nota: int = clamp(
		teclas[event.keycode] + oitava_offset,
		21,
		108
		)
		# Tecla pressionada
		if event.pressed and !event.echo:

			if !teclas_pressionadas.has(nota):

				teclas_pressionadas[nota] = true

				var midi_event := InputEventMIDI.new()
				midi_event.channel = 0
				midi_event.pitch = nota
				midi_event.velocity = 127
				midi_event.message = MIDI_MESSAGE_NOTE_ON

				midi_player.receive_raw_midi_message(midi_event)

		# Tecla solta
		elif !event.pressed:

			teclas_pressionadas.erase(nota)

			var midi_event := InputEventMIDI.new()
			midi_event.channel = 0
			midi_event.pitch = nota
			midi_event.velocity = 0
			midi_event.message = MIDI_MESSAGE_NOTE_OFF

			midi_player.receive_raw_midi_message(midi_event)



func interact(player: Player):
	if tocando_piano:
		return
	player_in_scene = player
	tocando_piano = true
	player.global_position = marker_position.global_position
	player.can_move = false
	player.can_open_menu = false
	tocar_minecraft_sweden()
	
func sair_do_piano():
	if player_in_scene:
		player_in_scene.can_move = true
		player_in_scene.can_open_menu = true
	tocando_piano = false
	player_in_scene = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
	
func tocar_acorde_duracao(notas:Array, duracao:float):
	for nota in notas:
		var on := InputEventMIDI.new()
		on.channel = 0
		on.pitch = nota
		on.velocity = 90
		on.message = MIDI_MESSAGE_NOTE_ON
		midi_player.receive_raw_midi_message(on)
	
	await get_tree().create_timer(duracao).timeout
	
	for nota in notas:
		var off := InputEventMIDI.new()
		off.channel = 0
		off.pitch = nota
		off.velocity = 0
		off.message = MIDI_MESSAGE_NOTE_OFF
		midi_player.receive_raw_midi_message(off)


func tocar_nota_duracao(nota:int, duracao:float):
	var on := InputEventMIDI.new()
	on.channel = 0
	on.pitch = nota
	on.velocity = 110
	on.message = MIDI_MESSAGE_NOTE_ON
	midi_player.receive_raw_midi_message(on)
	
	await get_tree().create_timer(duracao).timeout
	
	var off := InputEventMIDI.new()
	off.channel = 0
	off.pitch = nota
	off.velocity = 0
	off.message = MIDI_MESSAGE_NOTE_OFF
	midi_player.receive_raw_midi_message(off)


# Toca melodia e acorde ao mesmo tempo, sem bloquear um pelo outro
func tocar_camada(melodia:Array, acordes:Array):
	var t_melodia = await _tocar_sequencia_melodia(melodia)
	var t_acordes =  await _tocar_sequencia_acordes(acordes)
	await t_melodia
	await t_acordes


func _tocar_sequencia_melodia(seq:Array):
	for item in seq:
		var nota = item[0]
		var dur = item[1]
		if nota == 0:
			await get_tree().create_timer(dur).timeout
		else:
			await tocar_nota_duracao(nota, dur)


func _tocar_sequencia_acordes(seq:Array):
	for item in seq:
		var notas = item[0] # array de notas, ou [] para pausa
		var dur = item[1]
		if notas.is_empty():
			await get_tree().create_timer(dur).timeout
		else:
			await tocar_acorde_duracao(notas, dur)


func tocar_minecraft_sweden():
	# SUBSTITUA pelos valores de uma transcrição real
	var melodia = [
		[76, 1.0], [79, 1.0], [81, 1.0], [79, 1.0],
	]
	var acordes = [
		[[60, 64, 67], 1.0], # C
		[[57, 60, 64], 1.0], # Am
		[[53, 57, 60], 1.0], # F
		[[55, 59, 62], 1.0], # G
	]
	await tocar_camada(melodia, acordes)
