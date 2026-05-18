# UPI Analyzer

An Android Flutter app that quietly watches your financial messages, turns them into structured transactions, and gives you a clean place to review spending and see where your money actually goes.

You don't manually log every Swiggy order or UPI payment. The app picks up bank SMS and UPI app notifications, parses them (with AI when you have a Groq key, or with a built-in offline parser when you don't), stores everything locally on your phone, and surfaces insights on a simple dashboard.

---

## What it does

### Automatic transaction capture
- **SMS historical sync** ΓÇö On first launch (with permission), pulls the last 10 days of SMS from known financial senders: HDFC, SBI, Paytm, ICICI, Kotak, Axis, and Yes Bank.
- **Live UPI notifications** ΓÇö A native Android listener watches notifications from **Google Pay**, **PhonePe**, and **Paytm**, and saves them as they arrive.
- Everything lands in a local SQLite queue as raw messages with status `pending`.

### Smart parsing (AI + fallback)
- Each raw message is **PII-sanitized** before anything leaves the device (UPI IDs, account numbers, and masked card digits are stripped).
- With a **Groq API key**, messages are sent to **Mixtral** and parsed into structured JSON: amount, merchant, category, provider, transaction type, and a confidence score.
- **No API key?** A deterministic offline parser kicks in using regex and keyword rules ΓÇö still works, just less flexible.
- Parsing runs in the background: batches of 5, 10-second pause between cloud calls (rate-limit friendly), and re-checks every 30 seconds for new messages.

### Review tab
- Scrollable list of all parsed transactions.
- Low-confidence parses (< 0.60) are flagged **"Review Required"**.
- Tap any row to edit amount, merchant, category, or type (expense, income, refund, transfer, failed).
- Demo mode ships with sample data so you can explore the UI immediately; hit the refresh icon to reset and re-seed.

### Analytics tab
- **Daily expense bar chart** for the current month.
- **Category pie chart** ΓÇö Food, Travel, Shopping, Groceries, etc.
- **Top 5 merchants** by total spend.
- **AI Budget Insights** card at the top ΓÇö two short, actionable suggestions based on your actual numbers.

### Privacy-first by design
- Raw messages and parsed transactions stay in **local SQLite** (`upi_analyzer.db`).
- Only **sanitized** text goes to Groq ΓÇö never full account numbers or UPI handles.
- No cloud database, no account system.

---

## How data flows: SMS ΓåÆ parsing ΓåÆ LLM ΓåÆ insights



---

## Feature list

| Area | Feature |
|------|---------|
| **Data collection** | 10-day SMS sync from major Indian banks/wallets |
| | Real-time UPI notification listener (GPay, PhonePe, Paytm) |
| | SMS permission handling via `permission_handler` |
| **Parsing** | Groq Mixtral LLM parsing with JSON schema validation |
| | Offline regex parser when no API key is set |
| | PII sanitization before any cloud request |
| | Batch processing with rate limiting |
| | Automatic retry polling every 30 seconds |
| **Storage** | Shared SQLite DB (Flutter + native Kotlin write to same file) |
| | Raw message lifecycle: pending ΓåÆ processed / failed_parsing |
| **Review UI** | Transaction list with amount, merchant, category, provider |
| | Confidence-based "Review Required" flag |
| | Inline edit sheet for corrections |
| **Analytics** | Monthly daily expense bar chart |
| | Category distribution pie chart |
| | Top merchants bar chart |
| | AI-generated budget suggestions |
| **Dev / demo** | Demo mode with pre-seeded mock notifications + transactions |
| | One-tap demo reset from Review screen |

---

## Getting started

```powershell
cd apps/upi_analyzer_app
flutter pub get




GROQ_API_KEY=your_groq_api_key_here
flutter run
