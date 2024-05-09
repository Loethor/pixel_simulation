extends TextureButton
class_name Slot

const TILES: Resource = preload("res://assets/tiles.png")
const RUBBER: Resource = preload("res://assets/rubber.png")

var atlas :AtlasTexture = AtlasTexture.new()
var material_of_the_button: Element.ELEMENT = Element.ELEMENT.AIR :
	set(value):
		material_of_the_button = value
		if value != Element.ELEMENT.AIR:
			texture_normal = atlas
			var coords:Vector2i = Element.ELEMENT_TO_ATLAS_COORD[value]
			texture_normal.region = Rect2(coords.x, coords.y,1,1)
			tooltip_text = Element.ELEMENT_INFO[material_of_the_button]["name"]
		else:
			texture_normal = RUBBER
			tooltip_text = "Eraser"

@onready var border: NinePatchRect = $Border

func _ready() -> void:
	atlas.set_atlas(TILES)
	set_process_input(false)

func _on_pressed() -> void:
	get_parent().current_index = get_index()
