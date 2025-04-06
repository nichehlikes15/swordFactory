extends Node

const Settings_Save_Path : String = "user://data.json"
const Default_Save_Data : Dictionary = {
	"cash": 0,
	"unlocked_stations": {
		"Molder": false,
		"Polisher": false,
		"Classifier": false,
		"Upgrader": false,
		"Enchanter": false,
		"Appraiser": false
	},
	"banked_items": {
		"Slot1": null,
		"Slot2": null,
		"Slot3": null,
		"Slot4": null,
		"Slot5": null,
		"Slot6": null,
		"Slot7": null,
		"Slot8": {"molderRarities" : "Diamond", "polisherRarities" : "Phenomenal"}
	},
	"ascender": {"molderRarities" : "Diamond", "polisherRarities" : "Phenomenal"}
}

func _ready():
	get_tree().connect("tree_exiting", Callable(self, "_on_exit_save"))  
	print("Save file location: ", ProjectSettings.globalize_path(Settings_Save_Path))

	var loaded_data = load_game()  # Load game data
	print("Loaded data from load_game(): ", loaded_data)

	print("Cash value: ", loaded_data["cash"])
	print("Banked items Slot1: ", loaded_data["banked_items"]["Slot1"])

func save_game(data : Dictionary):
	var saveFile = FileAccess.open(Settings_Save_Path, FileAccess.WRITE)
	if saveFile == null:
		print("Failed to open save file for writing.")
		return

	var json_data_string = JSON.stringify(data)
	#print("Saving data: ", json_data_string)  # Debug print to ensure the data is what you expect
	saveFile.store_string(json_data_string)
	saveFile.close()
	#print("Game saved successfully!")
	print("Save file location: ", ProjectSettings.globalize_path(Settings_Save_Path))

func load_game() -> Dictionary:
	# Check if the file exists, otherwise create a new one
	if not FileAccess.file_exists(Settings_Save_Path):
		print("No save file found. Creating a new one...")
		save_game(Default_Save_Data)  
		return Default_Save_Data  

	# Try opening the file for reading
	var saveFile = FileAccess.open(Settings_Save_Path, FileAccess.READ)
	if saveFile == null:
		print("Failed to open save file for reading.")
		return Default_Save_Data

	var json_data_string = saveFile.get_as_text()
	saveFile.close()

	# Debug print to show the raw string
	#print("Loaded JSON string: ", json_data_string)

	# Parse the saved data
	var parsed_data = JSON.parse_string(json_data_string)
	if parsed_data is Dictionary:
		#print("Game loaded successfully!")
		return parsed_data
	else:
		print("Failed to load save data. Resetting to default values.")
		save_game(Default_Save_Data)  
		return Default_Save_Data  

func _on_exit_save():
	var current_game_data = load_game()
	save_game(current_game_data)
	print("Game saved on exit...")

func get_value(key: String):
	var loaded_data = load_game()
	#print("Loaded game data: ", loaded_data)
	if key in loaded_data:
		return loaded_data[key]
	else:
		print("Key not found: ", key)
		return null

func set_value(key: String, value):
	var loaded_data = load_game()
	loaded_data[key] = value
	save_game(loaded_data)
	print("Saved value for key '", key, "': ", value)
