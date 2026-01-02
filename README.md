  **SmartLibrary** — Gestion de Livres + Scan ISBN
SmartLibrary is a Flutter app scaffold adapted from the original Book Hive project. It focuses on managing a personal or school library with features such as adding books (manual or via ISBN scan), organizing by category, tracking reading status, and displaying simple statistics.

Getting started 
---------------  
1. Install Flutter and required SDKs.
2. From the project root run:  
 
```powershell  
flutter pub get  
flutter run
```
Notes & next steps
------------------
- If you plan to keep using launcher icons or images, add new files under `assets/` and update `pubspec.yaml` accordingly.
- We'll split development tasks among the team to implement the full Smart Library spec (models, DB, scanner, UI, stats). Ask me to scaffold those modules next.

## Technologies Used

- **Flutter**: UI framework for building cross-platform applications.
- **Dart**: Programming language used for Flutter development.
- **Google Books API**: Provides book search data and metadata.
- **sqflite**: Local SQLite database for storing favorite books.
- **Provider**: State management solution for Flutter apps.
