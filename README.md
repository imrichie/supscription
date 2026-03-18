# 📦 Supscription

[![SwiftUI](https://img.shields.io/badge/SwiftUI-%20-ff69b4)]()
[![macOS](https://img.shields.io/badge/Platform-macOS-blue)]()
[![Version 1.0](https://img.shields.io/badge/Version-1.0-green)]()

A native macOS app for tracking your subscriptions — without connecting to your bank.

> Built with SwiftUI and SwiftData. Private by design — everything stays on your device.

---

![Dashboard — Light Mode](Screenshots/dashboard_light.png)

---

## The Problem

Most subscription trackers want to connect to your bank. I didn't want that — and I figured I wasn't alone.

I wanted something focused. Enter your subscriptions, see what's coming up, get reminded before you're charged. No account linking, no bloat, no privacy tradeoffs. I couldn't find it built well for macOS, so I built it myself.

> "What's helpful, and what's just clutter?" — the question that drove every product decision.

---

## Screens

| All Subscriptions — Light | Dashboard — Dark |
|---|---|
| ![All Subscriptions Light](Screenshots/main_light.png) | ![Dashboard Dark](Screenshots/dashboard_dark.png) |

| To Cancel | Add Subscription |
|---|---|
| ![To Cancel](Screenshots/to_cancel.png) | ![Add Modal](Screenshots/add_modal.png) |

![All Subscriptions — Dark Mode](Screenshots/main_dark.png)

---

## Features

- **Dashboard** — monthly and annual spend, active subscription count, a 6-month Swift Charts trend, and upcoming renewals
- **To Cancel** — a watchlist of subscriptions flagged to cancel with urgency badges and direct links to cancel pages
- **Inline editing** — edit details directly in the detail view, no modal required
- **Smart reminders** — cancel reminder dates default intelligently based on billing frequency
- **Category management** — drag subscriptions between categories, rename and delete via right-click context menu
- **Logo fetching** — company logos fetched automatically by domain with local caching and fallbacks
- **Theme support** — Light, Dark, and System

---

## How It's Built

**Stack:** Swift · SwiftUI · SwiftData · Swift Charts · UserNotifications · URLSession

**Architecture:** Modular component-driven UI. Every part of the interface is its own view — subscription rows, detail cards, billing info, reminders. Logic lives in dedicated ViewModels. No third-party libraries.

> SwiftData was chosen over Core Data for its modern Swift-native API and clean SwiftUI integration. The subscription model handles sorting, filtering, category relationships, and notification scheduling entirely on-device.

Two distinct notification types — billing reminders and cancel reminders — each with their own scheduling logic. Edge cases like past-due dates, permission states, and frequency-aware defaults are all handled explicitly.

---

## What's Next

v1.0 is a complete manual tracking experience. v2.0 brings intelligence.

- Apple Intelligence and Foundation Models for on-device AI
- AI-powered category suggestions as you add subscriptions
- Predictive analytics and spending forecasts via CoreML
- iCloud sync using SwiftData with CloudKit
- CSV and JSON export

> The architecture was built deliberately to support this. Local-first, clean data model, modular components. v2.0 is the next layer — not a rebuild.

---

## About

Built by Ricardo Flores
