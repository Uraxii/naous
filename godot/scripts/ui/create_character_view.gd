class_name CreateCharacterView extends View


func _ready() -> void:
    print("hello")
    _connect_signals()
    # start the animation just in case it isn't set to do so by default
    #$AnimationPlayer.play("idle") # assumes this animation exists


func _connect_signals() -> void:
    var create_button: Button = %CreateButton
    create_button.pressed.connect(_on_create_pressed)
    
    var back_button: Button = %BackButton
    back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
    _return_to_character_select()


func _on_create_pressed() -> void:
    var character_name: LineEdit = %CharacterName
    var data = EntityData.new()
    data.id.display_name = character_name.text


    data.spellbook.spells.append(
        load("res://resources/spell_data/fireball/fireball.tres"))
    data.spellbook.spells.append(
        load("res://resources/spell_data/harm/harm.tres"))
        
    save.save_character(data)
    _return_to_character_select()


func _on_character_created(data: Dictionary) -> void:
    print("Character created: ", data)
    _return_to_character_select()


func _return_to_character_select() -> void:
    Globals.views.spawn(CharacterSelectView)
    despawn()
