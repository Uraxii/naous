class_name ActorData extends Resource

var id := Actor.INVALID_ID
var instance_id := Instance.INVALID_ID
var peer_auth_id := NaousNet.SERVER_PEER_ID
var display_name := "No Name"
var title := "The Nameless One"

var stats := {
    "health":           100.0,
    "speed":            10.0,
    "jump_force":       20.0,
    "gravity_scale":    1.0,
}

var spells: Array[String] = ["fireball"]
var equipment: Array[String] = []
var inventory: Array[String] = []

