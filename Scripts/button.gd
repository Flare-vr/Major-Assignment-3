extends Button

@onready var inventroy: HBoxContainer = $".."
@onready var infotext: Label = $"../../Text"
@onready var question: Label = $"../../Question"
@onready var input_line: Label = $"../../InputLine"


func _on_pressed() -> void:
	inventroy.visible = false
	infotext.visible = true
	question.visible = true
	input_line.visible = true
