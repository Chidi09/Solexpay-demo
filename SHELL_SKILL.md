# SKILL: Authoring Screens for DemoDeviceShell
### A complete technical reference — read fully before writing any screen

---

## 0. How to read this file

Sections 1–3 are **mechanical facts** extracted directly from the shell source.  
Sections 4–8 are **layout rules** that follow from those facts.  
Sections 9–11 are **non-obvious gotchas** — things that will bite you silently.  
Section 12 is the **pre-submit checklist**.

---

## 1. What the shell does — mechanically

`DemoDeviceShell` has two operating modes selected by a `LayoutBuilder`:

```
constraints.maxWidth < 500  →  passthrough (child renders directly, no frame)
constraints.maxWidth ≥ 500  →  phone frame mode
```

In phone frame mode the shell:

1. Renders a scaled `_PhoneFrame` (dark iPhone body, side buttons, Dynamic Island)
2. Clips the screen area with `ClipRRect(borderRadius: 42 * s)`
3. Injects a **fake `MediaQuery`** into the child's subtree via `_ScreenContent`
4. Paints the **status bar as an overlay on top of your content** — not behind it
5. Paints the **home indicator as an overlay on top of your content** — not behind it

Steps 4 and 5 are the most commonly misunderstood. Your content fills the entire
screen rectangle first. The status bar and home bar are then painted **over** it as
`Positioned` children of a `Stack`. The injected `MediaQuery.padding` is the only
thing that tells `SafeArea` to push your content clear of them. If you skip
`SafeArea`, your layout collides with both overlays with no visual error thrown.

---

## 2. The injected MediaQuery — what changes, what doesn't

The shell calls `parent.copyWith(...)`, which **preserves** everything from the real
device and **overrides** only these four fields:

| Field | Injected value | What it means for you |
|---|---|---|
| `size` | `Size(375, 812)` | All layout widgets believe the screen is 375 × 812 |
| `padding` | `top: 54, bottom: 34` | `SafeArea` reads these and pushes content inward |
| `viewPadding` | `top: 54, bottom: 34` | Same as padding — permanent insets |
| `viewInsets` | `EdgeInsets.zero` | **Keyboard insets are completely stripped** (see §9.1) |

Everything else comes from the **real host device**:

- `devicePixelRatio` — real device's DPR. Images resolve their `@2x`/`@3x` variants correctly.
- `textScaler` — real device accessibility scale. If a user has Large Text on, your text grows larger than designed. Use `MediaQuery.withNoTextScaling` wrapping hero text if pixel-perfect sizing matters.
- `physicalSize` — real physical screen dimensions. **Never use this for layout.** Use `size`.
- `platformBrightness` — real device dark/light setting. Theme-based colour switching works correctly.

---

## 3. The scale factor — what it is and what it does NOT do

Inside `_PhoneFrame`:

```dart
final double s = box.maxWidth / outerW;  // outerW = 375 + (8 * 2) = 391
```

`s` is applied **only to the frame chrome**: bezel thickness, corner radii, side
button dimensions, Dynamic Island pill size, status bar font size, home pill width.
It scales the phone hardware to look proportionally correct at any container size.

`s` is **never applied to your content.** Your widgets receive exactly `375 × 812`
from `MediaQuery.size` and lay out at their native logical pixel density. On a wide
desktop window the frame may occupy 420 real pixels — your 375-pt layout inside it
looks slightly zoomed. This is cosmetically correct. Do not try to compensate.

---

## 4. The canvas you are designing for

After safe area insets, your actual usable content area is:

```
Width:   375 pt  (no horizontal insets from the shell)
Height:  724 pt  (812 − 54 status − 34 home)
```

For safety, design as if height is only **600 pt** — that is approximately an iPhone SE
(667 total − 44 status − 34 home = 589). A screen that works on an SE works
everywhere. A screen that only works at 724 pt will overflow on older test devices
when the shell is in passthrough mode on a narrower real phone.

---

## 5. Mandatory Scaffold structure

Every screen must follow this nesting exactly.

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(                          // OUTER — fills device/browser window
      body: DemoDeviceShell(
        child: Scaffold(                      // INNER — renders inside phone frame
          backgroundColor: AppColors.shell,  // always set explicitly
          resizeToAvoidBottomInset: false,   // keyboard is handled externally (§9.1)
          body: SafeArea(                    // MANDATORY
            child: /* your UI */,
          ),
        ),
      ),
    );

  }
}
```

**Why the outer Scaffold?** `DemoDeviceShell` uses a `LayoutBuilder` whose constraints
come from its parent. An unconstrained parent (like a bare `Center`) gives infinite
constraints, which makes `LayoutBuilder.maxWidth` return infinity and the `< 500`
check always passes, rendering the passthrough mode permanently on desktop. The outer
`Scaffold` gives the `LayoutBuilder` a real bounded constraint.

**Why explicit `backgroundColor` on the inner Scaffold?** Without it, Flutter uses the
theme's `scaffoldBackgroundColor`. If that differs from what you intend, the dark
phone frame border becomes visible through the mismatch as a 1–2 pt halo. Always
explicit.

---

## 6. Padding, spacing, and tap targets

### Horizontal padding by screen type

| Screen type | Padding |
|---|---|
| Onboarding / auth flows | 24 pt |
| Data-dense screens (lists, cards) | 16 pt |
| Card internal padding | 14–20 pt |
| Full-bleed header cards | 0 pt (card handles its own padding) |

On a 375 pt canvas: 16 pt each side leaves **343 pt** for content. 24 pt leaves
**327 pt**. Never go below 14 pt each side.

### Vertical rhythm

| Gap context | Value |
|---|---|
| Between major screen sections | 20–24 pt |
| Between related cards or items | 10–14 pt |
| Label → its input | 6–8 pt |
| Stacked action buttons | 10–12 pt |
| After the last element before a pinned CTA | 24–32 pt |

### Tap targets

Minimum **44 × 44 pt** for every interactive element, no exceptions.

The shell scales the frame chrome visually but does **not** scale touch hit areas.
A 32 × 32 icon button that is comfortable on a real phone has roughly 26 physical
pixels of tap area inside the scaled frame on desktop — effectively untappable.

Always set `constraints` on `IconButton`:

```dart
IconButton(
  onPressed: onBack,
  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
)
```

For custom `GestureDetector`-wrapped containers, give the container a minimum size
of 44 × 44 even if the visible artwork is smaller. Use transparent padding inside
the container to fill the gap.

---

## 7. Typography rules

| Role | fontSize | fontWeight | Notes |
|---|---|---|---|
| Hero / balance display | 32–40 | w800 | Always inside `FittedBox` |
| Screen heading | 22–26 | w800 | letterSpacing: −0.3 to −0.5 |
| Section title | 15–16 | w700 | |
| Card title | 13–14 | w600–w700 | |
| Body / description | 13–14 | w400–w500 | height: 1.45–1.55 |
| Input label (floating) | 11 | w500 | |
| Metadata / timestamp | 10–11 | w500 | |
| Badge / chip label | 10–11 | w600–w700 | |

**Hard floor: never go below 10 pt.** The shell does not upscale text. At 9 pt, text
inside the frame on a desktop monitor has roughly 7 physical pixels of cap-height —
unreadable and an accessibility violation on a real device.

**Hero numbers always need `FittedBox`.** Currency strings can reach 14+ characters
(`₦1,234,567.89`). Without `FittedBox` they overflow the 375 pt width silently —
Flutter clips them or wraps them awkwardly.

```dart
FittedBox(
  fit: BoxFit.scaleDown,
  alignment: Alignment.centerLeft,
  child: Text(
    CurrencyFormatter.format(balance),
    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
  ),
)
```

**Line height on body text.** Always set `height: 1.45` or higher on any text that
wraps. Flutter's default line height is 1.0 × font metrics, which produces very tight
leading at 13–14 pt. Text without `height` set looks compressed inside the frame.

---

## 8. Layout patterns for common screen types

### 8.1 Header + scrollable body + pinned CTA (most common)

```dart
SafeArea(
  child: Column(
    children: [
      // Header — never inside the ListView
      Padding(
        padding: const EdgeInsets.fromLTRB(6, 4, 16, 0),
        child: _Header(),
      ),
      // Scrollable body
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          children: [ /* sections */ ],
        ),
      ),
      // Pinned CTA — outside scroll, bottom padding clears home bar
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: PrimaryButton(label: 'Continue', onPressed: onPressed),
      ),
    ],
  ),
)
```

### 8.2 Centering content vertically (success / illustration screens)

Prefer named `Spacer` flex ratios over `Center`, so content sits in the
upper-golden-third rather than dead centre. Dead centre on a tall canvas feels low.

```dart
SafeArea(
  child: Column(
    children: [
      const Spacer(flex: 2),   // more space above
      // illustration or icon
      const Spacer(flex: 1),
      // heading + body text
      const Spacer(flex: 3),   // more space below
      PrimaryButton(...),
      const SizedBox(height: 14),
    ],
  ),
)
```

### 8.3 Input screen (keyboard-safe)

Do not use `Spacer`. Use explicit spacing and `SingleChildScrollView`.

```dart
SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _Header(),
        const SizedBox(height: 28),
        _InputField(),
        const SizedBox(height: 14),
        _InputField2(),
        const SizedBox(height: 32),
        PrimaryButton(...),
        const SizedBox(height: 16),
      ],
    ),
  ),
)
```

### 8.4 Simulated bottom navigation bar

Never use `Scaffold(bottomNavigationBar: ...)`. See §9.4. Instead:

```dart
SafeArea(
  child: Column(
    children: [
      Expanded(child: /* page content */),
      _BottomNavBar(), // sits just above the 34pt home bar automatically
    ],
  ),
)
```

Add 8–12 pt of internal bottom padding inside `_BottomNavBar` so icons don't crowd
the home pill.

---

## 9. Non-obvious gotchas — things that will break you silently

### 9.1 Keyboard handling is intentionally broken — design around it

`viewInsets` is zeroed in the injected `MediaQuery`. Consequences:

- `Scaffold(resizeToAvoidBottomInset: true)` on the inner Scaffold **does nothing**.
  The inner Scaffold never sees keyboard insets.
- `MediaQuery.of(context).viewInsets.bottom` is always `0.0` inside the frame.

What actually happens: the **outer** Scaffold (which has real `viewInsets`) pushes the
entire shell frame upward when the keyboard appears. The whole phone frame slides up.
This is acceptable for a demo, but only if your input screens are scroll-wrapped so
fields are reachable.

**Fix:** `resizeToAvoidBottomInset: false` on the inner Scaffold (prevents a double
push attempt) + `SingleChildScrollView` wrapping all inputs.

### 9.2 Never use AppBar on the inner Scaffold

`AppBar` renders at y = 0 of the inner Scaffold — directly underneath the shell's
status bar overlay. The result: the AppBar's background colour bleeds through the
transparent areas around the Dynamic Island pill, your AppBar title is obscured by the
white "9:41" time text, and if your AppBar is light-coloured the time becomes invisible
entirely. There is no configuration that makes `AppBar` look correct inside the shell.

Always use a manual header `Row` inside `SafeArea`. Every screen in the codebase
already demonstrates this pattern.

### 9.3 The ClipRRect corner radius clips your content

The screen is clipped: `ClipRRect(borderRadius: BorderRadius.circular(42 * s))`.
At scale = 1, **42 pt corner radius**. Any widget that extends to the literal corners
of your 375 × 812 layout is rounded-clipped.

The clip zone overlaps with the status bar (top corners) and home indicator (bottom
corners) areas, so in practice it only affects:

- Full-bleed background images or gradients — they will look rounded, which is correct
- Status indicators or timestamps placed in the very top-left or top-right corners
  inside `SafeArea` — they may be visually clipped

Design backgrounds so that the rounded clipping reads as intentional (the phone's
screen edge) not as a cropping error.

### 9.4 `bottomNavigationBar` on inner Scaffold overlaps the home pill

Flutter places `bottomNavigationBar` at y = 812 − navBarHeight. The shell's home
indicator overlay (34 pt) then draws on top of the nav bar icons. The bar is not
pushed up because `viewPadding.bottom` is provided by the injected `MediaQuery` but
the `Scaffold` widget does not apply it to `bottomNavigationBar` positioning the same
way a real device OS would.

The result is your nav icons are partially covered by the home pill with no layout
error. Use the manual pattern in §8.4.

### 9.5 Dialogs, bottom sheets and snackbars live and die by their context

This is a Flutter fundamental that becomes critical inside the shell:

**`showDialog` / `showModalBottomSheet`:** Flutter roots these at the `Navigator`
that owns the given `context`. go_router's navigator sits above the entire shell in
the tree, so both dialogs and sheets called from inside the frame will appear above the
frame chrome, covering the phone outline entirely. If you want them contained inside the
frame, you need a local nested `Navigator` inside the inner `Scaffold`.

**`ScaffoldMessenger.of(context).showSnackBar`:** Resolves to the nearest
`ScaffoldMessenger` ancestor. If called from within the inner Scaffold's subtree, the
snackbar appears at the bottom of the phone frame (inside the home bar area, which
looks correct). If your widget's context is somehow above the shell (rare but possible
with global keys or callback plumbing), the snackbar appears at the bottom of the
entire window. When in doubt: call `showSnackBar` from a `Builder` that is provably a
descendant of the inner `Scaffold`.

**`showModalBottomSheet` inside the frame:** always pass `useSafeArea: true` so the
sheet respects the 54 pt top inset. Maximum `isScrollControlled` height is 812 − 54 =
758 pt. The sheet is clipped by the screen `ClipRRect`, so at full height its top
rounded corners will be clipped. Add `clipBehavior: Clip.antiAlias` to the sheet's
container and match the corner radius to the screen's 42 pt for a seamless look.

### 9.6 The status bar is always white — your background must contrast

`_StatusBar` renders white text ("9:41") and white icons with no adaptive logic. There
is no `SystemUiOverlayStyle` equivalent here — the colour is hardcoded. If the visible
area behind the Dynamic Island is light (white, pale grey, any light pastel), the
status bar text and icons become invisible. There is no error.

**Option A (recommended):** ensure your screen's background behind the status bar area
is always mid-tone or dark enough for white text. `AppColors.shell` and most branded
gradient cards work. Plain white `#FFFFFF` does not.

**Option B:** add a `LinearGradient` scrim in the status bar zone. Because the status
bar is painted over your content, you need to extend the scrim above `SafeArea` using
a `Stack`:

```dart
// Outside SafeArea, as a Stack sibling
Positioned(
  top: 0, left: 0, right: 0,
  height: 80,
  child: DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ),
    ),
  ),
)
```

### 9.7 `Spacer` is unsafe on input screens and dynamic-content screens

`Spacer` allocates all remaining vertical space in a `Column` after siblings are
measured. If any sibling has dynamic height (text that wraps, content loaded
asynchronously, error messages that appear and disappear), the `Column` overflows
because `Spacer` has no minimum and cannot shrink below zero.

**Spacer is safe only when every sibling has a fixed, bounded, predictable height.**
For any screen with text inputs, variable-length lists, or conditional content, use
`ListView` or explicit `SizedBox` spacing.

### 9.8 `Hero` animations clip at the screen boundary

The `ClipRRect` wrapping the screen content clips everything — including in-flight
`Hero` widget animations. A `Hero` that begins near a screen edge will appear to cut
off during its flight. Keep hero source and destination widgets at least 42 pt from
all four screen edges, or use `flightShuttleBuilder` with a custom `UnclippedLayer` to
route the animation above the clip.

### 9.9 The 500 px passthrough — your screen must look good without the frame

When the shell's `LayoutBuilder` sees `maxWidth < 500` it renders `child` directly.
On a real phone `MediaQuery.padding` comes from the OS (real insets, real safe areas).
`SafeArea` still works correctly because it reads those real values.

What changes: the real OS status bar sits above your app natively. The OS handles
status bar colour through `SystemUiOverlayStyle`. On a real device, a light
`AppColors.shell` background is fine because the OS status bar text adapts. Inside the
shell on desktop, that same light background makes the hardcoded white status bar text
invisible.

If you are deploying this to both real devices and the shell demo, pick a background
that works for white status bar text in both environments. Anything at ≥ 30%
saturation/darkness works. Off-white `#F4F6FA` is borderline — test it.

### 9.10 `LayoutBuilder` inside your screen receives phone-frame constraints correctly

Because your screen's subtree sits inside `_PhoneFrame`'s `LayoutBuilder`, any
`LayoutBuilder` you use in your screen receives `375 × 812` constraints — the injected
phone canvas — not the window's constraints. This is correct and useful. You can
build responsive sub-layouts within the phone canvas safely. `ConstrainedBox`,
`IntrinsicHeight`, `IntrinsicWidth` also all operate within 375 × 812.

---

## 10. Performance tips specific to this shell

**Localise `AnimatedBuilder` to the smallest possible subtree.**
The shell wraps your content in nested `Stack` → `Positioned` → `ClipRRect` → `MediaQuery` → `Stack` again. An `AnimatedBuilder` high in your widget tree causes the raster layer for all of those to dirty on every animation frame. Keep animation controllers and their `AnimatedBuilder`s as deep in the tree as possible.

**Wrap per-frame `CustomPaint` in `RepaintBoundary`.**
Progress rings, scan-line animators, and pulse effects driven by `AnimationController`
rasterize on every frame. Without a `RepaintBoundary`, the entire phone screen
re-rasterizes. With one, only the painter's layer dirties.

```dart
RepaintBoundary(
  child: AnimatedBuilder(
    animation: _controller,
    builder: (_, __) => CustomPaint(painter: _RingPainter(progress: _controller.value)),
  ),
)
```

**Keep the outer `Scaffold` and `DemoDeviceShell` out of `setState` rebuild paths.**
If your screen's `build()` method calls `setState` frequently (e.g., on text field
change), and `DemoDeviceShell` is rebuilt each time, the entire frame chrome repaints.
Extract `DemoDeviceShell` and the outer `Scaffold` into a parent that does not rebuild,
or use `Consumer` / `context.watch` only inside the inner `Scaffold`'s subtree.

**Avoid `const` animations — but `const` everything static.**
Static elements (headers, labels, decorative icons that don't animate) should be
`const`-constructed. Flutter's element reconciliation skips `const` widgets entirely
during rebuild. On a screen with 3 animated elements and 12 static ones, only the 3
should rebuild per frame.

---

## 11. Reference numbers at a glance

| Constant | Value | Source |
|---|---|---|
| Screen logical width | 375 pt | `_PhoneFrame._screenW` |
| Screen logical height | 812 pt | `_PhoneFrame._screenH` |
| Bezel thickness | 8 pt | `_PhoneFrame._bezel` |
| Outer corner radius | 48 pt | `_PhoneFrame._cornerR` |
| Screen corner radius (clip) | **42 pt** | `_PhoneFrame._screenR` |
| Status bar height | **54 pt** | `_PhoneFrame._statusH` |
| Home indicator height | **34 pt** | `_PhoneFrame._homeH` |
| Usable content height | **724 pt** | 812 − 54 − 34 |
| Frame breakpoint | 500 px | `DemoDeviceShell` `LayoutBuilder` |
| Minimum tap target | 44 pt | HIG / Material spec |
| Minimum font size | 10 pt | Readability floor |

---

## 12. Pre-submit checklist

**Structure**
- [ ] Outer `Scaffold` → `DemoDeviceShell` → inner `Scaffold` nesting is intact
- [ ] Inner `Scaffold` has an explicit `backgroundColor`
- [ ] Inner `Scaffold` has `resizeToAvoidBottomInset: false`
- [ ] `SafeArea` is the direct first child of inner `Scaffold.body`
- [ ] No `AppBar` or `CupertinoNavigationBar` on inner `Scaffold`
- [ ] No `bottomNavigationBar` on inner `Scaffold`
- [ ] No `floatingActionButton` on inner `Scaffold`

**Layout**
- [ ] Horizontal content padding is 16–24 pt — never below 14 pt
- [ ] No hard-coded container height exceeding 600 pt
- [ ] Screens taller than ~4 stacked sections use `ListView` or `SingleChildScrollView`
- [ ] Input screens use `SingleChildScrollView` — no `Spacer` on input screens
- [ ] `Spacer` only appears when all siblings have fixed, bounded heights
- [ ] All interactive elements have a minimum 44 × 44 pt hit area

**Typography**
- [ ] No `fontSize` below 10 pt anywhere
- [ ] Hero / balance text is inside `FittedBox(fit: BoxFit.scaleDown)`
- [ ] Multi-line body text has `height: 1.45` or greater

**Visual**
- [ ] Background behind status bar area has sufficient contrast for white text
- [ ] Full-bleed gradients and background images account for 42 pt corner clip
- [ ] `showModalBottomSheet` passes `useSafeArea: true`
- [ ] `showSnackBar` is called from a context provably inside the inner `Scaffold`

**Performance**
- [ ] Per-frame `CustomPaint` elements are wrapped in `RepaintBoundary`
- [ ] `AnimatedBuilder` subtrees are as narrow as possible
- [ ] Static UI elements are `const`-constructed where possible
