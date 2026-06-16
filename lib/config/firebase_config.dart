// lib/config/firebase_config.dart
// ============================================================
// Replace with your actual Firebase project values.
// Download google-services.json from Firebase Console and
// place it at: android/app/google-services.json
// ============================================================

class FirebaseConfig {
  // Your Firebase project ID (found in Project Settings)
  static const String projectId = 'YOUR_FIREBASE_PROJECT_ID';

  // Web API key (used for auth configuration)
  static const String apiKey = 'YOUR_WEB_API_KEY';

  // Auth domain
  static const String authDomain = 'YOUR_PROJECT_ID.firebaseapp.com';

  // Storage bucket
  static const String storageBucket = 'YOUR_PROJECT_ID.appspot.com';

  // Messaging sender ID
  static const String messagingSenderId = 'YOUR_MESSAGING_SENDER_ID';

  // App ID
  static const String appId = 'YOUR_APP_ID';

  // ============================================================
  // Firestore Collection Names
  // ============================================================
  static const String usersCollection = 'users';
  static const String progressCollection = 'progress';
  static const String missionsCollection = 'missions';
  static const String achievementsCollection = 'achievements';
  static const String quizzesCollection = 'quizzes';
  static const String lessonsCollection = 'lessons';

  // ============================================================
  // Firebase Storage Paths
  // ============================================================
  static const String profileImagesPath = 'profile_images';
  static const String lessonImagesPath = 'lesson_images';

  // ============================================================
  // App Configuration
  // ============================================================
  static const int dailyMissionsCount = 3;
  static const int xpPerCorrectAnswer = 10;
  static const int coinsPerCorrectAnswer = 5;
  static const int starsPerPerfectQuiz = 3;
  static const int xpPerMissionComplete = 50;
  static const int coinsPerMissionComplete = 25;
}
