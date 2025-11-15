# Assets Directory Structure

This directory contains all game assets organized by feature following Godot 4.5 best practices.

## Directory Organization

### `/cards/`
Card-related assets including the card scene, controller script, and resource definitions.

- `card_data.gd` - CardData resource class (Mental/Physical/Temporal aspects, values 1-11)
- `card.tscn` - Visual card scene with ColorRect background and labels
- `card.gd` - Card display controller
- `visuals/` - Card graphics (placeholder for future assets)

### `/game/`
Core game logic and state management.

- `game_state.gd` - GameState resource for managing match state
- `game_board.tscn` - Main game board scene (future)
- `game_board.gd` - Game controller (future)
- `managers/` - Game system managers
  - `deck_generator.gd` - Deck creation and manipulation utilities

### `/network/`
Multiplayer networking infrastructure (future).

- Network manager autoload
- Lobby scenes for host/join
- RPC synchronization

### `/ui/`
User interface components organized by feature.

- `theme/` - Second Foundation themed resources
- `hud/` - Heads-up display
- `score_display/` - Score tracking UI
- `mental_shield/` - Card concealment system

### `/effects/`
Visual and audio effects.

- `shaders/` - GLSL shaders (Prime Radiant glow, mental static)
- `particles/` - Particle systems (equation particles)
- `animations/` - Animation resources

### `/test/`
Test scenes for development and validation.

- `test_cards.tscn` - Stage 1 card generation test scene
- `test_cards.gd` - Test controller with validation

## Naming Conventions

- **Files**: snake_case (e.g., `card_data.gd`, `deck_generator.gd`)
- **Nodes**: PascalCase (e.g., `CardContainer`, `Background`)
- **Classes**: PascalCase with `class_name` (e.g., `class_name CardData`)
- **Variables**: snake_case with type hints (e.g., `var aspect: Aspect`)
- **Signals**: past_tense_snake_case (e.g., `signal card_selected`)

## Asset Prefixing

Exclusive resources are prefixed with their scene name:
- `player_sprite.png`
- `card_mental_bg.png`

Shared resources use descriptive names without prefixes:
- `metal_material.tres`
- `outline_shader.gdshader`

## Scene Organization

Each scene is self-contained with:
1. Root node with controller script
2. Only references to direct children (no deep tree navigation)
3. External dependencies via @export for dependency injection
4. Signals for upward communication
5. Direct method calls for downward communication
