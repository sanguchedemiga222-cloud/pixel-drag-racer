extends CharacterBody2D

@export var racer_tag: String = "P1"

# Variables de movimiento del jugador
var speed := 0.0
var max_speed := 250.0
var acceleration := 300.0
var friction := 200.0
var is_accelerating := false
var is_braking := false

# Variables de cambio de marcha
var current_gear := 0
var max_gears := 4
var gear_rpm := 0.0
var max_rpm := 8000.0

func _ready() -> void:
	$Tag.text = racer_tag
	print("Auto listo - ¡Comenzando carrera de velocidad!")

func _physics_process(delta: float) -> void:
	handle_input()
	update_speed(delta)
	update_gear()
	velocity = Vector2(speed, 0.0)
	move_and_slide()

func handle_input() -> void:
	is_accelerating = Input.is_action_pressed("ui_up")
	is_braking = Input.is_action_pressed("ui_down")
	if Input.is_action_just_pressed("ui_accept"):
		shift_up()

func update_speed(delta: float) -> void:
	if is_accelerating:
		var current_acceleration = acceleration
		if current_gear > 0:
			current_acceleration += current_gear * 50.0
		speed += current_acceleration * delta
		var gear_max_speed = max_speed + (current_gear * 50.0)
		speed = minf(speed, gear_max_speed)
	elif is_braking:
		speed = maxf(0.0, speed - friction * 3.0 * delta)
	else:
		speed = maxf(0.0, speed - friction * delta)
	gear_rpm = (speed / max_speed) * max_rpm

func update_gear() -> void:
	if gear_rpm >= max_rpm * 0.95 and current_gear < max_gears - 1:
		shift_up()
	if gear_rpm < max_rpm * 0.3 and current_gear > 0:
		shift_down()

func shift_up() -> void:
	if current_gear < max_gears - 1:
		current_gear += 1
		gear_rpm = max_rpm * 0.3
		print("Cambio a marcha %d" % (current_gear + 1))

func shift_down() -> void:
	if current_gear > 0:
		current_gear -= 1
		gear_rpm = max_rpm * 0.3
		print("Cambio a marcha %d" % (current_gear + 1))

func get_current_speed() -> int:
	return int(speed / 2.5)

func get_current_gear() -> int:
	return current_gear + 1

func get_current_rpm() -> int:
	return int(gear_rpm)
