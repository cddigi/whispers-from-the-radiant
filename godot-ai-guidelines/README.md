# Godot 4.6 AI Guidelines - Navigation Index

**Purpose**: Comprehensive, AI-optimized reference for Godot 4.6 game development
**Target**: Claude Code (AI-assisted development)
**Version**: Godot 4.6.0-dev4
**Last Updated**: 2025-11-15

---

## Quick Navigation

Use this index to quickly locate relevant guidelines for your current task.

### By File

| File | Focus Area | Key Topics |
|------|-----------|------------|
| [00-version-and-migration.md](00-version-and-migration.md) | **Version Info & Migration** | Breaking changes, platform requirements, migration checklist |
| [01-gdscript-modern-patterns.md](01-gdscript-modern-patterns.md) | **GDScript Language** | Typing, organization, abstractions, performance, idioms |
| [02-scene-architecture.md](02-scene-architecture.md) | **Scene System** | Composition, signals, instancing, autoloads, resources |
| [03-core-systems.md](03-core-systems.md) | **Core Engine** | Memory, pooling, groups, SceneTree, global systems |
| [04-2d-graphics-rendering.md](04-2d-graphics-rendering.md) | **2D Graphics** | Sprites, tilemaps, camera, z-index, rendering |
| [05-animation-physics-3d.md](05-animation-physics-3d.md) | **Animation & Physics** | IK, bones, Jolt vs Godot physics, navigation, collision |
| [06-ui-and-controls.md](06-ui-and-controls.md) | **User Interface** | Controls, layouts, theming, FileDialog, focus, input |
| [07-platform-performance.md](07-platform-performance.md) | **Platforms & Optimization** | Requirements, mobile, web, profiling, performance |
| [08-quick-reference.md](08-quick-reference.md) | **Quick Lookup** | Patterns, decision trees, API reference, gotchas |

---

## By Task Type

### Working on GDScript Code?
→ Start with [01-gdscript-modern-patterns.md](01-gdscript-modern-patterns.md)
- Naming conventions (snake_case, PascalCase)
- Type system (4.6 strict typing)
- Abstract classes (4.5+)
- Performance patterns (reserve(), StringName)

### Building Scene Hierarchy?
→ Start with [02-scene-architecture.md](02-scene-architecture.md)
- Scene vs node decisions
- Parent-child communication (call down, signal up)
- Autoload usage patterns
- Resource management

### Working with 2D Graphics?
→ Start with [04-2d-graphics-rendering.md](04-2d-graphics-rendering.md)
- Sprite2D vs AnimatedSprite2D
- **TileMapLayer** (critical 4.3+ change from legacy TileMap)
- Camera2D setup and effects
- Z-index and Y-sort

### Implementing Animation or 3D?
→ Start with [05-animation-physics-3d.md](05-animation-physics-3d.md)
- **IKModifier3D** (NEW in 4.6, replaces SkeletonIK)
- AnimationPlayer vs AnimationTree
- **Jolt Physics** (default in 4.6) vs GodotPhysics
- Collision layers and masks

### Creating UI/Menus?
→ Start with [06-ui-and-controls.md](06-ui-and-controls.md)
- Control hierarchy and anchors
- Layout containers (VBox, HBox, Grid)
- Theming with StyleBox
- FileDialog enhancements (4.6)

### Optimizing Performance?
→ Start with [07-platform-performance.md](07-platform-performance.md)
- Collection pre-allocation (`reserve()` - NEW 4.6)
- Visibility-based optimization
- Platform-specific patterns
- Profiling tools

### Migrating from 4.5 or Earlier?
→ Start with [00-version-and-migration.md](00-version-and-migration.md)
- **String conversion breaking change** (critical)
- Platform requirement updates (Windows 10+, Android API 24+)
- Abstract class syntax (`@abstract`)
- Migration checklist

### Need Quick Answer?
→ Start with [08-quick-reference.md](08-quick-reference.md)
- Common pattern templates
- Decision trees (when to use X vs Y)
- API quick reference
- Gotcha solutions

---

## Critical 4.6 Changes

### BREAKING CHANGES (Immediate Action Required)

1. **String Conversions** - `String(vector)` → `str(vector)`
   - See: [00-version-and-migration.md#string-conversion-changes](00-version-and-migration.md#string-conversion-changes)

2. **Platform Requirements**
   - Windows 10+ (7/8/8.1 dropped)
   - Android API 24+ (was 21)
   - .NET 8.0 (was 6.0)
   - See: [00-version-and-migration.md#platform-requirements-changes](00-version-and-migration.md#platform-requirements-changes)

3. **TileMapLayer Architecture** (4.3+, still critical)
   - Legacy TileMap deprecated
   - Separate TileMapLayer nodes
   - See: [04-2d-graphics-rendering.md#tilemaplayer-architecture](04-2d-graphics-rendering.md#tilemaplayer-architecture)

### NEW FEATURES (4.6 Enhancements)

1. **IKModifier3D** - Modern IK system
   - Replaces SkeletonIK
   - See: [05-animation-physics-3d.md#ikmodifier3d-system](05-animation-physics-3d.md#ikmodifier3d-system)

2. **Collection Pre-allocation** - `reserve()` methods
   - `Array.reserve()`, `Dictionary.reserve()`, `String.reserve()`
   - See: [01-gdscript-modern-patterns.md#collection-pre-allocation](01-gdscript-modern-patterns.md#collection-pre-allocation)

3. **Jolt Physics Default** - Better performance
   - Default for new projects
   - See: [05-animation-physics-3d.md#jolt-physics](05-animation-physics-3d.md#jolt-physics)

4. **Control Pivot Offset Ratio** - UI positioning
   - Relative pivot positioning
   - See: [06-ui-and-controls.md#control-pivot-offset-ratio](06-ui-and-controls.md#control-pivot-offset-ratio)

---

## Common Workflows

### Starting a New Project

1. Read: [00-version-and-migration.md](00-version-and-migration.md) - Understand current version
2. Read: [01-gdscript-modern-patterns.md](01-gdscript-modern-patterns.md) - Set up coding standards
3. Read: [02-scene-architecture.md](02-scene-architecture.md) - Plan scene structure
4. Reference: [08-quick-reference.md](08-quick-reference.md) - Common patterns

### Implementing Game Feature

1. Plan in: [02-scene-architecture.md](02-scene-architecture.md) - Scene composition
2. Code in: [01-gdscript-modern-patterns.md](01-gdscript-modern-patterns.md) - GDScript patterns
3. Check: [08-quick-reference.md](08-quick-reference.md) - Decision trees
4. Optimize in: [07-platform-performance.md](07-platform-performance.md) - Performance

### Debugging Performance Issue

1. Start: [07-platform-performance.md](07-platform-performance.md) - Profiling
2. Check: [01-gdscript-modern-patterns.md#performance-patterns](01-gdscript-modern-patterns.md#performance-patterns) - Code optimization
3. Review: [03-core-systems.md#memory-management](03-core-systems.md#memory-management) - Memory leaks
4. Verify: [08-quick-reference.md#performance-quick-checks](08-quick-reference.md#performance-quick-checks) - Quick wins

### Fixing Rendering Issue

1. 2D? → [04-2d-graphics-rendering.md](04-2d-graphics-rendering.md)
2. UI? → [06-ui-and-controls.md](06-ui-and-controls.md)
3. 3D? → [05-animation-physics-3d.md](05-animation-physics-3d.md)
4. General → [07-platform-performance.md#rendering-optimization](07-platform-performance.md#rendering-optimization)

---

## Feature Cross-Reference

### Abstract Classes (4.5+)
- Definition: [01-gdscript-modern-patterns.md#abstract-classes](01-gdscript-modern-patterns.md#abstract-classes)
- Migration: [00-version-and-migration.md#abstract-classes](00-version-and-migration.md#abstract-classes)
- Use cases: [02-scene-architecture.md#inheritance-patterns](02-scene-architecture.md#inheritance-patterns)

### Signals
- Basics: [01-gdscript-modern-patterns.md#signal-naming](01-gdscript-modern-patterns.md#signal-naming)
- Architecture: [02-scene-architecture.md#signals-and-event-bus](02-scene-architecture.md#signals-and-event-bus)
- Performance: [07-platform-performance.md#signal-optimization](07-platform-performance.md#signal-optimization)

### Object Pooling
- Pattern: [03-core-systems.md#object-pooling](03-core-systems.md#object-pooling)
- Performance: [07-platform-performance.md#pooling-strategies](07-platform-performance.md#pooling-strategies)
- Example: [01-gdscript-modern-patterns.md#memory-management](01-gdscript-modern-patterns.md#memory-management)

### TileMapLayer
- Architecture: [04-2d-graphics-rendering.md#tilemaplayer-architecture](04-2d-graphics-rendering.md#tilemaplayer-architecture)
- Migration: [00-version-and-migration.md#deprecated-features](00-version-and-migration.md#deprecated-features)

### IK System
- IKModifier3D: [05-animation-physics-3d.md#ikmodifier3d-system](05-animation-physics-3d.md#ikmodifier3d-system)
- Migration from SkeletonIK: [00-version-and-migration.md#animation-system](00-version-and-migration.md#animation-system)

### Physics
- Jolt vs GodotPhysics: [05-animation-physics-3d.md#physics-engines](05-animation-physics-3d.md#physics-engines)
- 2D Physics: [05-animation-physics-3d.md#2d-physics-patterns](05-animation-physics-3d.md#2d-physics-patterns)
- 3D Physics: [05-animation-physics-3d.md#3d-physics-patterns](05-animation-physics-3d.md#3d-physics-patterns)
- Performance: [07-platform-performance.md#physics-optimization](07-platform-performance.md#physics-optimization)

---

## Performance Optimization Path

1. **Identify bottleneck**
   - [07-platform-performance.md#profiling-tools](07-platform-performance.md#profiling-tools)

2. **Code-level optimization**
   - [01-gdscript-modern-patterns.md#performance-patterns](01-gdscript-modern-patterns.md#performance-patterns)
   - Use `reserve()`, StringName, cached references

3. **System-level optimization**
   - [03-core-systems.md#object-pooling](03-core-systems.md#object-pooling)
   - [02-scene-architecture.md#scene-instancing](02-scene-architecture.md#scene-instancing)

4. **Rendering optimization**
   - [04-2d-graphics-rendering.md#rendering-performance](04-2d-graphics-rendering.md#rendering-performance)
   - [07-platform-performance.md#rendering-optimization](07-platform-performance.md#rendering-optimization)

5. **Physics optimization**
   - [05-animation-physics-3d.md#physics-performance](05-animation-physics-3d.md#physics-performance)
   - Consider Jolt Physics (4.6 default)

---

## Quick Decision Trees

### When to use...?

**Scene vs Script?**
→ [02-scene-architecture.md#scene-vs-script-decision](02-scene-architecture.md#scene-vs-script-decision)

**AnimatedSprite2D vs AnimationPlayer?**
→ [04-2d-graphics-rendering.md#animation-decision-tree](04-2d-graphics-rendering.md#animation-decision-tree)

**Autoload vs Dependency Injection?**
→ [02-scene-architecture.md#autoload-decision-tree](02-scene-architecture.md#autoload-decision-tree)

**Jolt vs GodotPhysics?**
→ [05-animation-physics-3d.md#physics-engine-choice](05-animation-physics-3d.md#physics-engine-choice)

**Which Control layout container?**
→ [06-ui-and-controls.md#layout-container-choice](06-ui-and-controls.md#layout-container-choice)

All decision trees: [08-quick-reference.md#decision-trees](08-quick-reference.md#decision-trees)

---

## Document Structure

Each guideline file follows this structure:

1. **Header** - Purpose, target version, focus areas
2. **Core Concepts** - Fundamental understanding
3. **Patterns** - How to implement correctly
4. **Examples** - Code samples (WRONG vs CORRECT)
5. **Performance** - Optimization tips
6. **Gotchas** - Common mistakes and solutions
7. **Cross-References** - Related guidelines
8. **Metadata** - Version, update date, AI optimization level

---

## Using These Guidelines

### For AI Code Generation (Primary Use)

1. **Context Gathering**: Read relevant sections before generating code
2. **Pattern Matching**: Use provided templates as starting points
3. **Validation**: Check generated code against "WRONG vs CORRECT" examples
4. **Optimization**: Apply performance patterns from the start
5. **Cross-Check**: Verify related systems are compatible

### For Learning Godot 4.6

1. Start with [00-version-and-migration.md](00-version-and-migration.md) - Understand what's new
2. Master [01-gdscript-modern-patterns.md](01-gdscript-modern-patterns.md) - Language fundamentals
3. Study [02-scene-architecture.md](02-scene-architecture.md) - Core engine patterns
4. Explore domain-specific files (2D, 3D, UI) as needed
5. Reference [08-quick-reference.md](08-quick-reference.md) - Quick answers

### For Migration Projects

1. **Audit**: [00-version-and-migration.md#migration-checklist](00-version-and-migration.md#migration-checklist)
2. **Fix Breaking Changes**: String conversions, platform requirements
3. **Update Deprecated APIs**: TileMap → TileMapLayer, SkeletonIK → IKModifier3D
4. **Adopt New Features**: reserve(), abstract classes, Jolt Physics
5. **Test**: Verify all platforms meet new requirements

---

## Maintenance Notes

**Update Frequency**: These guidelines should be updated when:
- New Godot versions release (4.7, 5.0, etc.)
- Major API changes occur
- New patterns emerge from project experience
- Performance best practices evolve

**Contribution Pattern**:
1. Identify gap or outdated information
2. Research current best practice (docs, source code, community)
3. Update relevant guideline file(s)
4. Update cross-references
5. Update this README if structure changes

---

## File Sizes and Scope

| File | Size | Line Count (approx) | Scope |
|------|------|---------------------|-------|
| 00-version-and-migration.md | 12KB | 400 | Version-specific changes |
| 01-gdscript-modern-patterns.md | 22KB | 700 | Language mastery |
| 02-scene-architecture.md | 24KB | 750 | Engine architecture |
| 03-core-systems.md | 22KB | 700 | Core engine systems |
| 04-2d-graphics-rendering.md | 20KB | 650 | 2D graphics |
| 05-animation-physics-3d.md | 18KB | 600 | Animation & physics |
| 06-ui-and-controls.md | 21KB | 700 | User interface |
| 07-platform-performance.md | 16KB | 550 | Platforms & optimization |
| 08-quick-reference.md | 15KB | 500 | Quick lookup |
| **TOTAL** | **170KB** | **~5,550 lines** | Comprehensive |

---

## External Resources

**Official Godot Documentation**:
- Docs: https://docs.godotengine.org/en/stable/
- Interactive Changelog: https://godotengine.github.io/godot-interactive-changelog
- Class Reference: https://docs.godotengine.org/en/stable/classes/

**Community Resources**:
- GDQuest: https://www.gdquest.com/
- Godot Tutorials: https://godottutorials.com/
- Official Forums: https://forum.godotengine.org/

**Performance & Profiling**:
- Official Performance Guide: https://docs.godotengine.org/en/stable/tutorials/performance/
- Profiler Documentation: https://docs.godotengine.org/en/stable/tutorials/performance/using_the_godot_profiler.html

---

## AI Optimization Metadata

**Structured for**:
- Rapid pattern matching
- Quick decision making
- Code template extraction
- Error prevention
- Performance optimization
- Cross-system validation

**Optimization Techniques Used**:
- Decision trees for choices
- Code templates with placeholders
- "WRONG vs CORRECT" examples
- Quick reference tables
- Cross-reference system
- Comprehensive gotcha coverage
- Performance notes integrated throughout

---

**Document Version**: 1.0
**Guidelines Version**: 4.6.0
**Last Updated**: 2025-11-15
**Total Documentation**: 170KB across 9 files
**Maintained By**: Claude Code (AI-assisted development system)
