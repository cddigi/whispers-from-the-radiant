# Card Portrait Mapping

Complete mapping of all 33 card portraits organized by suit and rank.

## Mental Aspect (Blue 🧠)

Consistent deep blue background with psychohistorical equations and mental energy themes.

| Rank | Ability | Theme | Filename |
|------|---------|-------|----------|
| 1 | Whispered Redirection | Mysterious hooded mentalic whispering | `2025-11-15_204604.png` |
| 2 | - | Two psychic minds in harmony | `2025-11-15_204630.png` |
| 3 | Mental Static | Interference patterns disrupting psychic field | `2025-11-15_204655.png` |
| 4 | - | Four psychic nodes connected | `2025-11-15_204720.png` |
| 5 | Intuitive Leap | Figure ascending through psychic dimensions | `2025-11-15_204745.png` |
| 6 | - | Six psychic nodes forming hexagonal network | `2025-11-15_204831.png` |
| 7 | Conversion Point | Seven minds being converted to the Plan | `2025-11-15_204901.png` |
| 8 | - | Eight possible futures branching | `2025-11-15_204931.png` |
| 9 | Mentalic Resonance | Nine resonating psychic waves harmonizing | `2025-11-15_204956.png` |
| 10 | - | Ten psychohistorical equations layered | `2025-11-15_205022.png` |
| 11 | Imperial Decree | First Speaker commanding presence | `2025-11-15_205047.png` |

## Physical Aspect (Gold ⚔️)

Consistent golden background with trade routes, technology, and industrial power themes.

| Rank | Ability | Theme | Filename |
|------|---------|-------|----------|
| 1 | Whispered Redirection | Subtle merchant whispering trade secrets | `2025-11-15_205133.png` |
| 2 | - | Two fleets in military-economic equilibrium | `2025-11-15_205158.png` |
| 3 | Mental Static | Disrupted technology and glitching machinery | `2025-11-15_205223.png` |
| 4 | - | Four industrial foundations/trade centers | `2025-11-15_205248.png` |
| 5 | Intuitive Leap | Rocket launch technological breakthrough | `2025-11-15_205313.png` |
| 6 | - | Six trade routes intersecting hexagonally | `2025-11-15_205338.png` |
| 7 | Conversion Point | Seven worlds converting to Foundation control | `2025-11-15_205418.png` |
| 8 | - | Eight shipping lanes and fleet formations | `2025-11-15_205443.png` |
| 9 | Mentalic Resonance | Nine reactors harmonizing in perfect sync | `2025-11-15_205508.png` |
| 10 | - | Ten industrial complexes networked | `2025-11-15_205533.png` |
| 11 | Imperial Decree | Mayor of Terminus commanding authority | `2025-11-15_205558.png` |

## Temporal Aspect (Red ⏳)

Consistent deep red background with time streams, historical moments, and Seldon Plan themes.

| Rank | Ability | Theme | Filename |
|------|---------|-------|----------|
| 1 | Whispered Redirection | Mysterious figure whispering across time | `2025-11-15_205645.png` |
| 2 | - | Two timelines in temporal equilibrium | `2025-11-15_205710.png` |
| 3 | Mental Static | Disrupted timeline with temporal interference | `2025-11-15_205740.png` |
| 4 | - | Four historical eras/Seldon Crises | `2025-11-15_205810.png` |
| 5 | Intuitive Leap | Figure leaping through temporal epochs | `2025-11-15_205835.png` |
| 6 | - | Six historical nodes intersecting | `2025-11-15_205900.png` |
| 7 | Conversion Point | Seven historical turning points | `2025-11-15_205940.png` |
| 8 | - | Eight branching timeline possibilities | `2025-11-15_210005.png` |
| 9 | Mentalic Resonance | Nine epochs harmonizing in time | `2025-11-15_210030.png` |
| 10 | - | Ten thousand years of psychohistory | `2025-11-15_210055.png` |
| 11 | Imperial Decree | Hari Seldon master of time and fate | `2025-11-15_210120.png` |

## Usage in Code

To use these portraits with the CardTemplate:

```gdscript
# Load the appropriate portrait based on card data
var portrait_path = get_portrait_path(card_data.aspect, card_data.value)
var portrait_texture = load(portrait_path)

# Apply to card template
card_template.set_portrait(portrait_texture)

func get_portrait_path(aspect: CardData.Aspect, rank: int) -> String:
    var aspect_name = ""
    match aspect:
        CardData.Aspect.MENTAL:
            aspect_name = "mental"
        CardData.Aspect.PHYSICAL:
            aspect_name = "physical"
        CardData.Aspect.TEMPORAL:
            aspect_name = "temporal"

    # Map rank to filename (see table above)
    var filename = get_filename_for_card(aspect, rank)
    return "res://assets/cardfaces/portraits/" + filename
```

## Design Consistency

Each suit maintains visual consistency:

- **Mental**: Deep blue backgrounds, psychic energy, ethereal glows, Second Foundation mystique
- **Physical**: Golden backgrounds, industrial/military power, trade networks, First Foundation strength
- **Temporal**: Deep red backgrounds, time streams, historical moments, Seldon Plan vision

All portraits fit within the 358×410px portrait area defined in `base_cardface.tscn`.

## Future Enhancements

- [ ] Rename files to descriptive names (e.g., `mental_01_whispered.png`)
- [ ] Create higher resolution versions for print/export
- [ ] Add animated versions for special abilities
- [ ] Commission custom artwork for specific Foundation characters
- [ ] Create aspect-specific border variations to complement portraits
