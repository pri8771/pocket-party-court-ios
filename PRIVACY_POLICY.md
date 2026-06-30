# Pocket Party Court — Privacy Policy

_Updated 2026-06-30 to match the shipped product and launch scope. See LAUNCH_READINESS.md._

**Effective Date:** June 28, 2026
**Last Updated:** June 30, 2026

---

## Overview

Pocket Party Court is a **fully offline** iOS party game. It makes **no network connections**, has
**no accounts**, uses **no third-party SDKs**, and **transmits no data off your device**.

Our philosophy: what happens at the party stays at the party — and on your device only.

This policy is intentionally precise about the small amount of data the app stores **locally on your
device**, so that it is consistent with what the app actually does.

---

## The Short Version

- The app **does not connect to the internet** and **sends nothing to any server or third party**.
- It requires **no account** and asks for **no device permissions** (no camera, microphone, location,
  contacts, photos, or notifications).
- It stores a **small amount of game data on your device only** (see below). Nothing is uploaded.
- It includes **no advertising, attribution, or third-party tracking SDKs**.

---

## What Data the App Stores (On Device Only)

Pocket Party Court does **not** collect data for us — nothing is transmitted, and we (the developer)
never receive any information about you. The app does, however, store the following **locally on your
device** so the game works:

- **Game content and sessions (SwiftData):** the bundled starter decks/cases, and a local history of
  completed cases. A saved case record can include the player names you typed and the case prompt
  played. This data lives only in the app's on-device storage and is removed if you delete the app.
- **Diagnostic logging (development builds only):** in internal/DEBUG builds the app keeps an
  in-memory list of gameplay events (e.g. "game started", "verdict generated") and prints them to the
  developer console for debugging. This is **not present in the App Store release build**, is never
  written to a server, and never leaves the device.

We do not collect, transmit, or share any personal data, usage analytics, crash reports, device
identifiers, location data, or contact information.

---

## How the App Works

- **No network access:** the app makes no network connections and requests no internet permission.
- **No permissions required:** no camera, microphone, location, contacts, photos, or notification
  access.
- **Local storage:** game history and session results are stored only on your device via SwiftData.
- **Sharing:** when you tap "Share Verdict Card," iOS presents its standard share sheet with an image
  you choose to share. The image contains only the verdict, the case prompt, the aggregate vote tally,
  and a comedic summary — it does **not** include private arguments, who voted which way, or your
  player roster. Sharing is initiated by you, through Apple's share sheet; the app itself sends nothing.

---

## Analytics and Crash Reporting

The App Store release build includes **no** analytics SDKs, crash reporting tools, advertising
networks, or tracking libraries. We do not use Firebase, Google Analytics, Crashlytics, or any
advertising/attribution SDK. The only event logging that exists is the on-device, DEBUG-only
diagnostic logging described above, which is excluded from release builds and never transmitted.

---

## Children's Privacy

Pocket Party Court collects no data and transmits nothing off the device, so it inherently complies
with children's privacy laws including COPPA. That said, the game's tone is aimed at a general
audience; please review the App Store age rating and the Terms of Service for guidance on appropriate
group settings.

---

## Apple System Services

As with all iOS apps, your device's operating system may collect diagnostic or analytics information
governed by Apple's own privacy policy and your device settings — controlled entirely by Apple and
your iOS settings, not by Pocket Party Court. To review or change this: **Settings → Privacy &
Security → Analytics & Improvements**.

---

## Data Security

Any data the app stores exists only in your device's local app storage and is protected by your
device's built-in security (passcode, Face ID, Touch ID). Deleting the app removes this data.

---

## Your Rights

Because nothing is transmitted to us, there is no server-side data for us to provide, correct, or
delete. You control all on-device data through standard iOS settings, and you can remove it by
deleting the app. _(A planned in-app "Clear History" control is tracked in the launch checklist.)_

---

## Changes to This Privacy Policy

If we update this policy we will revise the "Last Updated" date and include the change in the next app
release.

---

## Contact

- **App:** Pocket Party Court
- **GitHub:** https://github.com/pri8771/pocket-party-court-ios
- **Support:** _[Add support email or URL before submission]_

---

## Summary for App Store Privacy Nutrition Label

The app collects no data that is linked to you or used to track you, and transmits nothing off the
device. All listed categories are answered as **not collected** (no data leaves the device):

| Category | Collected / Transmitted |
|----------|-------------------------|
| Contact Info | None |
| Health & Fitness | None |
| Financial Info | None |
| Location | None |
| Sensitive Info | None |
| Contacts | None |
| User Content | None transmitted (player names / prompts stored on device only) |
| Browsing/Search History | None |
| Identifiers | None |
| Usage Data | None transmitted (DEBUG-only diagnostics, not in release) |
| Diagnostics | None transmitted |
| Other Data | None |

**Target App Store Privacy answer: "Data Not Collected"** (the app stores some data on device but
transmits nothing off the device). Confirm this against Apple's current questionnaire wording before
submission, and add a `PrivacyInfo.xcprivacy` manifest.

---

*Pocket Party Court is built to be private by construction: it never touches the network and never
sends your data anywhere.*
