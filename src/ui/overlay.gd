## The 2D panels from the MVP, shown over the 3D world with Tab until the world's own
## machines, HUD and console replace them (stories 015–017).
extends CanvasLayer

## Loses its controls while the overlay is open.
@export var player: Player


func _ready() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_TAB:
		visible = not visible
		player.hint_blocked = visible
		player.set_controls(not visible)
		get_viewport().set_input_as_handled()
