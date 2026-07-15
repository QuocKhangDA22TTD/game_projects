extends Area2D

@export var speed: float = 260.0
@export var lifetime: float = 2.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(_body: Node2D) -> void:
	# Chưa có enemy/tường — để sẵn cho bước sau, đạn tự hủy khi chạm vật thể
	queue_free()
