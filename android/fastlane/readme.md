# Fastlane - Android

Automates building and distributing the app to Firebase App Distribution for internal testing.

## What it does

1. Runs ``flutter clean``
2. Builds a **production release APK** (``--flavor production``)
3. Uploads the APK to **Firebase App Distribution** to the ``Viora_tester`` group

## Command

| Action | Command |
|---|---|
| Build & distribute to testers | ``fastlane android distribute`` |

## Requirements

- ``FIREBASE_APP_ID`` env variable set
- ``FIREBASE_CLI_TOKEN`` env variable set