extends KinematicBody

export var speed = 2.2
var home = Vector3.ZERO
var target = Vector3.ZERO
var timer = 0.0

func setup(start_pos):
    home = start_pos
    target = start_pos

func _physics_process(delta):
    timer -= delta
    if timer <= 0:
        timer = rand_range(2.0, 5.0)
        target = home + Vector3(rand_range(-10, 10), 0, rand_range(-10, 10))
    var dir = target - global_transform.origin
    dir.y = 0
    if dir.length() > 1:
        dir = dir.normalized()
        move_and_slide(dir * speed, Vector3.UP)
        rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), delta * 2.0)
