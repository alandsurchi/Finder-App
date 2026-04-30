# Design System Document: The Empathetic Curator

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Empathetic Curator."** 

Lost and found platforms often feel like cluttered digital bulletin boards. This system rejects that chaos in favor of a high-end, editorial experience that treats every lost item with dignity and every community interaction with trust. We move beyond "utility" into "hospitality." 

To break the "template" look, the system utilizes **Intentional Asymmetry** and **Tonal Depth**. Instead of rigid, centered grids, we use generous, offset white space and overlapping elements to create a sense of movement and human touch. This is a premium safety net for the community—sophisticated, reliable, and calm.

---

## 2. Colors & Atmospheric Depth
Our palette is rooted in a "Friendly Blue" (`primary: #004ac6`), but its application is anything but standard.

### The "No-Line" Rule
**Borders are prohibited for sectioning.** To create separation, use background shifts. 
- *Example:* A card using `surface-container-lowest` (#ffffff) sitting on a `surface-container-low` (#eff4ff) background.
- This creates "soft boundaries" that feel organic rather than clinical.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers.
- **Base:** `surface` (#f8f9ff)
- **Grouping:** `surface-container` (#e6eeff)
- **Interactive Elements:** `surface-container-highest` (#d5e3fc)
- **Nesting Logic:** Always place a "High" container inside a "Low" container to draw the eye inward to the content that matters most (e.g., the item description).

### The "Glass & Gradient" Rule
To add "soul," avoid flat blocks of color.
- **CTAs:** Use a subtle linear gradient from `primary` (#004ac6) to `primary_container` (#2563eb).
- **Floating Overlays:** Use `surface_container_lowest` at 80% opacity with a `20px` backdrop blur (Glassmorphism) for navigation bars or floating action buttons.

---

## 3. Typography: The Editorial Voice
We use two sans-serifs to create a hierarchy that feels both authoritative and approachable.

*   **Display & Headlines (Manrope):** Chosen for its geometric precision and modern "tech-humanist" feel. 
    *   `display-lg` (3.5rem): Use for emotional hero moments (e.g., "Found!").
    *   `headline-md` (1.75rem): For item categories.
*   **Body & Titles (Plus Jakarta Sans):** Chosen for high legibility at small scales.
    *   `body-lg` (1rem): Standard reading text.
    *   `title-sm` (1rem, Bold): For high-density information like item locations.

**Hierarchy Tip:** Use `on_surface_variant` (#434655) for secondary metadata to create a "recessed" typographic layer, ensuring the primary headers pop.

---

## 4. Elevation & Depth
We eschew the 2014-era drop shadow in favor of **Tonal Layering.**

*   **The Layering Principle:** A card does not need a shadow to be "up"; it simply needs to be a lighter tone (`surface-container-lowest`) than the plane it sits on (`surface-container`).
*   **Ambient Shadows:** If a "Loss" report card needs to float, use a shadow with a 32px blur, 0px offset, and 6% opacity using the `on_surface` color. It should feel like a soft glow, not a dark smudge.
*   **The Ghost Border:** For accessibility in forms, use `outline-variant` (#c3c6d7) at **15% opacity**. This provides a guide for the eye without creating a "box" that traps the content.

---

## 5. Signature Components

### Verified & Reward Badges
- **Verified Badge:** A `surface-container-highest` pill with a small `primary` checkmark. Never use a heavy fill; the "Verified" status should feel like a subtle seal of quality.
- **Reward Tag:** Utilize `secondary_container` (#fea619) with `on_secondary_container` (#684000) text. The gold should feel "celebratory" but grounded.

### Status Labels (The Signal System)
- **'Lost' Label:** Use `tertiary_container` (#a65900) with `on_tertiary_fixed` (#2f1500). This "Alert Orange" is urgent but soft.
- **'Found' Label:** Use a custom "Success" green (derived from the `primary` family's complementary tones) but apply it as a **Glassmorphism** chip: Semi-transparent green background with a 1px "Ghost Border."

### Buttons & Inputs
- **Buttons:** Use the `xl` (1.5rem) roundedness scale. A primary button is not a rectangle; it’s a friendly, pill-like "object."
- **Input Fields:** Forbid the bottom-line-only style. Use `surface-container-low` as the field fill with no border. On focus, transition the background to `surface-container-highest`.
- **Lists:** No horizontal dividers. Use `1.5rem` (spacing-6) of vertical whitespace to separate items.

---

## 6. Do’s and Don’ts

### Do:
- **Do** overlap images. A "Lost Dog" photo should slightly break the container of the text box below it to feel tactile and "placed."
- **Do** use `2.5rem` (spacing-10) for external margins. Let the layout breathe.
- **Do** use `surface_bright` for items that are newly posted to give them a "fresh" shimmer.

### Don't:
- **Don't** use pure black (#000000) for text. Use `on_surface` (#0d1c2e) for a softer, more premium contrast.
- **Don't** use standard "Material Design" shadows. If you can see the shadow clearly, it’s too heavy.
- **Don't** use icons without labels for critical actions. Trust is built through clarity.
- **Don't** use 1px dividers. If you feel the need to separate two things, increase the spacing from `4` to `8`.