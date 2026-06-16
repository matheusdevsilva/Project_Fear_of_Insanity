extends Node3D


#func _ready() -> void:
#	add_child(GameManage.load_scene(GameManage.NameScenes.PLAYER))
	
func _ready():
	print("Lobby carregado")
	if multiplayer.is_server():
		SteamManage.spawn_player.rpc(multiplayer.get_unique_id())


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.global_position = $Marker3D.global_position
	pass # Replace with function body.
