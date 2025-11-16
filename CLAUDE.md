# Whispers from the Radiant: A Crisis in the Plan

## Project Overview

A two-player trick-taking card game set in Isaac Asimov's Foundation universe, inspired by "The Fox in the Forest" mechanics. The Prime Radiant has detected a crisis in the Seldon Plan, whispering different interpretations to rival Second Foundation mentalics. Players compete to prove whose calculation will correctly resolve the crisis. Designed for tablet play with innovative visual concealment mechanics representing mental shields and competing psychohistorical interpretations.

## Narrative Framework

The Seldon Plan faces a critical divergence point. The Prime Radiant, detecting this crisis, whispers different possible resolutions to two Second Foundation mentalics. Each receives their own interpretation of how to navigate this crisis (their hand of cards). Through careful manipulation of probability nodes (tricks), they must prove their interpretation is the correct path forward.

The winner's whispers are accepted by the Prime Radiant, their interpretation becoming the official Second Foundation response to the crisis. But beware - too aggressive manipulation (winning too many tricks) reveals your hand and invalidates your calculations, just as the Mule's crude power nearly destroyed the Plan.

## Core Game Mechanics

### Basic Rules

- **Players**: 2 (rival Second Foundation mentalics)
- **Deck**: 33 cards (3 aspects × 11 cards each)
- **Hand Size**: 13 cards per player
- **Rounds**: Play to 21 points across multiple calculations
- **Tricks per Round**: 13 (each a node in psychohistory)

### The Three Aspects (Variables in Psychohistory)

1. **Mental (Blue)** - Psychic manipulation and control
   - Represents Second Foundation's mentalic powers
   - The subtle art of emotional adjustment

2. **Physical (Gold)** - Economic and military forces
   - Represents the First Foundation's domain
   - Trade routes, fleets, and material power

3. **Temporal (Red)** - Historical momentum and crisis points
   - Represents the flow of the Seldon Plan
   - Critical moments where history pivots

### Special Card Abilities (Psychohistorical Manipulations)

- **1 - Whispered Redirection**: If you play this and lose the trick, you lead the next calculation
- **3 - Mental Static**: Exchange the Prime Radiant's current projection with a card from your hand
- **5 - Intuitive Leap**: Draw 1 variable, then discard any 1 card to bottom of deck
- **7 - Conversion Point**: Winner receives 1 point for each 7 in the trick (minds converted)
- **9 - Mentalic Resonance**: When only one 9 in trick, treat it as the dominant aspect
- **11 - Speaker's Command**: Opponent must play either their 1 or highest card of aspect

### Scoring System (Psychohistorical Effectiveness)

| Tricks Won | Points | Description              | Narrative                                 |
| ---------- | ------ | ------------------------ | ----------------------------------------- |
| 0-3        | 6      | **Subtle Influence**     | Perfect Second Foundation technique       |
| 4          | 1      | **Detected Pressure**    | Your touch was noticed                    |
| 5          | 2      | **Obvious Manipulation** | Resistance is building                    |
| 6          | 3      | **Contested Control**    | Equations in flux                         |
| 7-9        | 6      | **Calculated Dominance** | Mathematical perfection achieved          |
| 10-13      | 0      | **Exposed Operation**    | Your meddling revealed, calculations void |

## Technical Implementation

### Visual Concealment System - "Mental Shields"

The game uses psychohistorical mathematics as visual interference:

1. **Prime Radiant Equations**: Glowing mathematical symbols flow across concealed cards
2. **Mental Static**: Shifting patterns represent psychic shields between minds
3. **Touch-to-Pierce**: Hold button to temporarily pierce opponent's mental shield
4. **Instant Reshielding**: Mental defenses snap back when released

### UI/UX Design - The Prime Radiant Chamber

- **Tablet-Optimized**: Landscape view with mentalics facing each other
- **Rotated Perspectives**: Each player sees their own equations right-side up
- **Central Calculation Space**: Where probability nodes resolve
- **The Prime Radiant Display**: Current dominant equation (trump) glows in center

### Current Implementation Status

#### Completed Features

- [x] Full deck generation with three aspects
- [x] Card shuffling and probability distribution
- [x] Mental shield visualization system
- [x] Touch-to-reveal mechanism
- [x] Calculation management (turns)
- [x] Influence tracking (score)
- [x] Round/game resolution
- [x] Second Foundation themed UI

#### Features Needing Implementation

- [ ] **Mental Static (3)**: UI for selecting which variable to inject into Prime Radiant
- [ ] **Intuitive Leap (5)**: UI for selecting which calculation to discard
- [ ] **Speaker's Command (11)**: Logic forcing extreme responses
- [ ] **Mentalic Feedback**: Visual effects when abilities trigger
- [ ] **Sound Design**: Subtle whispers and mathematical chimes
- [ ] **Animation Polish**: Equations flowing between plays
- [ ] **Tutorial Mode**: First Speaker guides new mentalics

## Code Architecture

### Game State Structure

```javascript
gameState = {
  // Mentalic hands (hidden calculations)
  mentalic1Hand: [],
  mentalic2Hand: [],

  // Prime Radiant state
  dominantAspect: null, // Current trump
  radiantDisplay: null, // Face-up equation card

  // Current calculation
  activeCalculator: 1 | 2, // Whose turn to manipulate
  currentNode: [], // Cards in current probability node
  nodeNumber: 1 - 13, // Which point in history
  leadingAspect: null, // First aspect played

  // Influence accumulation
  mentalic1Nodes: 0, // Tricks won
  mentalic2Nodes: 0,
  mentalic1Converts: 0, // Round score
  mentalic2Converts: 0,
  mentalic1Influence: 0, // Total score
  mentalic2Influence: 0,

  // Probability deck
  deck: [],
  uncertainVariables: [], // Draw pile

  // Mental state
  mentalic1Piercing: boolean, // Currently viewing through shield
  mentalic2Piercing: boolean,
};
```

### Key Functions

- `initializeCalculation()`: Begin new psychohistorical calculation
- `manipulateNode(mentalic, cardIndex)`: Play card with validation
- `processResonance(card, mentalic)`: Execute special mental abilities
- `resolveNode()`: Determine which mentalic controls this point in time
- `pierceShield(mentalic, active)`: Toggle mental shield penetration

## Development Environment & Testing

### Godot Command-Line Interface

**Godot Executable Location**: `/Applications/Godot.app/Contents/MacOS/Godot`

**Godot Version**: 4.6-dev4

When writing or modifying GDScript files, use the Godot command-line interface to validate your work incrementally. This prevents accumulating errors and ensures each change compiles correctly.

### Essential Command-Line Patterns

#### 1. Validate Script Syntax

Check if a script has syntax errors without running it:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless --check-only --path /Volumes/Sidecar/FFAI/whispers-from-the-radiant
```

**When to use**: After editing any `.gd` file to verify syntax is valid.

#### 2. Run a Specific Scene

Test a scene directly from command line:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --path /Volumes/Sidecar/FFAI/whispers-from-the-radiant res://path/to/scene.tscn
```

**When to use**: After implementing scene-based features to verify behavior.

#### 3. Run in Debug Mode

Get detailed error output and stack traces:

```bash
/Applications/Godot.app/Contents/MacOS/Godot -d --path /Volumes/Sidecar/FFAI/whispers-from-the-radiant res://path/to/scene.tscn
```

**When to use**: When debugging runtime errors or investigating unexpected behavior.

#### 4. Headless Testing (No Window)

Run tests or validation without opening the Godot window:

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless -d --path /Volumes/Sidecar/FFAI/whispers-from-the-radiant
```

**When to use**: For automated validation during development, especially when checking multiple files.

#### 5. Execute a Specific Script

Run a GDScript that extends SceneTree or MainLoop:

```bash
/Applications/Godot.app/Contents/MacOS/Godot -s res://path/to/script.gd -d --path /Volumes/Sidecar/FFAI/whispers-from-the-radiant
```

**When to use**: For testing utility scripts or running automated checks.

#### 6. Run Unit Tests (with GUT framework, if installed)

```bash
/Applications/Godot.app/Contents/MacOS/Godot -d -s --path /Volumes/Sidecar/FFAI/whispers-from-the-radiant addons/gut/gut_cmdln.gd -gdir=res://test -ginclude_subdirs -gexit
```

**When to use**: After implementing testable functionality to verify behavior with automated tests.

### Validation Workflow for Claude Code

When writing or modifying GDScript files, follow this incremental validation pattern:

1. **After each file edit**: Run `--headless --check-only` to validate syntax
2. **After implementing a feature**: Run the relevant scene with `-d` to test functionality
3. **Before marking work complete**: Run all applicable tests to ensure nothing broke

### Common Command-Line Flags Reference

| Flag | Purpose | Example Use Case |
|------|---------|------------------|
| `--headless` | Run without GUI | CI/CD, automated testing, validation |
| `-d` | Debug mode with verbose output | Investigating errors, seeing detailed logs |
| `-s <script>` | Execute a specific script | Running utilities, automated tests |
| `--path <dir>` | Set project root directory | Specifying which Godot project to work with |
| `--check-only` | Validate and exit immediately | Quick syntax checking |
| `-e` | Open editor | Launching Godot editor from terminal |
| `--quit` | Quit after first iteration | One-shot validation tasks |

### Error Handling

- **Exit code 0**: Success, all operations completed without errors
- **Exit code 1**: Failure, errors occurred during execution
- Parse error output for specific file/line information to fix issues

### Best Practices

1. **Validate incrementally**: Don't accumulate multiple changes without validation
2. **Use headless mode**: Faster feedback, no window management overhead
3. **Debug mode by default**: The `-d` flag provides valuable context for errors
4. **Check syntax before runtime**: Use `--check-only` first, then test behavior
5. **Path specificity**: Always use `--path` to ensure Godot uses the correct project

## Development Priorities

### Phase 1: Core Mechanics (COMPLETE)

- Basic trick-taking as probability calculations
- Mental shield visualization
- Influence tracking

### Phase 2: Mentalic Abilities (IN PROGRESS)

- Implement all six psychohistorical manipulations
- Add UI for mental choices
- Handle forced calculations

### Phase 3: Second Foundation Polish

- Whispering sound effects on card plays
- Prime Radiant glow effects
- Equation particles flowing between nodes
- Achievement system ("First Speaker", "Mind Touched", etc.)

### Phase 4: Enhanced Features

- AI opponent with different calculation styles
- Online mentalic duels
- Campaign following Second Foundation history
- Statistics on calculation patterns

## Narrative Integration

### Second Foundation Elements

- **Mental Shields**: Cards hidden behind psychic static
- **Prime Radiant**: The decree card represents current equation focus
- **Whispers**: Subtle audio cues for special abilities
- **Conversion**: The 7s represent minds brought into the Plan
- **Exposure**: Winning too many tricks reveals your presence

### Visual Themes

- Deep purples and blues for Second Foundation mystique
- Golden equations flowing like the Prime Radiant
- Subtle glows and particles suggesting mental energy
- Mathematical symbols as primary aesthetic
- Shadowy chamber atmosphere

## Testing Requirements

### Gameplay Testing

- Verify mentalic abilities resolve correctly
- Ensure aspect-following rules work
- Test influence calculations
- Validate calculation end conditions

### Device Testing

- Test mental shield effectiveness on various screens
- Verify touch responsiveness for shield piercing
- Check both mentalic positions work
- Ensure equations are readable but mysterious

### Balance Testing

- Confirm abilities don't break mathematical balance
- Verify scoring encourages subtle play (Second Foundation way)
- Test that concealment adds tension without frustration

## Future Expansion Ideas

### Additional Modes

- **First Speaker Mode**: Asymmetric gameplay with one dominant mentalic
- **Council Mode**: 4-player with temporary alliances
- **Gaia Emergence**: Cooperative variant against growing Gaia influence
- **Anti-Mule Protocol**: Special rules when one player dominates

### Extended Universe

- Cards featuring famous Second Foundationers
- Preem Palver as tutorial character
- Special events from Second Foundation novel
- Alternative aspects (Gaia, Solaria, Earth influences)

## Resources and References

### Source Material

- Second Foundation (1953) - Primary inspiration
- Foundation's Edge (1982) - Prime Radiant details
- Foundation and Earth (1986) - Mental powers expanded

### Design Inspiration

- The Fox in the Forest - Core mechanics
- Prime Radiant visualization from Apple TV+ series
- Mathematical beauty of psychohistory
- Concept of subtle influence vs obvious control

## Development Notes

When implementing features, remember the Second Foundation philosophy:

- Subtle manipulation over direct control
- Mental prowess over physical force
- Long-term planning over immediate gain
- Hidden influence over visible power

The game should feel like a mental duel between psychohistorians, where the most elegant mathematical solution wins, not the most forceful. Players should feel they're shaping the galaxy's future through whispered adjustments and careful calculations, true to the Second Foundation's methods.

"From the shadows, we shape the light."
