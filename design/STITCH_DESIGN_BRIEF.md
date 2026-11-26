# Haven Service — Google Stitch Design Brief

Paste sections into Stitch as separate prompts (Mobile Guest App, Staff Web, Admin Web). Keep brand tokens identical across all screens.

---

## Product context

**Product name:** Haven Service  
**Tagline:** Quiet requests. Fast response.  
**What it is:** A hotel guest service request system.

- **Guests (Android phone):** request towels, cleaning, maintenance, room service, etc. using room number + check-in code.
- **Staff (web):** see live requests newest-first, assign department/person, move status Pending → In Progress → Completed.
- **Admin (web):** manage service menu, rooms, check-in codes/stays, staff accounts.

**Not in scope:** push notifications, guest balances, iPhone, PMS integration, payments.

**Tone:** calm hospitality, modern ops tool, trustworthy, uncluttered. Not flashy travel-booking. Not dark-mode cyber. Not purple SaaS.

---

## Brand system (use exactly)

### Logo
- **Wordmark:** “Haven” bold + “Service” lighter.
- **Mark:** geometric H combining a keyhole + soft bed-line.
- **Files:** `assets/brand/haven-service-logo-mark.jpg`, `assets/brand/haven-service-wordmark.jpg`
- Place mark in app bar / splash; wordmark on auth and web header.
- Do not redraw logo with gradients, shadows, or 3D.

### Color tokens
| Token | Hex | Use |
|---|---|---|
| Teal | `#0E7C7B` | Primary CTAs, active nav, links |
| Navy | `#1A2332` | Headings, primary text |
| Mist | `#F3F6F8` | Page / screen background |
| White | `#FFFFFF` | Cards / sheets only when needed for interaction |
| Amber | `#E8A838` | Pending status only |
| Blue | `#2B6CB0` | In Progress status only |
| Green | `#2F855A` | Completed status only |
| Border | `#D7E0E6` | Dividers, input outlines |
| Muted | `#5B6B76` | Secondary text |

Avoid purple, neon glow, heavy multi-shadows, terracotta + cream newspaper looks.

### Typography
- **Display / brand:** modern geometric sans (e.g. Plus Jakarta Sans or Satoshi).
- **UI body:** clean sans (e.g. Inter is acceptable for Stitch; final Flutter can map fonts).
- Hierarchy: one strong title per screen, short supporting line, then content.
- Guest phone: large tap targets, readable at arm’s length.
- Staff web: denser but airy tables, not dashboard-widget clutter.

### Layout rules
- First viewport = one job (brand + one action). No stats strip on auth.
- Prefer open layout over card grids; cards only for tappable request rows / service tiles.
- Status as quiet colored text or small pill, not loud badges everywhere.
- Motion later: soft fade/slide only — Stitch should focus on static modern UI.

---

## A) Mobile Guest App (Android, portrait 390×844)

Design these screens as one coherent mobile system.

### A1. Privacy notice
- Full-bleed soft mist background.
- Haven mark + wordmark hero-level (brand first).
- Short privacy copy (room, code, request notes only; used during stay).
- Single primary CTA: Continue.
- No secondary marketing blocks.

### A2. Guest sign-in
- Brand header (mark + “Haven Service” + “Guest room sign-in”).
- Fields: Room number, Check-in code (password-style).
- Primary: Sign In.
- Text link: Privacy notice.
- Error state under fields (inline, calm red).
- Empty + filled + error variants.

### A3. Service menu (home)
- Bottom nav: Services · My Requests · History.
- Title: “What do you need?”
- Grid/list of services (icons + labels):
  Do Not Disturb, Room cleaning, Towels, Toiletries, Maintenance, Room service, Laundry, Wake-up call, Other.
- Quantity-capable services feel slightly different (subtle badge “qty”).
- Tap service → new request.

### A4. New request
- Service name as title.
- Optional quantity stepper (only if service allows quantity).
- Notes multiline.
- Primary: Submit request.
- Success → navigate to My Requests.

### A5. My Requests (active)
- Newest first.
- Each row: service name, status chip (Pending / In Progress / Completed), time, optional quantity.
- Empty state: “No active requests yet.”
- Tap → detail.

### A6. Request detail + timeline
- Header status + service.
- Timeline events: created, assigned, status changes with actor + time.
- Read-only for guest.

### A7. History
- Completed / past requests list, same row language as My Requests.
- Tap → detail.

**Guest UX goals:** 3 taps max to submit a request. Large controls. Hotel-room lighting friendly (not pure black text on pure white only — use Mist background).

---

## B) Staff Web (desktop 1440×900)

Modern ops console, light theme.

### B1. Staff sign-in
- Split or centered composition with brand left/top.
- Email + password.
- Sign In.
- No guest entry on web.

### B2. Requests inbox (default home)
- Left or top nav: Requests | (Admin section if admin).
- Header: Haven Service + staff name + Sign out.
- Filters: All / Pending / In Progress / Completed + optional department.
- Table or dense list, **newest first**:
  Time · Room · Service · Qty · Status · Assigned dept/person · Notes snippet.
- Click row → detail panel or page.

### B3. Request detail (staff)
- Room + service + notes + status.
- Actions: set status (Pending→In Progress→Completed only valid transitions).
- Assign department dropdown + assign staff person.
- Audit timeline (same events guests see, plus assignment notes).
- Save/update clear primary action.

**Staff UX goals:** scan room numbers fast, update status in one glance, no decorative charts.

---

## C) Admin Web (same shell as staff)

Accessible only to admin role. Keep visual language identical; add Admin nav group.

### C1. Services
- List service types: name, quantity allowed, default department, sort order, hidden toggle.
- Add / edit service.

### C2. Rooms
- Room number list, active/inactive.
- Add room.

### C3. Stays / check-in codes
- Active stays by room.
- New stay: choose room + check-in code field with **Generate** button.
- Reset code (Generate available).
- End stay.
- After create/reset, show code clearly once (copy affordance).

### C4. Staff accounts
- List staff/admin users, department, role.
- Create staff: email, password, full name, role, department.

---

## Stitch prompt packs (copy/paste)

### Prompt 1 — Brand shell
```
Design a modern hospitality-tech UI system for “Haven Service”.
Brand: deep teal #0E7C7B, navy #1A2332, mist background #F3F6F8, amber/blue/green only for request statuses.
Logo: geometric teal H / keyhole mark + “Haven Service” wordmark.
Style: calm, premium, uncluttered, light mode, no purple, no neon glow, no heavy shadows, no dashboard stat cards on auth screens.
Typography: geometric sans, strong hierarchy, generous spacing.
```

### Prompt 2 — Guest mobile set
```
Design Android guest app screens for Haven Service (portrait):
1) Privacy notice with brand hero + Continue
2) Guest sign-in (room number + check-in code)
3) Service menu grid with bottom nav (Services, My Requests, History)
4) New request form (quantity + notes)
5) My Requests list with status chips
6) Request detail timeline
7) History list
Large tap targets, mist backgrounds, teal primary buttons, newest-first lists.
```

### Prompt 3 — Staff + admin web set
```
Design desktop web app for hotel staff/admin (1440px):
1) Staff email/password sign-in
2) Live requests inbox table newest-first with filters and status chips
3) Request detail with assign department/staff + status transitions + audit timeline
4) Admin: services CRUD, rooms CRUD, stays/check-in codes with Generate code button, staff accounts
Same Haven Service brand tokens as the mobile app. Light, modern ops UI, not a marketing site.
```

---

## Deliverables to bring back into Cursor

Please export from Stitch and share:
1. Guest mobile screens (PNG or Figma/Stitch export)
2. Staff web screens
3. Admin web screens
4. Any component notes (buttons, inputs, status chips, nav)
5. Confirm if you keep the provided Haven Service logo or a Stitch-redrawn version

When feeding designs back here, say which screens to implement first (guest, staff, or both).
