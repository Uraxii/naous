extends MultiMeshInstance3D

# takes the boring multimesh instances and spins them around Y for variety
# (godot multimesh gui rotates ramdomly on ALL axes which looks bad)

func apply_random_y_rotation():
    for i in range(0,  multimesh.instance_count):
        var current_trans = multimesh.get_instance_transform(i)
        # damn this seems to not work right........... arghhhh so close
        # current_trans.basis = Basis.IDENTITY
        # current_trans = current_trans.rotated(Vector3.UP, randf_range(-PI, PI))
        current_trans = current_trans.rotated_local(Vector3.UP, randf_range(-PI, PI))
        multimesh.set_instance_transform(i, current_trans)

func _ready():
    apply_random_y_rotation()
