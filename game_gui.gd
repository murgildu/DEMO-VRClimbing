extends Panel

@onready var button_start = $buttonStart
@onready var button_minimize = $ButtonMinimize

var timer_manager

func _ready():
	timer_manager = get_node("/root/main/TimerManager")	
	
	if timer_manager:
		timer_manager.game_ui_node = self
		
		button_start.pressed.connect(_on_start_pressed)
		button_minimize.pressed.connect(_on_minimize_pressed)

func _on_start_pressed():
	if timer_manager:
		timer_manager.start_game_sequence(button_start)

func _on_minimize_pressed():
	var is_minimized = !button_start.visible
	
	if not is_minimized: 
		button_start.visible = false
		self_modulate.a = 0.0 
		button_minimize.text = "+" 
		mouse_filter = Control.MOUSE_FILTER_IGNORE 
	else: 
		button_start.visible = true
		self_modulate.a = 1.0 
		button_minimize.text = "_" 
		mouse_filter = Control.MOUSE_FILTER_STOP

func reset_ui_state():
	button_start.text = "Start Game"
	button_start.disabled = false
	button_start.visible = true
	
	self.visible = true
	self_modulate.a = 1.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	button_minimize.text = "_"
