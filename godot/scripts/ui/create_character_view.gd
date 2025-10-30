class_name CreateCharacterView extends View


func _ready() -> void:
    print("hello")
    _connect_signals()
    # start the animation just in case it isn't set to do so by default
    $AnimationPlayer.play("idle") # assumes this animation exists


func _connect_signals() -> void:
    var create_button: Button = %CreateButton
    create_button.pressed.connect(_on_create_pressed)
    
    var back_button: Button = %BackButton
    back_button.pressed.connect(_on_back_pressed)
    
    signals.character_created.connect(_on_character_created)
    
    
func _on_back_pressed() -> void:
    _return_to_character_select()

    
func _on_create_pressed() -> void:
    var _character_name: LineEdit = %CharacterName
    ##API.create_character(_character_name.text)


func _on_character_created(data: Dictionary) -> void:
    print("Character created: ", data)
    _return_to_character_select()


func _return_to_character_select() -> void:
    Globals.views.spawn(CharacterSelectView)
    despawn()
