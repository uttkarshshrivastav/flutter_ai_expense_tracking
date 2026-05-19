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

See [apps/upi_analyzer_app/setup.md](apps/upi_analyzer_app/setup.md) for Groq
key setup, Android notification access, and dummy-data reset instructions.
