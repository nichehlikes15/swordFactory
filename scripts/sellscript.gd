extends TextureButton

signal augmented_pressed(a, b, c)

func _ready() -> void :
	pressed.connect(on_pressed)

func on_pressed() -> void : 
	augmented_pressed.emit(self, 5, "something")
