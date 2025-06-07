extends Node

signal on_main_menu_open()
signal on_main_menu_close()
signal change_theme
signal change_language
signal delete_all_tasks
signal delete_all_saves
	
@onready var h_slider = $"VBoxContainer/SFX Slider"
#@onready var animation_player: AnimationPlayer = $AnimationPlayer

var menu_open : bool
@onready var menu_tween_animator: Node = $"Menu Tween Animator"

func _ready() -> void:
	get_viewport().size_changed.connect(window_resize)
	window_resize()

func _on_menu_button_pressed():
	menu_open = true
	#animation_player.play("menu/open_right")
	self.visible = true
	menu_tween_animator.tween_animation(Vector2(0,0))
	on_main_menu_open.emit()
	h_slider.value = AudioManager.get_sfx_value()
	
func window_resize():
	if menu_open:
		self.position = Vector2(0,0)
	else:
		self.position = Vector2(get_window().size.x,0)

func _on_close_menu_button_pressed():
	menu_open = false
	#animation_player.play("menu/close_right")
	menu_tween_animator.tween_animation(Vector2(get_window().size.x,0))
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

	if menu_open and what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_close_menu_button_pressed()

func _on_sfx_slider_value_changed(value):
	print(linear_to_db(value))
	AudioManager._on_sfx_slider_value_changed(value)


func _on_always_top_check_toggled(toggled_on: bool) -> void:
	get_window().always_on_top = toggled_on
