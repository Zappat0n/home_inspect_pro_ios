# App Store Screenshots

## Requirements
- **6 screenshots** at iPhone 6.7" (1290×2796 px)
- English (`en-US`) and Spanish (`es-ES`) localizations

## Screenshots Needed

1. **Dashboard / Inspection List** — Show inspections with status badges
2. **Interactive Checklist** — Checklist items grouped by category with OK/Defect/N/A buttons  
3. **Photo Capture** — Camera interface or photo attachment view
4. **Digital Signature** — Signature pad with PencilKit canvas
5. **PDF Report Preview** — Generated report
6. **Offline Mode** — Offline banner/indicator

## How to Capture

### Option A: iOS Simulator (Recommended)

1. Build the app in Xcode and run on iPhone 14 Pro Max (6.7") simulator
2. Fastlane `screengrab` can automate this:
   ```
   bundle exec fastlane screenshots
   ```
3. UI test target must include `Screengrab` setup

### Option B: Manual with Simulator

1. Open iOS simulator (Device → iPhone 14 Pro Max)
2. Run the app: `Product → Run`
3. Navigate to each screen
4. Save screenshots: `File → Save Screen Shot` (or `Cmd+S`)
5. Name files:
   - `en-US/1_Dashboard.png`
   - `en-US/2_Checklist.png`
   - `en-US/3_PhotoCapture.png`
   - `en-US/4_Signature.png`
   - `en-US/5_PDFPreview.png`
   - `en-US/6_OfflineMode.png`
6. Repeat for Spanish (`es-ES/`)

### Option C: Browser (Fallback)

For placeholder screenshots only — capture the web app at ~390×844 viewport:
1. Open Chrome DevTools → Toggle Device Toolbar
2. Select iPhone 14 Pro Max (430×932)
3. Navigate to `http://localhost:3000`
4. Sign in with `inspector.us@example.com` / `password`
5. Capture each screen (Cmd+Shift+S)
