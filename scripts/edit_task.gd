extends Control

signal add_task(task)
signal on_edit_task(task)

const TASK_SLOT = preload("res://scenes/task_slot.tscn")
@onready var main_menu = %"Main menu"

@onready var minutes_duration_line_edit = $"MarginContainer/VBoxContainer/TimeHBoxContainer/Minutes Duration LineEdit"
@onready var seconds_duration_line_edit = $"MarginContainer/VBoxContainer/TimeHBoxContainer/Seconds Duration LineEdit"
@onready var minutes_left_line_edit = $"MarginContainer/VBoxContainer/TimeHBoxContainer/Minutes Left LineEdit"
@onready var seconds_left_line_edit = $"MarginContainer/VBoxContainer/TimeHBoxContainer/Seconds Left LineEdit"

@onready var icon_input = $"MarginContainer/VBoxContainer/HBoxContainer/Icon Input"
@onready var title_input = $"MarginContainer/VBoxContainer/HBoxContainer/Title Input"
@onready var task_container = $"../CronoTareas/MarginContainer/VBoxContainer/Task Manager/VBoxContainer/TaskContainer"

@onready var confirm_button = $"HBoxContainer/Confirm Button"

var is_task_new
var task_slot_script
var task_data
#Check if icon_input has only 1 char

func on_task_edit(edit_task_data, edit_task_slot_script):
	is_task_new = false
	#Update displayed data
	task_slot_script = edit_task_slot_script
	task_data = edit_task_data
	icon_input.text = task_data.icon
	title_input.text = task_data.title
	update_ui_time()
	#check_valid_time()
	confirm_button.text = tr("Editar")
	visible = true
	
func _on_new_task_button_pressed():
	is_task_new = true
	task_data =  Task.new("","", 0)
	check_valid_time()
	confirm_button.text = tr("Crear")
	visible = true
		
func minutes_to_seconds(str_minutes:String):
	var minutes = int(str_minutes)
	return minutes * 60	
	
func time_input_wrong(new_text:String, current_time:float,
current_time_processed:float, line_edit:LineEdit):
	
	if not new_text.is_valid_int() and new_text != "":
			
		if current_time <= 0:
			line_edit.clear()
		else: 
			line_edit.text = str(current_time_processed)
		return true
		
	return false
	
func add_duration_time_left(current_duration):
	if(task_data.state == Task.state_type.not_started):
		task_data.time_left = current_duration
	else:
		task_data.time_left = min(task_data.time_left, current_duration)
		
func update_ui_time():

	minutes_duration_line_edit.text = task_data._get_string_duration_minutes()
	seconds_duration_line_edit.text = task_data._get_string_duration_seconds()
	minutes_left_line_edit.text = task_data._get_string_time_left_minutes()
	seconds_left_line_edit.text = task_data._get_string_time_left_seconds()
	
func check_valid_time():
	if(task_data.state == Task.state_type.completed):
		confirm_button.disabled = false
		return
	
	if(task_data.time_left <= 0 or task_data.duration <= 0):
		confirm_button.disabled = true
	else:
		confirm_button.disabled = false

func clear_ui_and_exit():
	visible = false
	
	task_data = null
	task_slot_script = null
	
	icon_input.clear()
	title_input.clear()
	minutes_duration_line_edit.clear()
	seconds_duration_line_edit.clear()
	minutes_left_line_edit.clear()
	seconds_left_line_edit.clear()
	
func set_text_on_data():
	task_data.icon = icon_input.text
	task_data.title = title_input.text

func _on_back_button_pressed():
	clear_ui_and_exit()
	
func _on_confirm_button_pressed():
	set_text_on_data()
	if (is_task_new):
		var task_instance = TASK_SLOT.instantiate()
		#task_instance.set_task(new_task_data)
		
		task_instance.on_edit.connect(on_task_edit)
		main_menu.delete_all_tasks.connect(task_instance.delete)
		task_instance.task_data = task_data
		add_task.emit(task_instance)
		task_instance.update_task_ui()

	else:
		if task_data.time_left != 0 and task_data.state == task_data.state_type.completed:
			if task_data.duration == task_data.time_left:
				task_data.state == task_data.state_type.not_started
			else:
				task_data.state == task_data.state_type.paused
				
		task_slot_script.set_task(task_data)
		on_edit_task.emit(task_slot_script)
	print(str(task_data.duration) + " " + str(task_data.time_left))
		
	clear_ui_and_exit()
		
		
#func _on_icon_input_text_changed():
	#var icon_string = icon_input.text
	#if(icon_string.length() > 1):
		#icon_input.text = icon_string.left(1)
		
#region On time submited

func _on_minutes_duration_changed(new_text):
	if(task_data == null):
		return
	
	if(time_input_wrong(new_text, task_data.duration,
	task_data.duration_minutes,minutes_duration_line_edit)):
		return
		
	var new_minutes = clamp(minutes_to_seconds(new_text),0,60*99)
	
	task_data.duration = new_minutes + task_data.duration_seconds
	add_duration_time_left(task_data.duration)
	
	check_valid_time()


func _on_seconds_duration_changed(new_text):
	if(task_data == null):
		return

	if(time_input_wrong(new_text, task_data.duration,
	task_data.duration_seconds ,seconds_duration_line_edit)):
		return
		
	var new_seconds = clamp(int(new_text), 0, 60)

	task_data.duration = new_seconds + task_data.duration_minutes * 60
	add_duration_time_left(task_data.duration)	
	check_valid_time()
	
	
func _on_minutes_left_changed(new_text):
	if(task_data == null):
		return
		
	if(time_input_wrong(new_text, task_data.time_left,
	task_data.time_left_minutes,minutes_duration_line_edit)):
		return
		
	var new_minutes = clamp(minutes_to_seconds(new_text),0,99*60)
	
	task_data.time_left = clamp(new_minutes + task_data.time_left_seconds, 0, task_data.duration)
	
	check_valid_time()

func _on_seconds_left_changed(new_text):
	if(task_data == null):
		return
			
	if(time_input_wrong(new_text, task_data.time_left,
	task_data.time_left_seconds,seconds_duration_line_edit)):
		return
		
	var new_seconds = clamp(int(new_text), 0, 60)	

	task_data.time_left = clamp(new_seconds + task_data.time_left_minutes * 60, 0, task_data.duration)	
	
	check_valid_time()

func _on_time_submitted(_new_text):
	_on_time_set()
	
func _on_time_set():
	update_ui_time()
	
#endregion



