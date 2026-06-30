# Pocket Party Court — Project Documentation

GitHub is the source of truth for this project documentation. Notion indexes this file in the Priyansh App Factory Command Center.

## 00. Executive Summary
Pocket Party Court is an offline party game that turns small disputes into a funny courtroom. It is for friend groups, couples, roommates, and party hosts. The end product should include case creation, role assignment, prompt cards, verdicts, penalties, share cards, and optional local history.

## 01. Product
MVP scope: case setup, player names, role assignment, accusation prompt, evidence prompts, verdict flow, penalty card, shareable verdict card. Acceptance criteria: a group can finish a case in 3-7 minutes without confusion.

## 02. Design
Playful courtroom theme with bold cards, dramatic verdict moments, large typography, and one-hand controls. Screens: start case, add players, role assignment, prompt card, verdict, history/settings.

## 03. Frontend Technical
SwiftUI card-driven app with a GameSession state machine. Local JSON prompt decks and optional SwiftData case history. No required permissions for v1.

## 04. Backend Technical
No backend for v1. Future services may include downloadable decks, remote party mode, or shared verdict pages.

## 05. Business
Business model: free core deck with paid expansion decks, seasonal packs, or party bundle. Keep backend cost low.

## 06. Marketing
Positioning: settle dumb arguments like a court case. Channels: short skits, verdict reveals, roommate/couple scenarios, group game communities.

## 07. User Acquisition
Beta with live friend groups and roommates. Metrics: cases started, cases completed, average players, share rate, repeat party sessions.

## 08. Execution
Plan: audit repo, freeze party loop, build case state machine, add starter deck, add verdict/share cards, run live QA.

## 09. QA
Test empty names, long names, role assignment, restart case, verdict generation, share card, offline mode, and accessibility labels.

## 10. Legal / Compliance
Keep v1 local. Use content-safety review for starter prompt decks. Disclose any data handling if analytics or sharing are added.

## 11. Operations
Release process: internal live test, small group beta, TestFlight, launch. Post-launch: expansion decks, custom rules, remote mode.
