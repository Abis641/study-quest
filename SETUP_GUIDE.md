# 🔥 Firebase Setup Guide — Study Quest

Follow these steps in order to connect Study Quest to your Firebase project.

---

## Step 1: Create a Firebase Project

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click **"Add project"**
3. Enter project name: `study-quest` (or any name you prefer)
4. Disable Google Analytics (optional for development)
5. Click **"Create project"**

---

## Step 2: Register Your Android App

1. In your Firebase project dashboard, click the **Android icon** (➕ Add app)
2. Enter the Android package name: `com.studyquest.app`
3. Enter an app nickname: `Study Quest TV`
4. Leave SHA-1 blank for now (add later for production)
5. Click **"Register app"**

---

## Step 3: Download google-services.json

1. Download the `google-services.json` file from the Firebase wizard
2. Place it at: `android/app/google-services.json`

> ⚠️ **Never commit this file to a public Git repository!**  
> Add it to `.gitignore`:
> ```
> android/app/google-services.json
> ```

---

## Step 4: Configure Firebase Authentication

1. In Firebase Console, go to **Build → Authentication**
2. Click **"Get started"**
3. Under **Sign-in method**, enable:
   - **Email/Password** → Click, toggle Enable, Save

---

## Step 5: Configure Cloud Firestore

1. Go to **Build → Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in test mode"** (for development)
4. Select your Cloud Firestore location (pick closest to your users)
5. Click **"Enable"**

### Firestore Security Rules (Production)

Replace the default rules with these:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users can read/write only their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Progress tied to userId prefix
    match /progress/{docId} {
      allow read, write: if request.auth != null
        && docId.matches(request.auth.uid + '_.*');
    }

    // Achievements tied to userId prefix
    match /achievements/{docId} {
      allow read, write: if request.auth != null
        && docId.matches(request.auth.uid + '_.*');
    }

    // Missions tied to userId prefix
    match /missions/{docId} {
      allow read, write: if request.auth != null
        && docId.matches(request.auth.uid + '_.*');
    }

    // Lessons and quizzes are read-only for authenticated users
    match /lessons/{lessonId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin only via Firebase Console
    }

    match /quizzes/{quizId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

### Firestore Indexes

Create these composite indexes (Firebase Console → Firestore → Indexes → Composite):

| Collection | Fields | Query scope |
|-----------|--------|-------------|
| `lessons` | `subjectId ASC`, `order ASC` | Collection |
| `missions` | `userId ASC`, `date ASC` | Collection |
| `achievements` | `userId ASC` | Collection |

---

## Step 6: Configure Firebase Storage

1. Go to **Build → Storage**
2. Click **"Get started"**
3. Choose **"Start in test mode"**
4. Select the same location as Firestore
5. Click **"Done"**

### Storage Security Rules (Production)

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Profile images: user can read/write their own
    match /profile_images/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.auth.uid == userId
        && request.resource.size < 2 * 1024 * 1024  // 2 MB max
        && request.resource.contentType.matches('image/.*');
    }

    // Lesson images: read-only for authenticated users
    match /lesson_images/{imageId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## Step 7: Generate Firebase Options (Recommended)

Use the FlutterFire CLI to auto-generate `lib/firebase_options.dart`:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run configuration wizard
flutterfire configure
```

Select your Firebase project when prompted. This replaces the placeholder values in `lib/firebase_options.dart`.

---

## Step 8: Seed Sample Data

The app **automatically seeds sample lessons and quizzes** on first launch.  
It checks whether the `lessons` collection is empty and inserts:

- **Math**: Multiplication, Division  
- **Science**: Solar System  
- **English**: Vocabulary  
- **Geography**: Continents  

No manual seeding required.

---

## Step 9: Custom Profile Photos

Parents can place photos directly in the Flutter assets folder:

```
assets/profile_photos/
  brother.jpg
  sister.png
  child.jpg
```

Then reference the path in the user's `localAvatarPath` field.

> In production, use the in-app camera/gallery picker which uploads to Firebase Storage.

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| `google-services.json not found` | Place file at `android/app/google-services.json` |
| `Firebase: No app has been created` | Ensure `Firebase.initializeApp()` is called in `main()` |
| `Permission denied` on Firestore | Check Security Rules allow the authenticated user |
| `Storage: object does not exist` | Check Storage Rules and bucket name in `firebase_options.dart` |
| Build fails with `google-services plugin` | Check `android/app/build.gradle` has `apply plugin: 'com.google.gms.google-services'` |
