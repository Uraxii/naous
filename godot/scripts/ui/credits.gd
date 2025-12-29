extends Node

## Populates the visible credits.
## A simple syntax is employed to format the result. "-" indicate titles. You can optionally
## include a description in the line following an indented line.

@export var scroll_duration: int = 30
@export_file("*.txt") var credits_path: String ## Text file. No special features or parsing yet.
@export_multiline var credits_text: String ## Will be used if [member credits_path] is empty.

@onready var template_header: Label = %TemplateHeader
@onready var template_body: Label = %TemplateBody
@onready var credits_items: VBoxContainer = %CreditsItems
@onready var scroll_container: ScrollContainer = %ScrollContainer


func _ready() -> void:
	template_header.hide()
	template_body.hide()
	
	var credits_data: String
	if credits_path:
		var file = FileAccess.open(credits_path, FileAccess.READ)
		credits_data = file.get_as_text() if file != null else credits_text
		file.close()
	else:
		credits_data = credits_text
	populate_with(credits_data)
	start_scroll(scroll_duration)
		
func populate_with(text: String) -> void:
	## Clear all existing entries
	#for child in credits_items.get_children():
		#if child == template_header or child == template_body:
			#pass
		#else:
			#child.queue_free()
	
	## Parse it
	var splits: PackedStringArray = text.split("\n", false)
	
	for split: String in splits:
		var new_item: Label
		var new_text: String
		if split.begins_with("-"):
			## Title/heading
			new_item = template_header.duplicate()
			new_text = split.trim_prefix("-")
		else:
			new_item = template_body.duplicate()
			new_text = split
			
		new_item.text = new_text
		new_item.visible = true
		
		credits_items.add_child(new_item)

func start_scroll(duration: float) -> void:
	var scroll = scroll_container.get_v_scroll_bar()
	await scroll.changed
	scroll.value = 0
	#scroll_container.scroll_vertical = 0
	var tween: Tween = create_tween()
	tween.tween_property(scroll, ^"value", scroll.max_value, scroll_duration)
	tween.tween_property(scroll_container, ^"modulate", Color.TRANSPARENT, 4.0)
