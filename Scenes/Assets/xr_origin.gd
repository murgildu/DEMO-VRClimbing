extends XROrigin3D

var interface : XRInterface

# Comentamos la variable por ahora para que no dé error
# @onready var progress_bar = $SubViewport/ProgressBar
@export var meta_metros: float = 18

var altura_inicial: float = 0.0

func _ready():
	altura_inicial = global_position.y
	
	# Comentamos la configuración inicial de la barra
	# progress_bar.max_value = meta_metros
	# progress_bar.value = 0
	
	interface = XRServer.find_interface("OpenXR")
	if interface and interface.is_initialized():
		get_viewport().use_xr = true

func _process(_delta):
	var metros_subidos = global_position.y - altura_inicial
	
	# Comentamos la actualización de la barra
	# progress_bar.value = max(0, metros_subidos)
	
	# Adaptamos tu condición para que funcione sin la barra de progreso
	if metros_subidos >= meta_metros:
		print("¡Cima alcanzada!")
