extends Node3D

@export_group("Interface")
@export var hud_meter_label: Label3D
@export var hud_timer_label: Label3D       
@export var game_ui_node: Node 
@export var game_over_label: Label3D       

@export_group("Movement Control")
@export var climb_node: Node  
@export var flight_node: Node 

@export_group("Player position")
@export var xr_origin_3d: XROrigin3D

var time_elapsed: float = 0.0
var is_running: bool = false
var has_fallen: bool = false 
var max_height: float = 0.0

func _process(delta):
	if is_running:
		time_elapsed += delta
		update_display()
		update_has_fallen()
		
func update_has_fallen():
	var current_y = xr_origin_3d.global_position.y
	
	if current_y > max_height:
		max_height = current_y
		
	if is_running and (max_height - current_y) > 2.0:
		has_fallen = true

func update_display():
	var mins = int(time_elapsed) / 60.0
	var secs = int(time_elapsed) % 60
	var cents = int((time_elapsed - int(time_elapsed)) * 100)
		
	var time_text = "%02d:%02d:%02d" % [mins, secs, cents]
	
	if has_fallen:
		game_over_label.visible = true
		hud_meter_label.text = "Max height: " + str(snapped(max_height, 0.1)) + "m"
		
		stop_timer()
		set_climbing_enabled(false)
		set_flight_enabled(false)
		
	else:
		if hud_timer_label:
			hud_timer_label.text = time_text
	
		if hud_meter_label and xr_origin_3d:
			hud_meter_label.text = str(snapped(xr_origin_3d.global_position.y, 0.1)) + "m"	

func start_game_sequence(button_ref: Button):
	set_climbing_enabled(false)
	set_flight_enabled(false)
	has_fallen = false
	
	for i in range(5, 0, -1):
		if button_ref: button_ref.text = str(i) 
		await get_tree().create_timer(1.0).timeout
	
	if button_ref: button_ref.text = "GO!"
	start_timer()
	
	set_climbing_enabled(true) 
	set_flight_enabled(false)  
	
	if game_ui_node:
		game_ui_node.visible = false

func start_timer(_button = null):
	is_running = true

func stop_timer(_button = null):
	is_running = false

func reset_timer(_button = null):
	is_running = false
	has_fallen = false
	game_over_label.visible = false
	time_elapsed = 0.0
	
	if xr_origin_3d:
		max_height = xr_origin_3d.global_position.y
	else:
		max_height = 0.0
		
	update_display()
	
	set_climbing_enabled(true)
	set_flight_enabled(true)
	
	if game_ui_node:
		game_ui_node.visible = true
		if game_ui_node.has_method("reset_ui_state"):
			game_ui_node.reset_ui_state()

func set_climbing_enabled(enabled: bool):
	if climb_node: climb_node.enabled = enabled

func set_flight_enabled(enabled: bool):
	if flight_node: flight_node.enabled = enabled
