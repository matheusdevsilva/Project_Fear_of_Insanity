extends Node

var current_menu: Control = null

func open_menu(menu: Control) -> void:
	if current_menu and current_menu != menu:
		await current_menu.hide_menu()

	current_menu = menu
	current_menu.show_menu()

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close_menu() -> void:
	if current_menu:
		await current_menu.hide_menu()
		current_menu = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func toggle_menu(menu: Control) -> void:
	if current_menu == menu:
		await close_menu()
	else:
		await open_menu(menu)

func is_menu_open() -> bool:
	return current_menu != null
