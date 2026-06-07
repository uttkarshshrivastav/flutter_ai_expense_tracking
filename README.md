# AI UPI Analyzer

Android-only Flutter demo app for tracking UPI/SMS transactions with local
SQLite storage, PII sanitization, Groq-backed parsing, review flows, analytics,
and demo data.

## Runnable App

Use the nested app:

```powershell
cd C:\Users\vivek\Desktop\ai_expence_manager\expense_tracker_ai\apps\upi_analyzer_app
flutter pub get
flutter run -d <android-device-id>
```

Demo data is enabled by default, so the Review and Analytics tabs are populated
immediately for video recording.

See [apps/upi_analyzer_app/setup.md](apps/upi_analyzer_app/README.md) for Groq
key setup, Android notification access, and dummy-data reset instructions.

DEMO VIDEO-->https://drive.google.com/drive/folders/1YqTJVFmMMb0TEMpBZLfj139YGEfimaKJ?usp=drive_link
my emulator was not working so have uploded the video of screen recording 

package_link = https://pub.dev/packages/upi_parser_ai
