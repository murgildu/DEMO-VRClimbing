extends XRToolsClimbable
class_name UnstableRockClimb

@onready var fall_timer: Timer = $fallTimer
# Obtenemos referencias a la malla y la colisión basándonos en tu imagen
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var grabbers: int = 0

func _ready() -> void:
	super._ready()
	
	if not fall_timer.timeout.is_connected(_on_fall_timer_timeout):
		fall_timer.timeout.connect(_on_fall_timer_timeout)

func pick_up(by: Node3D) -> void:
	super.pick_up(by)
	
	grabbers += 1
	if grabbers == 1:
		fall_timer.start(2.0)

func let_go(by: Node3D, p_linear_velocity: Vector3, p_angular_velocity: Vector3) -> void:
	super.let_go(by, p_linear_velocity, p_angular_velocity)
	
	grabbers -= 1
	if grabbers <= 0:
		grabbers = 0
		fall_timer.stop()

func _on_fall_timer_timeout() -> void:
	# 1. "Romper" la roca (desaparece visual y físicamente)
	mesh.hide()
	# Usamos set_deferred porque cambiar colisiones en medio de un frame de físicas puede dar error en Godot
	collision.set_deferred("disabled", true) 
	
	# Reseteamos los agarres porque el jugador acaba de caer
	grabbers = 0
	
	# 2. Esperar 5 segundos usando un temporizador rápido del árbol de la escena
	await get_tree().create_timer(5.0).timeout
	
	# 3. "Restaurar" la roca (vuelve a aparecer)
	# Verificamos que el nodo siga existiendo en la escena antes de reactivarlo (por si cambiaste de nivel)
	if is_inside_tree():
		mesh.show()
		collision.set_deferred("disabled", false)
