extends Control

@onready var list_buttons_multiplayer:VBoxContainer = $ListButtonsMultiplayer

var current_menu:Control

func _on_button_play_offline_pressed() -> void:
	GameManage.change_scene(GameManage.NameScenes.LOBBY)
	pass # Replace with function body.


func _on_button_multiplayer_pressed() -> void:
	list_buttons_multiplayer.visible = !list_buttons_multiplayer.visible
	pass # Replace with function body.


func _on_button_settings_pressed() -> void:
	pass # Replace with function body.


func _on_button_credits_pressed() -> void:
	pass # Replace with function body.


func _on_button_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

	

func _on_button_host_game_pressed() -> void:
	SteamManage.on_create_lobby("Server",2,Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY)
	


func _on_button_join_game_pressed() -> void:
	pass # Replace with function body.
