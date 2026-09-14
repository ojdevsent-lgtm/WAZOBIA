extends KinematicBody

export var speed = 6.0
var target = null

func setup(player):
    target = player

func _physics_process(delta):
    if target == null: return
    var dir = target.global_transform.origin - global_transform.origin
    dir.y = 0
    if dir.length() > 4:
        dir = dir.normalized()
        move_and_slide(dir * speed, Vector3.UP)
        rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), delta * 5.0)
