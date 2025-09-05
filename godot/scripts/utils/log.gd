class_name Log

var signals: SignalBus
    

func _init(signal_bus: SignalBus) -> void:
    signals = signal_bus


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
