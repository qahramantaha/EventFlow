class UserSession {
  static String id = "";
  static String email = "";
  static String name = "";

  static bool get isLoggedIn => id.isNotEmpty;
}