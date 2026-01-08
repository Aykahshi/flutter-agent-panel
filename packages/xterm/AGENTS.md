# AGENTS.md

## OVERVIEW
High-performance terminal emulator core supporting complex buffer management and escape sequence parsing.

## STRUCTURE
```
lib/src/
├── buffer/                # Terminal buffer and scrollback
│   ├── buffer.dart        # Main buffer implementation
│   └── line.dart          # Efficient cell storage (Uint32List)
├── core/                  # Emulation logic
│   ├── escape/            # ANSI/VT sequence parser (CSI, OSC)
│   ├── input/             # Keyboard mapping and keytabs
│   └── mouse/             # Mouse protocol support
└── ui/                    # Flutter rendering layer
    ├── render.dart        # Custom RenderBox for terminal
    └── painter.dart       # Canvas painting logic (pixel-aligned)
```

## WHERE TO LOOK
- **Render Engine**: `lib/src/ui/render.dart` (Layout & DPI)
- **Painting logic**: `lib/src/ui/painter.dart` (Cell rendering)
- **Escape Parser**: `lib/src/core/escape/parser.dart` (ANSI parsing)
- **Buffer logic**: `lib/src/core/buffer/buffer.dart` (Resize/Scroll)

## CONVENTIONS
- **Storage**: Use `Uint32List` in `BufferLine` for compact memory and speed.
- **Attributes**: Colors and styles packed into 32-bit integers.
- **Private members**: Extensive use of `_` for internal state; exposed via getters.
- **Inlining**: `@pragma('vm:prefer-inline')` on critical hot paths (painter).

## ANTI-PATTERNS
- **Manual Mocks**: NEVER edit `*.mocks.dart` files manually.
- **Sub-pixel coordinates**: Avoid floating point offsets in `Painter`; use `roundToDouble()` for crispness.

## NOTES
- **Performance**: Designed for 60fps; avoid tree rebuilds, use `isRepaintBoundary = true`.
- **DPI**: Sensitive to `devicePixelRatio`. Use `TextScaler` for accurate cell measurement.
