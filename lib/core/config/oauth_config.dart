/// OAuth Configuration Constants
class OAuthConfig {
  /// Web Client ID for Google Sign-In on Android
  /// Get this from Firebase Console → Project Settings → Service Accounts → Google Cloud Console → Credentials
  static const String googleServerClientId = String.fromEnvironment(
    'FIREBASE_GOOGLE_SERVER_CLIENT_ID', defaultValue: '171037310820-nh3s7it97s0168qujhs0a3sqbq0cr647.apps.googleusercontent.com'
  );
}
