#### 2D

- Fix redundant calls of `CanvasItemEditor::_update_lock_and_group_button` on `SceneTreeEditor` node selection ([GH-110320](https://github.com/godotengine/godot/pull/110320)).

#### 3D

- GridMap: fix cell scale not applying to the cursor mesh ([GH-104510](https://github.com/godotengine/godot/pull/104510)).

#### Animation

- Fix Reset on Save corrupt poses if scene has multiple Skeletons ([GH-110506](https://github.com/godotengine/godot/pull/110506)).
- Fix backward/pingpong root motion in AnimationTree ([GH-110982](https://github.com/godotengine/godot/pull/110982)).
- Make extended SkeletonModifiers retrieve interpolated global transform ([GH-110987](https://github.com/godotengine/godot/pull/110987)).

#### Audio

- Add one padding frame to QOA buffer for short streams ([GH-110515](https://github.com/godotengine/godot/pull/110515)).

#### Buildsystem

- Linux: Allow unbundling libjpeg-turbo to use system package ([GH-110540](https://github.com/godotengine/godot/pull/110540)).
- Editor: Generate translation data in separate cpp files ([GH-110618](https://github.com/godotengine/godot/pull/110618)).
- SCons: Fix Windows `silence_msvc` logfile encoding ([GH-110691](https://github.com/godotengine/godot/pull/110691)).
- Windows: Migrate `godot.manifest` to `platform/windows`, include as dependency ([GH-110897](https://github.com/godotengine/godot/pull/110897)).
- Fix compiling SDL without DBus under Linux ([GH-111146](https://github.com/godotengine/godot/pull/111146)).
- macOS: Move includes inside `#ifdef` so OpenGL can be disabled ([GH-111301](https://github.com/godotengine/godot/pull/111301)).
- Revert "SCons: Add `CPPEXTPATH` for external includes" ([GH-111331](https://github.com/godotengine/godot/pull/111331)).
- SCons: Don't activate `fast_unsafe` automatically on `dev_build` ([GH-111411](https://github.com/godotengine/godot/pull/111411)).

#### Codestyle

- Remove dependency of `variant.h` in `print_string.h` ([GH-107721](https://github.com/godotengine/godot/pull/107721)).

#### Core

- Initialize `Quaternion` variant with identity ([GH-84658](https://github.com/godotengine/godot/pull/84658)).
- Avoid repeated `_copy_on_write()` calls in `Array::resize()` ([GH-110535](https://github.com/godotengine/godot/pull/110535)).
- Check for `NUL` characters in string parsing functions ([GH-110556](https://github.com/godotengine/godot/pull/110556)).
- X11 input: prevent non-printable keys from producing empty strings ([GH-110635](https://github.com/godotengine/godot/pull/110635)).
- Change "reserve called with a capacity smaller than the current size" error message to a verbose message ([GH-110826](https://github.com/godotengine/godot/pull/110826)).

#### Documentation

- Document typed dictionaries and arrays in the class reference ([GH-107071](https://github.com/godotengine/godot/pull/107071)).
- Clarify that velocity doesn't need delta multiplication in CharacterBody documentation ([GH-109925](https://github.com/godotengine/godot/pull/109925)).
- Document the interaction between Light3D cull mask and GI/volumetric fog ([GH-110423](https://github.com/godotengine/godot/pull/110423)).
- Fix Basis.determinant() doc: uniform scale determinant is scale^3 ([GH-110424](https://github.com/godotengine/godot/pull/110424)).
- Fix and improve `Node2D.move_local_{x,y}()` description ([GH-110878](https://github.com/godotengine/godot/pull/110878)).
- Fix /tutorial added twice in offline docs ([GH-110881](https://github.com/godotengine/godot/pull/110881)).

#### Editor

- Correct the order of Diagonal Mode in Add Property ([GH-109214](https://github.com/godotengine/godot/pull/109214)).
- Fix typos in BlendSpace2D editor's axis labels' accessibility names ([GH-109847](https://github.com/godotengine/godot/pull/109847)).
- Add column boundary check in the autocompletion ([GH-110017](https://github.com/godotengine/godot/pull/110017)).
- Fix favorite folders that are outside of the project being displayed in `FileSystemDock`'s file list ([GH-110415](https://github.com/godotengine/godot/pull/110415)).
- Fix crash due to null pointer dereference when moving/renaming folders in `FileSystemDock` ([GH-110420](https://github.com/godotengine/godot/pull/110420)).
- Fix the project file was not updated when some files were removed ([GH-110576](https://github.com/godotengine/godot/pull/110576)).
- Fix DPITexture editor icon name ([GH-110661](https://github.com/godotengine/godot/pull/110661)).
- Fix selection of remote tree using the keyboard ([GH-110738](https://github.com/godotengine/godot/pull/110738)).
- Tweak macOS notarization export message in the editor ([GH-110793](https://github.com/godotengine/godot/pull/110793)).
- Fix Quick Open history ([GH-111068](https://github.com/godotengine/godot/pull/111068)).
- Set correct saved history after clearing ([GH-111136](https://github.com/godotengine/godot/pull/111136)).
- Cherry-picks for the 4.5 branch (future 4.5.1) - 3rd batch ([GH-111388](https://github.com/godotengine/godot/pull/111388)).
- Enable script templates by default ([GH-111454](https://github.com/godotengine/godot/pull/111454)).

#### Export

- Android: Only validate keystore relevant to current export mode ([GH-109568](https://github.com/godotengine/godot/pull/109568)).
- Android: Ensure proper cleanup of the fragment ([GH-109764](https://github.com/godotengine/godot/pull/109764)).
- Fix iOS/visionOS export plugin crash on exit ([GH-110485](https://github.com/godotengine/godot/pull/110485)).
- Metal: Fix Metal compiler version inspection ([GH-110873](https://github.com/godotengine/godot/pull/110873)).
- Windows: Fix application manifest in exported projects with modified resources ([GH-111316](https://github.com/godotengine/godot/pull/111316)).

#### GDExtension

- Fix `--dump-extension-api-with-docs` indentation ([GH-110557](https://github.com/godotengine/godot/pull/110557)).
- Prevent breaking compatibility for unexposed classes that can only be created once ([GH-111090](https://github.com/godotengine/godot/pull/111090)).

#### GDScript

- LSP: Fix repeated restart attempts ([GH-111290](https://github.com/godotengine/godot/pull/111290)).

#### GUI

- Fix LineEdit icon positon in right-to-left layout ([GH-109363](https://github.com/godotengine/godot/pull/109363)).
- Editor font: do not embolden the Main Font if it's variable ([GH-110737](https://github.com/godotengine/godot/pull/110737)).
- Fix LineEdit's placeholder text being selected when double clicking ([GH-110886](https://github.com/godotengine/godot/pull/110886)).
- Fix text servers build with disabled FreeType ([GH-111001](https://github.com/godotengine/godot/pull/111001)).
- TextServer: Enforce zero width spaces and joiners to actually be zero width and not fallback to regular space ([GH-111014](https://github.com/godotengine/godot/pull/111014)).
- Fix bottom panel being unintentionally draggable ([GH-111121](https://github.com/godotengine/godot/pull/111121)).
- Enforce zero width spaces and joiners with missing font. Do not warn about missing non-visual characters ([GH-111355](https://github.com/godotengine/godot/pull/111355)).

#### Import

- Material Conversion Error Handling ([GH-109369](https://github.com/godotengine/godot/pull/109369)).
- OBJ importer: Support bump multiplier (normal scale) ([GH-110925](https://github.com/godotengine/godot/pull/110925)).

#### Input

- macOS: Remove old embedded window joystick init code ([GH-110491](https://github.com/godotengine/godot/pull/110491)).
- Fix the bug causing `java.lang.StringIndexOutOfBoundsException` crashes when showing the virtual keyboard ([GH-110611](https://github.com/godotengine/godot/pull/110611)).
- Fix weak and strong joypad vibration being swapped ([GH-111191](https://github.com/godotengine/godot/pull/111191)).
- Fix invalid reported joypad presses ([GH-111192](https://github.com/godotengine/godot/pull/111192)).

#### Navigation

- [Navigation 2D] Fix sign of cross product ([GH-110815](https://github.com/godotengine/godot/pull/110815)).
- Make navmesh rasterization errors more lenient ([GH-110841](https://github.com/godotengine/godot/pull/110841)).

#### Physics

- Fix bug in ManifoldBetweenTwoFaces ([GH-110507](https://github.com/godotengine/godot/pull/110507)).
- Fix CCD bodies adding multiple contact manifolds when using Jolt ([GH-110914](https://github.com/godotengine/godot/pull/110914)).
- Fix crash when calling `move_and_collide` with a null `jolt_body` ([GH-110964](https://github.com/godotengine/godot/pull/110964)).
- JoltPhysics: Fix Generic6DOFJoint3D not respecting angular limits ([GH-111087](https://github.com/godotengine/godot/pull/111087)).

#### Porting

- Wayland: Emulate frame event for old `wl_seat` versions ([GH-105587](https://github.com/godotengine/godot/pull/105587)).
- Workaround X11 crash issue ([GH-106798](https://github.com/godotengine/godot/pull/106798)).
- macOS: Always use "Regular" activation policy for GUI, and headless main loop for command line only tools ([GH-109795](https://github.com/godotengine/godot/pull/109795)).
- Wayland: Inhibit idle in DisplayServerWayland::screen_set_keep_on ([GH-110875](https://github.com/godotengine/godot/pull/110875)).
- Change `macos.permission.RECORD_SCREEN` version check from 10.15 to 11.0 ([GH-110936](https://github.com/godotengine/godot/pull/110936)).
- Unix: Fix retrieval of PID exit code ([GH-111058](https://github.com/godotengine/godot/pull/111058)).

#### Rendering

- DirectX DescriptorsHeap pooling on CPU ([GH-106809](https://github.com/godotengine/godot/pull/106809)).
- Disable unsupported SSR, SSS, DoF on transparent viewports ([GH-108206](https://github.com/godotengine/godot/pull/108206)).
- Windows: Try reading GPU driver information directly from registry ([GH-109346](https://github.com/godotengine/godot/pull/109346)).
- Compatibility: Fix backface culling gets ignored when double-sided shadows are used ([GH-109793](https://github.com/godotengine/godot/pull/109793)).
- OpenXR: Fix ViewportTextures not displaying correct texture (OpenGL) ([GH-110002](https://github.com/godotengine/godot/pull/110002)).
- Divide screen texture by luminance multiplier in compatibility ([GH-110004](https://github.com/godotengine/godot/pull/110004)).
- Increase precision of SpotLight attenuation calculation to avoid driver bug on Intel devices ([GH-110363](https://github.com/godotengine/godot/pull/110363)).
- Move check for sky cubemap array back into the SkyRD initializer ([GH-110627](https://github.com/godotengine/godot/pull/110627)).
- Fix glow intensity not showing in compatibility renderer ([GH-110843](https://github.com/godotengine/godot/pull/110843)).
- Fix OpenXR with D3D12 using the wrong clip space projection matrix ([GH-110865](https://github.com/godotengine/godot/pull/110865)).
- Fix d3d12 stencil buffer not clearing ([GH-111032](https://github.com/godotengine/godot/pull/111032)).
- Sort render list correctly in RD renderers ([GH-111054](https://github.com/godotengine/godot/pull/111054)).
- Fix LightmapGI not being correctly applied to objects ([GH-111125](https://github.com/godotengine/godot/pull/111125)).
- Fix uniform name for luminance multiplier in shader compiler ([GH-111438](https://github.com/godotengine/godot/pull/111438)).

#### XR

- Fix late destruction access violation with OpenXRAPIExtension object ([GH-110868](https://github.com/godotengine/godot/pull/110868)).
