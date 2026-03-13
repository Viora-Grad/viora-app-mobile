# viora_app

Flutter application with a Docker workflow for consistent tooling across contributors.

## Why Docker in this project

Docker is used to standardize Flutter tooling for all developers.

It helps contributors run the same versions and commands for:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk`

## Important scope

This setup does **not** run Android/iOS emulators inside Docker.

Use emulator/device on your host machine (Android Studio, iOS Simulator, or physical device).

## Prerequisites

- Docker Desktop installed and running
- Host emulator/device setup (outside Docker)

## Docker files

- `Dockerfile` - Flutter image definition
- `docker-compose.yml` - shared service for contributor commands
- `.dockerignore` - keeps image builds fast/small

## Quick start

From repository root:

```bash
docker compose build
docker compose run --rm flutter flutter pub get
docker compose run --rm flutter flutter analyze
docker compose run --rm flutter flutter test
```

## Build Android APK with Docker

```bash
docker compose run --rm flutter flutter build apk --release
```

APK output on host:

- `build/app/outputs/flutter-apk/app-release.apk`

## Open shell in container

```bash
docker compose run --rm flutter bash
```

Then run Flutter commands inside container as needed.

## Run app with emulator outside Docker

For day-to-day UI debugging, run Flutter from host so it can communicate with your local emulator/device.

Typical host flow:

```bash
flutter pub get
flutter run
```

Use Docker primarily for consistent checks and build commands used by contributors/CI.

## PowerShell examples

If you are on Windows PowerShell:

```powershell
docker compose build
docker compose run --rm flutter flutter pub get
docker compose run --rm flutter flutter analyze
docker compose run --rm flutter flutter test
docker compose run --rm flutter flutter build apk --release
```
