# Complete Card Deck Mapping

All 33 complete card faces with border + portrait composite images.

## File Naming Convention

`{aspect}_{rank}.png` where:
- **aspect**: `mental`, `physical`, or `temporal`
- **rank**: `01` through `11` (zero-padded)

## Mental Aspect Cards (🧠 Blue)

| Rank | Ability | Filename | Description |
|------|---------|----------|-------------|
| 1 | Whispered Redirection | `mental_01.png` | If you lose this trick, lead the next |
| 2 | - | `mental_02.png` | Standard card |
| 3 | Mental Static | `mental_03.png` | Exchange Prime Radiant card with one from hand |
| 4 | - | `mental_04.png` | Standard card |
| 5 | Intuitive Leap | `mental_05.png` | Draw 1 card, then discard 1 to bottom |
| 6 | - | `mental_06.png` | Standard card |
| 7 | Conversion Point | `mental_07.png` | Winner receives 1 point per 7 in trick |
| 8 | - | `mental_08.png` | Standard card |
| 9 | Mentalic Resonance | `mental_09.png` | If only 9 in trick, treated as dominant aspect |
| 10 | - | `mental_10.png` | Standard card |
| 11 | Imperial Decree | `mental_11.png` | Opponent must play 1 or highest of aspect |

## Physical Aspect Cards (⚔️ Gold)

| Rank | Ability | Filename | Description |
|------|---------|----------|-------------|
| 1 | Whispered Redirection | `physical_01.png` | If you lose this trick, lead the next |
| 2 | - | `physical_02.png` | Standard card |
| 3 | Mental Static | `physical_03.png` | Exchange Prime Radiant card with one from hand |
| 4 | - | `physical_04.png` | Standard card |
| 5 | Intuitive Leap | `physical_05.png` | Draw 1 card, then discard 1 to bottom |
| 6 | - | `physical_06.png` | Standard card |
| 7 | Conversion Point | `physical_07.png` | Winner receives 1 point per 7 in trick |
| 8 | - | `physical_08.png` | Standard card |
| 9 | Mentalic Resonance | `physical_09.png` | If only 9 in trick, treated as dominant aspect |
| 10 | - | `physical_10.png` | Standard card |
| 11 | Imperial Decree | `physical_11.png` | Opponent must play 1 or highest of aspect |

## Temporal Aspect Cards (⏳ Red)

| Rank | Ability | Filename | Description |
|------|---------|----------|-------------|
| 1 | Whispered Redirection | `temporal_01.png` | If you lose this trick, lead the next |
| 2 | - | `temporal_02.png` | Standard card |
| 3 | Mental Static | `temporal_03.png` | Exchange Prime Radiant card with one from hand |
| 4 | - | `temporal_04.png` | Standard card |
| 5 | Intuitive Leap | `temporal_05.png` | Draw 1 card, then discard 1 to bottom |
| 6 | - | `temporal_06.png` | Standard card |
| 7 | Conversion Point | `temporal_07.png` | Winner receives 1 point per 7 in trick |
| 8 | - | `temporal_08.png` | Standard card |
| 9 | Mentalic Resonance | `temporal_09.png` | If only 9 in trick, treated as dominant aspect |
| 10 | - | `temporal_10.png` | Standard card |
| 11 | Imperial Decree | `temporal_11.png` | Opponent must play 1 or highest of aspect |

## Card Face Specifications

- **Dimensions**: 512×768 pixels (2:3 aspect ratio)
- **Components**:
  - Ornate border frame (elegant holographic blue-gold design)
  - Character/thematic portrait (358×410px, centered)
  - Rank and suit indicators (rendered by CardTemplate overlay)
  - Ability text (rendered by CardTemplate for odd ranks only)

## Usage in Game

These card face images are used as the `portrait` texture in the `CardTemplate` scene:

```gdscript
# Load complete card face
var card_face = load("res://assets/cardfaces/deck/mental_07.png")

# Create card template instance
var card = CardTemplate.new()

# Set card data (for rank/suit/ability overlays)
var card_data = CardData.new(7, CardData.Aspect.MENTAL)
card.set_card_data(card_data)

# Set the card face image
card.set_portrait(card_face)
```

The `CardTemplate` will overlay:
- Rank numbers (top-left and bottom-right corners)
- Suit emoji symbols (below ranks)
- Ability panel (for odd ranks: 1, 3, 5, 7, 9, 11)

## Generation Details

Card faces were generated using `generate_deck.gd` which composites:
1. Default border (`default_border.png`)
2. Aspect-specific portrait artwork from `/portraits/` directory

All 33 cards maintain visual consistency within their aspect while varying by rank theme.

## File Sizes

Each PNG ranges from ~120-160KB, totaling approximately 4-5MB for the complete deck.
