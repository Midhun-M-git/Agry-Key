class AppState {

  // Language Selection
  static String selectedLanguage = "English";

  // User Role
  static String selectedRole = "";

  // Theme
  static String selectedTheme = "Green Harvest";

  // User Details
  static String userName = "";
  static String userLocation = "";
  static String userOccupation = "";
  static String phoneNumber = "";

  // Farming Details
  static String farmName = "";
  static String mainCrop = "";
  static String userCrop = "";

  // Geo Location
  static double latitude = 0.0;
  static double longitude = 0.0;
  static String state = "";
  static String district = "";

  // JWT Storage
  static String accessToken = "";
  static String refreshToken = "";

  // Payload Storage
  static Map<String, dynamic> farmPayload = {};
}