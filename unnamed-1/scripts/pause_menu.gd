extends Control

const MAIN_MENU_PATH := "res://scenes/MainMenu.tscn"

func _ready() -> void:
	# Đảm bảo menu bị ẩn khi game bắt đầu
	hide()


func _input(event: InputEvent) -> void:
	# Kiểm tra nếu nhấn phím ESC (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			resume()
		else:
			pause()


func pause() -> void:
	get_tree().paused = true # Dừng toàn bộ game
	show() # Hiện menu


func resume() -> void:
	get_tree().paused = false # Chạy lại game
	hide() # Ẩn menu


func _on_resume_button_pressed() -> void:
	resume()


func _on_quit_button_pressed() -> void:
	get_tree().paused = false # tắt pause trước chuyển scene để tránh lỗi
	get_tree().change_scene_to_file(MAIN_MENU_PATH) # Load scene được chỉ định trong biến MAIN_MENU_PATH
