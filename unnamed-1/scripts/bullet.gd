extends Area2D

@export var speed: float = 260.0
@export var lifetime: float = 2.0
@export var damage: int = 1

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Gây sát thương nếu vật thể có hàm take_damage (heo, enemy sau này)
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
