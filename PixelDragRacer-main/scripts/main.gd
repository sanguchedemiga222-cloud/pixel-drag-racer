extends Node2D

@onready var car = $Car
@onready var speed_label = $UI/VelocidadLabel
@onready var gear_label = $UI/MarchaLabel
@onready var rpm_label = $UI/RPMLbl

func _ready():
	print("¡Juego iniciado!")

func _process(delta):
	# Actualizar HUD en tiempo real
	var current_speed = car.get_current_speed()
	var current_gear = car.get_current_gear()
	var current_rpm = car.get_current_rpm()
	
	speed_label.text = "Velocidad: %d km/h" % current_speed
	gear_label.text = "Marcha: %d" % current_gear
	rpm_label.text = "RPM: %d" % current_rpm
