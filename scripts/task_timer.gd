extends Control

signal task_finished()

@onready var timer = $VBoxContainer/TimerBar/Timer
@onready var timer_button = $"VBoxContainer/TimerBar/Timer Button"
@onready var timer_bar = $VBoxContainer/TimerBar

const PLAY = preload("res://sprites/play.png")
const PAUSE = preload("res://sprites/pause.png")

var current_task : Task


func _ready():
	reset_timer()
	pass

func _process(_delta):
	if (current_task == null):
		return
	if (timer.is_stopped() or timer.paused):
		return
	timer_bar.value = timer.time_left
	current_task.time_left = timer.time_left
	#print(timer_bar.value)
	#if(timer.is_stopped() or timer.paused):
		#return
	#
	#if (timer_bar.value <= 0):
		#update_task(true) #Completed = true
		
func reset_timer():
	current_task = null
	timer_bar.value = 0
	timer_button.icon = PLAY

func update_task(completed = false):
	current_task.time_left = max(timer.time_left, 0)
	
	if (completed == false):
		return
		
	timer_button.icon = PLAY
	current_task._finish()
	current_task = null
	task_finished.emit()

func _on_timer_button_pressed():
	if (current_task == null):
		return
	
	if (timer.is_stopped()):
		timer.start()
		timer_button.icon = PAUSE
		current_task._resume()
		return
	
	timer.paused = not timer.paused
	if (timer.paused):
		timer_button.icon = PLAY
		current_task._pause()
		update_task()
	else:
		timer_button.icon = PAUSE
		current_task._resume()
		
func _stop_timer():		
	timer.stop()
	timer_button.icon = PLAY
	
func _add_task(new_task):
	current_task = new_task
	reset_timer_task_values()


func reset_timer_task_values():	
		#Can't change wait time directly
	timer.wait_time = current_task.time_left
	timer.start()
	timer.paused = true
	timer.wait_time = current_task.duration
	
	timer_bar.max_value = current_task.duration
	timer_bar.value = current_task.time_left
	
func _on_timer_timeout():
	update_task(true) #Completed = true
