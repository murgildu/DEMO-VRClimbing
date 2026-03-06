extends XRToolsClimbable
class_name UnstableRockClimb

@onready var fall_timer: Timer = $fallTimer
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

# En lugar de un número, guardamos una lista de las manos (nodos) que agarran la roca
var current_grabbers: Array[Node3D] = []

func _ready() -> void:
	super._ready()
	
	if not fall_timer.timeout.is_connected(_on_fall_timer_timeout):
		fall_timer.timeout.connect(_on_fall_timer_timeout)

func pick_up(by: Node3D) -> void:
	super.pick_up(by)
	
	# Añadimos la mano a nuestra lista si no estaba ya
	if not current_grabbers.has(by):
		current_grabbers.append(by)
		
	# Si es la primera mano en agarrarse, iniciamos el contador
	if current_grabbers.size() == 1:
		fall_timer.start(2.0)

func let_go(by: Node3D, p_linear_velocity: Vector3, p_angular_velocity: Vector3) -> void:
	super.let_go(by, p_linear_velocity, p_angular_velocity)
	
	# Quitamos la mano de nuestra lista
	current_grabbers.erase(by)
	
	# Si ya nadie nos agarra, paramos el contador
	if current_grabbers.is_empty():
		fall_timer.stop()

func _on_fall_timer_timeout() -> void:
	# 1. FORZAR LA CAÍDA: Obligamos a todas las manos a soltarse.
	# Hacemos una copia del array (.duplicate()) porque al soltar, 
	# el XRTools llamará a let_go() y borrará elementos de la lista original.
	var grabbers_copy = current_grabbers.duplicate()
	for grabber in grabbers_copy:
		# La función en XRToolsFunctionPickup para soltar algo es drop_object()
		if grabber.has_method("drop_object"):
			grabber.drop_object()
	
	# 2. "Romper" la roca (desaparece visual y físicamente)
	mesh.hide()
	collision.set_deferred("disabled", true) 
	
	# 3. Esperar 5 segundos usando un temporizador rápido del árbol de la escena
	await get_tree().create_timer(5.0).timeout
	
	# 4. "Restaurar" la roca (vuelve a aparecer)
	if is_inside_tree():
		mesh.show()
		collision.set_deferred("disabled", false)
