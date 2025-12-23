class_name Log extends Node

@onready var signals := Globals.signal_bus


func info(...args: Array) -> void:
    var message = " ".join(args.map(str))
    signals.log_new_message.emit(message)
    print(message)


func debug(...args: Array) -> void:
    var message = " ".join(args.map(str))
    signals.log_new_debug.emit(message)
    print(message)


func warn(...args: Array) -> void:
    var message = " ".join(args.map(str))
    signals.log_new_warning.emit(message)
    print(message)


func error(...args: Array) -> void:
    var message = " ".join(args.map(str))
    signals.log_new_error.emit(message)
    push_error(message)


func success(...args: Array) -> void:
    var message = " ".join(args.map(str))
    signals.log_new_success.emit(message)
    print(message)

