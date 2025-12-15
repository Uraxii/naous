class_name Sanitizer

const alpha = "a-zA-Z"
const numeric = "0-9"
const allowed_specials = "_"
const default_rule := "^[" + alpha + numeric + allowed_specials + "]+$"


static func is_legal(text: String) -> bool:
    var regex = RegEx.new()
    var error = regex.compile(default_rule)
    
    if error != OK:
        push_error("RegEx compilation failed!")
        return false

    return regex.search(text) != null
