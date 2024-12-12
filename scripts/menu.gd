extends Control

@export var panel_container: PanelContainer

func _on_close_button_pressed() -> void:
	hide()
	panel_container.show()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
