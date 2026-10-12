# Anise App Design System

This is the central design system for **Anise App** (School Management System).
When generating screens, refer strictly to this design system to maintain visual consistency.

## 1. Vibe & Aesthetics
- **Theme:** Clean, modern, minimalist, and educational.
- **Vibe:** Sleek glassmorphism, vibrant yet soft pastel colors. 
- **Performance:** Avoid heavy blurred backdrops. Prefer solid smooth linear gradients.

## 2. Color Palette
The app relies heavily on a soft, pastel-driven color scheme for quick-action menus to ensure easy scannability and eye-pleasing aesthetics.

- **Primary Brand:** Soft, vibrant blue/indigo (`#4A62FF`)
- **Backgrounds:** Off-white or very light grey for high readability (`#FAFAFA`)
- **Surface/Containers:** Pure white (`#FFFFFF`) with extremely subtle dropshadows.
- **On-Surface (Text):** Dark grey/black for high contrast (`#1E1E1E`)

### Pastel Accent Colors (For Grid Icons & Tags)
- **Mint/Green:** Success, Attendance, KPI (`#E8F5E9` / `#4CAF50`)
- **Blue:** Schedule, Mentoring, Info (`#E3F2FD` / `#2196F3`)
- **Purple:** Tasks, Assignments, Mail (`#F3E5F5` / `#9C27B0`)
- **Lilac/Pink:** Habits (Pembiasaan) (`#FCE4EC` / `#E91E63`)
- **Red:** Disciplinary, Reports (`#FFEBEE` / `#F44336`)
- **Greyish/Neutral:** Agendas, Files (`#ECEFF1` / `#607D8B`)

## 3. Typography
- **Primary Font:** Google Fonts `Google Sans` or `Inter`.
- **Headings (H1/H2):** Bold, heavy weight, dark color.
- **Body Text:** Regular weight, slightly muted dark color (`#424242`).
- **Labels (Icons/Tags):** Small, semi-bold.

## 4. Layouts & Structure
- **SliverAppBar:** All main screens must use a scrollable `CustomScrollView` with a `SliverAppBar` that pins to the top.
- **Header:** The top header often includes a 3D Identity Card, user greeting, and real-time clock.
- **Spacing:** Generous padding (`24px` horizontal edges), `16px` between grid items.
- **No Back Buttons:** Main dashboard tab screens must NOT have an escape or back button.

## 5. Components
### Cards
- Smooth rounded corners (`border-radius: 20px`).
- Subtle shadow: `rgba(0,0,0, 0.05)` with `blur: 10px`, `y: 4`.

### Icon Containers
- Soft pastel background (20% opacity of the accent color).
- The icon itself uses the full 100% accent color.
- `width` and `height`: `56px`.

## 6. Interaction & Micro-animations
- Hover and tap effects should be visible (e.g., scale down slightly on tap).
- Use `Hero` animations for page transitions where applicable.
