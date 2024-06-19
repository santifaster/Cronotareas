extends Node

signal change_theme
signal delete_all_tasks

var language_list
var language_index : int

func _ready():
	language_list = TranslationServer.get_loaded_locales()
	language_index = language_list.find(TranslationServer.get_locale())
	

func _on_menu_button_pressed():
	self.visible = true


func _on_close_menu_button_pressed():
	self.visible = false


func _on_language_button_pressed():
	language_index += 1
	if language_index > language_list.size() - 1:
		language_index = 0
	TranslationServer.set_locale(language_list[language_index])
	
	print(language_list[language_index])


func _on_themes_button_pressed():
	change_theme.emit()
	

func _on_delete_tasks_button_pressed():
	delete_all_tasks.emit()
	self.visible = false
