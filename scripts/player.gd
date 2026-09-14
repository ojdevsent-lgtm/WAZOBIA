extends KinematicBody

export var walk_speed = 7.0
export var sprint_speed = 11.0
export var gravity = 22.0
var velocity = Vector3.ZERO
var health = 100
var money = 50000
var touch_forward = false
var touch_backward = false
var touch_left = false
var touch_right = false
var touch_sprint = false
var current_vehicle = null

func _physics_process(delta):
    if current_vehicle != null:
        global_transform.origin = current_vehicle.global_transform.origin + Vector3(0, 1.1, 0)
        return
    var x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    var z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
    if touch_left: x -= 1
    if touch_right: x += 1
    if touch_forward: z -= 1
    if touch_backward: z += 1
    var direction = Vector3(x, 0, z)
    if direction.length() > 1: direction = direction.normalized()
    var speed = sprint_speed if touch_sprint or Input.is_key_pressed(KEY_SHIFT) else walk_speed
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    if is_on_floor(): velocity.y = -0.5
    else: velocity.y -= gravity * delta
    velocity = move_and_slide(velocity, Vector3.UP)
    if direction.length() > 0.05:
        rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * 8.0)

func take_damage(amount):
    health = max(0, health - amount)
    if health <= 0:
        health = 100
        global_transform.origin = Vector3(0, 1, 0)
