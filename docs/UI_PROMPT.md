# AILaga: mixed-user design (Elder + Helper)

## Part 0: Who does what

The app has **one phone and two modes**. The elder uses **Elder mode** every day. The helper (son, daughter, live-in aide) uses **Helper mode** for anything hard, risky, or administrative. Anything the AI is unsure about goes to the helper.

| Task | Elder | Helper | Why |
|---|---|---|---|
| See the next pill | ✅ | ✅ | Core daily need |
| Tap "I took it" | ✅ | ✅ (logs for her) | Simple, one tap |
| Speak a log ("I took my pill, BP 130/85") | ✅ | ✅ | Voice avoids typing |
| Confirm **Sure** cards | ✅ | ✅ | Low risk, one tap |
| Confirm **Check** or error cards | ❌ sent to helper | ✅ | Risk of a wrong record |
| Fix or edit values | ❌ | ✅ | Needs steppers and care |
| Press SOS | ✅ | ✅ | Must be instant |
| Call family | ✅ | ✅ | One tap |
| Ask "Did I take my pills?" | ✅ (4 fixed buttons) | ✅ (full Ask) | Elder gets simple answers |
| Add or edit a medicine | ❌ | ✅ | Wrong dose is dangerous |
| Scan a pill bottle or reseta | ❌ | ✅ | Needs camera framing |
| Scan the BP monitor | ✅ (optional) | ✅ | Easier than typing digits |
| Reports, Week, Brief | ❌ | ✅ | Dense information |
| Handover to sibling, doctor, helper | ❌ | ✅ | Audience choices |
| Set up the on-device helper (download) | ❌ | ✅ | One-time setup |
| Privacy panel, delete model | ❌ | ✅ | Admin |
| SOS contacts, language, PIN | ❌ | ✅ | Admin |

**Rule:** Elder mode never shows more than 3 things at once. Helper mode may be denser, but still large and clear.

**Switching modes:**
- Elder → Helper: tap a small lock labeled "Helper", then enter a 4-digit PIN.
- Helper → Elder: one tap on "Done" at the top of Helper mode.
- Every record shows who made it: "By Lola" or "By Ana".

---

## Part 1: Master prompt (paste first)

```
Design a mobile app (Android, 390x844 portrait) called "AILaga". It supports
an older adult ("Lola") who takes daily medicine and checks her blood pressure,
and a helper (her son, daughter or aide) who looks after her. An AI that runs
only on the phone turns spoken words into records. Everything works with no
internet. Nothing is saved until a person taps Confirm.

THE APP HAS TWO MODES ON ONE PHONE:

ELDER MODE (default, used by Lola, 65-85, weak eyesight, shaky hands, low
tech confidence):
- Very few things on screen, never more than 3 competing items.
- Body 24sp, titles 32sp bold, buttons 26sp bold. Buttons 88dp tall.
- Bottom nav with 3 items only: My Day, Speak (big round teal, raised), Call.
- Speak as "I/my": "I took it", "My pills".
- Warm white background, teal accent.

HELPER MODE (used by the family helper, more capable but often tired and busy):
- Same visual language, a bit denser. Body 20sp, titles 28sp bold, buttons 22sp
  bold, buttons 64dp tall.
- Bottom nav with 5 items: Today, Reports, Speak (big round, raised), Ask, More.
- A clear indigo band at the top reading "Helper mode" with a "Done" button on
  the right, so nobody confuses the modes.

SHARED RULES FOR ALL SCREENS:
- English only. Titles 1-2 words, buttons 1-2 words, no sentence over 5 words.
  Every action has a big icon AND a word. Never an icon alone.
- No jargon. Never use "AI", "model", "proposal", "sync", "tier". Say
  "helper" for the AI where needed ("Phone helper").
- Contrast at least 7:1. Never use color alone: color + icon + word.
- Font: Atkinson Hyperlegible. No thin weights, no italics.
- Colors: background #FFFDF8, text #1A1A1A, card #F3EFE6, border #D9D2C3,
  primary teal #0B6B6B, helper indigo #2F4B8A, SOS red #C62828,
  "Sure" green #1B7F3B, "Check" amber #9A5B00, error #B3261E.
- Corner radius 24dp. Cards have a 2dp border and no soft shadows.
- Outlined icons with 3dp strokes.
- App bar on every main screen: left = "On phone" shield badge (plus a plane
  icon when offline); right = round red SOS button (64dp).
- Each record shows a small tag "By Lola" or "By Ana".
- Illustrations only on setup and empty screens (flat, warm, friendly).

Create a consistent design system for both modes first, then wait for screen
prompts.
```

---

## Part 2: Screen prompts (one at a time)

### Shared

**S1. Who is using? (first launch)**
```
Screen "Who is using?". Two huge cards stacked, each 160dp tall, icon + word:
a smiling elder icon "Lola" and a helper icon with a heart "Helper". Under them
one small line: "Pick who uses now". Tapping "Helper" starts setup.
```

**S2. Helper PIN gate**
```
Screen "Helper". Lock icon on top. Title "Enter PIN". Four large dots and a
big number pad (key 88dp, 36sp digits). Text button "Back". Error state: dots
shake and the line "Try again" appears with a warning icon.
```

---

### Elder mode

**E1. My Day (home)**
```
Screen "My Day", Elder mode. App bar: "On phone" badge left, red SOS right.
Title "My Day" and today's date in 24sp. ONE hero card: next medicine,
for example "Losartan", "1 tablet", "8:00 AM", with a huge 88dp teal button
"I took it" with a check icon. Below, a short list of the rest of today:
3 rows with a status icon (check = done, clock = later), name and time.
A single tile row: "BP 128/82" with a heart icon. A small lock button at the
very bottom right labeled "Helper".
Bottom nav, 3 items: My Day (active), Speak, Call.
```

**E2. Pill reminder (full screen)**
```
Screen "Time for pills", full screen. Giant pill icon. Medicine name in 40sp
bold, "1 tablet", and the time. Two stacked buttons: teal "I took it" (88dp,
check icon) and outlined "Later" (clock icon). Small text link "Skip".
After 10 minutes, a second state shows "Tell helper" with a phone icon.
```

**E3a. Speak, ready**
```
Screen "Speak". Huge teal circle microphone (220dp) in the center. One line
"Tap and talk". Small button with a keyboard icon "Type". Bottom hint with a
lightbulb: "Say pills or BP".
```

**E3b. Speak, listening**
```
Same screen while listening. The circle pulses with a thick countdown ring
(30 seconds). Big timer "0:12". Soft sound-wave. One line "Listening". A large
outlined "Stop" button with a square icon.
```

**E3c. Speak, thinking**
```
Spinning teal ring with a small sparkle. Title "One moment". The heard
sentence appears in a rounded card, 24sp, for example:
"I took my Losartan, BP 130 over 85".
```

**E4. Is this right? (all cards Sure)**
```
Screen "Is this right?", Elder mode. Top: ear icon card with the heard
sentence. Two big cards: pill icon "Losartan 50 mg, taken 8:00 AM" with a green
"Sure" badge (check icon); heart icon "BP 130/85" with a green "Sure" badge.
Each card has one 72dp button "Remove" (X icon). Sticky bottom: 88dp teal
button "Yes, save" with a check icon.
```

**E5. Needs helper (some cards Check or error)**
```
Same screen, but one card shows an amber "Check" badge with an eye icon, and
one card is outlined in red with a warning icon and "Number too high".
The big save button is replaced by a white button "Send to helper" with a
person and arrow icon, and a smaller teal button "Save the rest". Under it
one line: "Helper will check".
```

**E6. Saved**
```
Screen with a large green check icon in a circle. Title "Saved". One line
"Thank you, Lola". Auto-return button "OK" (88dp).
```

**E7. Call (replaces Help)**
```
Screen "Call". Three stacked 96dp buttons, each with a big photo-style circle
placeholder, name, and phone icon: "Ana (daughter)", "Ben (son)", "Doctor".
Below them a small outlined button "My pills?" with a pill icon that shows a
big answer card: "Yes. 2 of 2 today" with a check icon.
```

**E8. SOS (shared)**
```
Full-screen red #C62828. Giant white phone icon. A 140dp "Call family" button
with a 3-second hold ring. A second button "Call 911". Lola's name and
address in 28sp white. Small white outlined "Cancel". Looks the same online
and offline. No AI.
```

---

### Helper mode

**H1. Helper Today (home)**
```
Screen "Today", Helper mode. Indigo band "Helper mode" with a "Done" button.
App bar: "On phone" badge, red SOS. Top amber strip with a tray icon: "3 to
check" and a chevron. Below, a timeline of today's medicines grouped by Morning,
Noon, Night. Each card: status icon, name, dose, time, and a small tag
"By Lola" or "By Ana". Two quick tiles: "BP 128/82", "Sugar 105".
Bottom nav, 5 items: Today (active), Reports, Speak, Ask, More.
```

**H2. Check queue**
```
Screen "To check". List of cards the elder sent. Each row: a person icon with
"From Lola", the heard sentence, and the issue ("Check" amber badge, or "Number
too high" red). Tap to open. Empty state: a green check icon and "All clear".
```

**H3. Check cards (helper review)**
```
Screen "Check", Helper mode. Top: ear icon card with the heard sentence.
Below, stacked cards for each record, each with a badge (Sure green or Check
amber), a one-line quote of the words heard, and two buttons: pencil "Edit"
and X "Remove". One red error card with "Number too high", Confirm disabled
until edited. Sticky bottom: 72dp teal button "Confirm all" with a check icon
and the text "3 cards" above it.
```

**H4. Edit**
```
Screen "Edit". Two huge number boxes "Top" and "Bottom" with 48sp digits and
minus/plus buttons (72dp). A time row with a clock icon and a big "8:05 AM"
button. Teal "Save", outlined "Back".
```

**H5. Speak for Lola (helper logs)**
```
Screen "Speak", Helper mode. A selector chip at the top: "For Lola" (selected,
indigo fill with a check icon) or "Note". Huge teal circle mic. One line
"Tap and talk". The same listening and thinking states as the elder mode.
After speaking, the Check screen appears with the tag "By Ana".
```

**H6. Medicines**
```
Screen "Medicines". List of Lola's medicines, each card: pill icon, name,
dose, times per day ("8 AM, 8 PM"), and a toggle "On". Floating big button at
the bottom: "Add" with a plus icon. Empty state: a pill illustration and
"Nothing yet" with a "Scan bottle" button.
```

**H7. Snap**
```
Screen "Snap". Camera view with a rounded guide frame. Two tabs at the top:
"Label" (bottle icon) and "Monitor" (BP cuff icon). Big white shutter button.
Gallery button bottom left. One line over the frame: "Fit it in the box".
Result state: card with pill name and strength; unreadable fields are blank
with an amber "Check" badge. Buttons "Save" and "Retake".
```

**H8. Reports**
```
Screen "Reports". Three big tabs: "Week", "Brief", "Handover".
Week tab: simple bar chart of pills taken per day with icons for check and
miss, plus three numbers: "Pills 12 of 14", "BP 128/82", "Missed 2".
```

**H9. Handover**
```
Screen "Handover". Choice chips (56dp, icon + word): Who: "Sibling", "Helper",
"Doctor". Language: "English", "Filipino". Length: "Short", "Full". Below, a
readable card (22sp, line spacing 1.5) with 4 short sentences about Lola's
week. Some phrases are underlined in teal and tappable. A small grey chip with
a trash icon: "2 removed". Footer buttons: "Share" (teal) and "Print"
(outlined).
```

**H10. Ask**
```
Screen "Ask". Four large suggestion chips: "Did Lola take pills?", "Last BP?",
"Missed this week?", "New notes?". Answered example: a card "Yes. 2 of 2 today"
with source chips ("Tue 8 AM", "Wed 8 AM"). Refusal example: an amber card with
a stethoscope icon and "Ask the doctor". Bottom: a rounded input with a mic and
a send button.
```

**H11. More**
```
Screen "More", a list of big rows with icons: "Phone helper" (sparkle),
"On my phone" (shield), "SOS contacts" (phone), "Language" (globe),
"PIN" (lock), "Appointments" (calendar), "Notes" (pencil).
```

**H12. Phone helper setup**
```
Screen "Phone helper". Friendly flat illustration of a smiling phone with a
shield and a heart. Title "Phone helper". Three icon rows: lock "Stays on
this phone", plane "Works offline", mic "Hears Lola". Teal button "Get it",
text "Skip". Progress state: thick bar and big "62%" with "Pause". Done state:
large green check and "Ready".
```

**H13. On my phone (privacy proof)**
```
Screen "On my phone". Large shield icon. Rows: plane + "Offline", green check +
"Nothing sent". Two tiles "Sent 0 KB", "Received 0 KB". Rows: "Helper: Ready",
"Size: 2.1 GB", and "Delete" in red with a trash icon.
```

**H14. Helper off (basic mode)**
```
Today screen with a soft yellow banner: info icon, "Helper is off. Typing
works.", and a small button "Turn on". The Speak button shows a keyboard icon.
```

**H15. Mic permission**
```
Screen "Mic". Flat illustration of a microphone with a soft glow. One line
"Allow the mic?" Subline "To hear you." Buttons: teal "Allow" and text
"Not now".
```

---

## Part 3: Design guide

### 1. Mode comparison

| Item | Elder mode | Helper mode |
|---|---|---|
| Body text | 24sp | 20sp |
| Titles | 32sp bold | 28sp bold |
| Buttons | 26sp bold, 88dp tall | 22sp bold, 64dp tall |
| Nav | 3 items | 5 items |
| Max items on screen | 3 | About 6 |
| Accent | Teal | Teal and indigo band |
| Top bar | "On phone" badge, SOS | Indigo "Helper mode" band, badge, SOS |
| Tone | "I took it" | "Confirm all" |
| Icon size | 40dp | 32dp |

### 2. Color tokens

| Token | Hex | Use |
|---|---|---|
| Background | #FFFDF8 | Screens |
| Card | #F3EFE6 | Cards |
| Border | #D9D2C3 | Card outlines |
| Text | #1A1A1A | Body |
| Primary teal | #0B6B6B | Main buttons, active nav |
| Helper indigo | #2F4B8A | Helper mode band only |
| Sure | #1B7F3B | Confident cards (with check icon) |
| Check | #9A5B00 | Needs review (with eye icon) |
| Error | #B3261E | Out-of-range values |
| SOS | #C62828 | SOS only |

### 3. Handoff rules (elder → helper)

1. Only **Sure** cards can be saved by the elder.
2. **Check** and **error** cards go to the helper queue with "Send to helper".
3. The helper sees a counter on Today ("3 to check").
4. Each saved record keeps a tag: "By Lola" or "By Ana".
5. The elder never sees the edit forms, reports, medicine settings, or the privacy panel.
6. If the helper does not respond, the elder still keeps the saved Sure cards. Nothing is lost.

### 4. Microcopy

| Place | Elder text | Helper text |
|---|---|---|
| Main action | I took it | Confirm all |
| Voice | Tap and talk | Tap and talk |
| Review title | Is this right? | Check |
| Save | Yes, save | Confirm all |
| Escalate | Send to helper | n/a |
| Nav | My Day · Speak · Call | Today · Reports · Speak · Ask · More |
| Offline | On phone | On phone |
| Error | Number too high | Number too high |
| Basic mode | n/a | Helper is off. Typing works. |

### 5. Accessibility checklist
- Text contrast at least 7:1, with icons and borders at least 4.5:1.
- Never use color alone. Every state has an icon and a word.
- Support font scale up to 200%. Elder mode may grow to 130% by default (optional setting in Helper mode).
- Tap-to-talk, not hold-to-talk, in Elder mode. Hold-to-talk is optional in Helper mode.
- No gestures required. No time-limited toasts. Use banners that stay.
- Optional vibration and a loud ring for pill reminders.
- Minimal motion. Respect "reduce motion".

### 6. Tips for using Stitch
- If text looks small: "Increase Elder mode text by 20% and set every button to 88dp tall."
- If it adds extra elements: "Remove everything that is not listed."
- To iterate: "Keep the design system, change only the [screen name]."
- To compare modes: "Show the same Today screen in Elder mode and Helper mode side by side."

---

**Suggested generation order (demo flow):** Who is using? → My Day → Speak (3 states) → Is this right? (Sure) → Needs helper → Helper Today → To check → Check cards → Edit → Medicines → Snap → Reports → Handover → Ask → More → Phone helper → On my phone → SOS.