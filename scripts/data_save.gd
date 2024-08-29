extends Node

signal task_loaded(task:Task)

var save_dir = "user://cronotareas.save"
var config_dir = "user://options.cfg"

func save_tasks():
	var save_nodes = get_tree().get_nodes_in_group("save_nodes")
	if save_nodes == []:
		delete_tasks_save()
		return
	
	var save_file = FileAccess.open(save_dir, FileAccess.WRITE)
	for node in save_nodes:
		# Now, we can call our save function on each node.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)

func load_tasks():
	if not FileAccess.file_exists(save_dir):
		print("There is no save to load")
		return

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_file = FileAccess.open(save_dir, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		var loaded_task := Task.new()
		loaded_task.state = Task.state_type.values()[node_data["state"]]
		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "state":
				continue
			loaded_task.set(i, node_data[i])

		task_loaded.emit(loaded_task)

func save_options(options:Options):
	var config = ConfigFile.new()
	
	config.set_value("Options", "language", options.language)
	config.set_value("Options", "theme", options.theme)
	
	config.save(config_dir)
	
func load_options():
	var config = ConfigFile.new()
	var error = config.load(config_dir)
	var loaded_options = Options.new()
	
	if error != OK:
		print("Couldn't find options data")
		return null
	
	loaded_options.language = config.get_value("Options","language")
	loaded_options.theme = config.get_value("Options","theme")
	return loaded_options

func delete_tasks_save():
	DirAccess.remove_absolute(save_dir)
	
func delete_options_save():
	DirAccess.remove_absolute(config_dir)
