extends Control


@export var main_scene: PackedScene # scene được load khi nhấn nút "BẮT ĐẦU"


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene) # Load scene được chỉ định trong biến main_scene


func _on_exit_button_pressed() -> void:
	get_tree().quit() # Thoát khỏi trò chơi khi nhấn nút "THOÁT"
