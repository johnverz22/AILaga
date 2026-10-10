# AILaga Demo & Narration Guide

A complete blueprint for a 90-second showcase video. Includes step-by-step
on-screen actions, exact timing, and a full narration script written to be
read aloud by a real person — conversational, no teleprompter stiffness.

---

## 🎵 Audio & Visual Setup

### Background Music
- **Vibe:** Warm acoustic instrumental — gentle guitar picking, soft piano pad.
- **Keywords for royalty-free search:** "corporate heartwarming," "acoustic
  care," "gentle morning instrumental," "lo-fi acoustic."
- **Mix level:** BGM at 15–20% volume. Fade in slowly at the top, fade out
  gently at the end.

### Recording Tips
- Film on the actual demo device (Samsung S942B or equivalent) with the
  screen recording tool built into Android.
- Enable **Airplane Mode** before recording — the status bar icon is visual
  proof of the offline-first story.
- Use a phone stand or tripod. Shaky handheld looks unpolished.
- Go through the full flow once as a dry run so taps feel natural, not
  hesitant.
- The demo data (Lola Maria, medications, BP readings) must already be
  seeded before you start. Use `flutter run --flavor demo` so all seed data
  is present from launch.

---

## ⏱️ Scene-by-Scene Action & Timing

| Time | Duration | What to Show on Screen |
|:---|:---|:---|
| 00:00–00:07 | 7 s | Splash screen → first onboarding card → tap **"Try a demo"** |
| 00:07–00:13 | 6 s | Initialization screen (Smart Assistant checking) → auto-advance to Home |
| 00:13–00:27 | 14 s | Home screen with demo data — slow scroll: Medication card, BP tile, Appointment card |
| 00:27–00:43 | 16 s | Tap the teal **Mic** button → Hold-to-talk → show "Listening" state with countdown ring → release |
| 00:43–00:52 | 9 s | "Processing…" spinner → Review Tray appears with two cards (Medication Taken + BP Measurement) |
| 00:52–01:04 | 12 s | Highlight the **Sure** badge and the verbatim source quote on each card → tap **Confirm** → "Saved" screen |
| 01:04–01:18 | 14 s | Tap **Reports** tab → open **Smart Handover** → slow scroll through generated summary |
| 01:18–01:28 | 10 s | Tap **SOS** button → show red emergency overlay with the countdown ring → tap Cancel |
| 01:28–01:30 | 2 s | Fade to AILaga logo + tagline: *"Sabihin mo lang, kami na ang magtatala."* |

---

## 🎙️ Full Narration Script (Read This Yourself)

> **How to use this script:**
> Read it out loud once before recording to find your natural pace. The
> slash marks `/` are breathing cues — not literally said. Sentences are
> kept short on purpose so you don't run out of breath mid-sentence on
> camera. Speak at the pace of a calm explanation, not a pitch.

---

### Scene 1 — The Problem (00:00–00:07)

> Every Filipino family has a Lola.
> She takes four medicines a day / checks her blood pressure / and needs
> someone watching over her.
> That someone is usually you — / fitting it in between work, kids, and
> everything else.

---

### Scene 2 — Meet AILaga (00:07–00:13)

> This is AILaga. /
> An app that lives entirely on your phone. /
> No account. No internet. No cloud. /
> Everything stays here — private, / always accessible, / even in airplane mode.

---

### Scene 3 — The Dashboard (00:13–00:27)

> The home screen shows today at a glance. /
> Lola's medications — which ones are due, which are done. /
> Her latest blood pressure. /
> The next appointment. /
> All of it in one place, / updated in real time by whoever is with her.

---

### Scene 4 — Voice Capture (00:27–00:43)

> Now here's the part that makes AILaga different. /
> Instead of filling out forms, / you just talk. /
>
> *(tap the mic button)*
>
> *"Nainom na ni Lola ang Metformin. /
> BP niya, one-thirty over eighty-five."*
>
> That's it. One sentence. / In whatever language feels natural. /
> Taglish, Filipino, English — / the Smart Assistant understands all of it. /
> And it runs completely on the phone. / No data leaves this device.

---

### Scene 5 — The Review Tray (00:43–01:04)

> Watch what happens next. /
> The app doesn't just save what it heard. /
> It structures it — / extracts the medication, the dose, the blood pressure
> reading. /
>
> And then it stops. /
> It waits for you. /
>
> Every card shows exactly what the AI heard — / the verbatim quote, right
> there — / and a confidence badge. /
> Green "Sure" means it's confident. / Amber "Check" means it wants a
> human to look. /
>
> Nothing is saved until you tap Confirm. /
> The AI proposes. / You decide. / Always.

---

### Scene 6 — Smart Handover (01:04–01:18)

> At the end of a shift — / or when the doctor asks for an update — /
> tap Reports. /
>
> AILaga generates a clear, readable summary. /
> Not a dump of raw data. /
> A handover note: / what happened, / what was taken, / what to watch. /
>
> Written from the confirmed records. / Nothing invented. /
> Ready to share, print, or read aloud to the next caregiver.

---

### Scene 7 — SOS (01:18–01:28)

> And if there's ever an emergency — /
> one tap. /
>
> *(tap SOS)*
>
> The SOS screen needs no internet. / No AI. / No delay. /
> It dials family. / It shows the address. /
> It works even when the phone is in airplane mode.

---

### Scene 8 — Closing (01:28–01:30)

> AILaga. /
> Private. Offline. / Always ready. /
>
> *Sabihin mo lang — kami na ang magtatala.*

---

## 📄 Continuous Read Block (Single Take Version)

*Use this if you want to record the narration in one continuous take. Mark
the `//` lines as mental pauses — a full breath — not spoken.*

---

Every Filipino family has a Lola.
She takes four medicines a day, checks her blood pressure, and needs someone
watching over her. That someone is usually you — fitting it in between work,
kids, and everything else.

// *(scene cut — app launch)*

This is AILaga. An app that lives entirely on your phone. No account. No
internet. No cloud. Everything stays here — private, always accessible, even
in airplane mode.

// *(scene cut — dashboard)*

The home screen shows today at a glance. Lola's medications — which ones are
due, which are done. Her latest blood pressure. The next appointment. All of
it in one place, updated in real time by whoever is with her.

// *(scene cut — tap mic)*

Now here's the part that makes AILaga different. Instead of filling out forms,
you just talk.

*"Nainom na ni Lola ang Metformin. BP niya, one-thirty over eighty-five."*

That's it. One sentence. In whatever language feels natural — Taglish,
Filipino, English — the Smart Assistant understands all of it. And it runs
completely on the phone. No data leaves this device.

// *(scene cut — review tray)*

Watch what happens next. The app doesn't just save what it heard. It
structures it — extracts the medication, the dose, the blood pressure reading.

And then it stops. It waits for you.

Every card shows exactly what the AI heard — the verbatim quote, right there —
and a confidence badge. Green "Sure" means it's confident. Amber "Check"
means it wants a human to look. Nothing is saved until you tap Confirm.

The AI proposes. You decide. Always.

// *(scene cut — reports)*

At the end of a shift — or when the doctor asks for an update — tap Reports.

AILaga generates a clear, readable summary. Not a dump of raw data. A
handover note: what happened, what was taken, what to watch. Written from the
confirmed records. Nothing invented. Ready to share, print, or read aloud to
the next caregiver.

// *(scene cut — SOS)*

And if there's ever an emergency — one tap.

The SOS screen needs no internet. No AI. No delay. It dials family. It shows
the address. It works even when the phone is in airplane mode.

// *(fade to logo)*

AILaga. Private. Offline. Always ready.

*Sabihin mo lang — kami na ang magtatala.*

---

## 💡 Demo Checklist

**Before you record:**
- [ ] Run `flutter run --flavor demo` — confirm seed data is loaded (Lola
      Maria, 4 medications, 2 BP readings, 1 upcoming appointment)
- [ ] Smart Assistant model is installed and shows "Ready" on init screen
- [ ] Enable Airplane Mode — confirm the plane icon shows in the status bar
- [ ] Screen brightness at 100%
- [ ] Do Not Disturb mode ON — no notification banners mid-recording
- [ ] Font scale at default (100%) — Elder mode text is already large enough
- [ ] Do one full dry run of the tap sequence before recording

**During recording:**
- [ ] Tap deliberately — give each screen 1–2 seconds to settle before moving
- [ ] During the voice capture scene, say the sentence slowly and clearly so
      the model has time to process
- [ ] On the Review Tray, pause long enough for viewers to read the "Sure"
      badge and the source quote
- [ ] On the Handover screen, scroll slowly — the summary text is the payoff

**After recording:**
- [ ] Trim silence at the start and end
- [ ] BGM fade-in first 2 seconds, fade-out last 3 seconds
- [ ] Add subtitles for the Taglish sentence
      (*"Nainom na ni Lola ang Metformin. BP niya, one-thirty over eighty-five."*)
      so international judges understand it
- [ ] Export at 1080p minimum

---

## 🗣️ Pronunciation Notes (for Taglish phrases)

| Phrase | Pronunciation guide |
|:---|:---|
| AILaga | "eye-LAH-gah" |
| Nainom na | "nah-EE-nom nah" — "already took" |
| ni Lola | "nee LOH-lah" — possessive marker + Lola |
| Metformin | "met-FOR-min" (English pronunciation) |
| BP niya | "bee-PEE NEE-yah" — "her BP" |
| one-thirty over eighty-five | say in English numbers, normal pace |
| Sabihin mo lang | "sah-BEE-hin moh lang" — "just say it" |
| kami na ang magtatala | "KAH-mee nah ang mag-tah-TAH-lah" — "we'll record it" |
