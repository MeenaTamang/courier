class Endpoints {
  static const String baseUrl = "http://192.168.137.1:7047/api"; // Replace with your actual local IP

  static const String login = "$baseUrl/login";
  static const String register = "$baseUrl/register";
  static const String getUser = "$baseUrl/user";
  static const String getAllUsers = "$baseUrl/users";
}