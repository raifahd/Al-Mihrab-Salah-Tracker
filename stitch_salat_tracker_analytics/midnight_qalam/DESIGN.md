```markdown
# Design System Strategy: The Midnight Sanctuary

## 1. Overview & Creative North Star
**Creative North Star: "The Celestial Compass"**

This design system rejects the "utilitarian app" aesthetic in favor of a high-end editorial experience that feels like a digital sanctuary. We are moving away from rigid, boxy layouts to create a sense of infinite, atmospheric depth. By leveraging intentional asymmetry, overlapping geometric motifs, and a "Midnight" palette, we evoke the serenity of a moonlit courtyard. 

The goal is not just to display information, but to curate an experience that feels sacred, premium, and calm. We achieve this through "The Celestial Compass" principle: using light (Gold) to guide the user through the vastness of the dark (Navy).

---

## 2. Colors & The Surface Philosophy
The palette is rooted in the interplay between `#0f131f` (Midnight) and `#e9c349` (Gold). 

### The "No-Line" Rule
**Explicit Instruction:** Solid 1px borders are strictly prohibited for sectioning. 
Structure is defined through **Tonal Transitions**. To separate a content block from the background, shift from `surface` (#0f131f) to `surface-container-low` (#171b28). This creates a sophisticated, seamless flow that feels organic rather than mechanical.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers of silk and tinted glass.
- **Base Level:** `surface` (#0f131f) — The infinite sky.
- **Secondary Level:** `surface-container` (#1b1f2c) — Used for primary content groupings.
- **Elevated Level:** `surface-container-highest` (#313442) — Used for interactive elements like cards or modals.

### The Glass & Gold Rule
To move beyond a flat UI, utilize **Glassmorphism**. Floating navigation bars or top headers should use a semi-transparent `surface-container-low` with a 20px backdrop blur. 
- **Signature Texture:** Apply a 3% opacity Islamic geometric pattern (Star or Girih) as a mask over `surface-container` areas. It should be felt, not seen.
- **CTA Soul:** Use a subtle radial gradient for primary buttons, moving from `primary` (#e9c349) at the top-left to `on-primary-container` (#b6941a) at the bottom-right.

---

## 3. Typography: Editorial Sophistication
We pair the timeless authority of **Noto Serif** with the modern, high-legibility of **Manrope**.

- **Display & Headlines (Noto Serif):** These are our "Hero" moments. Use `display-lg` to `headline-sm` for titles that require emotional resonance (e.g., Daily Verses, Prayer Times). The serif typeface conveys tradition and scholarly depth.
- **Body & Titles (Manrope):** Use for functional data and long-form reading. Manrope’s geometric nature complements the Islamic patterns used in the background.
- **The Contrast Play:** Always pair a `headline-md` (Gold/`primary`) with a `body-sm` (Light Blue/`on-surface-variant`) to create a clear, editorial hierarchy that feels like a luxury magazine.

---

## 4. Elevation & Depth
In this system, depth is "Atmospheric," not "Structural."

- **The Layering Principle:** Place a `surface-container-lowest` card on top of a `surface-container-high` section to create a "recessed" look, or vice versa for a "raised" look. No shadows are needed for standard cards.
- **Ambient Shadows:** For high-importance floating elements (like a FAB), use a custom shadow: `0px 24px 48px rgba(0, 0, 0, 0.4)`. The shadow must feel like it is part of the midnight air, never harsh or grey.
- **The "Ghost Border":** If a boundary is required for accessibility, use the `outline-variant` (#454652) at 15% opacity. It should act as a whisper of a line, barely catching the light.

---

## 5. Components

### Buttons & Interaction
- **Primary Button:** High-sheen Gold (`primary`). Roundedness: `xl` (0.75rem) to maintain a soft, premium feel. Text is `on-primary` (#3c2f00).
- **Secondary Button:** A "Ghost" style. No fill, only the `outline` (#908f9d) at 20% opacity, with `primary` colored text.

### Cards & Lists
- **The "Border-Free" Card:** Cards must use `surface-container-highest` with no borders. Use `xl` (0.75rem) corner radius.
- **No-Divider Lists:** Forbid horizontal lines between list items. Instead, use a 16px vertical gap (from the Spacing Scale) or a subtle shift in `surface-container` tiers for every second item to create a rhythmic, zebra-like cadence.

### Specialized Components
- **The Prayer Progress Ring:** Use a dual-tone stroke. The "track" is `secondary-container` (#005db7) and the "indicator" is a gradient of `primary` to `tertiary`.
- **Geometric Chips:** Action chips for filtering should use the `md` (0.375rem) roundedness and a `surface-bright` (#353946) background to pop against the dark theme.

---

## 6. Do’s and Don’ts

### Do
- **Do** use asymmetrical margins. For example, a header might be indented further than the body text to create an editorial, high-end feel.
- **Do** use `primary` (#e9c349) sparingly. It is "Light." If everything is gold, nothing shines.
- **Do** embrace negative space. The "Midnight" background is a feature, not a void.

### Don’t
- **Don’t** use pure white (#FFFFFF) for text. Always use `on-surface` (#dfe2f3) to avoid harsh contrast that causes eye strain in dark mode.
- **Don’t** use standard Material Design drop shadows. They look "cheap" in a premium dark mode. Use Tonal Layering.
- **Don’t** use 100% opaque patterns. Islamic geometric patterns must be subtle (2-5% opacity) so they don't compete with the content.

---

## 7. Signature Layout Guideline: "The Overlap"
To break the "template" feel, allow images (like a mosque silhouette or a crescent moon) to break out of their containers. An image might sit in a `surface-container` but bleed into the `background` margin. This creates a sense of scale and custom craftsmanship that off-the-shelf components cannot replicate.```