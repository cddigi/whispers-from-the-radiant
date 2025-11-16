extends Control

## Base card face template for creating individual card artwork.
## This scene serves as a visual guide for portrait placement and composition.
## Export this scene at desired resolution to create card face images.

@onready var border := %BorderTexture as TextureRect
@onready var portrait_guide := %PortraitGuide as ColorRect
@onready var safe_area := %SafeArea as ColorRect


func _ready() -> void:
	# This is just a visual template - no runtime logic needed
	pass


## Export this scene as an image for use as card face texture
func export_as_texture(output_path: String) -> void:
	# Get the viewport
	var viewport := get_viewport()

	# Wait for rendering to complete
	await RenderingServer.frame_post_draw

	# Get the rendered image
	var img := viewport.get_texture().get_image()

	# Save to file
	img.save_png(output_path)

	print("Exported card face to: ", output_path)
