# UI and Control Nodes

**Purpose**: Comprehensive UI development patterns for Godot 4.6
**Focus**: Control node hierarchy, layout containers, theming, FileDialog enhancements (4.5-4.6), input handling, Control pivot offset ratio (NEW 4.6)

---

## Control Node Hierarchy

### Control Node Fundamentals

```gdscript
# Control: Base class for all UI elements
# Inherits from CanvasItem, provides:
# - Anchors and margins
# - Size flags
# - Focus management
# - Mouse filtering
# - Theming

@onready var my_control: Control = $Control

func _ready() -> void:
    # Size and position:
    my_control.size = Vector2(200, 100)
    my_control.position = Vector2(50, 50)
    my_control.custom_minimum_size = Vector2(100, 50)

    # Visibility:
    my_control.visible = true
    my_control.modulate = Color(1, 1, 1, 0.5)  # 50% transparent

    # Mouse interaction:
    my_control.mouse_filter = Control.MOUSE_FILTER_STOP  # Receive and block
    # Control.MOUSE_FILTER_PASS  # Receive but pass through
    # Control.MOUSE_FILTER_IGNORE  # Don't receive

    # Focus:
    my_control.focus_mode = Control.FOCUS_ALL  # Can receive focus
    # Control.FOCUS_CLICK  # Focus on click
    # Control.FOCUS_NONE  # No focus
```

### UI Scene Structure

```gdscript
# Proper UI hierarchy:
UI (Control) - Full Rect anchor
├── CanvasLayer (layer: 100)
│   └── HUD (Control) - Full Rect
│       ├── MarginContainer (32px margins)
│       │   └── VBoxContainer
│       │       ├── TopBar (HBoxContainer)
│       │       │   ├── HealthBar (ProgressBar)
│       │       │   └── Score (Label)
│       │       └── BottomBar (HBoxContainer)
│       │           ├── WeaponSlot (TextureRect)
│       │           └── AmmoCount (Label)
│       └── PauseMenu (Control) - Center anchor
│           └── Panel
│               └── VBoxContainer
│                   ├── Title (Label)
│                   ├── ResumeButton (Button)
│                   └── QuitButton (Button)

# Principles:
# - Use CanvasLayer for UI (independent of scene transform)
# - MarginContainer for breathing room
# - Containers for automatic layout
# - Control nodes for manual positioning
```

---

## Anchor and Margin System

### Anchor Presets

```gdscript
# Anchors define where Control edges attach to parent (0.0 to 1.0)
@onready var control: Control = $Control

func setup_anchors() -> void:
    # Full Rect (fill parent):
    control.anchor_left = 0.0
    control.anchor_top = 0.0
    control.anchor_right = 1.0
    control.anchor_bottom = 1.0
    control.offset_left = 0
    control.offset_top = 0
    control.offset_right = 0
    control.offset_bottom = 0

    # Center:
    control.anchor_left = 0.5
    control.anchor_top = 0.5
    control.anchor_right = 0.5
    control.anchor_bottom = 0.5
    control.offset_left = -100  # Half width
    control.offset_right = 100
    control.offset_top = -50    # Half height
    control.offset_bottom = 50

    # Top Wide (spans width, stays at top):
    control.anchor_left = 0.0
    control.anchor_top = 0.0
    control.anchor_right = 1.0
    control.anchor_bottom = 0.0
    control.offset_bottom = 100  # 100px tall

# Anchor layout examples:
# Health bar - top-left:
health_bar.anchor_right = 0.3
health_bar.anchor_bottom = 0.1

# Minimap - top-right:
minimap.anchor_left = 0.8
minimap.anchor_right = 1.0
minimap.anchor_bottom = 0.2

# Action bar - bottom-center:
action_bar.anchor_left = 0.3
action_bar.anchor_top = 0.9
action_bar.anchor_right = 0.7
action_bar.anchor_bottom = 1.0
```

### Control Pivot Offset Ratio (NEW in 4.6)

```gdscript
# NEW in 4.6: pivot_offset as ratio of size (0.0-1.0)
@onready var button: Button = $Button

func setup_pivot() -> void:
    # OLD way (pixel-based pivot):
    button.pivot_offset = Vector2(50, 25)  # Specific pixels

    # NEW in 4.6 (ratio-based, responsive):
    # Set via property or in inspector:
    # pivot_offset_ratio = Vector2(0.5, 0.5)  # Center of control

    # Rotate around center:
    button.rotation = deg_to_rad(45)

# Use case: Scaling UI elements from center
func pulse_button() -> void:
    var tween = create_tween()
    tween.tween_property(button, "scale", Vector2(1.2, 1.2), 0.2)
    tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
```

---

## Layout Containers

### Container Types

| Container | Purpose | Layout |
|-----------|---------|--------|
| **VBoxContainer** | Vertical stack | Top to bottom |
| **HBoxContainer** | Horizontal stack | Left to right |
| **GridContainer** | Grid | Rows and columns |
| **MarginContainer** | Add padding | Single child |
| **ScrollContainer** | Scrollable | Single child |
| **PanelContainer** | Styled background | Single child |
| **CenterContainer** | Center child | Single child |
| **SplitContainer** | Resizable split | Two children |
| **TabContainer** | Tabbed interface | Multiple children |
| **FlowContainer** | Wrap overflow | Horizontal/vertical |

### VBoxContainer / HBoxContainer

```gdscript
# VBoxContainer: Vertical layout
@onready var vbox: VBoxContainer = $VBoxContainer

func setup_vbox() -> void:
    vbox.add_theme_constant_override("separation", 10)  # Spacing between children

    # Add children:
    var label = Label.new()
    label.text = "Title"
    vbox.add_child(label)

    var button = Button.new()
    button.text = "Click Me"
    vbox.add_child(button)

# Size flags control child behavior:
func setup_size_flags() -> void:
    # FILL: Take available space
    button.size_flags_horizontal = Control.SIZE_FILL
    button.size_flags_vertical = Control.SIZE_FILL

    # EXPAND: Request space from parent
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.size_flags_vertical = Control.SIZE_EXPAND_FILL

    # SHRINK_CENTER: Minimum size, centered
    label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

    # Stretch ratio (relative sizing):
    button1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button1.size_flags_stretch_ratio = 2.0  # Takes 2x space

    button2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button2.size_flags_stretch_ratio = 1.0  # Takes 1x space
    # Result: button1 gets 2/3 width, button2 gets 1/3 width
```

### GridContainer

```gdscript
# GridContainer: Grid layout
@onready var grid: GridContainer = $GridContainer

func setup_grid() -> void:
    grid.columns = 3  # 3 columns, rows auto-calculate

    # Add 9 items (creates 3x3 grid):
    for i in 9:
        var button = Button.new()
        button.text = "Item %d" % i
        button.custom_minimum_size = Vector2(100, 50)
        grid.add_child(button)

# Inventory grid example:
const GRID_SIZE = Vector2i(5, 4)  # 5x4 inventory

func create_inventory_grid() -> void:
    grid.columns = GRID_SIZE.x

    for i in GRID_SIZE.x * GRID_SIZE.y:
        var slot = TextureRect.new()
        slot.custom_minimum_size = Vector2(64, 64)
        slot.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
        grid.add_child(slot)
```

### MarginContainer

```gdscript
# MarginContainer: Add padding around single child
@onready var margin: MarginContainer = $MarginContainer

func setup_margins() -> void:
    # Set margins:
    margin.add_theme_constant_override("margin_left", 32)
    margin.add_theme_constant_override("margin_right", 32)
    margin.add_theme_constant_override("margin_top", 16)
    margin.add_theme_constant_override("margin_bottom", 16)

# Common pattern: Full-screen UI with margins
func create_ui() -> void:
    var root = Control.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(root)

    var margin_container = MarginContainer.new()
    margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
    margin_container.add_theme_constant_override("margin_left", 40)
    margin_container.add_theme_constant_override("margin_right", 40)
    margin_container.add_theme_constant_override("margin_top", 20)
    margin_container.add_theme_constant_override("margin_bottom", 20)
    root.add_child(margin_container)

    # Content goes inside:
    var content = VBoxContainer.new()
    margin_container.add_child(content)
```

### ScrollContainer

```gdscript
# ScrollContainer: Make content scrollable
@onready var scroll: ScrollContainer = $ScrollContainer

func setup_scroll() -> void:
    # Scroll mode:
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

    # Scroll properties:
    scroll.scroll_horizontal = 0  # Scroll position
    scroll.scroll_vertical = 100

    # Follow focus:
    scroll.follow_focus = true

# Signals:
func _ready() -> void:
    scroll.scroll_started.connect(_on_scroll_started)
    scroll.scroll_ended.connect(_on_scroll_ended)

# Scroll to position:
func scroll_to_bottom() -> void:
    await get_tree().process_frame
    scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value

# Long content example:
func create_log_viewer() -> void:
    var vbox = VBoxContainer.new()
    scroll.add_child(vbox)

    for i in 100:
        var label = Label.new()
        label.text = "Log entry %d" % i
        vbox.add_child(label)
```

---

## Theming System

### Theme Hierarchy

```gdscript
# Theme priority (highest to lowest):
# 1. Control's theme overrides (in inspector)
# 2. Control's theme property
# 3. Parent Control's theme (inherited)
# 4. Project default theme (Project Settings)

# Set project-wide theme:
# Project Settings → GUI → Theme → Custom = theme.tres

# Create theme in code:
var theme = Theme.new()

# Fonts:
var font = load("res://fonts/main_font.ttf")
theme.set_font("font", "Label", font)
theme.set_font_size("font_size", "Label", 16)

# Colors:
theme.set_color("font_color", "Label", Color.WHITE)
theme.set_color("font_color", "Button", Color.BLACK)

# StyleBoxes:
var button_normal = StyleBoxFlat.new()
button_normal.bg_color = Color(0.2, 0.2, 0.2)
button_normal.corner_radius_top_left = 5
button_normal.corner_radius_top_right = 5
button_normal.corner_radius_bottom_left = 5
button_normal.corner_radius_bottom_right = 5
theme.set_stylebox("normal", "Button", button_normal)

# Apply theme:
get_tree().root.theme = theme
```

### StyleBox Types

```gdscript
# StyleBoxFlat: Procedural styling
var style = StyleBoxFlat.new()
style.bg_color = Color(0.1, 0.1, 0.1)
style.border_color = Color.WHITE
style.border_width_left = 2
style.border_width_top = 2
style.border_width_right = 2
style.border_width_bottom = 2
style.corner_radius_top_left = 10
style.corner_radius_top_right = 10
style.corner_radius_bottom_left = 10
style.corner_radius_bottom_right = 10
style.shadow_color = Color(0, 0, 0, 0.5)
style.shadow_size = 5
style.shadow_offset = Vector2(2, 2)

# StyleBoxTexture: 9-slice texture
var texture_style = StyleBoxTexture.new()
texture_style.texture = load("res://ui/panel.png")
texture_style.region_rect = Rect2(0, 0, 64, 64)
# Margins define 9-slice areas:
texture_style.texture_margin_left = 10
texture_style.texture_margin_top = 10
texture_style.texture_margin_right = 10
texture_style.texture_margin_bottom = 10
texture_style.modulate_color = Color(0.8, 0.8, 1.0)  # Tint

# Apply to button:
button.add_theme_stylebox_override("normal", style)
button.add_theme_stylebox_override("hover", hover_style)
button.add_theme_stylebox_override("pressed", pressed_style)
```

### Theme Variations (Type Variations)

```gdscript
# Create type variations for specialized styles:
# In theme editor: Add Type Variation

# Example: Create "DangerButton" based on "Button"
var theme = Theme.new()

# Copy base button styles:
var danger_normal = StyleBoxFlat.new()
danger_normal.bg_color = Color(0.8, 0.2, 0.2)  # Red
theme.set_stylebox("normal", "DangerButton", danger_normal)

var danger_hover = StyleBoxFlat.new()
danger_hover.bg_color = Color(1.0, 0.3, 0.3)  # Lighter red
theme.set_stylebox("hover", "DangerButton", danger_hover)

theme.set_color("font_color", "DangerButton", Color.WHITE)

# Use in scene:
button.theme_type_variation = "DangerButton"

# Common variations:
# - "HeaderLabel" (larger font)
# - "ConfirmButton" (green)
# - "DangerButton" (red)
# - "SubtleButton" (transparent)
```

---

## Common Control Nodes

### Button

```gdscript
@onready var button: Button = $Button

func _ready() -> void:
    button.text = "Click Me"
    button.icon = load("res://icons/play.png")
    button.flat = false  # false = styled, true = flat
    button.disabled = false

    # Signals:
    button.pressed.connect(_on_button_pressed)
    button.button_down.connect(_on_button_down)
    button.button_up.connect(_on_button_up)

func _on_button_pressed() -> void:
    print("Button clicked!")

# Button types:
# - Button: Basic button
# - CheckButton: Checkbox with label
# - CheckBox: Checkbox
# - LinkButton: Text link
# - MenuButton: Button with popup menu
# - OptionButton: Dropdown selection
```

### Label

```gdscript
@onready var label: Label = $Label

func setup_label() -> void:
    label.text = "Hello World"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

    # Text wrapping:
    label.autowrap_mode = TextServer.AUTOWRAP_WORD
    # AUTOWRAP_OFF, AUTOWRAP_ARBITRARY, AUTOWRAP_WORD, AUTOWRAP_WORD_SMART

    # Text overflow:
    label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
    # OVERRUN_NO_TRIMMING, OVERRUN_TRIM_CHAR, OVERRUN_TRIM_WORD

    # Rich text (BBCode):
    var rich_label = RichTextLabel.new()
    rich_label.bbcode_enabled = true
    rich_label.text = "[center][color=red]Red Text[/color][/center]"
    rich_label.text += "\n[b]Bold[/b] [i]Italic[/i]"
```

### LineEdit / TextEdit

```gdscript
@onready var line_edit: LineEdit = $LineEdit
@onready var text_edit: TextEdit = $TextEdit

func setup_text_input() -> void:
    # LineEdit: Single-line input
    line_edit.placeholder_text = "Enter name..."
    line_edit.max_length = 20
    line_edit.secret = false  # true for password
    line_edit.editable = true

    # Signals:
    line_edit.text_changed.connect(_on_text_changed)
    line_edit.text_submitted.connect(_on_text_submitted)

    # TextEdit: Multi-line input
    text_edit.placeholder_text = "Enter description..."
    text_edit.editable = true
    text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY

func _on_text_changed(new_text: String) -> void:
    print("Text: ", new_text)

func _on_text_submitted(text: String) -> void:
    print("Submitted: ", text)
    # Process input
```

### ProgressBar

```gdscript
@onready var progress: ProgressBar = $ProgressBar

func setup_progress() -> void:
    progress.min_value = 0.0
    progress.max_value = 100.0
    progress.value = 50.0
    progress.show_percentage = true

# Update with health:
func update_health_bar(current: int, maximum: int) -> void:
    progress.max_value = maximum
    progress.value = current

    # Smooth transition:
    var tween = create_tween()
    tween.tween_property(progress, "value", current, 0.3)

# Custom progress bar with fill:
func create_custom_health_bar() -> void:
    var background = TextureRect.new()
    background.texture = load("res://ui/health_bar_bg.png")

    var foreground = TextureRect.new()
    foreground.texture = load("res://ui/health_bar_fill.png")
    foreground.expand_mode = TextureRect.EXPAND_FIT_WIDTH
    background.add_child(foreground)

func update_custom_bar(ratio: float) -> void:
    foreground.scale.x = ratio  # 0.0 to 1.0
```

---

## FileDialog Enhancements (4.5-4.6)

### FileDialog Improvements

```gdscript
# FileDialog: File/folder selection dialog
@onready var file_dialog: FileDialog = $FileDialog

func setup_file_dialog() -> void:
    # Mode:
    file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    # FILE_MODE_OPEN_FILE, FILE_MODE_OPEN_FILES (multiple)
    # FILE_MODE_OPEN_DIR, FILE_MODE_OPEN_ANY
    # FILE_MODE_SAVE_FILE

    # Access:
    file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    # ACCESS_RESOURCES (res://), ACCESS_USERDATA (user://)

    # Filters:
    file_dialog.filters = PackedStringArray(["*.png ; PNG Images", "*.jpg ; JPEG Images"])

    # NEW in 4.5+: Improved layout and icons
    # NEW in 4.6: Better keyboard navigation

    # Signals:
    file_dialog.file_selected.connect(_on_file_selected)
    file_dialog.files_selected.connect(_on_files_selected)
    file_dialog.dir_selected.connect(_on_dir_selected)

func _on_file_selected(path: String) -> void:
    print("Selected: ", path)
    load_file(path)

# Show dialog:
func show_open_dialog() -> void:
    file_dialog.current_dir = "res://"
    file_dialog.current_file = ""
    file_dialog.popup_centered(Vector2(800, 600))

# EditorFileDialog (editor only):
func show_editor_file_dialog() -> void:
    var editor_dialog = EditorFileDialog.new()
    editor_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
    editor_dialog.access = EditorFileDialog.ACCESS_RESOURCES
    add_child(editor_dialog)
    editor_dialog.popup_centered(Vector2(800, 600))
```

---

## Input Handling

### Focus Management (4.6 Improvements)

```gdscript
# Focus system for keyboard/gamepad navigation:
@onready var button1: Button = $Button1
@onready var button2: Button = $Button2
@onready var button3: Button = $Button3

func setup_focus() -> void:
    # Set initial focus:
    button1.grab_focus()

    # Configure focus neighbors:
    button1.focus_neighbor_bottom = button2.get_path()
    button1.focus_next = button2.get_path()

    button2.focus_neighbor_top = button1.get_path()
    button2.focus_neighbor_bottom = button3.get_path()
    button2.focus_previous = button1.get_path()
    button2.focus_next = button3.get_path()

    button3.focus_neighbor_top = button2.get_path()
    button3.focus_previous = button2.get_path()

    # Focus mode:
    button1.focus_mode = Control.FOCUS_ALL
    # FOCUS_NONE, FOCUS_CLICK, FOCUS_ALL

# Focus signals:
func _ready() -> void:
    button1.focus_entered.connect(_on_button1_focus_entered)
    button1.focus_exited.connect(_on_button1_focus_exited)

# NEW in 4.6: Improved focus navigation
# Better tab order, gamepad D-pad navigation
```

### Mouse Input

```gdscript
# _gui_input for Control nodes:
func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mouse_event = event as InputEventMouseButton

        if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
            print("Left click at: ", mouse_event.position)

        if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_RIGHT:
            print("Right click")

    elif event is InputEventMouseMotion:
        var motion_event = event as InputEventMouseMotion
        print("Mouse moved: ", motion_event.relative)

# Mouse signals:
func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    gui_input.connect(_on_gui_input)

# Stop event propagation:
func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        accept_event()  # Consume event, don't pass to parent
```

### Drag and Drop

```gdscript
# Source control (draggable):
func _get_drag_data(at_position: Vector2) -> Variant:
    # Return data to be dragged:
    var data = {"type": "item", "id": 123}

    # Create preview:
    var preview = TextureRect.new()
    preview.texture = item_icon
    set_drag_preview(preview)

    return data

# Target control (drop receiver):
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
    # Return true if we accept this data:
    if data is Dictionary and data.get("type") == "item":
        return true
    return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
    # Handle dropped data:
    var item_id = data.get("id")
    print("Dropped item: ", item_id)
    add_item(item_id)
```

---

## Responsive UI

### Window Resize Handling

```gdscript
# Detect window resize:
func _ready() -> void:
    get_viewport().size_changed.connect(_on_viewport_size_changed)

func _on_viewport_size_changed() -> void:
    var size = get_viewport().size
    print("New size: ", size)

    # Adjust UI for small screens:
    if size.x < 800:
        switch_to_compact_layout()
    else:
        switch_to_full_layout()

# Stretch mode (Project Settings):
# Display → Window → Stretch → Mode:
# - disabled: No scaling
# - canvas_items: Scale UI (recommended for 2D/UI)
# - viewport: Scale entire viewport

# Stretch Aspect:
# - ignore: Stretch to fill
# - keep: Letterbox/pillarbox
# - keep_width: Scale to width
# - keep_height: Scale to height
# - expand: Expand to fill
```

---

## Cross-Reference

**Related Guidelines**:
- Scene architecture → `02-scene-architecture.md#signals`
- Theming resources → `02-scene-architecture.md#resources`
- Input handling → `01-gdscript-modern-patterns.md#input`
- Platform UI → `07-platform-performance.md#platform-specifics`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Godot Version**: 4.6.0-dev4
**AI Optimization**: Maximum (Control pivot ratio, FileDialog improvements, focus system enhancements)
