extends CharacterBody2D

# Variables de movimiento
var speed = 0.0
var max_speed = 250.0
var acceleration = 300.0
var friction = 200.0

# Variables de entrada
var is_accelerating = false
var is_braking = false

# Dimensiones del coche
var car_width = 60.0
var car_height = 40.0

# Variables para el cambio de marcha
var current_gear = 0
var max_gears = 4
var gear_rpm = 0.0
var max_rpm = 8000.0

func _ready():
	print("Auto listo - ¡Comenzando carrera de velocidad!")

func _physics_process(delta):
	handle_input()
	update_speed(delta)
	update_gear()
	
	# Aplicar velocidad solo en X (horizontal)
	velocity.x = speed
	velocity.y = 0
	move_and_slide()

func handle_input():
	"""Maneja la entrada del jugador"""
	is_accelerating = Input.is_action_pressed("ui_up")
	is_braking = Input.is_action_pressed("ui_down")
	
	# Cambio de marcha manual con SPACE
	if Input.is_action_just_pressed("ui_accept"):
		shift_up()

func update_speed(delta):
	"""Actualiza la velocidad basado en aceleración y fricción"""
	
	if is_accelerating:
		# Acelerar
		var current_acceleration = acceleration
		
		# Las marchas superiores aceleran más rápido
		if current_gear > 0:
			current_acceleration = acceleration + (current_gear * 50)
		
		speed += current_acceleration * delta
		
		# Limitar velocidad según la marcha
		var gear_max_speed = max_speed + (current_gear * 50)
		speed = min(speed, gear_max_speed)
		
	elif is_braking:
		# Frenar
		speed -= friction * 3 * delta
		if speed < 0:
			speed = 0
	else:
		# Fricción natural
		speed -= friction * delta
		if speed < 0:
			speed = 0
	
	# Actualizar RPM basado en velocidad
	gear_rpm = (speed / max_speed) * max_rpm

func update_gear():
	"""Sistema de cambio de marcha automático"""
	if gear_rpm >= max_rpm * 0.95 and current_gear < max_gears - 1:
		shift_up()
	
	if gear_rpm < max_rpm * 0.3 and current_gear > 0:
		shift_down()

func shift_up():
	"""Cambiar a marcha superior"""
	if current_gear < max_gears - 1:
		current_gear += 1
		gear_rpm = max_rpm * 0.3
		print("Cambio a marcha %d" % (current_gear + 1))

func shift_down():
	"""Cambiar a marcha inferior"""
	if current_gear > 0:
		current_gear -= 1
		gear_rpm = max_rpm * 0.3
		print("Cambio a marcha %d" % (current_gear + 1))

func get_current_speed():
	"""Retorna la velocidad actual en km/h realista"""
	return int(speed / 2.5)

func get_current_gear():
	"""Retorna la marcha actual"""
	return current_gear + 1

func get_current_rpm():
	"""Retorna el RPM actual"""
	return int(gear_rpm)
