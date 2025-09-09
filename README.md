# multi-drag&drop-poc

Simple Godot proof-of-concept for multi-touch drag & drop. Drag items from the ItemPanel grid and drop copies onto the ColorRect. Original items remain in the panel.

## Requirements
- Godot 4.x
- Windows (development); run on mobile device to test true multi-touch

## Files of interest
- scripts/item.gd — attached to item TextureRect scenes (provides _get_drag_data)
- scripts/multi_touch.gd — attach to `Main` (Node2D). Handles touch/mouse input, previews and multi-touch state.
- scripts/dropable_bg.gd — attach to `ColorRect`. Implements _can_drop_data / _drop_data and creates TextureRect copies.
- scene/main.tscn — example scene with ItemPanel and ColorRect.

## Setup
1. Open the project folder in Godot.
2. Open `scene/main.tscn`.
3. Attach scripts if not already attached:
   - `Main` node -> `scripts/multi_touch.gd`
   - `ColorRect` -> `scripts/dropable_bg.gd`
   - Item instances in the ItemPanel -> `scripts/item.gd`
4. Run the project (F5).

## How to use
- On a device with touch: touch and drag items from the ItemPanel; release over the ColorRect to place a copy. Simultaneous touches create separate previews and drops.
- On desktop: left mouse acts as a single touch (mouse fallback). True multi-touch requires a device.

## Notes / Troubleshooting
- Previews created while dragging use `mouse_filter = MOUSE_FILTER_IGNORE` so they don't block picking other controls.
- Drop position is converted from global -> Control local using the control's global rect (no to_local on Control).
- If a dropped item appears offset, check the ColorRect's anchors/margins — conversion uses `get_global_rect().position`.
- If a preview blocks picks, ensure its `mouse_filter` is set to `MOUSE_FILTER_IGNORE` and previews are added to the same CanvasLayer as UI (or a separate layer behind UI).

## Extending
- Snap items to a grid on drop.
- Add rotation/scale per-finger gestures.
- Persist placed items to a scene or