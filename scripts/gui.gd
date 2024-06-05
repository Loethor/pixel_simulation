extends Control
class_name GUIInterface

@onready var menu: Control = $Menu
@onready var fps_label: Label = $FPSLabel
@onready var tooltip_label: Label = $TooltipLabel
@onready var hot_bar: HotBar = $PanelContainer/MarginContainer/HotBar
@onready var panel_container: PanelContainer = $PanelContainer
@onready var brush_size_indicator: GridContainer = $BrushSizeIndicator

signal hotbal_index_changed(current_material: Elements.ELEMENT)

var min_brush: int
var max_brush: int

# Brush settings
const MIN_BRUSH_SIZE: int = 1
const MAX_BRUSH_SIZE:int = 5
@export var brush_size: int = MIN_BRUSH_SIZE : set = set_brush
func set_brush(value: int) -> void:
	brush_size = clamp(value, MIN_BRUSH_SIZE, MAX_BRUSH_SIZE)
	_update_brush_size_colors()

func _ready() -> void:
	hot_bar.index_changed.connect(_on_hot_bar_index_changed)
	_prepare_brush_size_indicator()

func _process(_delta: float) -> void:
	fps_label.text = "%s" % Engine.get_frames_per_second()

func _on_hot_bar_index_changed(current_material: Elements.ELEMENT) -> void:
	# Emits the signal for main to receive it.
	hotbal_index_changed.emit(current_material)

	# Temporary flicks the element label
	_flick_element_name(current_material)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("increase_brush"):
		_increase_brush()
	if event.is_action_pressed("decrease_brush"):
		_decrease_brush()

func _increase_brush() -> void:
	brush_size += 1
func _decrease_brush() -> void:
	brush_size -= 1

func _prepare_brush_size_indicator() -> void:
	var number_of_columns:int = 2 * MAX_BRUSH_SIZE - 1
	brush_size_indicator.columns = number_of_columns
	brush_size_indicator.size = Vector2i(number_of_columns, number_of_columns)
	for i in range(number_of_columns * number_of_columns):
		var new_color_rect: ColorRect = ColorRect.new()
		new_color_rect.custom_minimum_size = Vector2i(1,1)
		new_color_rect.color = Color.DARK_BLUE
		brush_size_indicator.add_child(new_color_rect)
	_update_brush_size_colors()

func _update_brush_size_colors() -> void:
	var number_of_children: int = brush_size_indicator.get_child_count()
	var middle_child: int = brush_size_indicator.columns / 2

	for k in range(number_of_children):
		brush_size_indicator.get_child(k).color = Color.DARK_BLUE
		var i:int = k / brush_size_indicator.columns
		var j:int = k % brush_size_indicator.columns
		if i <= middle_child + brush_size - 1 and \
		   j <= middle_child + brush_size - 1 and \
		   j >= middle_child - brush_size + 1 and \
		   i >= middle_child - brush_size + 1:
			brush_size_indicator.get_child(k).color = Color.YELLOW

func _flick_element_name(current_material: Elements.ELEMENT) -> void:
	tooltip_label.text = Elements.ELEMENT_TO_TEMPLATE[current_material].name
	tooltip_label.show()
	await get_tree().create_timer(.4).timeout
	tooltip_label.hide()

func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	menu.show()
	panel_container.hide()

func _on_plus_button_pressed() -> void:
	_increase_brush()

func _on_minus_button_pressed() -> void:
	_decrease_brush()
