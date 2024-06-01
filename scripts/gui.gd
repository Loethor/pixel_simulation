extends Control
class_name GUIInterface

@onready var menu: Control = $Menu
@onready var fps_label: Label = $FPSLabel
@onready var tooltip_label: Label = $TooltipLabel
@onready var hot_bar: HotBar = $PanelContainer/MarginContainer/HotBar

signal plus_pressed
signal minus_pressed
signal hotbal_index_changed(current_material: Elements.ELEMENT)

func _ready() -> void:
	hot_bar.index_changed.connect(_on_hot_bar_index_changed)
	hot_bar.tooltip_text_changed.connect(_on_tooltip_text_changed)
	hot_bar.tooltip_hid.connect(_on_tooltip_hid)

func _process(_delta: float) -> void:
	fps_label.text = "%s" % Engine.get_frames_per_second()

func _on_hot_bar_index_changed(current_material: Elements.ELEMENT) -> void:
	# Emits the signal for main to receive it.
	hotbal_index_changed.emit(current_material)

	# Temporary flicks the element label
	_flick_element_name(current_material)

func _flick_element_name(current_material: Elements.ELEMENT) ->void:
	tooltip_label.text = Elements.ELEMENT_TO_TEMPLATE[current_material].name
	tooltip_label.show()
	await get_tree().create_timer(.4).timeout
	tooltip_label.hide()

func _on_reset_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	menu.show()

func _on_plus_button_pressed() -> void:
	plus_pressed.emit()

func _on_minus_button_pressed() -> void:
	minus_pressed.emit()

func _on_tooltip_text_changed(new_element: element_template) -> void:
	tooltip_label.text = new_element.name
	tooltip_label.show()

func _on_tooltip_hid() -> void:
	tooltip_label.hide()
