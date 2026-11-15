extends CharacterBody2D

@export var racer_tag: String = "P1"

# La velocidad interna se expresa en km/h; se convierte a unidades de movimiento al mover el auto.
var speed := 0.0
var friction := 5.0
var braking_deceleration := 35.0
var is_accelerating := false
var is_braking := false
var controls_enabled := true

# Velocidad máxima por marcha. La quinta permite llegar a 250 km/h.
const GEAR_MAX_SPEEDS_KMH: Array[float] = [80.0, 125.0, 170.0, 210.0, 250.0]
# Aceleración decreciente en marchas altas para que la velocidad suba progresivamente.
const GEAR_ACCELERATION_KMH_PER_SEC: Array[float] = [18.0, 13.0, 9.0, 6.5, 4.5]

var current_gear := 0
var gear_rpm := 900.0
var max_rpm := 8000.0
const RPM_RESPONSE := 3500.0
const SPEED_TO_PIXELS := 2.5

func _ready() -> void:
	$Tag.text = racer_tag

func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	if not enabled:
		is_accelerating = false
		is_braking = false

func _input(event: InputEvent) -> void:
	if not controls_enabled or not event is InputEventKey or not event.pressed or event.echo:
		return

	if event.keycode == KEY_SHIFT:
		shift_up()
	elif event.keycode == KEY_CTRL and event.location == KEY_LOCATION_LEFT:
		shift_down()

func _physics_process(delta: float) -> void:
	if not controls_enabled:
		return
	handle_input()
	update_speed(delta)
	velocity = Vector2(speed * SPEED_TO_PIXELS, 0.0)
	move_and_slide()

func handle_input() -> void:
	is_accelerating = Input.is_action_pressed("ui_up")
	is_braking = Input.is_action_pressed("ui_down")

func update_speed(delta: float) -> void:
	if is_accelerating:
		speed += GEAR_ACCELERATION_KMH_PER_SEC[current_gear] * delta
		speed = minf(speed, GEAR_MAX_SPEEDS_KMH[current_gear])
	elif is_braking:
		speed = maxf(0.0, speed - braking_deceleration * delta)
	else:
		speed = maxf(0.0, speed - friction * delta)

	# Las RPM responden gradualmente y bajan al pasar a una marcha superior.
	var rpm_ratio := clampf(speed / GEAR_MAX_SPEEDS_KMH[current_gear], 0.0, 1.0)
	var target_rpm := lerpf(900.0, max_rpm, rpm_ratio)
	gear_rpm = move_toward(gear_rpm, target_rpm, RPM_RESPONSE * delta)

func shift_up() -> void:
	if current_gear < GEAR_MAX_SPEEDS_KMH.size() - 1:
		current_gear += 1
		print("Cambio manual a marcha %d" % (current_gear + 1))

func shift_down() -> void:
	if current_gear > 0:
		current_gear -= 1
		print("Cambio manual a marcha %d" % (current_gear + 1))

func get_current_speed() -> int:
	return int(speed)

func get_current_gear() -> int:
	return current_gear + 1

func get_current_rpm() -> int:
	return int(gear_rpm)
