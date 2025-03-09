extends Sprite2D

@export var scroll_speed: float = 0.01  # Pixels per frame

func _ready() -> void:
	# Set the initial region to the full texture size
	if texture:
		region_rect = Rect2(Vector2.ZERO, texture.get_size())
	else:
		push_warning("Texture not set for background sprite!")

func _process(delta: float) -> void:
	if texture:	
		# Update the region's x position
		region_rect.position.x += scroll_speed
		
		# Reset the position if it exceeds the texture width to create a loop
		if region_rect.position.x >= texture.get_width():
			region_rect.position.x = 0
	elif not texture:
		push_warning("Texture not set for background sprite!")
