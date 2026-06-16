# Fonts

The app uses **Nunito** via the `google_fonts` package, which downloads fonts at runtime.

For offline use or custom fonts, place font files here:

```
assets/fonts/
  Nunito-Regular.ttf
  Nunito-Bold.ttf
  Nunito-ExtraBold.ttf
```

## Download Nunito
https://fonts.google.com/specimen/Nunito

Click "Download family" to get all weights.

## Already works without this folder
The `google_fonts` package fetches and caches Nunito automatically
on first launch (requires internet). No manual font files needed
unless you want to bundle them for offline use.
