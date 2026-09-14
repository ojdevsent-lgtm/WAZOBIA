extends Area

var velocity = Vector3.ZERO
var life = 1.5
var damage = 25

func _physics_process(delta):
    global_translate(velocity * delta)
    life -= delta
    if life <= 0: queue_free()

func _on_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage(damage)
    queue_free()
