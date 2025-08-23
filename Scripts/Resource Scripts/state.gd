extends Resource
class_name State


# runs once to set up variables for state
func on_init(camera_controller: CameraController):
	pass


# runs once when state is entered
func on_enter() -> void:
	pass
	

# runs every frame
func on_process(delta: float) -> void:
	pass
	
	
# runs every physics frame
func on_physics_process(delta: float) -> void:
	pass
	
	
# runs once when state is terminated
func on_exit() -> void:
	pass
	
	
# runs every time input event is detected
func on_input(event: InputEvent) -> void:
	pass
