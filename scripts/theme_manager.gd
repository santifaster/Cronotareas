extends Control

@export var themes : Array[Theme]
var theme_index : int = 0
@onready var timer_bar = $"CronoTareas/MarginContainer/VBoxContainer/Timer Menu/VBoxContainer/TimerBar"

func _ready():
	update_non_theme_nodes()

func _on_change_theme():
	if themes.size() == 0:
		return
	
	theme_index += 1
	if theme_index > themes.size() - 1:
		theme_index = 0
	theme = themes[theme_index]
	update_non_theme_nodes()
	
func update_non_theme_nodes():
	timer_bar.tint_progress = get_theme_color("tint_progress", "TextureProgressBar")
	timer_bar.tint_under = get_theme_color("tint_under", "TextureProgressBar")
	

