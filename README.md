<p align="center">
  <img src="assets/images/app_logo.png" alt="Al-Mihrab Logo" width="150" height="150">
</p>

# Al-Mihrab: Salah Tracker

> *"Indeed, prayer has been decreed upon the believers a decree of specified times."*
> — Surah An-Nisa, 4:103

---

## What is Al-Mihrab?

**Al-Mihrab** is a free, open-source Islamic prayer tracking application built for Muslims who want to maintain consistency with their Salah. But it's not just a tracker — it's a **spiritual accountability companion** that uses guilt-driven notifications to remind you that you are answerable to Allah for every prayer you miss.

The app is named after the **Mihrab** — the sacred niche in a mosque that marks the direction of the Qibla and calls the congregation to prayer. Just as the Mihrab symbolizes spiritual direction, this app calls *you* forward — to your prayer mat, five times a day, every day.

---

## The Core Philosophy

Most prayer reminder apps send generic notifications and call it a day. Al-Mihrab takes a different approach.

**We guilt-trip you. On purpose.**

Research shows that humans respond strongly to accountability. When you see a notification that says *"You missed Fajr. How will you answer for this?"*, it hits differently than a simple ping. That discomfort is intentional. That is the entire point.

The goal is not to shame you — it is to make you **feel the weight of the prayer you almost skipped**, so that you don't skip the next one. This creates a powerful motivator: the desire to maintain your streak and stay consistent with your obligations to Allah.

---

## Features

### Accurate Prayer Times
- Automatically detects your location via GPS
- Calculates precise prayer times for your location
- Supports multiple calculation methods
- Covers all 5 daily prayers: Fajr, Dhuhr, Asr, Maghrib, Isha

### Detailed Prayer Logging
Track each prayer with meaningful status indicators:

| Status | Meaning |
|---|---|
| On Time | Prayed within the prayer window |
| With Congregation | Prayed in Jamaat — the highest reward |
| Late | Prayed after the time had passed (Qada) |
| Missed | Did not pray — logged honestly |

### Streak Tracking
- Tracks your **current streak** — consecutive days where all 5 prayers were completed
- Records your **longest streak ever**
- Maintains streaks for on-time, late, and congregation statuses
- A live reminder of how consistent you have been

### Guilt-Driven Notifications
The heart of Al-Mihrab. These notifications are **carefully designed to make you feel the gravity of missing Salah**:

- Sent after a prayer time passes without being logged
- Escalate in tone the longer you wait
- Reference your streak so you feel what you stand to lose
- Inspired by real Islamic reminders about accountability

### Statistics and Analytics
- Visual breakdown of your prayer consistency over time
- Weekly and monthly performance charts
- Per-prayer analysis — identify which prayers need more focus
- Track your progress and growth

### User Accounts
- Secure sign-up and login with JWT authentication
- Cloud-based data storage — accessible from any device
- Passwords encrypted with bcrypt — never stored in plain text

---

## Tech Stack

### Frontend
| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile app |
| Provider | State management |
| Dio | HTTP client for API calls |
| Firebase | Integration and distribution |

### Backend
| Technology | Purpose |
|---|---|
| Node.js | Server runtime |
| Express.js | REST API framework |
| MongoDB | Database for user and prayer data |
| JWT | Authentication and security |
| bcryptjs | Password encryption |

---

## Architecture

```
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
