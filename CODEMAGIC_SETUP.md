# 🚀 CodeMagic CI/CD Setup Guide — Study Quest

Build and deploy Study Quest to Android TV using CodeMagic.

---

## Prerequisites

- A [CodeMagic](https://codemagic.io) account (free tier available)
- Your project pushed to GitHub, GitLab, or Bitbucket
- A keystore for release signing (see Step 3)
- `google-services.json` downloaded from Firebase

---

## Step 1: Connect Your Repository

1. Log in at [https://codemagic.io](https://codemagic.io)
2. Click **"Add application"**
3. Choose your Git provider (GitHub / GitLab / Bitbucket)
4. Authorize CodeMagic to access your repositories
5. Select the **study_quest** repository
6. Choose **"Flutter App"** as the project type
7. Click **"Finish: Add application"**

---

## Step 2: Add google-services.json as a Secure File

Since `google-services.json` must **not** be in your repo, upload it securely:

1. In CodeMagic, go to your app → **Environment variables**
2. Click **"Add variable"**
3. Name: `GOOGLE_SERVICES_JSON`
4. Value: paste the **full contents** of your `google-services.json`
5. Check **"Secure"**
6. Click **"Add"**

Then add a script step in `codemagic.yaml` to write it before the build:

```yaml
- name: Set up google-services.json
  script: |
    echo "$GOOGLE_SERVICES_JSON" > android/app/google-services.json
```

---

## Step 3: Create a Keystore for Release Signing

### Generate Keystore (run locally)

```bash
keytool -genkey -v \
  -keystore study_quest_release.keystore \
  -alias study_quest \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Fill in the prompts (name, organization, country). Remember your passwords!

### Upload Keystore to CodeMagic

1. Go to **Teams → Code signing identities → Android keystores**
2. Click **"Add keystore"**
3. Upload your `.keystore` file
4. Enter:
   - **Reference name**: `study_quest_keystore`
   - **Keystore password**: (from keytool step)
   - **Key alias**: `study_quest`
   - **Key password**: (from keytool step)
5. Click **"Add keystore"**

### Create key.properties (local only, gitignored)

```
storeFile=/path/to/study_quest_release.keystore
storePassword=YOUR_STORE_PASSWORD
keyAlias=study_quest
keyPassword=YOUR_KEY_PASSWORD
```

---

## Step 4: Configure the Build in CodeMagic

The `codemagic.yaml` file is already included in the project.  
It defines two workflows:

| Workflow | Purpose |
|----------|---------|
| `android-tv-release` | Builds signed release APK + AAB |
| `android-tv-debug` | Runs tests and builds debug APK |

---

## Step 5: Trigger a Build

### Manual Build
1. In CodeMagic dashboard, select your app
2. Choose workflow: **Study Quest - Android TV Release**
3. Click **"Start new build"**

### Automatic Builds (Recommended)
1. Go to your app → **Workflow settings**
2. Under **Triggering**, enable:
   - **Push** → trigger on push to `main` branch
   - **Pull request** → trigger on PRs (uses debug workflow)

---

## Step 6: Download the APK

Once the build succeeds:

1. Go to your app → **Builds**
2. Click the successful build
3. Under **Artifacts**, find:
   - `app-arm64-v8a-release.apk` — for ARM64 Android TV devices
   - `app-release.aab` — for Google Play submission
4. Click **Download**

---

## Step 7: Install on Android TV

### Via ADB (Developer Mode)

Enable Developer Mode on your TV:
1. Go to Settings → Device Preferences → About → Build
2. Click Build number 7 times
3. Enable USB debugging or Network ADB

```bash
# Connect via ADB over network
adb connect YOUR_TV_IP_ADDRESS:5555

# Install the APK
adb install -r app-arm64-v8a-release.apk
```

### Via USB

```bash
adb -d install app-arm64-v8a-release.apk
```

---

## Environment Variable Reference

| Variable | Description | Secure? |
|----------|-------------|---------|
| `GOOGLE_SERVICES_JSON` | Contents of google-services.json | ✅ Yes |
| `CM_KEYSTORE` | Auto-set by CodeMagic keystore upload | ✅ Yes |
| `CM_KEYSTORE_PASSWORD` | Auto-set by CodeMagic | ✅ Yes |
| `CM_KEY_ALIAS` | Auto-set by CodeMagic | ✅ Yes |
| `CM_KEY_PASSWORD` | Auto-set by CodeMagic | ✅ Yes |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `google-services.json not found` | Add the secure env var and script step |
| `Keystore not found` | Upload keystore in Code Signing Identities |
| `Build timeout` | Increase `max_build_duration` in `codemagic.yaml` |
| `Flutter pub get failed` | Check `pubspec.yaml` for typos |
| `minSdk too low` | TV requires minSdk 21+; project uses 30 |
| `Leanback not in manifest` | Already configured in `AndroidManifest.xml` |
