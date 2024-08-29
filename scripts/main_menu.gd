extends Node

signal on_main_menu_open()
signal on_main_menu_close()
signal change_theme
signal change_language
signal delete_all_tasks
signal delete_all_saves
	
func _on_menu_button_pressed():
	self.visible = true
	on_main_menu_open.emit()


func _on_close_menu_button_pressed():
	self.visible = false
	on_main_menu_close.emit()


func _on_language_button_pressed():
	change_language.emit()


func _on_themes_button_pressed():
	change_theme.emit()
	
#TODO Make lock in window to prevent missclick
func _on_delete_tasks_button_pressed():
	delete_all_tasks.emit()
	_on_close_menu_button_pressed()
	
func _on_delete_saves_and_exit():
	delete_all_saves.emit()
	get_tree().quit()

func _notification(what):

	if self.visible and what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_close_menu_button_pressed()
