# nursemate

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Official drug data API

NurseMate calls its same-origin `/api/drugs` Vercel Function. The function
combines MFDS pharmaceutical product authorization, e약은요, and pill
identification data without exposing the public-data service key to Flutter.

1. Apply for the relevant MFDS APIs at `data.go.kr`.
2. Add the decoded service key to Vercel as `MFDS_SERVICE_KEY` for Production,
   Preview, and Development.
3. For local Function development, copy `.env.example` to `.env.local` and
   fill the key. Never commit `.env.local`.
4. Run the site with `vercel dev` when testing the Function locally.

When the Function or key is unavailable, the Flutter repository automatically
falls back to the verified sample `DrugCatalog`.
