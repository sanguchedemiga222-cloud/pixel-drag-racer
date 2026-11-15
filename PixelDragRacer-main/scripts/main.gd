extends Node2D

@onready var car: CharacterBody2D = $Car
@onready var rival: Node2D = $Rival
@onready var ui: CanvasLayer = $UI
@onready var speed_label: Label = $UI/VelocidadLabel
@onready var gear_label: Label = $UI/MarchaLabel
@onready var rpm_label: Label = $UI/RPMLbl

var rival_speed := 0.0
var rival_target_speed := 0.0
var rival_max_speed := 0.0
var rival_acceleration := 0.0
var rival_change_timer := 0.0
var race_started := false
var race_finished := false
var start_screen: ColorRect
var finish_screen: ColorRect
var countdown_label: Label

const FINISH_X := 3950.0

func _ready() -> void:
	randomize()
	car.set_controls_enabled(false)
	configure_rival_for_new_race()
	start_screen = create_screen("¡PIXEL DRAG RACER!", "Jugar", start_race)
	countdown_label = Label.new()
	countdown_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.add_theme_font_size_override("font_size", 56)
	countdown_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	countdown_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	countdown_label.add_theme_constant_override("outline_size", 8)
	countdown_label.hide()
	ui.add_child(countdown_label)

func _process(delta: float) -> void:
	if not race_started or race_finished or not is_instance_valid(car) or not is_instance_valid(rival):
		return

	# P2 varía su ritmo durante la carrera y también entre partidas.
	rival_change_timer -= delta
	if rival_change_timer <= 0.0:
		choose_rival_target_speed()
	if rival_speed < rival_target_speed:
		rival_speed = minf(rival_speed + rival_acceleration * delta, rival_target_speed)
	else:
		rival_speed = maxf(rival_speed - rival_acceleration * 0.65 * delta, rival_target_speed)
	rival.position.x += rival_speed * delta

	speed_label.text = "Velocidad: %d km/h" % car.get_current_speed()
	gear_label.text = "Marcha: %d" % car.get_current_gear()
	rpm_label.text = "RPM: %d" % car.get_current_rpm()

	if car.global_position.x >= FINISH_X:
		finish_race("P1")
	elif rival.global_position.x >= FINISH_X:
		finish_race("P2")

func start_race() -> void:
	start_screen.hide()
	countdown_label.show()
	for number in [3, 2, 1]:
		countdown_label.text = "Comienza en: %d" % number
		await get_tree().create_timer(1.0).timeout
	countdown_label.text = "¡YA!"
	await get_tree().create_timer(0.6).timeout
	countdown_label.hide()
	race_started = true
	car.set_controls_enabled(true)

func configure_rival_for_new_race() -> void:
	rival_speed = 0.0
	rival_max_speed = randf_range(220.0, 320.0)
	rival_acceleration = randf_range(140.0, 230.0)
	choose_rival_target_speed()

func choose_rival_target_speed() -> void:
	rival_target_speed = randf_range(rival_max_speed * 0.72, rival_max_speed)
	rival_change_timer = randf_range(1.5, 3.5)

func finish_race(winner: String) -> void:
	race_finished = true
	race_started = false
	car.set_controls_enabled(false)
	finish_screen = create_screen("¡FIN DE LA CARRERA!\n¡%s ganó!" % winner, "Reiniciar", restart_race)

func restart_race() -> void:
	get_tree().reload_current_scene()

func create_screen(title_text: String, button_text: String, action: Callable) -> ColorRect:
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.82)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 220)
	center.add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 24)
	panel.add_child(layout)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 32)
	layout.add_child(title)

	var button := Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(180, 52)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(action)
	layout.add_child(button)

	return overlay
