class_name Session

var token := ""

var peer_id := 0
var ws := WebSocketPeer.new()
var last_state := WebSocketPeer.STATE_CLOSED

var user_id := ""
