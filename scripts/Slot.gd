extends TextureButton
class_name Slot

const TILES: Resource = preload("res://assets/tiles.png")
const RUBBER: Resource = preload("res://assets/rubber.png")

var tool_tip_label_text :String = ""
var atlas :AtlasTexture
var material_of_the_button: Elements.ELEMENT = Elements.ELEMENT.AIR :
	set(value):
		material_of_the_button = value
		tool_tip_label_text = Elements.ELEMENT_TO_TEMPLATE[material_of_the_button].name

@onready var border: NinePatchRect = $Border

signal slot_reacted(my_id: int)

func _ready() -> void:
	set_process_input(false)

func _on_pressed() -> void:
	get_parent().current_index = get_index()
	slot_reacted.emit(get_index())

func _on_mouse_entered() -> void:
	slot_reacted.emit(get_index())

func _on_mouse_exited() -> void:
	slot_reacted.emit(-1)
