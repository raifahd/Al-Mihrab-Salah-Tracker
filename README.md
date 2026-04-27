<img src="assets/images/app_logo.png" alt="Al-Mihrab Logo" width="100" height="100" align="left" style="margin-right: 20px;">

# Al-Mihrab: Salah Tracker
## Your Spiritual Accountability Companion

<br clear="left">

> *"Indeed, prayer has been decreed upon the believers a decree of specified times."* — Surah An-Nisa, 4:103

---

## Overview

**Al-Mihrab** is an open-source Islamic prayer tracker that uses **guilt-driven psychology** to motivate consistent prayer habits. Unlike generic prayer apps, it sends emotionally resonant notifications like *"You missed Fajr. How will you answer for this?"* to create accountability and psychological motivation.

**Problem**: Muslims struggle with prayer consistency; generic reminders don't work. **Solution**: Streak tracking, guilt-based notifications, analytics, and cloud sync.

---

## Screenshots

Add screenshots here to showcase the app UI:

| Screen | Screenshot |
|---|---|
| **Dashboard** | ![Dashboard](assets/images/screenshot_dashboard.png) |
| **Prayer Logging** | ![Prayer Logging](assets/images/screenshot_prayer_logging.png) |
| **Statistics** | ![Statistics](assets/images/screenshot_statistics.png) |
| **Profile** | ![Profile](assets/images/screenshot_profile.png) |

*Note: Add actual screenshot images to the `assets/images/` directory and update the paths above.*

---

## Key Features

| Feature | Details |
|---|---|
| **GPS Prayer Times** | Auto-detects location, multiple calculation methods, all 5 daily prayers |
| **Prayer Logging** | On Time / With Congregation / Late / Missed status tracking |
| **Streak Tracking** | Current streak, longest streak, per-prayer streaks for motivation |
| **Guilt Notifications** | Escalating accountability reminders with streak references |
| **Analytics** | Weekly/monthly charts, per-prayer analysis, progress tracking |
| **Secure Accounts** | JWT auth, bcrypt encryption, cloud sync across devices |

---

## Tech Stack

**Frontend**: Flutter 3.11+ • Provider 6.1+ • Dio 5.9+ • Firebase 3.0+ • Geolocator 14+ • Shared Preferences 2.5+

**Backend**: Node.js 18+ • Express.js 5.2+ • MongoDB 4.4+ • Mongoose 9.4+ • JWT 9.0+ • bcryptjs 3.0+ • Swagger 6.2+

---

## Quick Setup

### Backend
```bash
cd backend
npm install
# Create .env: MONGO_URI, PORT=5000, JWT_SECRET
npm run dev  # Dev mode or npm start for production
# API docs at http://localhost:5000/api-docs
```

### Frontend
```bash
cd frontend
flutter pub get
# Update lib/services/api_config.dart with backend URL
flutter run -d android  # or -d ios / -d chrome
```

**Requirements**: Flutter 3.11+, Node.js 18+, MongoDB 4.4+

---

## Design Decisions

| Decision | Why | Trade-off |
|---|---|---|
| **Guilt Notifications** | Emotional resonance drives behavior change better than neutral pings | Some users may find it harsh initially |
| **Streak Gamification** | Loss-aversion psychology creates self-reinforcing prayer habit loop | May feel game-like to purists |
| **Provider State Mgmt** | Lightweight, performant, minimal boilerplate, great community support | Limited features vs alternatives |
| **Separate Frontend/Backend** | Independent scaling, multi-platform support, better security | Higher initial complexity |
| **MongoDB** | Flexible schema for semi-structured prayer logs, easy horizontal scaling | Less ACID guarantees than PostgreSQL |
| **GPS Auto-Detection** | Seamless experience, supports travel, reduces friction | Battery drain risk (mitigated by caching) |

---

## Key Challenges Solved

1. **Prayer Time Accuracy**: Integrated multiple calculation methods (Hanafi, Shafi'i, etc.). Lesson: Religious apps require higher precision standards.

2. **GPS Battery Drain**: Location cached 24 hours, network-based fallback. Result: Minimal impact with maintained accuracy.

3. **Notification Reliability**: FCM + server-side scheduling + local fallbacks. Trade-off: Can't guarantee OS-level delivery, but significantly improved.

4. **Offline State Sync**: Optimistic UI updates + local queueing + conflict resolution via timestamps. Result: Seamless offline experience without data loss.

5. **Midnight Edge Cases**: UTC timestamps + timezone-aware streaks reset at local midnight. Lesson: Timezones are complex—invest in edge case testing.

6. **Culturally Sensitive Notifications**: Tested with Islamic scholars, varied tone, referenced Quran/Hadith. Result: Users report notifications feel "spiritually motivating."

---

## Limitations & Future Work

**Current Limitations**: 
- Notifications not guaranteed (OS restrictions)
- GPS accuracy varies by location  
- No offline logging yet
- English-only interface
- Single user per device

**Priority 1: Notification System (Planned)**
- Escalating urgency (+5min, +15min, +30min reminders)
- Smart timing (avoid work hours, batch notifications)
- Voice notifications + Adhan option
- Intelligent DND respect

**Other Priorities**: Community features • Offline queueing • Advanced analytics • Social accountability • Multi-language • Wearables • Mosque finder

---

## License & Contributing

Open-source under ISC License. Contributions welcome: bug reports, features, code improvements, documentation.

---

*May Allah accept from all of us. Ameen.*
Flutter App (Android/iOS)
       │
       │  HTTPS API requests
       ▼
Express.js Backend
       │
       ├──▶ MongoDB (user data, prayer logs, streaks)
       │
       └──▶ Prayer Time Calculations
```

---

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Node.js (14 or higher)
- MongoDB Atlas account (free tier)
- Git

### Backend Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/al-mihrab.git
cd al-mihrab/backend

# Install dependencies
npm install

# Create .env file with your configuration
cp .env.example .env
# Edit .env with your MongoDB URI and other settings

# Start the server
npm start
```

### Frontend Setup

```bash
# Navigate to frontend directory
cd al-mihrab/frontend

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## API Documentation

The backend provides a comprehensive REST API for all features:

- **Authentication** (`/api/auth`) — User registration and login
- **Prayers** (`/api/prayers`) — Prayer tracking and logging
- **Users** (`/api/users`) — User profile management
- **Utilities** (`/api/utilities`) — Prayer times and calculations

Full API documentation available at `/api/docs` when the server is running.

---

## Why This App?

There are many prayer apps out there. Most are beautiful dashboards that you open once, feel good about, and forget.

Al-Mihrab is different because it **comes to you** — with notifications that don't let you forget, with a streak that hurts to lose, and with an honest log that shows you exactly how consistent you really are.

The app doesn't judge you. But it does hold up a mirror.

And sometimes, that's all it takes.

---

## Contributing

Contributions are welcome. Please feel free to submit issues and pull requests.

---

## License

This project is open source and available under the MIT License.

---

## Acknowledgments

- Built for the Muslim community with sincere intentions
- May this app help strengthen the spiritual practice of Salah
- May it be a source of continuous good (Sadaqah Jariyah)

---

<p align="center">
  Built with sincerity. May Allah accept it from you. 
</p>
