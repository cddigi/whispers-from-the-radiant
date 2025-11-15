# Implementation Plan: Whispers from the Radiant

## Overview

Building a networked two-player trick-taking card game for Android tablets using Godot 4.5. Players connect via LAN (ENetMultiplayerPeer) to play as rival Second Foundation mentalics manipulating probability nodes in the Seldon Plan.

---

## Stage 1: Foundation & Project Setup

**Goal**: Establish Godot project with proper structure, configuration, and core data models

**Success Criteria**:
- Project opens in Godot 4.5 with correct display/rendering settings
- Scene-based directory structure following guidelines
- Card and GameState resource scripts with full type safety
- Basic card visual representation (colored sprites with numbers)

**Tests**:
- [x] Project runs on Android in landscape mode (desktop testing complete)
- [x] Card resource can be created with all three aspects
- [x] Deck generates exactly 33 cards (11 per aspect)
- [x] GameState resource stores all required game variables

**Implementation Details**:

### Directory Structure
```
assets/
├── cards/
│   ├── card.tscn               # Base card scene
│   ├── card.gd                 # Card controller
│   ├── card_data.gd            # Card resource definition
│   ├── visuals/
│   │   ├── mental_bg.png       # Blue aspect background
│   │   ├── physical_bg.png     # Gold aspect background
│   │   └── temporal_bg.png     # Red aspect background
├── game/
│   ├── game_state.gd           # GameState resource
│   ├── game_board.tscn         # Main game scene
│   ├── game_board.gd           # Game controller
│   └── managers/
│       ├── trick_manager.gd    # Trick-taking logic
│       ├── scoring_manager.gd  # Score calculations
│       └── ability_manager.gd  # Special card abilities
├── network/
│   ├── network_manager.gd      # Autoload: multiplayer coordination
│   ├── lobby.tscn              # Lobby UI
│   └── lobby.gd                # Host/join logic
├── ui/
│   ├── theme/
│   │   ├── main_theme.tres     # Second Foundation styling
│   │   └── fonts/
│   ├── hud/
│   │   ├── hud.tscn
│   │   └── hud.gd
│   ├── score_display/
│   │   ├── score_display.tscn
│   │   └── score_display.gd
│   └── mental_shield/
│       ├── mental_shield.tscn
│       └── mental_shield.gd
└── effects/
    ├── shaders/
    │   ├── prime_radiant_glow.gdshader
    │   └── mental_static.gdshader
    ├── particles/
    │   └── equation_particles.tscn
    └── animations/
```

### Project Settings Configuration
```gdscript
# Display
Window/Size/Viewport Width: 1920
Window/Size/Viewport Height: 1080
Window/Size/Mode: 3 (Fullscreen)
Window/Handheld/Orientation: 0 (Landscape)
Window/Stretch/Mode: canvas_items
Window/Stretch/Aspect: keep

# Rendering (optimized for Android)
Textures/Default Texture Filter: Linear
Textures/Canvas Textures/Default Texture Filter: Nearest (for UI crispness)
2D/Snap/Snap 2D Transforms To Pixel: false (allow smooth animations)

# Debug
GDScript/Untyped Declaration: Error
GDScript/Unsafe Method Access: Error
GDScript/Unsafe Cast: Warn
```

### Input Maps
```
# Touch controls for tablet
touch_tap: Mouse Button 1
touch_hold: Mouse Button 1 (hold)

# Testing on desktop
ui_accept: Space, Enter
ui_cancel: Escape
```

### Core Resource Scripts

#### card_data.gd
```gdscript
class_name CardData
extends Resource

enum Aspect {
    MENTAL,    # Blue - psychic manipulation
    PHYSICAL,  # Gold - economic/military
    TEMPORAL   # Red - historical momentum
}

@export var value: int = 1  # 1-11
@export var aspect: Aspect = Aspect.MENTAL
@export var has_ability: bool = false
@export var ability_description: String = ""

func get_aspect_name() -> String:
    match aspect:
        Aspect.MENTAL: return "Mental"
        Aspect.PHYSICAL: return "Physical"
        Aspect.TEMPORAL: return "Temporal"
        _: return "Unknown"

func get_aspect_color() -> Color:
    match aspect:
        Aspect.MENTAL: return Color(0.3, 0.4, 0.8)  # Blue
        Aspect.PHYSICAL: return Color(0.8, 0.6, 0.2)  # Gold
        Aspect.TEMPORAL: return Color(0.8, 0.2, 0.2)  # Red
        _: return Color.WHITE
```

#### game_state.gd
```gdscript
class_name GameState
extends Resource

# Player hands (private information)
var mentalic1_hand: Array[CardData] = []
var mentalic2_hand: Array[CardData] = []

# Prime Radiant state
var dominant_aspect: CardData.Aspect
var radiant_display_card: CardData  # Face-up decree card

# Current trick state
var active_mentalic: int = 1  # 1 or 2
var current_trick: Array[CardData] = []
var trick_number: int = 1
var lead_aspect: CardData.Aspect

# Score tracking
var mentalic1_tricks: int = 0
var mentalic2_tricks: int = 0
var mentalic1_round_score: int = 0
var mentalic2_round_score: int = 0
var mentalic1_total_score: int = 0
var mentalic2_total_score: int = 0

# Deck management
var draw_pile: Array[CardData] = []

# Mental shield state (local only, not synced)
var mentalic1_piercing: bool = false
var mentalic2_piercing: bool = false

# Network identity
var local_player_id: int = 1

func is_local_players_turn() -> bool:
    return active_mentalic == local_player_id

func get_opponent_hand() -> Array[CardData]:
    if local_player_id == 1:
        return mentalic2_hand
    else:
        return mentalic1_hand

func get_local_hand() -> Array[CardData]:
    if local_player_id == 1:
        return mentalic1_hand
    else:
        return mentalic2_hand
```

**Status**: ✅ Complete

---

## Stage 2: Network Infrastructure

**Goal**: Create robust LAN multiplayer using ENetMultiplayerPeer with lobby, connection, and synchronization

**Success Criteria**:
- Two Android tablets can discover and connect on same WiFi
- Game state synchronizes reliably between clients
- Reconnection handling works after brief disconnects
- Lag compensation maintains playability

**Tests**:
- [ ] Host creates game, client discovers it
- [ ] Game state changes propagate correctly
- [ ] Card plays sync within 100ms
- [ ] Disconnect/reconnect doesn't crash game

**Implementation Details**:

### network_manager.gd (Autoload)
```gdscript
extends Node

signal peer_connected(id: int)
signal peer_disconnected(id: int)
signal connection_failed
signal game_started
signal game_state_synced

const DEFAULT_PORT = 7777
const MAX_PLAYERS = 2

var peer: ENetMultiplayerPeer
var is_host := false
var connected_players: Array[int] = []

func create_server() -> Error:
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(DEFAULT_PORT, MAX_PLAYERS)

    if error != OK:
        push_error("Failed to create server: %s" % error)
        return error

    multiplayer.multiplayer_peer = peer
    is_host = true

    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

    print("Server created on port %d" % DEFAULT_PORT)
    return OK

func join_server(address: String) -> Error:
    peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(address, DEFAULT_PORT)

    if error != OK:
        push_error("Failed to connect to %s: %s" % [address, error])
        connection_failed.emit()
        return error

    multiplayer.multiplayer_peer = peer
    is_host = false

    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)

    print("Connecting to %s:%d" % [address, DEFAULT_PORT])
    return OK

@rpc("any_peer", "call_local", "reliable")
func sync_game_state(state_data: Dictionary) -> void:
    # Called by host to sync full game state
    game_state_synced.emit(state_data)

@rpc("any_peer", "reliable")
func play_card(player_id: int, card_index: int) -> void:
    # RPC for card plays
    pass

func _on_peer_connected(id: int) -> void:
    print("Peer connected: %d" % id)
    connected_players.append(id)
    peer_connected.emit(id)

    if is_host and connected_players.size() == MAX_PLAYERS:
        game_started.emit()

func _on_peer_disconnected(id: int) -> void:
    print("Peer disconnected: %d" % id)
    connected_players.erase(id)
    peer_disconnected.emit(id)

func _on_connected_to_server() -> void:
    print("Successfully connected to server")

func _on_connection_failed() -> void:
    print("Connection failed")
    connection_failed.emit()
```

### Lobby System
```gdscript
# lobby.gd
extends Control

@onready var host_button := %HostButton
@onready var join_button := %JoinButton
@onready var ip_input := %IPInput
@onready var status_label := %StatusLabel

func _ready() -> void:
    host_button.pressed.connect(_on_host_pressed)
    join_button.pressed.connect(_on_join_pressed)

    NetworkManager.game_started.connect(_on_game_started)
    NetworkManager.connection_failed.connect(_on_connection_failed)

    # Auto-fill local IP for convenience
    ip_input.text = IP.get_local_addresses()[0]

func _on_host_pressed() -> void:
    var error = NetworkManager.create_server()
    if error == OK:
        status_label.text = "Waiting for opponent..."
        host_button.disabled = true
        join_button.disabled = true

func _on_join_pressed() -> void:
    var address = ip_input.text
    if address.is_empty():
        status_label.text = "Enter host IP address"
        return

    var error = NetworkManager.join_server(address)
    if error == OK:
        status_label.text = "Connecting..."
        host_button.disabled = true
        join_button.disabled = true

func _on_game_started() -> void:
    get_tree().change_scene_to_file("res://assets/game/game_board.tscn")

func _on_connection_failed() -> void:
    status_label.text = "Connection failed. Try again."
    host_button.disabled = false
    join_button.disabled = false
```

**Status**: Not Started

---

## Stage 3: Card Visuals & Mental Shield System

**Goal**: Create beautiful Second Foundation themed cards with mental shield concealment

**Success Criteria**:
- Cards display aspect color, number, and ability icon
- Mental shields obscure opponent cards with Prime Radiant equations
- Touch-and-hold reveals cards smoothly
- Visual polish matches Second Foundation aesthetic

**Tests**:
- [ ] All 33 cards render correctly with unique visuals
- [ ] Shields activate/deactivate smoothly
- [ ] Touch input reliably toggles shield penetration
- [ ] Performance maintains 60fps with full hand visible

**Implementation Details**:

### card.tscn Structure
```
Card (Control)
├── CardBackground (ColorRect)
├── AspectBorder (TextureRect)
├── ValueLabel (Label)
├── AbilityIcon (TextureRect)
└── MentalShield (Control)
    ├── ShieldOverlay (ColorRect + shader)
    └── EquationParticles (GPUParticles2D)
```

### mental_shield.gdshader
```glsl
shader_type canvas_item;

uniform float static_intensity : hint_range(0.0, 1.0) = 0.8;
uniform float equation_speed = 1.0;
uniform vec3 shield_color : source_color = vec3(0.4, 0.3, 0.8);

// Procedural Prime Radiant equations effect
void fragment() {
    vec2 uv = UV * 10.0;
    float time_offset = TIME * equation_speed;

    // Flowing mathematical symbols
    float pattern = sin(uv.x + time_offset) * cos(uv.y - time_offset);
    pattern += sin(uv.x * 2.0 - time_offset * 0.5) * cos(uv.y * 2.0);
    pattern = smoothstep(0.2, 0.8, pattern * 0.5 + 0.5);

    // Mental static noise
    float noise = fract(sin(dot(uv + time_offset, vec2(12.9898, 78.233))) * 43758.5453);
    noise = mix(pattern, noise, static_intensity);

    // Combine with shield color
    vec3 shield = shield_color * noise;
    COLOR = vec4(shield, 0.9);
}
```

**Status**: Not Started

---

## Stage 4: Core Game Mechanics

**Goal**: Implement complete trick-taking rules including aspect following and winner determination

**Success Criteria**:
- Players can only play legal cards (follow aspect or any if can't)
- Trick winner determined correctly (lead aspect, highest value)
- Trump aspect (dominant) beats non-trump
- Game enforces turn order

**Tests**:
- [ ] Legal move validation prevents illegal plays
- [ ] All trick scenarios resolve correctly (trump, follow, off-aspect)
- [ ] Turn alternates properly after trick completion
- [ ] 13 tricks complete a round successfully

**Implementation Details**:

### trick_manager.gd
```gdscript
class_name TrickManager
extends Node

signal trick_completed(winner_id: int)
signal illegal_move_attempted(reason: String)

var game_state: GameState

func is_legal_play(card: CardData, player_id: int) -> bool:
    # First card of trick is always legal
    if game_state.current_trick.is_empty():
        return true

    var lead_card = game_state.current_trick[0]
    var lead_aspect = lead_card.aspect

    # Must follow lead aspect if possible
    var hand = game_state.get_local_hand() if player_id == game_state.local_player_id else game_state.get_opponent_hand()
    var has_lead_aspect = hand.any(func(c): return c.aspect == lead_aspect)

    if has_lead_aspect:
        return card.aspect == lead_aspect
    else:
        return true  # Can play any card if can't follow

func determine_trick_winner() -> int:
    if game_state.current_trick.size() != 2:
        push_error("Trick incomplete")
        return -1

    var card1 = game_state.current_trick[0]
    var card2 = game_state.current_trick[1]

    var lead_aspect = card1.aspect
    var trump = game_state.dominant_aspect

    # Card 9 special rule: if only one 9, treat as dominant aspect
    if card1.value == 9 and card2.value != 9:
        card1_aspect_override = trump
    elif card2.value == 9 and card1.value != 9:
        card2_aspect_override = trump

    # Trump beats non-trump
    var card1_is_trump = (card1.aspect == trump) or (card1.value == 9 and card2.value != 9)
    var card2_is_trump = (card2.aspect == trump) or (card2.value == 9 and card1.value != 9)

    if card1_is_trump and not card2_is_trump:
        return 1
    elif card2_is_trump and not card1_is_trump:
        return 2

    # Both trump or both not trump: follow beats off-aspect
    if card1.aspect == lead_aspect and card2.aspect != lead_aspect:
        return 1
    elif card2.aspect == lead_aspect and card1.aspect != lead_aspect:
        return 2

    # Both following: higher value wins
    return 1 if card1.value > card2.value else 2

func resolve_trick() -> void:
    var winner = determine_trick_winner()

    if winner == 1:
        game_state.mentalic1_tricks += 1
    else:
        game_state.mentalic2_tricks += 1

    # Set next lead
    game_state.active_mentalic = winner
    game_state.current_trick.clear()
    game_state.trick_number += 1

    trick_completed.emit(winner)
```

**Status**: Not Started

---

## Stage 5: Special Card Abilities

**Goal**: Implement all six psychohistorical manipulation abilities with UI

**Success Criteria**:
- All abilities trigger at correct times
- UI prompts appear for choices (3, 5, 11)
- Abilities sync correctly over network
- Visual feedback shows ability activation

**Tests**:
- [ ] Card 1: Losing grants next lead
- [ ] Card 3: Exchange UI allows card selection
- [ ] Card 5: Draw/discard UI works
- [ ] Card 7: Extra points calculated correctly
- [ ] Card 9: Wild aspect functions
- [ ] Card 11: Forces legal extreme plays

**Implementation Details**:

### ability_manager.gd
```gdscript
class_name AbilityManager
extends Node

signal ability_triggered(card: CardData, player_id: int)
signal choice_required(ability_type: String, choices: Array)

var game_state: GameState

# Called when card is played
func check_on_play_abilities(card: CardData, player_id: int) -> void:
    match card.value:
        3:  # Mental Static - exchange with Prime Radiant
            _trigger_mental_static(player_id)
        5:  # Intuitive Leap - draw and discard
            _trigger_intuitive_leap(player_id)
        11: # Speaker's Command - force opponent choice
            _trigger_speakers_command(player_id)

# Called after trick resolution
func check_post_trick_abilities(trick_cards: Array[CardData], winner_id: int) -> void:
    # Card 1: Whispered Redirection
    for i in range(trick_cards.size()):
        var card = trick_cards[i]
        var player_id = i + 1

        if card.value == 1 and player_id != winner_id:
            # Loser of this card leads next
            game_state.active_mentalic = player_id
            ability_triggered.emit(card, player_id)
            break

    # Card 7: Conversion Point
    var sevens_count = trick_cards.filter(func(c): return c.value == 7).size()
    if sevens_count > 0:
        if winner_id == 1:
            game_state.mentalic1_round_score += sevens_count
        else:
            game_state.mentalic2_round_score += sevens_count
        ability_triggered.emit(trick_cards[0], winner_id)

func _trigger_mental_static(player_id: int) -> void:
    # Emit signal to show UI for selecting hand card
    var hand = game_state.get_local_hand() if player_id == game_state.local_player_id else game_state.get_opponent_hand()
    choice_required.emit("mental_static", hand)

@rpc("any_peer", "call_local", "reliable")
func execute_mental_static(player_id: int, card_index: int) -> void:
    var hand = game_state.mentalic1_hand if player_id == 1 else game_state.mentalic2_hand
    var selected_card = hand[card_index]
    var radiant_card = game_state.radiant_display_card

    # Swap
    hand[card_index] = radiant_card
    game_state.radiant_display_card = selected_card
```

**Status**: Not Started

---

## Stage 6: Scoring & Round Management

**Goal**: Complete psychohistorical effectiveness scoring and round flow

**Success Criteria**:
- Scoring table accurately calculates points based on tricks won
- Rounds end after 13 tricks
- New rounds deal fresh hands with new trump
- Game ends when player reaches 21 points

**Tests**:
- [ ] All scoring brackets calculate correctly (0-3=6, 4=1, 5=2, 6=3, 7-9=6, 10-13=0)
- [ ] Round transitions smoothly with new deal
- [ ] Game declares winner at 21+ points
- [ ] Card 7 bonus points add correctly

**Implementation Details**:

### scoring_manager.gd
```gdscript
class_name ScoringManager
extends Node

const SCORING_TABLE = {
    0: 6, 1: 6, 2: 6, 3: 6,  # Subtle Influence
    4: 1,                     # Detected Pressure
    5: 2,                     # Obvious Manipulation
    6: 3,                     # Contested Control
    7: 6, 8: 6, 9: 6,        # Calculated Dominance
    10: 0, 11: 0, 12: 0, 13: 0  # Exposed Operation
}

func calculate_round_score(tricks_won: int, bonus_points: int = 0) -> int:
    var base_score = SCORING_TABLE.get(tricks_won, 0)
    return base_score + bonus_points

func end_round(game_state: GameState) -> void:
    # Calculate final scores
    var m1_score = calculate_round_score(
        game_state.mentalic1_tricks,
        game_state.mentalic1_round_score
    )
    var m2_score = calculate_round_score(
        game_state.mentalic2_tricks,
        game_state.mentalic2_round_score
    )

    game_state.mentalic1_total_score += m1_score
    game_state.mentalic2_total_score += m2_score

    # Reset for next round
    game_state.mentalic1_tricks = 0
    game_state.mentalic2_tricks = 0
    game_state.mentalic1_round_score = 0
    game_state.mentalic2_round_score = 0
    game_state.trick_number = 1

func check_game_winner(game_state: GameState) -> int:
    if game_state.mentalic1_total_score >= 21:
        return 1
    elif game_state.mentalic2_total_score >= 21:
        return 2
    return 0  # No winner yet
```

**Status**: Not Started

---

## Stage 7: UI/UX Polish & Second Foundation Theme

**Goal**: Professional visual design with Prime Radiant aesthetics, animations, and sound

**Success Criteria**:
- Purple/blue/gold theme with flowing equations
- Smooth card animations
- Whispered sound effects
- Clear game state feedback
- Touch-optimized for tablets

**Tests**:
- [ ] Theme applied consistently across all screens
- [ ] Animations play smoothly at 60fps
- [ ] Sound effects trigger appropriately
- [ ] Touch targets are 44+ dp minimum
- [ ] Safe area respected on notched devices

**Implementation Details**:

### Theme Configuration (main_theme.tres)
- Base colors: Deep purple background (#2A1A4A), blue accents (#4A6FA5), gold highlights (#D4AF37)
- Fonts: Monospace for equations, sans-serif for UI
- StyleBoxFlat: Rounded corners, subtle glow effects
- Custom type variations: MentalButton (blue), PhysicalButton (gold), TemporalButton (red)

### Animation System
- Card play: Slide to center with equation particle trail (0.3s)
- Trick resolution: Winner glows, cards fade out (0.5s)
- Shield pierce: Shader transition over 0.2s
- Score update: Number count-up animation (0.8s)

### Sound Design
- Whisper_01-05.ogg: Randomized subtle whispers on card play
- Chime_Mental/Physical/Temporal.ogg: Aspect-specific tones
- Ability_Trigger.ogg: Special sound for ability activation
- Victory/Defeat.ogg: End-game stingers

**Status**: Not Started

---

## Stage 8: Android Optimization & Deployment

**Goal**: Optimized, deployable Android build for tablet devices

**Success Criteria**:
- APK runs smoothly on target tablets (60fps)
- Network discovery works on WiFi
- Touch input responsive and accurate
- Battery usage acceptable
- Build size under 50MB

**Tests**:
- [ ] Performance profiling shows no bottlenecks
- [ ] Memory usage stays under 200MB
- [ ] No dropped frames during gameplay
- [ ] APK installs and runs on 3+ devices
- [ ] Network play stable for 20+ minute sessions

**Implementation Details**:

### Export Settings
```
Android/Architectures: arm64-v8a (primary), armeabi-v7a (compatibility)
Android/Min SDK: 24 (Android 7.0)
Android/Target SDK: 34 (latest)
Permissions: INTERNET, ACCESS_NETWORK_STATE, ACCESS_WIFI_STATE
Screen/Orientation: Landscape
```

### Performance Optimizations
- Object pooling for particles and cards
- Texture atlases for all card graphics
- Simplified shaders for mid-range devices
- VisibleOnScreenNotifier2D for off-screen culling
- Low-processor usage mode when waiting for opponent

### Build Process
1. Test on desktop with Android emulator
2. Export debug APK, install via ADB
3. Profile with Godot's remote debugger
4. Optimize bottlenecks
5. Export release APK with signing
6. Test on physical tablets

**Status**: Not Started

---

## Implementation Order

Execute stages sequentially, marking complete only when all tests pass:

1. **Stage 1** (Week 1): Foundation - Get basic project running
2. **Stage 2** (Week 2): Network - Enable multiplayer connection
3. **Stage 3** (Week 1): Visuals - Cards look good with shields
4. **Stage 4** (Week 2): Mechanics - Game rules work correctly
5. **Stage 5** (Week 2): Abilities - All six special cards implemented
6. **Stage 6** (Week 1): Scoring - Complete game loop
7. **Stage 7** (Week 2): Polish - Professional presentation
8. **Stage 8** (Week 1): Deploy - Shippable Android build

**Total Estimated Time**: 10-12 weeks

---

## Risk Mitigation

### Network Reliability
- **Risk**: WiFi instability causes desyncs
- **Mitigation**: Implement rollback for failed RPCs, heartbeat ping system, reconnection with state recovery

### Android Fragmentation
- **Risk**: Different tablets have varying performance
- **Mitigation**: Quality settings (shader complexity, particle count), target mid-range as baseline (Snapdragon 660+)

### Scope Creep
- **Risk**: Feature additions delay core gameplay
- **Mitigation**: Strict adherence to stage-based plan, defer non-essential features to post-launch

### Testing Complexity
- **Risk**: Hard to test networked game solo
- **Mitigation**: Built-in AI opponent for local testing, mock network layer for unit tests

---

## Notes

- Follow Godot 4.5 guidelines strictly (static typing, scene organization)
- GitButler handles commits via MCP tool after each stage completion
- Maintain IMPLEMENTATION_PLAN.md status as stages complete
- Remove this file when all stages marked complete
