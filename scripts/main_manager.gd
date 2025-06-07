extends Control

var options_data : Options
#Themes
var themes = {
	"default":"res://themes/default_theme.tres",
	"sunset":"res://themes/sunset_theme.tres",
	"desert":"res://themes/desert_theme.tres"
} 
@onready var theme_keys = themes.keys()
@onready var timer_bar = $"CronoTareas/MarginContainer/TaskManager/Timer Menu/VBoxContainer/TimerBar"

#Languages
var language_list
var language_index : int

var menu_opened := false

func _ready():
	get_window().min_size = Vector2(384,768)
	options_data = DataSave.load_options()
	if options_data == null:
		options_data = Options.new()
	else:
		load_options()
		
	DataSave.load_tasks()
	update_non_theme_nodes()
	
	language_list = TranslationServer.get_loaded_locales()
	language_index = language_list.find(TranslationServer.get_locale())
	

func _on_change_theme():
	if themes.size() == 0:
		push_warning("No themes loaded on main manager")
		return
	
	var theme_index = theme_keys.find(options_data.theme)
	theme_index += 1
	if theme_index > themes.size() - 1:
		theme_index = 0
		
	options_data.theme = theme_keys[theme_index]
	theme = load(themes[options_data.theme])
	print("Theme name:" + options_data.theme)
	update_non_theme_nodes()
	DataSave.save_options(options_data)

func _on_change_language():
	language_index += 1
	if language_index > language_list.size() - 1:
		language_index = 0
	options_data.language = language_list[language_index]
	TranslationServer.set_locale(options_data.language)
	
	print(options_data.language)
	DataSave.save_options(options_data)

func _on_delete_all_tasks():
	DataSave.delete_tasks_save()

func _on_delete_all_saves():
	DataSave.delete_tasks_save()
	DataSave.delete_options_save()

func load_options():
	theme = load(themes[options_data.theme])
	TranslationServer.set_locale(options_data.language)
	AudioManager.set_sfx_db(options_data.sfx_db)
	pass
	
func update_non_theme_nodes():
	timer_bar.tint_progress = get_theme_color("tint_progress", "TextureProgressBar")
	timer_bar.tint_under = get_theme_color("tint_under", "TextureProgressBar")
	
func on_task_change():
	DataSave.save_tasks()
	
#Save on close
func _notification(what):
	
	match (what):
		NOTIFICATION_WM_CLOSE_REQUEST:
			DataSave.save_tasks()
			get_tree().quit() # default behavior
		#In case the app is paused in android, could be closed while paused
		NOTIFICATION_APPLICATION_PAUSED:
			DataSave.save_tasks()
		#Back closes by default the popup menu
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if not menu_opened:
				DataSave.save_tasks()
				get_tree().quit()


func on_menu_open():
	if not menu_opened:
		menu_opened = true
	else:
		printerr("Tried to open multiple menus at the same time, this should not happen")
		
func on_menu_close():
	if menu_opened:
		menu_opened = false
	else:
		printerr("There were multiple menus open at the same time, this should not happen")
		
		
