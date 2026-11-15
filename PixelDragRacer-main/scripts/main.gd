extends Node2D

@onready var car: CharacterBody2D = $Car
@onready var rival: Node2D = $Rival
@onready var speed_label: Label = $UI/VelocidadLabel
@onready var gear_label: Label = $UI/MarchaLabel
@onready var rpm_label: Label = $UI/RPMLbl
@onready var finish_label: Label = $UI/FinishLabel

var rival_speed := 0.0
var rival_target_speed := 0.0
var rival_max_speed := 0.0
var rival_acceleration := 0.0
var rival_change_timer := 0.0
var race_finished := false
const FINISH_X := 3950.0

func _ready() -> void:
	# Cada carrera genera un rival con ritmo y velocidad máxima distintos.
	randomize()
	rival_max_speed = randf_range(220.0, 320.0)
	rival_acceleration = randf_range(140.0, 230.0)
	choose_rival_target_speed()
	print("¡Juego iniciado!")

func _process(delta: float) -> void:
	if race_finished or not is_instance_valid(car) or not is_instance_valid(rival):
		return

	# P2 varía su ritmo durante la carrera en vez de mantener siempre la misma velocidad.
	rival_change_timer -= delta
	if rival_change_timer <= 0.0:
		choose_rival_target_speed()

	if rival_speed < rival_target_speed:
		rival_speed = minf(rival_speed + rival_acceleration * delta, rival_target_speed)
	else:
		rival_speed = maxf(rival_speed - rival_acceleration * 0.65 * delta, rival_target_speed)
	rival.position.x += rival_speed * delta

	# Actualizar el HUD de P1.
	speed_label.text = "Velocidad: %d km/h" % car.get_current_speed()
	gear_label.text = "Marcha: %d" % car.get_current_gear()
	rpm_label.text = "RPM: %d" % car.get_current_rpm()

	if car.global_position.x >= FINISH_X:
		finish_race("P1")
	elif rival.global_position.x >= FINISH_X:
		finish_race("P2")

func choose_rival_target_speed() -> void:
	# Los cambios de ritmo ocurren cada pocos segundos y varían entre partidas.
	rival_target_speed = randf_range(rival_max_speed * 0.72, rival_max_speed)
	rival_change_timer = randf_range(1.5, 3.5)

func finish_race(winner: String) -> void:
	race_finished = true
	finish_label.text = "¡FIN DE LA CARRERA!\n¡%s ganó!" % winner
	finish_label.show()
	get_tree().paused = true
