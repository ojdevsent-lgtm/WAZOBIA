extends KinematicBody

export var speed := 7.0
export var gravity := 18.0
var velocity := Vector3.ZERO

func _physics_process(delta):
    var input_vector = Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
    )

    var direction = Vector3(input_vector.x, 0, input_vector.y)
    if direction.length() > 1.0:
        direction = direction.normalized()

    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    velocity.y -= gravity * delta

    velocity = move_and_slide(velocity, Vector3.UP)

    if direction.length() > 0.05:
        rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * 8.0)
