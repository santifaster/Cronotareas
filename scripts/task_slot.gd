extends Control

signal on_start(task_node:Node)
signal on_edit(edit_task_data, task_script)
signal on_drag(preview_node, task_node)
signal on_drop
signal on_reset(task_node:Node)
signal on_delete(task_node:Node)

#Can't make const preload of the same scene because it's a recursive call
#Have to look a way to make it const to only load it once
#const TASK_SLOT = preload("res://scenes/task_slot.tscn")
var task_scene

@onready var task_duration_label = $"MarginContainer/VBoxContainer/TimeHBoxContainer/Task Duration Label"
@onready var time_left_label = $"MarginContainer/VBoxContainer/TimeHBoxContainer/Time Left Label"
@onready var progress_bar = $MarginContainer/VBoxContainer/TimeHBoxContainer/ProgressBar

@onready var icon_label = $"MarginContainer/VBoxContainer/TextHBoxContainer/Icon Label"
@onready var title_label = $"MarginContainer/VBoxContainer/TextHBoxContainer/Title Label"
@onready var button_drop_h_container = $MarginContainer/VBoxContainer/ButtonDropHContainer
@onready var hide_panel = $"MarginContainer/Hide Panel"

	
var task_data : Task

enum interaction {idle, drag, open}
var task_interaction = interaction.idle


func _ready():
	if(task_scene == null):
		task_scene = load("res://scenes/task_slot.tscn")
	if(task_data == null):
		set_task(Task.new("T","Test card",10.0))
		
	add_to_group("save_nodes")
		
func _process(_delta):
	if(task_data.state == Task.state_type.in_progress):
		update_ui_time()
	
func set_task(n_task_data):
	task_data = n_task_data
	update_task_ui()

func save():
	return task_data.get_save_data()	

func update_task_ui():
	title_label.text = task_data.title
	icon_label.text = task_data.icon
	
	update_ui_time()
	
func update_ui_time():
	var duration = task_data.duration
	var time_left = task_data.time_left
	
	task_duration_label.text = task_data._get_string_duration()
	time_left_label.text = task_data._get_string_time_left()
	progress_bar.max_value = duration
	progress_bar.value = time_left
	
func _enter_tree():
	#Update task on finished, to set time interface to 0
	if(task_data == null):
		return
	
	#Updated UI time on parent change to set time to 0
	#On save load tasks can be added compleated, while nodes aren't loaded
	#To prevent this, compare to any variable that shouldn't be null
	if(task_data.state == Task.state_type.completed and icon_label != null):
		update_ui_time()
	
func _get_drag_data(_position):

	close_panel()

	var task_instance = task_scene.instantiate()
	
	#Make the slot follow the mouse where it started dragging
	task_instance.position -= _position
	var preview_task_control = Control.new()
	preview_task_control.add_child(task_instance)
	
	task_interaction = interaction.drag
	
	set_drag_preview(preview_task_control)
	preview_task_control.tree_exiting.connect(_on_preview_tree_exit)
	task_instance.set_task(task_data)
	hide_panel.visible = true
	
	on_drag.emit(preview_task_control, self)
	
	return task_data

func _can_drop_data(_position, _data):
	return true

func _drop_data(_position, _data):
	pass
	
func _on_preview_tree_exit():
	on_drop.emit()
	hide_panel.visible = false
	task_interaction = interaction.idle

func open_panel():
	if(task_interaction != interaction.idle):
		return
	button_drop_h_container.visible = true
	task_interaction = interaction.open
	
func close_panel():
	if(task_interaction != interaction.open):
		return
	button_drop_h_container.visible = false
	task_interaction = interaction.idle
	
func delete():
	queue_free()
	on_delete.emit(self)
	
func reset():
	task_data.reset_task()
	close_panel()
	on_reset.emit(self)
	update_ui_time()
	
func _on_mouse_entered():
	#color_rect.color
	pass

func _on_dropdown_button_pressed():
	if button_drop_h_container.visible == false:
		open_panel()
	else: 
		close_panel()
		
func _on_start_button_pressed():
	close_panel()
	
	if task_data.state == task_data.state_type.completed:
		reset()
	on_start.emit(self)
	pass # Replace with function body.

func _on_edit_button_pressed():
	close_panel()
	on_edit.emit(task_data, self)

func _on_reset_button_pressed():
	reset()

func _on_eliminate_button_pressed():
	delete()
