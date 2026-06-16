extends Node

signal avatar_loaded(texture: Texture2D)

var player_name: String
var player_avatar: Texture2D

const AppID = 480
var steam_peer:SteamMultiplayerPeer
var current_lobby_id
var lobby_name:String
var lobby_size:int
var lobby_type:Steam.LobbyType
var list_players = {}
var host_id
var is_joining:bool = false


func _ready() -> void:
	OS.set_environment("SteamAppID", str(AppID))
	OS.set_environment("SteamGameID", str(AppID))
	var init = Steam.steamInit(AppID, true)
	
	print("Steam iniciada: ", init)
	print(get_username())
	Steam.avatar_loaded.connect(_on_avatar_loaded)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joining)
	multiplayer.peer_connected.connect(on_peer_connected)
	
	Steam.allowP2PPacketRelay(true)
	load_player_data()
	

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	

func on_create_lobby(new_name:String,size:int,type:Steam.LobbyType):
	lobby_name = new_name
	lobby_size = size
	lobby_type = type
	Steam.createLobby(type,size)
	
func _on_lobby_created(connect: int,lobby_id: int):
	if connect != 1:
		print("Erro ao criar lobby")
		return
	steam_peer = SteamMultiplayerPeer.new()
	var result = steam_peer.create_host(0)
	print("HOST RESULT: ", result)
	if result != OK:
		print("Erro ao criar host")
		return
	multiplayer.multiplayer_peer = steam_peer
	current_lobby_id = lobby_id
	Steam.setLobbyData(lobby_id,"Lobby_name",lobby_name)
	Steam.setLobbyData(lobby_id,"Lobby_size",str(lobby_size))
	Steam.setLobbyData(lobby_id,"Lobby_type",str(lobby_type))
	Steam.setLobbyJoinable(lobby_id,true)
	print("Lobby cliado: ",lobby_id)
	await GameManage.change_scene(GameManage.NameScenes.LOBBY)

func on_join_lobby(lobby_id:int):
	print("Joining lobby id: ", lobby_id)
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	Steam.joinLobby(lobby_id)
	
func _on_lobby_joining(
	lobby: int,
	permissions: int,
	locked: bool,
	response: int
):
	print("======== JOIN LOBBY ========")

	print("Lobby ID: ", lobby)
	print("Permissions: ", permissions)
	print("Locked: ", locked)
	print("Response: ", response)

	if response != Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("Erro ao entrar no lobby")
		return

	print("Entrou no lobby Steam")

	current_lobby_id = lobby

	steam_peer = SteamMultiplayerPeer.new()

	print("SteamPeer criado")

	host_id = Steam.getLobbyOwner(lobby)

	print("Host ID: ", host_id)
	print("Meu Steam ID: ", Steam.getSteamID())
	
	if host_id != Steam.getSteamID():

		print("Tentando conectar ao host...")

		var result = steam_peer.create_client(
			host_id
		)

		print("CLIENT RESULT: ", result)

		if result != OK:
			print("Erro ao criar client")
			return

		print("Client criado com sucesso")

		multiplayer.multiplayer_peer = steam_peer

		print("Multiplayer peer definido")

		print("Esperando conexão com servidor...")

		await multiplayer.connected_to_server

		print("Conectado ao servidor")

		print("Trocando para cena lobby...")

		await GameManage.change_scene(
			GameManage.NameScene.LOBBY
		)

		print("Cena lobby carregada")
	

func on_peer_connected(id:int):
	print("Peer conectado: ", id)
	if multiplayer.is_server():
		for peer_id in list_players.keys():
			spawn_player.rpc_id(id, peer_id)
		spawn_player.rpc(id)

@rpc("authority", "call_local")
func spawn_player(id: int):
	create_player(id)
	

func get_lobby_list() -> Array:
	print("Enviando requisição de lista para a Steam...")
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
	var list_lobby = await Steam.lobby_match_list
	print("Lista recebida com sucesso! Total de lobbies: ", list_lobby.size())
	return list_lobby

func create_player(id: int):
	if list_players.has(id):
		return
	var player = GameManage.load_scene(GameManage.NameScenes.PLAYER)
	var steam_id = Steam.getSteamID()
	player.name = str(id)
	player.username_steam = Steam.getFriendPersonaName(steam_id)
	list_players[id] = player
	get_tree().current_scene.add_child(player)
	
	
	

func load_player_data():
	var steam_id = Steam.getSteamID()
	player_name = Steam.getFriendPersonaName(steam_id)
	Steam.getPlayerAvatar(Steam.AVATAR_MEDIUM,steam_id)
	
func _on_avatar_loaded(user_id: int,size: int,buffer: PackedByteArray):
	var image = Image.create_from_data(size,size,false,Image.FORMAT_RGBA8,buffer)
	player_avatar = ImageTexture.create_from_image(image)
	avatar_loaded.emit(player_avatar)
	
func invite_friends():
	if not current_lobby_id:
		return
	Steam.activateGameOverlayInviteDialog(current_lobby_id)
func get_username() -> String:
	return Steam.getPersonaName()
func get_steam_id() -> int:
	return Steam.getSteamID()
