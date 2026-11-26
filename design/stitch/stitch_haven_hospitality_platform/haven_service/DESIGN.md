---
name: Haven Service
colors:
  surface: '#f5faff'
  surface-dim: '#cbdce9'
  surface-bright: '#f5faff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#e9f5ff'
  surface-container: '#dff0fd'
  surface-container-high: '#daeaf7'
  surface-container-highest: '#d4e5f2'
  on-surface: '#0d1d27'
  on-surface-variant: '#3e4948'
  inverse-surface: '#23323c'
  inverse-on-surface: '#e3f3ff'
  outline: '#6e7979'
  outline-variant: '#bdc9c8'
  surface-tint: '#006a69'
  primary: '#006161'
  on-primary: '#ffffff'
  primary-container: '#0e7c7b'
  on-primary-container: '#c3fffd'
  inverse-primary: '#7cd5d3'
  secondary: '#565f70'
  on-secondary: '#ffffff'
  secondary-container: '#d7e0f4'
  on-secondary-container: '#5a6374'
  tertiary: '#854524'
  on-tertiary: '#ffffff'
  tertiary-container: '#a35d39'
  on-tertiary-container: '#fff1eb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#98f2f0'
  primary-fixed-dim: '#7cd5d3'
  on-primary-fixed: '#002020'
  on-primary-fixed-variant: '#00504f'
  secondary-fixed: '#dae3f7'
  secondary-fixed-dim: '#bec7db'
  on-secondary-fixed: '#131c2a'
  on-secondary-fixed-variant: '#3e4758'
  tertiary-fixed: '#ffdbcc'
  tertiary-fixed-dim: '#ffb693'
  on-tertiary-fixed: '#351000'
  on-tertiary-fixed-variant: '#713615'
  background: '#f5faff'
  on-background: '#0d1d27'
  surface-variant: '#d4e5f2'
  bg-mist: '#F3F6F8'
  surface-white: '#FFFFFF'
  status-pending: '#E8A838'
  status-progress: '#2B6CB0'
  status-completed: '#2F855A'
  border-subtle: '#D7E0E6'
  text-muted: '#5B6B76'
  error-subtle: '#C53030'
typography:
  display-hero:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-hero-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.015em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.5rem
  gutter-mobile: 1rem
  margin: 2rem
  margin-mobile: 1.25rem
  space-2xs: 0.25rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-2xl: 3rem
---

## Brand & Style

The design system embodies a serene, high-trust hospitality operations environment characterized by calm precision, quiet confidence, and tactile restraint. Built to serve two distinct touchpoints—tired hotel guests seeking immediate, low-friction room assistance and hotel operations teams managing live service queues—the visual tone replaces loud software paradigms with an architectural, quiet luxury demeanor.

The visual style is rooted in a refined **Warm Minimalist & Structural Modernism**. It deliberately avoids decorative SaaS excesses: no gratuitous gradient glows, no synthetic purples, no drop-shadow drama, and no skeuomorphic newspaper or resort textures. Instead, the interface relies on expansive breathing room, an unyielding typographic hierarchy, crisp single-pixel structural dividers, and purposeful surface layering using a soft atmospheric mist base. The emotional response is immediate relief, absolute legibility in low-light guestrooms, and rapid operational clarity on desktop consoles.

## Colors

The palette is anchored by a deep sea teal primary, paired with an authoritative deep navy for prominent typography and structural anchors. The foundational canvas is never harsh pure white; screens rest upon `#F3F6F8` (Mist), with `#FFFFFF` reserved exclusively for elevated surfaces, selectable tiles, modal sheets, and interactive input fields.

### Functional Chromatic Rules
- **Teal (`#0E7C7B`):** Reserved exclusively for interactive commitments—primary buttons, active tab indicators, key interactive triggers, and focused states.
- **Navy (`#1A2332`):** Delivers resolute contrast across all primary titles, headlines, and data values.
- **Semantic Status Spectrum:** Status colors are used in strict isolation for state signaling and never as decorative accents.
  - **Pending (`#E8A838`):** Indicates unhandled guest intake.
  - **In Progress (`#2B6CB0`):** Indicates operational assignment and active workflow.
  - **Completed (`#2F855A`):** Indicates resolved requests and operational success.
- **Border Subtle (`#D7E0E6`):** Provides razor-sharp perimeter framing and table row demarcation without relying on heavy box shadows.

## Typography

The typographic hierarchy combines geometric structure with neutral legibility. **Plus Jakarta Sans** provides a warm, architectural headline rhythm across displays and section headers. **Inter** handles data tables, inputs, metadata lines, and multi-line instructions, maintaining legibility across arm's-length mobile viewports and multi-column desktop dispatch grids.

Strict typographic constraints:
- One dominant visual anchor per screen view. Subtitles are kept concise, rendered in `text-muted` (`#5B6B76`).
- Headlines maintain a tightened negative tracking (`-0.01em` to `-0.02em`) to avoid airy sprawl, ensuring room numbers and request categories present with unified structural weight.
- Table headers and status tags employ uppercase tracking via `label-sm` to maintain clarity even at miniature scales.

## Layout & Spacing

The layout model adapts between a structured fluid grid on desktop operations monitors and an open single-column layout on handheld mobile screens.

### Desktop Web Layout (1440×900)
- **Canvas Structure:** A persistent 240px lateral navigation rail pinned to the viewport left edge, flanked by an edge-to-edge work surface constrained to a maximum content width of 1200px or full-bleed dynamic table widths.
- **Grid:** 12-column responsive fluid grid utilizing 24px (`1.5rem`) gutters and 32px (`2rem`) outer margin offsets.
- **Rhythm:** Dense, scannable data layouts using `space-sm` (12px) vertical table row paddings and `space-xl` (32px) section segmentations to eliminate arbitrary visual clutter.

### Mobile Guest App (Android 390×844)
- **Canvas Structure:** Single-column stacked arrangement with 20px (`1.25rem`) fixed margins.
- **Vertical Spacing:** Generous breathing room above primary action zones. The first viewport enforces a strict "one core intent" rule (e.g., service selection or explicit request confirmation).
- **Touch Ergonomics:** Interactive targets mandate a minimum physical height of 48px, with list elements and grid tiles spaced via `space-md` (16px) margins to prevent mis-taps.

## Elevation & Depth

Visual hierarchy is constructed through **tonal surface separation and architectural borders** rather than drop shadows. Multi-layered drop shadows, glowing neons, and heavy blurry elevations are strictly prohibited.

- **Level 0 (Canvas):** Mist `#F3F6F8`. Full-bleed backdrop for guest handheld screens and web console containers.
- **Level 1 (Interactive Flat Surface):** Pure White `#FFFFFF` bound by a 1px solid stroke of `#D7E0E6`. Used for table rows, guest service cards, and input text containers. Zero box shadow.
- **Level 2 (Floating Overlays & Sheets):** Pure White `#FFFFFF` with a 1px outline of `#D7E0E6` supplemented by an ultra-subtle ambient diffusion: `0 4px 16px -2px rgba(26, 35, 50, 0.04)`. Used exclusively for guest bottom sheets and staff slide-over detail drawers.
- **Focus & Selection Depth:** Visual elevation is conveyed through border state transitions: transitioning from `#D7E0E6` to the primary brand teal `#0E7C7B` (accompanied by an optional 2px subtle outline ring `rgba(14, 124, 123, 0.15)`).

## Shapes

The geometric identity balances hospitality softness with industrial operational order. Curvatures avoid bubble-like expressions while rejecting sharp brutalist corners.

- **Inputs, Buttons, and Base Cards:** Standard `rounded` (8px / `0.5rem`) to ensure balanced visual ergonomics.
- **Status Indicators & Quiet Chips:** Full pill radius (`9999px`) applied to status pills to distinguish state badges from selectable rectilinear tiles.
- **Guest Service Grid Tiles:** Elevated card containers use `rounded-lg` (12px / `0.75rem`) with internal paddings of 16px to 20px, presenting approachable tap targets.
- **Dividers & Strokes:** Linear borders consistently maintain a precise 1px stroke weight using `#D7E0E6`.

## Components

### Buttons
- **Primary:** Solid `#0E7C7B` fill with `#FFFFFF` text (`label-lg`). Border radius 8px. Height 48px on mobile, 40px on desktop web. Hover: `#0B6564`. Active: `#084F4E`. No box-shadows.
- **Secondary / Ghost:** Transparent background with 1px border `#D7E0E6` and `#1A2332` label. Hover brings background to `#FFFFFF` with border darkened to `#5B6B76`.
- **Destructive / Reset:** Transparent background with quiet text tone `#C53030`. Never loud filled red blocks unless confirming destructive room wipeouts.

### Input Fields & Controls
- **Text Inputs & Steppers:** `#FFFFFF` background, 1px `#D7E0E6` perimeter border, 8px radius. Text set in `body-md` (`#1A2332`), placeholder in `#5B6B76`. 
- **Focus State:** 1px `#0E7C7B` border accompanied by an ambient 2px outer ring of `rgba(14, 124, 123, 0.12)`.
- **Inline Error:** 1px `#C53030` border with an immediate sub-field label in `label-sm` `#C53030`.

### Status Indicators & Pills
- Status indicators are quiet and muted, avoiding high-saturation badges:
  - **Pending:** `#E8A838` text set on `rgba(232, 168, 56, 0.12)` pill background.
  - **In Progress:** `#2B6CB0` text set on `rgba(43, 108, 176, 0.10)` pill background.
  - **Completed:** `#2F855A` text set on `rgba(47, 133, 90, 0.10)` pill background.
- Typography: `label-sm` (11px, 600 weight, uppercase tracking). Padding: 3px vertical, 8px horizontal.

### Service Tiles (Mobile Guest)
- `#FFFFFF` surface, 1px solid `#D7E0E6` border, 12px border radius.
- Standard 2-column or list layout containing a 24px line icon colored in `#0E7C7B`, service title in `#1A2332` (`headline-sm`), and a subtle `qty` pill where applicable.

### Data Tables (Staff Console)
- Header row rests on canvas background `#F3F6F8` with uppercase `label-sm` labels in `#5B6B76`.
- Body rows use `#FFFFFF` backgrounds separated by a single-pixel horizontal stroke `#D7E0E6`. Hover state shifts row tone to `#F8FAFB`.
- Newest requests sort to the top, featuring bold room labels in `headline-sm` `#1A2332` for fast visual scanning.