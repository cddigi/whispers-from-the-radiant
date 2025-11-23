extends SceneTree

## Generates complete card face images for all 33 cards in the deck
## Composites border + portrait + ability text overlay
## Run with: godot -s res://assets/cardfaces/generate_deck.gd

const CARD_WIDTH = 512
const CARD_HEIGHT = 768

# Portrait filename mapping (from PORTRAIT_MAPPING.md)
const MENTAL_PORTRAITS = [
	"2025-11-15_204604.png",  # 1
	"2025-11-15_204630.png",  # 2
	"2025-11-15_204655.png",  # 3
	"2025-11-15_204720.png",  # 4
	"2025-11-15_204745.png",  # 5
	"2025-11-15_204831.png",  # 6
	"2025-11-15_204901.png",  # 7
	"2025-11-15_204931.png",  # 8
	"2025-11-15_204956.png",  # 9
	"2025-11-15_205022.png",  # 10
	"2025-11-15_205047.png",  # 11
]

const PHYSICAL_PORTRAITS = [
	"2025-11-15_205133.png",  # 1
	"2025-11-15_205158.png",  # 2
	"2025-11-15_205223.png",  # 3
	"2025-11-15_205248.png",  # 4
	"2025-11-15_205313.png",  # 5
	"2025-11-15_205338.png",  # 6
	"2025-11-15_205418.png",  # 7
	"2025-11-15_205443.png",  # 8
	"2025-11-15_205508.png",  # 9
	"2025-11-15_205533.png",  # 10
	"2025-11-15_205558.png",  # 11
]

const TEMPORAL_PORTRAITS = [
	"2025-11-15_205645.png",  # 1
	"2025-11-15_205710.png",  # 2
	"2025-11-15_205740.png",  # 3
	"2025-11-15_205810.png",  # 4
	"2025-11-15_205835.png",  # 5
	"2025-11-15_205900.png",  # 6
	"2025-11-15_205940.png",  # 7
	"2025-11-15_210005.png",  # 8
	"2025-11-15_210030.png",  # 9
	"2025-11-15_210055.png",  # 10
	"2025-11-15_210120.png",  # 11
]

func _init() -> void:
	print("=== Generating Full Card Deck ===")
	print("Creating 33 complete card faces...")

	# Generate all Mental cards (1-11)
	for rank in range(1, 12):
		generate_card(CardData.Aspect.MENTAL, rank, MENTAL_PORTRAITS[rank - 1])

	# Generate all Physical cards (1-11)
	for rank in range(1, 12):
		generate_card(CardData.Aspect.PHYSICAL, rank, PHYSICAL_PORTRAITS[rank - 1])

	# Generate all Temporal cards (1-11)
	for rank in range(1, 12):
		generate_card(CardData.Aspect.TEMPORAL, rank, TEMPORAL_PORTRAITS[rank - 1])

	print("\n✓ All 33 card faces generated successfully!")
	print("Output directory: res://assets/cardfaces/deck/")

	quit()


func generate_card(aspect: CardData.Aspect, rank: int, portrait_filename: String) -> void:
	# Create card data
	var card_data: CardData = CardData.new(rank, aspect)

	# Load resources
	var border_tex: Texture2D = load("res://assets/cardfaces/default_border.png")
	var portrait_tex: Texture2D = load("res://assets/cardfaces/portraits/" + portrait_filename)

	if not border_tex or not portrait_tex:
		print("ERROR: Failed to load textures for card ", get_card_name(aspect, rank))
		return

	# Create composite image
	var img: Image = Image.create(CARD_WIDTH, CARD_HEIGHT, false, Image.FORMAT_RGBA8)

	# Draw border
	var border_img: Image = border_tex.get_image()
	if border_img:
		border_img.resize(CARD_WIDTH, CARD_HEIGHT, Image.INTERPOLATE_LANCZOS)
		img.blit_rect(border_img, Rect2i(0, 0, CARD_WIDTH, CARD_HEIGHT), Vector2i(0, 0))

	# Draw portrait (centered at approximately 256, 384 - middle of card)
	var portrait_img: Image = portrait_tex.get_image()
	if portrait_img:
		var portrait_w: int = 358
		var portrait_h: int = 410
		portrait_img.resize(portrait_w, portrait_h, Image.INTERPOLATE_LANCZOS)
		var portrait_x: int = (CARD_WIDTH - portrait_w) / 2
		var portrait_y: int = (CARD_HEIGHT - portrait_h) / 2
		img.blit_rect(portrait_img, Rect2i(0, 0, portrait_w, portrait_h), Vector2i(portrait_x, portrait_y))

	# Save the image
	var aspect_name: String = get_aspect_name(aspect).to_lower()
	var filename: String = "%s_%02d.png" % [aspect_name, rank]
	var output_path: String = "res://assets/cardfaces/deck/" + filename

	var err: Error = img.save_png(output_path)
	if err == OK:
		print("✓ Generated: ", filename, " (", get_card_name(aspect, rank), ")")
	else:
		print("✗ Failed to save: ", filename)


func get_aspect_name(aspect: CardData.Aspect) -> String:
	match aspect:
		CardData.Aspect.MENTAL:
			return "Mental"
		CardData.Aspect.PHYSICAL:
			return "Physical"
		CardData.Aspect.TEMPORAL:
			return "Temporal"
		_:
			return "Unknown"


func get_card_name(aspect: CardData.Aspect, rank: int) -> String:
	return "%s %d" % [get_aspect_name(aspect), rank]
