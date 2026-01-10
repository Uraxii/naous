class_name InventoryAudioManager
extends Node

const MENU_OPEN = preload("uid://df084f3ieq60d")
const MENU_CLOSE = preload("uid://yse30gnksftw")
@onready var inventory_open_close_stream: AudioStreamPlayer = %InventoryOpenCloseStream

const CHANGE_EQUIPMENT = preload("uid://ckm4ioum8fkpq")
const BLOP = preload("uid://dkhtrbk1hg1y8")
const BLIP = preload("uid://cw7y8tv2gtkc6")
@onready var inventory_item_stream: AudioStreamPlayer = %InventoryItemStream


func play_opened() -> void:
    inventory_open_close_stream.stream = MENU_OPEN
    inventory_open_close_stream.play()


func play_closed() -> void:
    inventory_open_close_stream.stream = MENU_CLOSE
    inventory_open_close_stream.play()


func play_gear_equipped() -> void:
    inventory_item_stream.stream = CHANGE_EQUIPMENT
    inventory_item_stream.play()


func play_echo_equipped() -> void:
    inventory_item_stream.stream = BLIP
    inventory_item_stream.play()


func play_item_stored() -> void:
    inventory_item_stream.stream = BLOP
    inventory_item_stream.play()
