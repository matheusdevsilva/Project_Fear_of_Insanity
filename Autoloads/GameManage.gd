extends Node

# lista de cenas
enum NameScenes{PLAYER,UI_HUDPLAYYER,UI_PLAYERMENU,LOBBY,UI_MAINMENU,LOADING}
var scenes:Dictionary[NameScenes,PackedScene] = {
	NameScenes.PLAYER: preload("res://Player/Player.tscn"),
	NameScenes.LOBBY: preload("res://Scenes/Lobby/Lobby.tscn"),
	NameScenes.LOADING:preload("res://Scenes/UI/Loading/Loading.tscn"),
	NameScenes.UI_HUDPLAYYER:preload("res://Player/UI/Hud.tscn"),
	NameScenes.UI_PLAYERMENU:preload("res://Player/UI/Menu.tscn")
	
}
# cena atual
var current_scene:Node
var target_scene:NameScenes

# inicializando a cena atual
func _ready() -> void:
	current_scene = get_tree().current_scene

# carregar uma cena	
func load_scene(scene:NameScenes) -> Node:
	if scene not in scenes:
		return null
	return scenes[scene].instantiate()
	
## troca de cena
func change_scene(scene:NameScenes) -> void:
	if not scene in scenes:
		return 
	target_scene = scene
	get_tree().change_scene_to_packed(scenes[NameScenes.LOADING])
	await get_tree().process_frame
	GameManage.current_scene = get_tree().current_scene
	
	

		
