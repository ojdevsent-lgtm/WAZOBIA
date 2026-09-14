extends KinematicBody

export var max_speed = 22.0
export var acceleration = 30.0
export var brake_power = 45.0
var speed = 0.0
var driver = null
var occupied = false

func _physics_process(delta):
    if not occupied:
        return
    var throttle = 0.0
    if Input.is_key_pressed(KEY_W): throttle += 1.0
    if Input.is_key_pressed(KEY_S): throttle -= 1.0
    speed = move_toward(speed, throttle * max_speed, (acceleration if throttle != 0 else brake_power) * delta)
    var steer = 0.0
    if Input.is_key_pressed(KEY_A): steer -= 1.0
    if Input.is_key_pressed(KEY_D): steer += 1.0
    rotation.y += steer * 1.8 * delta * clamp(abs(speed) / 8.0, 0.25, 1.0)
    var forward = -transform.basis.z
    var motion = forward * speed
    motion.y = -0.5
    move_and_slide(motion, Vector3.UP)
    if Input.is_key_pressed(KEY_F):
        occupied = false
        if driver:
            driver.current_vehicle = null
            driver.global_transform.origin = global_transform.origin + transform.basis.x * 2.5 + Vector3(0, 1, 0)
            driver = null
