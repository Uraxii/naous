extends Node

signal finished

#const USE_ITERATIVE_REVEAL:bool = true ## DEPRECATED

## Populates the visible credits.
## A simple syntax is employed to format the result. "-" indicate titles. You can optionally
## include a description in the line following an indented line.
@export var cancel_button_presses_to_quit:int = 5
@export var iterative_duration: float = 158.0 ## in seconds

@export var start_delay:float = 4.0
@export_file("*.txt") var credits_path: String ## Text file. No special features or parsing yet.
@export_multiline var credits_text: String ## Will be used if [member credits_path] is empty.

var groups: Array[Array] = []

@onready var template_header: Label = %TemplateHeader
@onready var template_body: Label = %TemplateBody
@onready var title: Label = %TITLE
@onready var credits_items: VBoxContainer = %CreditsItems
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var skip_credits_warning_label: Label = %SkipCreditsWarningLabel
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	template_header.hide()
	template_body.hide()
	exit_button.hide()
	skip_credits_warning_label.modulate = Color.TRANSPARENT
	
	var credits_data: String
	if credits_path:
		var file = FileAccess.open(credits_path, FileAccess.READ)
		credits_data = file.get_as_text() if file != null else credits_text
		file.close()
	else:
		credits_data = credits_text
	populate_with(credits_data)
	#if not USE_ITERATIVE_REVEAL: ##DEPRECATED
		#start_scroll(scroll_duration)
	#else:
	start_reveal_iter()
		
	var fade_in_title:Tween = title.create_tween()
	fade_in_title.tween_property(title, ^"modulate", Color.WHITE, 3.0).from(Color.TRANSPARENT)
	
var cancel_button_pressed_count:int = 0
var debouncing:bool = false
func _undebounce() -> void: debouncing = false
const DEBOUNCE_TIME:float = 0.5

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if not debouncing:
			debouncing = true
			var debounce:Tween = create_tween()
			debounce.tween_interval(DEBOUNCE_TIME)
			debounce.tween_callback(_undebounce)
			
			cancel_button_pressed_count += 1
			print("Cancel count %d" % [cancel_button_pressed_count])
			throb_cancel_label(cancel_button_presses_to_quit + 1 - cancel_button_pressed_count)
			if cancel_button_pressed_count > cancel_button_presses_to_quit:
				cancel_revealing()

func cancel_revealing() -> void:
	if ticker:
		if ticker.is_running():
			ticker.kill()
	for group:Array in groups:
		for ci:CanvasItem in group:
			ci.show()
			ci.modulate = Color.WHITE
			
			scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
			scroll_container.mouse_filter = Control.MOUSE_FILTER_PASS
	
	exit_button.show()

func fade_out_and_exit() -> void:
	const FADE_TIME:float = 3.0
	
	## Fade out
	var fade:Tween = create_tween()
	fade.set_parallel()
	fade.tween_property(scroll_container, ^"modulate", Color.TRANSPARENT, FADE_TIME)
	fade.tween_method(
		DynamicMusicManager.set_music_bus_volume, 
		DynamicMusicManager.get_music_bus_volume_linear(),
		0.0,
		FADE_TIME
		)
	fade.chain().tween_callback(finished.emit)
	
var throb_cancel_label_tween:Tween
func throb_cancel_label(remaining) -> void:
	if remaining > 0:
		if throb_cancel_label_tween:
			if throb_cancel_label_tween.is_running():
				throb_cancel_label_tween.kill()
			
		skip_credits_warning_label.text = "Press any key to skip credits... (%d)" % [remaining]
		skip_credits_warning_label.modulate = Color.WHITE
		throb_cancel_label_tween = skip_credits_warning_label.create_tween()
		throb_cancel_label_tween.tween_interval(0.5)
		throb_cancel_label_tween.tween_property(skip_credits_warning_label, ^"modulate", Color.TRANSPARENT, 1.0)
	
func populate_with(text: String) -> void:
	## Clear all existing entries
	#for child in credits_items.get_children():
		#if child == template_header or child == template_body:
			#pass
		#else:
			#child.queue_free()
	
	## Parse it
	var splits: PackedStringArray = text.split("\n", false)
	var group: int = -1 ## Used for grouping everything between headings
	for split: String in splits:
		var new_item: Label
		var new_text: String
		if split.begins_with("-"):
			## Title/heading
			group += 1
			groups.resize(group + 1)
			groups[group] = Array()
			new_item = template_header.duplicate()
			new_text = split.trim_prefix("-")
		else:
			new_item = template_body.duplicate()
			new_text = split
			
		new_item.text = new_text
		
		#if USE_ITERATIVE_REVEAL:
		new_item.visible = false
		new_item.modulate = Color.TRANSPARENT
		#else:
			#new_item.visible = true
			#new_item.modulate = Color.WHITE
		
		credits_items.add_child(new_item)
		groups[group].push_back(new_item)

## DEPRECATED
#func start_scroll(duration: float) -> void:
	#var scroll = scroll_container.get_v_scroll_bar()
	#await scroll.changed
	#scroll.value = 0
	##scroll_container.scroll_vertical = 0
	#var tween: Tween = create_tween()
	#tween.set_ease(Tween.EASE_IN)
	#tween.tween_interval(start_delay)
	#tween.tween_property(scroll, ^"value", scroll.max_value, scroll_duration)
	#tween.tween_property(scroll_container, ^"modulate", Color.TRANSPARENT, 4.0)
	#tween.tween_callback(finished.emit)


var iter_current_group:int
var pages:int
var tick_interval:float
var ticker:Tween
func start_reveal_iter() -> void:
	#for group:Array in groups:
		#for ci:CanvasItem in group:
			#ci.hide()
	iter_current_group = -1
	
	pages = groups.size()
	tick_interval = iterative_duration / (pages + 1)
	ticker = create_tween()
	ticker.set_loops(pages)
	ticker.tween_interval(tick_interval)
	ticker.tween_callback(_on_iterative_tick)
	#ticker.finished.connect(_on_ticker_finished) ## Need to let the ticker execute and quit
	
	
func _on_iterative_tick() -> void:
	#var first_canvas_item:CanvasItem = groups[iter_current_group].front()
	#if first_canvas_item.visible:
	for ci:CanvasItem in groups[iter_current_group]:
		ci.hide()
		
	iter_current_group += 1
	
	var fade_time:float = tick_interval / 8.0
	var clear_time:float = fade_time
	var remainder:float = tick_interval - clear_time - (fade_time * 2)
	
	if iter_current_group == 1:
		## Hide the title
		var title_tween:Tween = title.create_tween()
		title_tween.tween_property(title, ^"modulate", Color.TRANSPARENT, remainder + clear_time)
		title_tween.tween_interval(fade_time * 2)
		#title_tween.tween_callback(title.hide) ## Leave it to act as a spacer
	
	for ci:CanvasItem in groups[iter_current_group]:
		var tween:Tween = create_tween()
		## Fade In
		tween.tween_property(ci, ^"modulate", Color.WHITE, fade_time)#.from(Color.TRANSPARENT)
		## Show time
		tween.tween_interval(remainder)
		## Fade Out
		tween.tween_property(ci, ^"modulate", Color.TRANSPARENT, fade_time)
		## Clear time
		## (do nothing, tween is finished)
		ci.show()
		#ci.show.call_deferred()
		
	if iter_current_group + 1 >= groups.size():
		await create_tween().tween_interval(tick_interval * 1.15).finished
		_on_ticker_finished()

func _on_ticker_finished() -> void:
	## Exit the credits scene
	finished.emit()


func _on_exit_button_pressed() -> void:
	fade_out_and_exit()
