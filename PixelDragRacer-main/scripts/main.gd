extends Node2D

@onready var car: CharacterBody2D = $Car
@onready var rival: Node2D = $Rival
@onready var speed_label: Label = $UI/VelocidadLabel
@onready var gear_label: Label = $UI/MarchaLabel
@onready var rpm_label: Label = $UI/RPMLbl
@onready var finish_label: Label = $UI/FinishLabel

var rival_speed := 0.0
var race_finished := false
const RIVAL_ACCELERATION := 220.0
const RIVAL_MAX_SPEED := 250.0
const FINISH_X := 3950.0

func _ready() -> void:
	print("¡Juego iniciado!")

func _process(delta: float) -> void:
	if race_finished or not is_instance_valid(car) or not is_instance_valid(rival):
		return

	# P2 acelera automáticamente por el carril superior.
	rival_speed = minf(rival_speed + RIVAL_ACCELERATION * delta, RIVAL_MAX_SPEED)
	rival.position.x += rival_speed * delta

	# Actualizar el HUD de P1.
	speed_label.text = "Velocidad: %d km/h" % car.get_current_speed()
	gear_label.text = "Marcha: %d" % car.get_current_gear()
	rpm_label.text = "RPM: %d" % car.get_current_rpm()

	# Terminar y pausar la carrera cuando cualquiera cruce la meta.
	if car.global_position.x >= FINISH_X:
		finish_race("P1")
	elif rival.global_position.x >= FINISH_X:
		finish_race("P2")

func finish_race(winner: String) -> void:
	race_finished = true
	finish_label.text = "¡FIN DE LA CARRERA!\n¡%s ganó!" % winner
	finish_label.show()
	get_tree().paused = true
