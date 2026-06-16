extends CharacterBody3D
class_name Player

@export var speed := 6.0
@export var run_speed := 8.5
@export var accel := 12.0

@export var mouse_sens := 0.002
@export var jump_force := 4.5
@export var jump_hold_time := 0.2
@export var jump_cut_multiplier := 0.5
@export var jump_sprint_multiplier := 1.1
@export var air_control := 0.

@export var stand_height := 1.8
@export var crouch_height := 0.9
@export var stand_camera_y := 0.0
@export var crouch_camera_y := -0.6

@export var jump_kick_strength := 0.15
@export var land_kick_strength := 0.25
@export var cam_return_speed := 8.

@export var stamina_max := 100.0
@export var stamina_recovery := 10.0
@export var stamina_drain := 10.0
@export var stamina_recover_limit := 50.0

@export var base_fov := 75.0
@export var run_fov := 95.0
@export var fov_speed := 8.0

@export var tilt_amount := 0.08
@export var tilt_speed := 6
@export var steam_id = ""
@export var username_steam = ""

var jump_time := 0.0
var stamina := 100.0
var current_speed := 0.0
var exhausted:= false
var is_running:bool= false
var is_crouching :bool = false
var is_jumping := false
var can_move:bool = true
var can_open_menu:bool = true


var current_menu: Control = null
var cam_impact := 0.0
var was_on_floor := true
var bob_time := 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var hud = GameManage.load_scene(GameManage.NameScenes.UI_HUDPLAYYER)
@onready var menu = GameManage.load_scene(GameManage.NameScenes.UI_PLAYERMENU)
@onready var pivot:Node3D = $Pivot
@onready var collision:CollisionShape3D = $CollisionShape3D
@onready var camera:Camera3D = $Pivot/Camera3D
@onready var ray:RayCast3D = $Pivot/Camera3D/RayCast3D
@onready var audio:AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var label_name_player:Label3D = $NamePlayer


func _ready():
	hud.player = self
	menu.player = self
	add_child(hud)
	add_child(menu)
	menu.hide()
	label_name_player.text = name
	stamina = stamina_max
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if Input.is_action_just_pressed("ui_cancel") and can_open_menu:
		MenuManage.toggle_menu(menu)
		return
	if MenuManage.is_menu_open():
		return
		
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sens)
		pivot.rotation.x -= event.relative.y * mouse_sens
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
func update_stamina(delta: float, direction: Vector3) -> void:
	if stamina <= 0:
		exhausted = true
	if exhausted and stamina >= stamina_recover_limit:
		exhausted = false
	is_running = Input.is_action_pressed("run") \
		and direction != Vector3.ZERO \
		and !exhausted
	if is_running:
		stamina -= stamina_drain * delta
	else:
		if direction == Vector3.ZERO:
			stamina += stamina_recovery * 1.5 * delta
		else:
			stamina += stamina_recovery * delta
	stamina = clamp(stamina, 0.0, stamina_max)
	
func handle_movement(delta: float, direction: Vector3) -> void:
	
	var target_speed = run_speed if is_running else speed
	if is_crouching:
		target_speed = speed * 0.4
	else:
		target_speed = run_speed if is_running else speed
	current_speed = lerp(current_speed, target_speed, 5.0 * delta)
	
	var target_velocity = direction * current_speed
	if is_on_floor():
		velocity.x = move_toward(velocity.x, target_velocity.x, accel * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, accel * delta)
	else:
		air_control = 0.6
		velocity.x = lerp(velocity.x, target_velocity.x, accel * air_control * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, accel * air_control * delta)

	move_and_slide()

func handle_jump(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor() and Input.is_action_just_pressed("jump") and !is_crouching:
		var final_jump_force = jump_force
		if is_running:
			final_jump_force *= jump_sprint_multiplier
		velocity.y = final_jump_force

		is_jumping = true
		jump_time = jump_hold_time


	if is_jumping and Input.is_action_pressed("jump") and jump_time > 0:
		velocity.y += jump_force * 1.5 * delta
		jump_time -= delta
	if Input.is_action_just_released("jump") and velocity.y > 0:
		velocity.y *= 0.5
		is_jumping = false
	if is_on_floor():
		is_jumping = false
	
func handle_camera(delta: float, direction: Vector3) -> void:
	if direction != Vector3.ZERO and is_on_floor():
		var bob_speed = 10.0 if is_running else 6.0
		var bob_amount = 0.1 if is_running else 0.05
		bob_time += delta * bob_speed
		camera.position.x = cos(bob_time) * bob_amount * 0.5
		camera.position.y = sin(bob_time * 2.0) * bob_amount
	else:
		camera.position.x = lerp(camera.position.x, 0.0, 8.0 * delta)
		camera.position.y = lerp(camera.position.y, 0.0, 8.0 * delta)
		
	var target_fov = run_fov if is_running else base_fov
	camera.fov = lerp(camera.fov, target_fov, fov_speed * delta)

	var input_dir := Input.get_vector("walk_left","walk_right","walk_up","walk_down")
	var tilt_target = -input_dir.x * tilt_amount
	pivot.rotation.z = lerp(
		pivot.rotation.z,
		tilt_target,
		tilt_speed * delta
	)
	
func _physics_process(delta):
	if MenuManage.is_menu_open():
		return 
	if !can_move:
		velocity = Vector3.ZERO
		return
	var input_dir := Input.get_vector(
		"walk_left",
		"walk_right",
		"walk_up",
		"walk_down"
	)
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	update_stamina(delta, direction)
	handle_jump(delta)
	handle_ground(delta)
	handle_movement(delta, direction)
	handle_camera(delta, direction)
	handle_audio(direction)
	handle_raycast()
	
func handle_audio(dir: Vector3):
	if dir.length() > 0 and is_on_floor():
		if audio and not audio.playing:
			audio.play()
	else:
		if audio:
			audio.stop()

func handle_raycast():
	if ray.is_colliding():
		var obj = ray.get_collider()
		if obj:
			var piano = obj.get_parent()
			if piano and piano.has_method("interact"):
				if Input.is_action_just_pressed("interact"):
					piano.interact(self)
				
func handle_ground(delta):
	is_crouching = Input.is_action_pressed("crouch")
	var shape = collision.shape as CapsuleShape3D
	if is_crouching:
		camera.position.y = lerp(
			camera.position.y,
			crouch_camera_y,
			10.0 * delta
		)

		shape.height = lerp(
			shape.height,
			crouch_height,
			10.0 * delta
		)
	else:
		camera.position.y = lerp(
			camera.position.y,
			stand_camera_y,
			10.0 * delta
		)

		shape.height = lerp(
			shape.height,
			stand_height,
			10.0 * delta
		)

	
	
