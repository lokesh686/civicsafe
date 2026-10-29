# CivicSafe Combined Project

This repository contains both the backend (FastAPI) and frontend (Flutter) for the CivicSafe project.

## Backend

The backend is already running (if you started it via the setup instructions). It serves the API at:

- http://127.0.0.1:8000
- API docs: http://127.0.0.1:8000/docs

### Backend Setup (if not already running)

1. Navigate to the backend directory:
   ```bash
   cd civic-safe-combined/backend
   ```
2. Create a `.env` file (copy from `.env.example`) and fill in your Google Sheet ID and optionally Google Drive Folder ID.
3. Install dependencies using UV:
   ```bash
   uv sync
   ```
4. Start the server:
   ```bash
   uv run uvicorn main:app --host 127.0.0.1 --port 8000 --reload
   ```

## Frontend

The frontend is a Flutter application. To run it, you need to have Flutter installed.

### Flutter Installation

Follow the official guide: https://docs.flutter.dev/get-started/install/windows

Summary for Windows:
1. Download the Flutter SDK from: https://storage.googleapis.com/flutter_infra_release/flutter/windows/latest/flutter_windows_v3.22.0-stable.zip
2. Extract the zip to a desired location (e.g., `C:\src\flutter`).
3. Add the `flutter\bin` directory to your PATH.
4. Run `flutter doctor` to verify the installation.

### Running the Frontend

1. Navigate to the frontend directory:
   ```bash
   cd civic-safe-combined/frontend
   ```
2. Get dependencies:
   ```bash
   flutter pub get
   ```
3. Ensure the backend is running (see above).
4. Run the app on Chrome (or your preferred device):
   ```bash
   flutter run -d chrome --web-port 8080
   ```
5. The app will be available at http://localhost:8080.

### Building an APK (Android)

To build a release APK:
```bash
flutter build apk --release
```
The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

## Notes

- The backend and frontend can run independently. Make sure the backend is running before starting the frontend for full functionality.
- If you encounter any issues, check the logs of the backend and frontend.
