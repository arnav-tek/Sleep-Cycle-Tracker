# Design System Strategy: The Celestial Guardian

## 1. Overview & Creative North Star
The Creative North Star for **LunaSleep** is **"The Celestial Guardian."** 

We are moving away from the "utilitarian utility" of standard alarm apps and toward a high-end, editorial wellness experience. The interface feels like a high-tech observatory—quiet, precise, and deeply immersive. We achieve this by breaking the traditional rigid grid; elements should breathe with intentional asymmetry and overlapping "glass" layers. 

Rather than boxed-in data, we treat sleep metrics as ethereal artifacts floating in a deep-space vacuum. The use of high-contrast typography scales (the massive `display-lg` vs. the delicate `label-sm`) creates an authoritative, sophisticated hierarchy that feels both premium and futuristic.

---

## 2. Colors & Surface Soul
This system uses a monochromatic dark foundation punctuated by high-energy neon pulses.

### The "No-Line" Rule
**Strict Mandate:** 1px solid borders are prohibited for sectioning. Structural definition must be achieved through background shifts. For example, a sleep summary card sits directly on the `background` without a stroke. The eye should perceive depth through tonal change, not physical containment.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of frosted obsidian. 
- **Base Level:** `surface` (#0e0e0e) for the main canvas.
- **Mid Level:** `surface-container-low` (#131313) for secondary content groupings.
- **Top Level:** `surface-container-highest` (#262626) for active interaction points.
Nesting these layers creates a natural "lift" that mimics high-end hardware interfaces.

### The "Glass & Gradient" Rule
To achieve the "Futuristic Tech" mood, use Glassmorphism for floating controllers. Use a linear gradient: `primary_dim` to `primary` (45-degree angle) for buttons and active tracks.

---

## 3. Typography: The Editorial Edge
We pair the geometric precision of **Space Grotesk** with the humanist readability of **Manrope**.

- **Display & Headlines (Space Grotesk):** Used for "Hero Data"—the wake-up time, sleep score, and hours slept. These should feel like a premium watch face: bold, oversized, and unignorable.
- **Body & Labels (Manrope):** Used for secondary insights and settings. The tight tracking and lowercase-heavy styling lend a "softness" to the data, making the tech feel approachable and calm.
- **Visual Contrast:** Never pair two similar sizes. If a headline is `headline-lg`, the supporting text should jump down to `body-md` to ensure a clear, editorial "tempo" on the page.

---

## 4. Elevation & Depth
Depth is a feeling, not a drop-shadow.

- **The Layering Principle:** Avoid elevation numbers. Instead, "stack" tokens. A `surface-container-high` element on a `surface` background is our primary method of elevation.
- **Ambient Shadows:** When an element must "float" (e.g., a modal), use a diffused glow.
    - *Shadow:* 0px 20px 40px, `primary` at 8% opacity. This mimics the soft light of a screen in a dark room.

---

## 5. Components & Interaction

### Circular Sleep Dials
- **Visuals:** Use `secondary_container` for the track and a `primary` to `tertiary` gradient for the progress fill. 

### Pulsing Action Buttons (CTAs)
- **Primary:** Roundedness `full`. Background: Gradient of `primary` to `primary_dim`. No border.

### Cards & Lists
- **Forbid Dividers:** Use vertical whitespace (spacing-6) to separate list items. 
- **Selection:** Instead of a checkbox, a selected list item should transition its background from `surface` to `surface-container-high`.
