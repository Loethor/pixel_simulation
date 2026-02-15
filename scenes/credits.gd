extends Control

const SECTION_TIME: float = 2.0
const LINE_TIME: float = 0.3
const SCROLLING_SPEED: float = 100
const COLOR := Color.SKY_BLUE

@onready var scrolling_line: Label = $Container/ScrollingLine

var started := false
var finished := false

var section:Array
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits: Array = [
	[
		"A game by Awesome Game Company"
	],[
		"Programming",
		"Loethor",
		"nielesonimusso",
	],[
		"Designers",
		"Loethor",
		"nielesonimusso",
	],[
		"Art",
		"nielesonimusso",
		"Loethor",
	],[
		"Testers",
		"nielesonimusso",
		"Loethor",
	],[
		"Proudly developed with Godot Engine",
		"https://godotengine.org/license",
	]
]

func _process(delta: float) -> void:
	var scrolling_speed:float  = SCROLLING_SPEED * delta

	if section_next:
		section_timer += delta
		if section_timer >= SECTION_TIME:
			section_timer -= SECTION_TIME

			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()

	else:
		line_timer +=  delta
		if line_timer >= LINE_TIME:
			line_timer -= LINE_TIME
			add_line()


	if lines.size() > 0:
		for l:Label in lines:
			l.position.y -= scrolling_speed
			if l.position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()

func finish() -> void:
	if not finished:
		finished = true
		# This is called when the credits finish and returns to the main menu
		#get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func add_line() -> void:
	var new_line:Label = scrolling_line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		# new_line.add_color_override("font_color", title_color)
		new_line.set("theme_override_colors/font_color", COLOR)
	$Container.add_child(new_line)

	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event:InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		finish()
