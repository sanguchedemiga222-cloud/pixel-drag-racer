extends CharacterBody2D

@export var racer_tag: String = "P1"

# Velocidad y aceleración en unidades de Godot (get_current_speed convierte a km/h).
var speed := 0.0
var max_speed := 250.0
var acceleration := 300.0
var friction := 200.0
var is_accelerating := false
var is_braking := false

# Cambios manuales: SHIFT sube y CTRL derecho baja.
var current_gear := 0
var max_gears := 4
var gear_rpm := 0.0
var max_rpm := 8000.0

func _ready() -> void:
	$Tag.text = racer_tag
	print("Auto listo - ¡Comenzando carrera de velocidad!")

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return

	if event.keycode == KEY_SHIFT:
		shift_up()
	elif event.keycode == KEY_CTRL and event.location == KEY_LOCATION_RIGHT:
		shift_down()

func _physics_process(delta: float) -> void:
	handle_input()
	update_speed(delta)
	velocity = Vector2(speed, 0.0)
	move_and_slide()

func handle_input() -> void:
	is_accelerating = Input.is_action_pressed("ui_up")
	is_braking = Input.is_action_pressed("ui_down")

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

	var gear_max_speed = max_speed + (current_gear * 50.0)
	gear_rpm = minf((speed / gear_max_speed) * max_rpm, max_rpm)

func shift_up() -> void:
	if current_gear < max_gears - 1:
		current_gear += 1
		print("Cambio manual a marcha %d" % (current_gear + 1))

func shift_down() -> void:
	if current_gear > 0:
		current_gear -= 1
		print("Cambio manual a marcha %d" % (current_gear + 1))

func get_current_speed() -> int:
	return int(speed / 2.5)

func get_current_gear() -> int:
	return current_gear + 1

func get_current_rpm() -> int:
	return int(gear_rpm)
