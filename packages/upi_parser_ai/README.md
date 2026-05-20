# UPI Parser AI

A pure Dart package for sanitizing financial messages and parsing UPI
transactions through Groq.

## Installation

For this monorepo app:

```yaml
dependencies:
  upi_parser_ai:
    path: ../../packages/upi_parser_ai
```

For another local project, adjust the path to this package.

## Usage

```dart
import 'package:upi_parser_ai/upi_parser_ai.dart';

Future<void> main() async {
  final raw = 'Paid Rs.500 to Swiggy via GPay A/c 1234 user@okaxis';
  final sanitized = PiiSanitizer.sanitize(raw);

  final client = GroqClient(apiKey: 'your-groq-api-key');
  try {
    final transaction = await client.parseTransaction(sanitized);
    print(transaction.toJson());
  } on LlmParsingException catch (error) {
    print('Could not parse transaction: $error');
  }
}
```

## PII Sanitization Logic

`PiiSanitizer.sanitize` redacts:

- UPI IDs such as `user@okaxis`, `name@ybl`, and uppercase variants.
- Explicit account/card numbers such as `A/c 1234`, `Card No. 9876`,
  `Account No: 1234567890`, and `ending in 4567`.
- Masked numbers such as `xxx4567` or `****9876`.

Cloud requests should only receive sanitized text.

## Handling LLM Hallucinations

`GroqClient.parseTransaction` enforces JSON output and wraps failures in
`LlmParsingException`. It rejects:

- Invalid JSON.
- Non-object JSON.
- Negative amounts.
- `transactionType` values outside `expense`, `income`, `refund`, `transfer`,
  or `failed`.
- `confidence` values outside `0.0` to `1.0`.
- Empty provider, merchant, or category fields.

## JSON Schema

```json
{
  "amount": 450.0,
  "currency": "INR",
  "transactionType": "expense",
  "provider": "GPay",
  "merchant": "Swiggy",
  "category": "Food",
  "confidence": 0.92
}
```

## Example

Run the package example from `packages/upi_parser_ai`:

```powershell
dart run example/main.dart
```

Pass a real key to exercise Groq:

```powershell
$env:GROQ_API_KEY="your_key"
dart run example/main.dart
```
