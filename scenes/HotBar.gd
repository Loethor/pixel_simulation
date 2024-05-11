extends HBoxContainer
class_name HotBar

@export var slot_scene:PackedScene
@onready var tool_tip_label: Label = $"../ToolTipLabel"
@export var elements_in_hotbar: Array[element_template]

signal index_changed(current_material:Element.ELEMENT)
signal scrolled()

var slots :Array
var slot_materials:Array
var current_material:Element.ELEMENT
var current_index: int:
	set(value):
		current_index = value
		index_changed.emit(elements_in_hotbar[current_index].element_type)
		reset_focus()
		set_focus()

func _ready() -> void:
	#slot_materials = [
		#Element.ELEMENT.AIR,
		#Element.ELEMENT.SAND,
		#Element.ELEMENT.WATER,
		#Element.ELEMENT.ICE,
		#Element.ELEMENT.BEDROCK,
		#Element.ELEMENT.OIL,
		#Element.ELEMENT.FIRE,
		#Element.ELEMENT.FUSE,
		#Element.ELEMENT.WATER_GENERATOR,
		#Element.ELEMENT.WATER_DRAIN,
		#Element.ELEMENT.METHANE,
		#Element.ELEMENT.HONEY,
	#]
	for slot_material:element_template in elements_in_hotbar:
		var new_slot: Slot = slot_scene.instantiate()
		new_slot.texture_normal = slot_material.atlas
		new_slot.material_of_the_button = slot_material.element_type
		add_child(new_slot)
	slots = get_children()
	current_index = 0

func reset_focus() -> void:
	for slot:Slot in slots:
		slot.set_process_input(false)
		slot.border.visible = false

func set_focus() -> void:
	get_child(current_index).grab_focus()
	get_child(current_index).border.visible = true
	get_child(current_index).set_process_input(true)

func _input(event:InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		if current_index == get_child_count() - 1:
			current_index = 0
		else:
			current_index += 1
		emit_signal("scrolled")

	if event.is_action_pressed("scroll_down"):
		if current_index == 0:
			current_index = get_child_count() - 1
		else:
			current_index -= 1
		emit_signal("scrolled")


