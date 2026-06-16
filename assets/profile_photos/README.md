# Profile Photos Folder

Place child/profile photos here so the app can display them.

## Usage

1. Add your photo file here:
   ```
   assets/profile_photos/brother.jpg
   assets/profile_photos/sister.png
   ```

2. After adding, run `flutter pub get` to re-bundle assets.

3. In the user's Firestore document, set the `localAvatarPath` field:
   ```
   localAvatarPath: "assets/profile_photos/brother.jpg"
   ```

## Supported Formats
- `.jpg` / `.jpeg`
- `.png`
- `.webp`

## Recommended Size
- At least **200×200 px** for best display quality
- Square images work best (they are cropped to a circle)

## Fallback
If the photo is not found, the app displays the user's initials
in a purple gradient circle automatically.
