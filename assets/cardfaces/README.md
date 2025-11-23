# Card Faces Directory

This directory contains the ornate borders and base templates for creating card face artwork for the Foundation card game.

## Files

### Border Designs

- **default_border.png** - The default ornate border (elegant holographic blue-gold design)
- **2025-11-15_201711.png** - Art nouveau with psychohistory equation borders
- **2025-11-15_201811.png** - Art deco retro-futurism (1950s Foundation era)
- **2025-11-15_201906.png** - Minimalist geometric with subtle patterns
- **2025-11-15_202006.png** - Gothic sci-fi with Prime Radiant equations
- **2025-11-15_202112.png** - Elegant modern holographic (currently used as default)

### Template Scenes

- **base_cardface.tscn** - Base template scene for creating card face artwork
- **base_cardface.gd** - Script for the base template

## Using the Base Card Face Template

The `base_cardface.tscn` scene provides a visual guide for creating card face artwork:

### Layout Guide

```
┌─────────────────────────────┐
│  Rank    [Border Frame]     │ ← Top 100px reserved for rank/suit
│  Suit                       │
│                             │
│    ┌─────────────────┐      │
│    │                 │      │
│    │   Portrait      │      │ ← 358×410px portrait area (centered)
│    │   Area          │      │
│    │                 │      │
│    └─────────────────┘      │
│                             │
│                             │ ← Bottom 100px reserved for ability text
│  [Ability Panel Area]       │
└─────────────────────────────┘
```

### Dimensions

- **Total Card Size**: 512×768 pixels (2:3 aspect ratio)
- **Portrait Area**: 358×410 pixels (centered)
- **Safe Area**: Margins of 26px left/right, 100px top/bottom
- **Rank/Suit Area**: Top-left and bottom-right corners (40×75px each)
- **Ability Area**: Bottom 80px height (for odd-numbered cards only)

### Creating Card Face Artwork

1. **Open the base template**: Load `base_cardface.tscn` in Godot
2. **Add your portrait**: Place character/thematic artwork in the portrait guide area
3. **Export the scene**: Use the `export_as_texture()` method or screenshot at 512×768
4. **Use in CardTemplate**: Call `card_template.set_portrait(your_texture)`

### Portrait Guidelines

- **Aspect Ratio**: Portrait should fit within 358×410px (roughly 7:8 ratio)
- **Theme**: Foundation universe characters, psychohistory visualizations, or abstract sci-fi
- **Style**: Should complement the ornate border aesthetic
- **Colors**: Consider using aspect colors (blue for Mental, gold for Physical, red for Temporal)

### Card Types

#### Odd-Numbered Cards (1, 3, 5, 7, 9, 11)
These have special abilities, so keep portraits clear of the bottom 100px:
- Whispered Redirection (1)
- Mental Static (3)
- Intuitive Leap (5)
- Conversion Point (7)
- Mentalic Resonance (9)
- Imperial Decree (11)

#### Even-Numbered Cards (2, 4, 6, 8, 10)
These are standard cards with no abilities - more vertical space available for portraits.

## Integration with CardTemplate

The `CardTemplate` class (in `assets/cards/`) uses these card faces:

```gdscript
# Create a card
var card = CardTemplate.new()

# Set card data
card.set_card_data(card_data)  # Automatically sets rank, suit, ability

# Optional: Set custom portrait
var portrait = load("res://assets/cardfaces/my_portrait.png")
card.set_portrait(portrait)

# Optional: Override border
var custom_border = load("res://assets/cardfaces/2025-11-15_201711.png")
card.set_border(custom_border)
```

## Future Enhancements

- [ ] Create unique portraits for each card (33 total)
- [ ] Aspect-specific border variations
- [ ] Animated card faces for special abilities
- [ ] Character portraits from Foundation series
- [ ] Psychohistory equation overlays for different card values
