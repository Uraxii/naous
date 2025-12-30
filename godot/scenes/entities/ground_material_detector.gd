# Checks the ground below the attached entity through a raycast and reads the assigned material
extends Node3D

# This signal is emitted when a detected material changes
signal material_changed(new_material: NaousMaterial.Materials)

# How many times per second the detection should query for changed ground materials
@export var triggers_per_second = 5

# the elapsed seconds counted from the physics process
@onready var elapsed_seconds: float = 0.

# the timestamp(elasted_seconds) when the last material detection was triggered at
@onready var last_triggered: float = 0.

# The player body to provide positional and floor information
@export var player: CharacterBody3D

# The shape of the player
@export var player_shape: CollisionShape3D

# The currently detected material
var detected_material: NaousMaterial.Materials = NaousMaterial.Materials.UNKNOWN

# Half of the players height, so
@onready var character_height_half: float

func _ready() -> void:
    if player_shape.shape is CapsuleShape3D:
        character_height_half = player_shape.height / 2.
    # Can be extended for other shapes here!
    else:
        character_height_half = 0.5
        push_warning("Unsupported Character Collision shape: ", player_shape.shape)

func _physics_process(delta: float) -> void:
    elapsed_seconds += delta
    if player.is_on_floor() and last_triggered + (1. / triggers_per_second) < elapsed_seconds:
        last_triggered = elapsed_seconds
        var raycast_query = PhysicsRayQueryParameters3D.create( \
            player.get_global_transform().origin, \
            player.get_global_transform().origin - Vector3(0, character_height_half, 0.) \
        )
        var raycast = get_world_3d().direct_space_state.intersect_ray(raycast_query)
        var new_detected_material = NaousMaterial.Materials.UNKNOWN
        if raycast.has("collider"): # Raycast collided with a Node
            if ( # collided body has a child called "material", which has a member variable "material" \
                raycast.collider.has_node("material") \
                and "material" in raycast.collider.get_node("material") \
                and raycast.collider.get_node("material").material is NaousMaterial \
            ):
                new_detected_material = raycast.collider.material
            elif ( "material" in raycast.collider and raycast.collider.material is NaousMaterial):
                # or collided body has member a variable "material"
                new_detected_material = raycast.collider.material

        if detected_material != new_detected_material:
            emit_signal("material_changed", new_detected_material)
        detected_material = new_detected_material
