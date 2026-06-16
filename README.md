# 🎓 Study Quest — Android TV Educational App

> A gamified learning experience for kids aged 8–14. Built with Flutter, Firebase, and ❤️.

![Study Quest Banner](assets/images/banner_placeholder.png)

---

## ✨ Features

### 🎮 Game-Like Learning
- **XP & Leveling** — earn experience points, level up, unlock rewards
- **Coins** — virtual currency earned by answering questions and completing missions
- **Stars** — bonus stars for perfect quiz scores
- **Daily Streaks** — keep a streak alive by studying every day 🔥

### 📚 Four Subject Worlds
| Subject | Emoji | Topics Covered |
|---------|-------|----------------|
| Math | 🔢 | Multiplication, Division |
| Science | 🔬 | Solar System, Space |
| English | 📖 | Vocabulary, Word Power |
| Geography | 🌍 | Continents, Countries |

### 🏆 Achievement System
- 10 unique badges to unlock
- From **First Quest** to **30-Day Streak Champion**
- Stored in Firestore, persisted across sessions

### 🎯 Daily Missions
- 3 fresh missions generated every day at midnight
- Examples: *"Answer 10 Math questions"*, *"Complete a Science quiz"*
- Bonus XP and Coins on completion

### 📊 Progress Tracking
- Per-subject progress bars
- Accuracy statistics
- Lesson and quiz completion history

### 👤 Personalized Profiles
- Custom name, age, grade, and favorite subject
- Photo support: upload via Firebase Storage or place photos in `assets/profile_photos/`
- Shown on Home, Profile, and Achievements screens

### 📺 Android TV Ready
- Full TV remote / D-Pad navigation
- Large cards and buttons optimized for 10-foot UI
- Leanback launcher integration
- Immersive fullscreen mode

---

## 📸 Screenshots

> _Place your screenshots in `assets/images/screenshots/` and update these links._

| Home Screen | Quiz Screen | Achievements |
|-------------|-------------|--------------|
| ![Home](assets/images/screenshots/home.png) | ![Quiz](assets/images/screenshots/quiz.png) | ![Achievements](assets/images/screenshots/achievements.png) |

---

## 🏗️ Project Structure

```
study_quest/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── firebase_options.dart        # Firebase configuration
│   ├── config/
│   │   ├── app_theme.dart           # Colors, typography, TV sizes
│   │   ├── app_router.dart          # GoRouter navigation
│   │   └── firebase_config.dart     # Collection names, constants
│   ├── models/
│   │   ├── user_model.dart          # User profile + stats
│   │   ├── quiz_model.dart          # Quiz + Question models
│   │   └── lesson_model.dart        # Lesson, Subject, Achievement, Mission, Progress
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Auth
│   │   ├── user_service.dart        # Firestore user CRUD
│   │   ├── lesson_service.dart      # Lessons + Quizzes + Seeder
│   │   ├── progress_service.dart    # Progress tracking
│   │   ├── storage_service.dart     # Firebase Storage
│   │   └── (achievement/mission in progress_service.dart)
│   ├── providers/
│   │   ├── auth_provider.dart       # Auth state + notifier
│   │   └── user_provider.dart       # All app state providers
│   ├── screens/
│   │   ├── auth/                    # Splash, Login, Register, Profile Setup
│   │   ├── home/                    # Home screen hub
│   │   ├── subjects/                # Subject + Lesson detail
│   │   ├── quiz/                    # Quiz + Result screens
│   │   ├── achievements/            # Achievements gallery
│   │   ├── profile/                 # User profile + stats
│   │   └── missions/                # Daily missions
│   └── widgets/
│       ├── tv_focusable_card.dart   # TV-navigable card + button
│       ├── user_avatar.dart         # Avatar with network/local/initials fallback
│       ├── stats_bar.dart           # XP/Coins/Stars/Streak bar
│       └── subject_card.dart        # Subject + action cards
├── assets/
│   ├── images/                      # App images
│   ├── profile_photos/              # Parent-placed child photos
│   └── sounds/                      # Future: sound effects
├── android/
│   ├── app/
│   │   ├── build.gradle             # App build config + signing
│   │   └── src/main/
│   │       ├── AndroidManifest.xml  # TV permissions + leanback
│   │       ├── kotlin/.../          # MainActivity
│   │       └── res/
│   │           ├── drawable/        # TV banner, launch background
│   │           └── values/styles.xml
│   ├── build.gradle                 # Project-level build config
│   └── gradle.properties
├── codemagic.yaml                   # CI/CD pipeline
├── SETUP_GUIDE.md                   # Firebase setup instructions
├── CODEMAGIC_SETUP.md               # CodeMagic deployment guide
└── README.md                        # This file
```

---

## 🚀 Installation

### Prerequisites

- Flutter SDK (stable, 3.22+): [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- Android Studio or VS Code with Flutter extension
- Android SDK with API 30+ (Android 11)
- A Firebase account: [firebase.google.com](https://firebase.google.com)

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/study_quest.git
cd study_quest
```

### 2. Set up Firebase

Follow **[SETUP_GUIDE.md](SETUP_GUIDE.md)** to:
- Create your Firebase project
- Download `google-services.json`
- Configure Auth, Firestore, and Storage
- Generate `lib/firebase_options.dart`

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Add placeholder assets

```bash
# Create placeholder files so Flutter doesn't error on missing assets
touch assets/images/.gitkeep
touch assets/profile_photos/.gitkeep
touch assets/sounds/.gitkeep
```

### 5. Run on Android TV emulator

```bash
# Start an Android TV AVD from Android Studio's Device Manager,
# then:
flutter run
```

### 6. Run on physical Android TV

```bash
# Enable ADB debugging on your TV, then:
adb connect YOUR_TV_IP:5555
flutter run
```

---

## 🎨 Customization

### Colors & Theme
Edit `lib/config/app_theme.dart` to change the color palette, typography, and card sizes.

### Adding More Questions
Edit the quiz data in `lib/services/lesson_service.dart` inside `_buildSampleQuizzes()`.  
Or add documents directly to Firestore under the `quizzes` collection.

### Adding Lessons
Add to `seedSampleData()` in `lesson_service.dart`, or insert directly into Firestore.

### Profile Photos
Place JPG/PNG files in `assets/profile_photos/` and set `localAvatarPath` in the user's Firestore document.

### TV Banner
Replace `android/app/src/main/res/drawable/tv_banner.xml` with a real 320×180 PNG named `tv_banner.png`.

---

## 🔐 Security Notes

- Never commit `google-services.json` or `key.properties` to Git
- Add them to `.gitignore`
- Use environment variables in CI/CD (see CodeMagic guide)
- Update Firestore and Storage security rules before going to production (rules are in `SETUP_GUIDE.md`)

---

## 🛠️ Technology Stack

| Technology | Purpose |
|-----------|---------|
| Flutter 3.22+ | UI framework |
| Dart 3.3+ | Programming language |
| Firebase Auth | User authentication |
| Cloud Firestore | Database |
| Firebase Storage | Profile image hosting |
| Riverpod 2.x | State management |
| GoRouter | Navigation |
| flutter_animate | Animations |
| confetti | Quiz result celebration |
| cached_network_image | Efficient image loading |
| Google Fonts (Nunito) | Typography |
| CodeMagic | CI/CD |

---

## 📋 Roadmap

- [ ] Mini Games (word scramble, math speed round)
- [ ] Leaderboard (family/class rankings)
- [ ] Sound effects and background music
- [ ] Parent dashboard (view child's progress)
- [ ] More subjects (History, Art, Coding)
- [ ] Multiplayer quizzes
- [ ] Offline mode with local caching

---

## 📄 License

MIT License — free to use, modify, and distribute.

---

## 🙌 Contributing

Pull requests are welcome! For major changes, please open an issue first.

---

*Built with Flutter 💙 for curious kids everywhere.*
