extends Control

const MAIN_SCENE_PATH := "res://scenes/Main.tscn" # scene chính của game

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE_PATH) # Load scene được chỉ định trong biến MAIN_SCENE_PATH


func _on_exit_button_pressed() -> void:
	get_tree().quit() # Thoát khỏi trò chơi khi nhấn nút "THOÁT"
